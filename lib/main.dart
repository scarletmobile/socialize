import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:soXialz/constant/constant.dart';
import 'package:soXialz/widgets/simple_world_widgets.dart';
import 'package:soXialz/widgets/splashscreen.dart';
import 'firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MobileAds.instance.initialize();

  await initialize();

  SharedPreferences.getInstance().then(
    (prefs) async {
      runApp(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "soXialz",
          home: SplashScreen(
            userId: globalID,
          ),
          routes: <String, WidgetBuilder>{
            APP_SCREEN: (BuildContext context) => App(prefs, savedThemeMode),
          },
        ),
      );
    },
  );
}
