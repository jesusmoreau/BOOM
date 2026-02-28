class AdsConfig {
  // Poner en true cuando se configuren los IDs de AppLovin MAX
  static const bool adsEnabled = false;

  // REEMPLAZAR CON TUS IDs REALES DE APPLOVIN MAX
  static const String sdkKey = 'YOUR_SDK_KEY';
  static const String interstitialAdUnitId = 'YOUR_INTERSTITIAL_AD_UNIT_ID';
  static const String rewardedAdUnitId = 'YOUR_REWARDED_AD_UNIT_ID';

  // Configuración de frecuencia
  static const int roundsBetweenAds = 3;
  static const int initialFreeRounds = 5;
}
