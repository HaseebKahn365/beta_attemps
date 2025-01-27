import 'dart:async';
import 'dart:developer';

import 'package:beta_attemps/event_progress.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: MainPage(),
    );
  }
}

// a global boolean change value notifier
ValueNotifier<bool> isDark = ValueNotifier<bool>(false);

class MainPage extends StatelessWidget {
  MainPage({super.key});

  //initiate a timer to change the value of notifier every 5 seconds

  Timer? timer = Timer.periodic(const Duration(seconds: 5), (timer) {
    isDark.value = !isDark.value;
  });

  @override
  Widget build(BuildContext context) {
    // return EventProgress();
    //three buttons to navigate to the three pages
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EventProgress()),
                );
              },
              child: const Text('Event Progress'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AwesomeSnackbarContentPage()),
                );
              },
              child: const Text('Swipable Awesome Snakbars'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EventProgress()),
                );
              },
              child: const Text('Event Progress'),
            ),
          ],
        ),
      ),
    );
  }
}

class AwesomeSnackbarContentPage extends StatefulWidget {
  const AwesomeSnackbarContentPage({super.key});

  @override
  State<AwesomeSnackbarContentPage> createState() => _AwesomeSnackbarContentPageState();
}

class _AwesomeSnackbarContentPageState extends State<AwesomeSnackbarContentPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
      reverseCurve: Curves.linear,
    );
    isDark.addListener(_themeChangeListener);
  }

  @override
  void dispose() {
    _controller.dispose();
    isDark.removeListener(_themeChangeListener);

    log('dispose');
    super.dispose();
  }

  //add a listener to the global boolean change value notifier and show a snackbar whenever the value changes

  void _themeChangeListener() {
    if (mounted) {
      _showCustomSnackbar(context, 'Theme changed to ${isDark.value ? "dark" : "light"} mode');
    }
  }

  //add a listener to the global boolean change value notifier

  void _showCustomSnackbar(BuildContext context, String message) {
    var snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      dismissDirection: DismissDirection.horizontal,
      duration: const Duration(seconds: 3),
      content: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(_animation),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  //lets use the native Theme.of(context).colorScheme
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    Theme.of(context).colorScheme.error.withOpacity(0.8),
                  ]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notification_important_rounded,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is a custom Snackbar!\n$message ',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((reason) {
      // Play the reverse animation only for swipe and timeout
      switch (reason) {
        case SnackBarClosedReason.swipe:
        case SnackBarClosedReason.timeout:
          _controller.reverse();
          break;
        case SnackBarClosedReason.hide:
        case SnackBarClosedReason.remove:
        case SnackBarClosedReason.dismiss:
        case SnackBarClosedReason.action:
          break;
      }
    });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _showCustomSnackbar(context, 'hiwoehrowehroiwero[iweiuadhpfoiwero[iweiuadhpfoiwero[iweiuadhpfoiwero[iweiuadhpfoiwero[iweiuadhpfoiwero[iweiuadhpfoiwero[iweiuadhpfoiwero[iweiuadhpfoiwero[iweiuadhpfiuhsufhapiufhp : 🪔🪔⌚😋😋😋😋]');
          },
          child: const Text('Show Snackbar'),
        ),
      ),
    );
  }
}
