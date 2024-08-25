// import 'dart:io';
// import 'package:flutter/material.dart';
// import '../../home/profile/profile_screen.dart';
// import '../../home/search/search_screen.dart';
//
// class InstaHomeScreen extends StatefulWidget {
//   final int selectedIndex;
//
//   const InstaHomeScreen({super.key, this.selectedIndex = 0});
//
//   @override
//   State<InstaHomeScreen> createState() => _InstaHomeScreenState();
// }
//
// class _InstaHomeScreenState extends State<InstaHomeScreen> {
//
//   late int _selectedIndex;
//   final List<GlobalKey<NavigatorState>> _navigatorKeys = [
//     GlobalKey<NavigatorState>(),
//     GlobalKey<NavigatorState>(),
//     GlobalKey<NavigatorState>(),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.selectedIndex;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: IndexedStack(
//           index: _selectedIndex,
//           children: [
//             Navigator(
//               key: _navigatorKeys[0],
//               onGenerateRoute: (routeSettings) {
//                 return MaterialPageRoute(
//                   builder: (context) => ReelsScreen(onPostUploaded: _PostUploaded),
//                 );
//               },
//             ),
//             Navigator(
//               key: _navigatorKeys[1],
//               onGenerateRoute: (routeSettings) {
//                 return MaterialPageRoute(
//                   builder: (context) => SearchScreen(onPostUploaded: _PostUploaded),
//                 );
//               },
//             ),
//             Navigator(
//               key: _navigatorKeys[2],
//               onGenerateRoute: (routeSettings) {
//                 return MaterialPageRoute(
//                   builder: (context) => ProfileScreen(onPostUploaded: _PostUploaded),
//                 );
//               },
//             ),
//           ],
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//             items: const [
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.video_library),
//                 label: 'Reels',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.search),
//                 label: 'Search',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.person),
//                 label: 'Profile',
//               ),
//             ],
//             currentIndex: _selectedIndex,
//             onTap: _onItemTapped,
//             ),
//         );
//   }
//
//   void _onItemTapped(int index) {
//     if (_selectedIndex == index) {
//       _navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }
//
//   void _PostUploaded(File mediaFile) {
//     setState(() {
//       _selectedIndex = 0;
//     });
//
//     for (var navigatorKey in _navigatorKeys) {
//       navigatorKey.currentState?.popUntil((route) => route.isFirst);
//       navigatorKey.currentState?.pushReplacement(
//         MaterialPageRoute(builder: (context) {
//           if (navigatorKey == _navigatorKeys[0]) {
//             return ReelsScreen(onPostUploaded: _PostUploaded);
//           } else if (navigatorKey == _navigatorKeys[1]) {
//             return SearchScreen(onPostUploaded: _PostUploaded);
//           } else {
//             return ProfileScreen(onPostUploaded: _PostUploaded);
//           }
//         }),
//       );
//     }
//   }
// }

import 'package:flutter/material.dart';

import '../profile_/profiles_screen.dart';
import '../reels_/reels_screen.dart';
import '../search_/search_view/search_screen.dart';

class InstaHomeScreen extends StatefulWidget {
  const InstaHomeScreen({super.key});

  @override
  State<InstaHomeScreen> createState() => _InstaHomeScreenState();
}

class _InstaHomeScreenState extends State<InstaHomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    ReelsScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.saved_search_outlined),
            label: 'se',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

