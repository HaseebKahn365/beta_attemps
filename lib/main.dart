import 'dart:math';

import 'package:beta_attemps/testing_haptics/haptics_home_page.dart';
import 'package:flutter/material.dart';

final themeProvider = ThemeProvider();

void main() {
  // debugRepaintRainbowEnabled = true;
  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider.value(
//       value: themeProvider,
//       child: Consumer<ThemeProvider>(
//         builder: (context, themeProviderWatch, _) => MaterialApp(
//           title: 'Flutter Demo',
//           debugShowCheckedModeBanner: false,
//           theme: themeProviderWatch.theme,
//           // home: UltimateProviderScreen(provider: ultimateProvider),
//           home: const MyApp(),
//         ),
//       ),
//     );
//   }
// }

class Button extends StatelessWidget {
  const Button({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ElevatedButton(
        onPressed: () {
          themeProvider.randomizeTheme();
        },
        child: const Text(
          'Change Theme',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

//a theme provider provider to change the primary color and theme using a random theme selction that will be called b the button

class ThemeProvider extends ChangeNotifier {
  // List of possible primary colors
  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];

  // Current theme mode
  ThemeMode _themeMode = ThemeMode.light;
  // Current primary color
  Color _primaryColor = Colors.blue;

  // Getters
  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;

  // Get current theme data
  ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: _themeMode == ThemeMode.light ? Brightness.light : Brightness.dark,
        ),
      );

  // Toggle between light and dark mode
  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Set random primary color
  void randomizeTheme() {
    final random = Random();
    _primaryColor = _colors[random.nextInt(_colors.length)];
    notifyListeners();
  }
}

// // a global boolean change value notifier
// ValueNotifier<bool> isDark = ValueNotifier<bool>(false);

// // ignore: must_be_immutable
// class MainPage extends StatelessWidget {
//   MainPage({super.key});

//   //initiate a timer to change the value of notifier every 5 seconds

//   Timer? timer = Timer.periodic(const Duration(seconds: 5), (timer) {
//     isDark.value = !isDark.value;
//   });

//   @override
//   Widget build(BuildContext context) {
//     // return EventProgress();
//     //three buttons to navigate to the three pages
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const EventProgress()),
//                 );
//               },
//               child: const Text('Event Progress'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const AwesomeSnackbarContentPage()),
//                 );
//               },
//               child: const Text('Swipable Awesome Snakbars'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const EventProgress()),
//                 );
//               },
//               child: const Text('Event Progress'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AwesomeSnackbarContentPage extends StatefulWidget {
//   const AwesomeSnackbarContentPage({super.key});

//   @override
//   State<AwesomeSnackbarContentPage> createState() => _AwesomeSnackbarContentPageState();
// }

// class _AwesomeSnackbarContentPageState extends State<AwesomeSnackbarContentPage> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late CurvedAnimation _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.linear,
//       reverseCurve: Curves.linear,
//     );
//     isDark.addListener(_messageListener);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     isDark.removeListener(_messageListener);

//     log('dispose');
//     super.dispose();
//   }

//   //add a listener to the global boolean change value notifier and show a snackbar whenever the value changes

//   void _messageListener() {
//     if (mounted) {
//       _showCustomSnackbar(context, 'Theme changed to ${isDark.value ? "dark" : "light"} mode');
//     }
//   }

//   //add a listener to the global boolean change value notifier

//   void _showCustomSnackbar(BuildContext context, String message) {
//     var snackBar = SnackBar(
//       elevation: 0,
//       behavior: SnackBarBehavior.floating,
//       backgroundColor: Colors.transparent,
//       dismissDirection: DismissDirection.horizontal,
//       duration: const Duration(seconds: 3),
//       content: AnimatedBuilder(
//         animation: _animation,
//         builder: (context, child) => SlideTransition(
//           position: Tween<Offset>(
//             begin: const Offset(0, 1),
//             end: Offset.zero,
//           ).animate(_animation),
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   //lets use the native Theme.of(context).colorScheme
//                   colors: [
//                     Theme.of(context).colorScheme.primary.withOpacity(0.8),
//                     Theme.of(context).colorScheme.error.withOpacity(0.8),
//                   ]),
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Theme.of(context).colorScheme.error.withOpacity(0.2),
//                   blurRadius: 5,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 const Icon(
//                   Icons.notification_important_rounded,
//                   size: 28,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'This is a custom Snackbar!\n$message ',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );

//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((reason) {
//       // Play the reverse animation only for swipe and timeout
//       switch (reason) {
//         case SnackBarClosedReason.swipe:
//         case SnackBarClosedReason.timeout:
//           _controller.reverse();
//           break;
//         case SnackBarClosedReason.hide:
//         case SnackBarClosedReason.remove:
//         case SnackBarClosedReason.dismiss:
//         case SnackBarClosedReason.action:
//           break;
//       }
//     });

//     _controller.forward();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             _showCustomSnackbar(context, 'hiwoehrowehroiwero[iweiuadhpfoiwero[iweiuadhpfoiwero[iweiuadhpfoiwero[iweiuadhpfoiwero[iweiuadhpfoiwero[iweiuadhpfoiwero[iweiuadhpfoiwero[iweiuadhpfoiwero[iweiuadhpfiuhsufhapiufhp : 🪔🪔⌚😋😋😋😋]');
//           },
//           child: const Text('Show Snackbar'),
//         ),
//       ),
//     );
//   }
// }
