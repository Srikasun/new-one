part of 'purchase_bloc.dart';

/// Base state for PurchaseBloc
abstract class PurchaseState extends Equatable {
  const PurchaseState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PurchaseInitial extends PurchaseState {
  const PurchaseInitial();
}

/// Loading products
class PurchaseLoading extends PurchaseState {
  const PurchaseLoading();
}

/// Products loaded successfully
class ProductsLoaded extends PurchaseState {
  final List<ProductDetails> products;
  final bool isPremium;

  const ProductsLoaded({
    required this.products,
    this.isPremium = false,
  });

  @override
  List<Object?> get props => [products, isPremium];
}

/// Purchase in progress
class PurchaseInProgress extends PurchaseState {
  final String productId;

  const PurchaseInProgress(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Purchase successful
class PurchaseSuccess extends PurchaseState {
  final String productId;
  final String message;

  const PurchaseSuccess({
    required this.productId,
    this.message = 'Purchase successful!',
  });

  @override
  List<Object?> get props => [productId, message];
}

/// Purchases restored
class PurchasesRestored extends PurchaseState {
  final int restoredCount;
  final bool isPremium;

  const PurchasesRestored({
    required this.restoredCount,
    required this.isPremium,
  });

  @override
  List<Object?> get props => [restoredCount, isPremium];
}

/// Premium status checked
class PremiumStatusChecked extends PurchaseState {
  final bool isPremium;
  final DateTime? expiryDate;

  const PremiumStatusChecked({
    required this.isPremium,
    this.expiryDate,
  });

  @override
  List<Object?> get props => [isPremium, expiryDate];
}

/// Purchase error
class PurchaseError extends PurchaseState {
  final String message;

  const PurchaseError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Purchases not available (e.g., on unsupported platform)
class PurchasesNotAvailable extends PurchaseState {
  const PurchasesNotAvailable();
}

/// Product details class for UI
class ProductDetails extends Equatable {
  final String id;
  final String title;
  final String description;
  final String price;
  final String currencyCode;
  final bool isSubscription;

  const ProductDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currencyCode,
    this.isSubscription = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        currencyCode,
        isSubscription,
      ];
}
