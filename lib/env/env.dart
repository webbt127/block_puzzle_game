import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'REVENUECAT_API_KEY_ANDROID')
  static const String revenueCatApiKeyAndroid = _Env.revenueCatApiKeyAndroid;
  
  @EnviedField(varName: 'REVENUECAT_API_KEY_IOS')
  static const String revenueCatApiKeyIos = _Env.revenueCatApiKeyIos;

  @EnviedField(varName: 'AMPLITUDE_API_KEY')
  static const String amplitudeApiKey = _Env.amplitudeApiKey;
}