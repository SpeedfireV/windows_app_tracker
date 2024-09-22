import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:windows_apps_time_measurements_app/bloc/db_bloc/charts_bloc.dart';
import 'package:windows_apps_time_measurements_app/bloc/db_bloc/db_bloc.dart';
import 'package:windows_apps_time_measurements_app/functions.dart';
import 'package:windows_apps_time_measurements_app/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSystemTray();
  sqfliteFfiInit();
  runApp(const MyApp());
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1080, 600);
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
      providers: [
        BlocProvider(create: (state) => DbBloc()),
        BlocProvider(create: (state) => ChartsBloc())
      ],
      child: FluentApp(
        debugShowCheckedModeBanner: false,
        home: WindowBorder(
            color: borderColor,
            width: 1,
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: 40,
                    ),
                    Expanded(child: MainPage()),
                  ],
                ),
                Container(
                  height: 40,
                  color: Color(0xffFBF7F4),
                  child: Row(
                    children: [
                      Expanded(child: MoveWindow()),
                      Row(
                        children: [
                          SizedBox(
                            height: 40,
                            child: MinimizeWindowButton(
                                colors: WindowButtonColors(
                                    iconNormal: const Color(0xFF805306),
                                    mouseOver: const Color(0xFFF6A00C),
                                    mouseDown: const Color(0xFF805306),
                                    iconMouseOver: const Color(0xFF805306),
                                    iconMouseDown: const Color(0xFFFFD500))),
                          ),
                          SizedBox(
                            height: 40,
                            child: MaximizeWindowButton(
                                colors: WindowButtonColors(
                                    iconNormal: const Color(0xFF805306),
                                    mouseOver: const Color(0xFFF6A00C),
                                    mouseDown: const Color(0xFF805306),
                                    iconMouseOver: const Color(0xFF805306),
                                    iconMouseDown: const Color(0xFFFFD500))),
                          ),
                          SizedBox(
                            height: 40,
                            child: CloseWindowButton(
                                colors: WindowButtonColors(
                                    iconNormal: const Color(0xFF805306),
                                    mouseOver: const Color(0xFFF6A00C),
                                    mouseDown: const Color(0xFF805306),
                                    iconMouseOver: const Color(0xFF805306),
                                    iconMouseDown: const Color(0xFFFFD500))),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
