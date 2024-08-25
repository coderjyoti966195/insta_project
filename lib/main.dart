// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'instaclone/controller/auth_controller.dart';
// import 'instaclone/controller/insta_login_screen.dart';
//  import 'instaclone/registration_screen/registration_screen.dart';
// import 'instaclone/splash/splash.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   Get.put(AuthController());
//
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       home: InstaSplashScreen(),
//       getPages: [
//         GetPage(name: '/register', page: () => InstaRegistrationScreen()),
//         GetPage(name: '/login', page: () => InstaLoginScreen()),
//       ],
//     );
//   }
// }



//
//  import 'package:firebase_app_check/firebase_app_check.dart';
//  import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/adapters.dart';
// import 'instagram_clone/responsive_/mobile_screen.dart';
// import 'instagram_clone/screen/login_.dart';
// import 'instagram_clone/utils_/colors_.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   // Add Firebase AppCheck activation
//   await FirebaseAppCheck.instance.activate();
//
//   await Hive.initFlutter();
//   await Hive.openBox<String>('my_box');
//   await Hive.openBox('details');
//   runApp(const MyApp());
//
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     var box = Hive.box('details');
//
//
//     return GetMaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Instagram Clone',
//         theme: ThemeData.dark().copyWith(
//           scaffoldBackgroundColor: mobileBackgroundColor,
//         ),
//         home:box.get('uname')==null
//             ?const LoginScreen()
//             :const MobileScreenLayout()
//     );
//   }
//

//  _checkConnectivityAndAuth(context) async {
//   final connectivityResult = await Connectivity().checkConnectivity();
//   if (connectivityResult == ConnectivityResult.none) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: Colors.green,
//         content: Text('Internet Lost'.toUpperCase(),style: TextStyle(color: Colors.white)),
//       ),
//     );
//     return false;
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'grafh_/grafh_design/grafh_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TradeChartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: TradeChartPage(),
          ),
        ),
      ),
    );
  }
}




