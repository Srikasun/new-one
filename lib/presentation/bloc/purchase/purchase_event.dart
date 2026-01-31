part of 'purchase_bloc.dart';

/// Base event for PurchaseBloc
abstract class PurchaseEvent extends Equatable {
  const PurchaseEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize in-app purchases
class InitializePurchases extends PurchaseEvent {
  const InitializePurchases();
}

/// Event to load available products
class LoadProducts extends PurchaseEvent {
  const LoadProducts();
}

/// Event to initiate a purchase
class BuyProduct extends PurchaseEvent {
  final String productId;

  const BuyProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Event to restore purchases
class RestorePurchases extends PurchaseEvent {
  const RestorePurchases();
}

/// Event when purchase is completed
class PurchaseCompleted extends PurchaseEvent {
  final String productId;
  final bool isSubscription;

  const PurchaseCompleted({
    required this.productId,
    this.isSubscription = false,
  });

  @override
  List<Object?> get props => [productId, isSubscription];
}

/// Event when purchase fails
class PurchaseFailed extends PurchaseEvent {
  final String error;

  const PurchaseFailed(this.error);

  @override
  List<Object?> get props => [error];
}

/// Event to check premium status
class CheckPremiumStatus extends PurchaseEvent {
  const CheckPremiumStatus();
}

/// Event to check book limit for free users
class CheckBookLimit extends PurchaseEvent {
  final int currentBookCount;

  const CheckBookLimit({required this.currentBookCount});

  @override
  List<Object?> get props => [currentBookCount];
}
