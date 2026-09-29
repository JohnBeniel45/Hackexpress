import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/apple_liquid_theme.dart';
import 'screens/apple_root_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const GridFlowAppleLiquidApp());
}

class GridFlowAppleLiquidApp extends StatelessWidget {
  const GridFlowAppleLiquidApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GridFlow AI — Apple Liquid Glass',
      debugShowCheckedModeBanner: false,
      theme: AppleLiquidTheme.darkTheme,
      home: const AppleRootScreen(),
    );
  }
}
