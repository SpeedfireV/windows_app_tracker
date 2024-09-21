import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:windows_apps_time_measurements_app/bloc/db_bloc/db_bloc.dart';
import 'package:windows_apps_time_measurements_app/functions.dart';

import 'main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSystemTray();
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  var db = await databaseFactory.openDatabase(inMemoryDatabasePath);
  await db.execute('''
  CREATE TABLE Product (
      id INTEGER PRIMARY KEY,
      title TEXT
  )
  ''');
  runApp(const MyApp());
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(600, 450);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "App Measurment";
    win.hide();
  });
}

const borderColor = Color(0xFF805306);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (state) => DbBloc())],
      child: FluentApp(
        debugShowCheckedModeBanner: false,
        home: WindowBorder(
          color: borderColor,
          width: 1,
          child: Row(
            children: const [RightSide()],
          ),
        ),
      ),
    );
  }
}

const backgroundStartColor = Color(0xFFFFD500);
const backgroundEndColor = Color(0xFFF6A00C);

class RightSide extends StatelessWidget {
  const RightSide({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [backgroundStartColor, backgroundEndColor],
              stops: [0.0, 1.0]),
        ),
        child: Column(children: [
          WindowTitleBarBox(
            child: Row(
              children: [Expanded(child: MoveWindow()), const WindowButtons()],
            ),
          ),
          Expanded(
            child: MainPage(),
          )
        ]),
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF805306),
    mouseOver: const Color(0xFFF6A00C),
    mouseDown: const Color(0xFF805306),
    iconMouseOver: const Color(0xFF805306),
    iconMouseDown: const Color(0xFFFFD500));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.orange.darkest);

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
