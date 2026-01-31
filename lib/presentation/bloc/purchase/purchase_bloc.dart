import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/preferences_repository.dart';
import '../ad/ad_bloc.dart';

part 'purchase_event.dart';
part 'purchase_state.dart';

/// BLoC for managing in-app purchases
class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final PreferencesRepository _preferencesRepository;
  final AdBloc? _adBloc;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  List<ProductDetails> _cachedProducts = [];

  PurchaseBloc({
    required PreferencesRepository preferencesRepository,
    AdBloc? adBloc,
  })  : _preferencesRepository = preferencesRepository,
        _adBloc = adBloc,
        super(const PurchaseInitial()) {
    on<InitializePurchases>(_onInitializePurchases);
    on<LoadProducts>(_onLoadProducts);
    on<BuyProduct>(_onBuyProduct);
    on<RestorePurchases>(_onRestorePurchases);
    on<PurchaseCompleted>(_onPurchaseCompleted);
    on<PurchaseFailed>(_onPurchaseFailed);
    on<CheckPremiumStatus>(_onCheckPremiumStatus);
    on<CheckBookLimit>(_onCheckBookLimit);
  }

  /// Get cached products
  List<ProductDetails> get products => _cachedProducts;

  Future<void> _onInitializePurchases(
    InitializePurchases event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(const PurchaseLoading());

    final available = await _inAppPurchase.isAvailable();
    if (!available) {
      emit(const PurchasesNotAvailable());
      return;
    }

    // Listen to purchase updates
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      (purchaseDetailsList) {
        _handlePurchaseUpdates(purchaseDetailsList);
      },
      onError: (error) {
        add(PurchaseFailed(error.toString()));
      },
    );

    // Load products
    add(const LoadProducts());
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(const PurchaseLoading());

    try {
      // Combine subscription and non-consumable IDs
      final productIds = <String>{
        ...PurchaseConstants.subscriptionIds,
        ...PurchaseConstants.nonConsumableIds,
      };

      final response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.error != null) {
        emit(PurchaseError(response.error!.message));
        return;
      }

      _cachedProducts = response.productDetails.map((product) {
        return ProductDetails(
          id: product.id,
          title: product.title,
          description: product.description,
          price: product.price,
          currencyCode: product.currencyCode,
          isSubscription:
              PurchaseConstants.subscriptionIds.contains(product.id),
        );
      }).toList();

      final preferences = await _preferencesRepository.getPreferences();

      emit(ProductsLoaded(
        products: _cachedProducts,
        isPremium: preferences.isPremiumActive,
      ));
    } catch (e) {
      emit(PurchaseError(e.toString()));
    }
  }

  Future<void> _onBuyProduct(
    BuyProduct event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseInProgress(event.productId));

    try {
      final productIds = <String>{event.productId};
      final response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.error != null || response.productDetails.isEmpty) {
        emit(const PurchaseError('Product not found'));
        return;
      }

      final productDetails = response.productDetails.first;
      final isSubscription =
          PurchaseConstants.subscriptionIds.contains(event.productId);

      final purchaseParam = PurchaseParam(productDetails: productDetails);

      if (isSubscription) {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      emit(PurchaseError(e.toString()));
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchases event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(const RestoreInProgress());

    try {
      await _inAppPurchase.restorePurchases();
      
      // Wait a bit for purchases to be processed
      await Future.delayed(const Duration(seconds: 2));
      
      final preferences = await _preferencesRepository.getPreferences();
      
      emit(PurchasesRestored(
        restoredCount: preferences.isPremiumActive ? 1 : 0,
        isPremium: preferences.isPremiumActive,
      ));
    } catch (e) {
      emit(PurchaseError('Failed to restore purchases: ${e.toString()}'));
    }
  }

  Future<void> _onPurchaseCompleted(
    PurchaseCompleted event,
    Emitter<PurchaseState> emit,
  ) async {
    try {
      // Update premium status
      await _preferencesRepository.updatePremiumStatus(
        isPremium: true,
        purchaseId: event.productId,
        // Set expiry date for subscriptions
        expiryDate: event.isSubscription
            ? _calculateExpiryDate(event.productId)
            : null,
      );

      // Hide ads
      _adBloc?.add(const HideAds());

      emit(PurchaseSuccess(productId: event.productId));

      // Reload products to update premium status
      add(const LoadProducts());
    } catch (e) {
      emit(PurchaseError(e.toString()));
    }
  }

  void _onPurchaseFailed(
    PurchaseFailed event,
    Emitter<PurchaseState> emit,
  ) {
    if (event.error.toLowerCase().contains('cancel')) {
      emit(const PurchaseCanceled());
    } else {
      emit(PurchaseError(event.error));
    }
  }

  Future<void> _onCheckPremiumStatus(
    CheckPremiumStatus event,
    Emitter<PurchaseState> emit,
  ) async {
    try {
      final preferences = await _preferencesRepository.getPreferences();

      emit(PremiumStatusChecked(
        isPremium: preferences.isPremiumActive,
        expiryDate: preferences.premiumExpiryDate,
      ));
    } catch (e) {
      emit(PurchaseError(e.toString()));
    }
  }

  Future<void> _onCheckBookLimit(
    CheckBookLimit event,
    Emitter<PurchaseState> emit,
  ) async {
    try {
      final preferences = await _preferencesRepository.getPreferences();
      
      if (preferences.isPremiumActive) {
        emit(const BookLimitChecked(
          isLimitReached: false,
          currentCount: 0,
          maxBooks: -1, // Unlimited
        ));
        return;
      }

      // Check current book count
      final isLimitReached = event.currentBookCount >= PurchaseConstants.freeUserBookLimit;
      
      emit(BookLimitChecked(
        isLimitReached: isLimitReached,
        currentCount: event.currentBookCount,
        maxBooks: PurchaseConstants.freeUserBookLimit,
      ));
    } catch (e) {
      emit(PurchaseError(e.toString()));
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Verify and complete purchase
        _verifyAndCompletePurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        add(PurchaseFailed(
            purchaseDetails.error?.message ?? 'Purchase failed'));
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        add(const PurchaseFailed('Purchase was canceled'));
      }
    }
  }

  Future<void> _verifyAndCompletePurchase(
    PurchaseDetails purchaseDetails,
  ) async {
    // In production, verify the purchase with your server
    // For now, we'll trust the purchase

    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }

    add(PurchaseCompleted(
      productId: purchaseDetails.productID,
      isSubscription:
          PurchaseConstants.subscriptionIds.contains(purchaseDetails.productID),
    ));
  }

  DateTime? _calculateExpiryDate(String productId) {
    final now = DateTime.now();

    if (productId == PurchaseConstants.premiumMonthlyId) {
      return now.add(const Duration(days: 30));
    } else if (productId == PurchaseConstants.premiumYearlyId) {
      return now.add(const Duration(days: 365));
    }

    // Lifetime purchase - no expiry
    return null;
  }

  @override
  Future<void> close() {
    _purchaseSubscription?.cancel();
    return super.close();
  }
}
