import 'package:beta_attemps/data/datasource/local_data/database_helper.dart';
import 'package:beta_attemps/presentation/bloc/note_bloc.dart';
import 'package:beta_attemps/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'injection.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = DatabaseHelper();
  await db.initDB();
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MultiProvider(
      providers: [BlocProvider(create: (_) => di.locator<NoteBloc>())],
      child: const MaterialApp(
        title: 'Flutter Note App',
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}
