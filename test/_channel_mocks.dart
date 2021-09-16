class MethodCallValidator {
  final Map<String, Type>? expectedTypes;
  final Map<String, dynamic> methodCallArgs;
  final Iterable<String>? requiredArgs;

  MethodCallValidator(
    this.methodCallArgs, {
    this.requiredArgs,
    this.expectedTypes,
  });

  bool get argumentsMatchType {
    if (expectedTypes == null) return true;
    return methodCallArgs.entries.every((entry) {
      return entry.value.runtimeType == expectedTypes![entry.key];
    });
  }

  bool get argumentsArePresent {
    if (requiredArgs == null) return true;
    return requiredArgs!.every((requiredArg) {
      return methodCallArgs.containsKey(requiredArg);
    });
  }

  bool get isValid => argumentsMatchType && argumentsArePresent;
}
