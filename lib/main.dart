import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tiktok_style_feed/routes/app_routes.dart';

import 'core/utils/app_colors.dart';
import 'core/utils/navigator_services.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
      ],
      child: const MyApp(),
    ),
  );

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark
    )
    );
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return   MaterialApp(
        title: '',
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.splashScreen,
        navigatorKey: NavigationService.navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primaryColor,
          colorScheme: ColorScheme.light(primary: AppColors.primaryColor),
        ),

      );
    });
  }
}



