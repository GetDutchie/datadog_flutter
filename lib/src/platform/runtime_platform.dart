/// Flutter Web can't import `Platform`. This implementation permits access
abstract class RuntimePlatform {
  bool get isAndroid;
  bool get isIOS;
  bool get isWeb;

  const RuntimePlatform();
}
