/// Base class for use cases with parameters
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Base class for use cases without parameters
abstract class UseCaseNoParams<Type> {
  Future<Type> call();
}

/// No parameters class for use cases that don't need parameters
class NoParams {
  const NoParams();
}
