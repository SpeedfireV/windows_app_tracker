import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:windows_apps_time_measurements_app/app_colors.dart';
import 'package:windows_apps_time_measurements_app/bloc/db_bloc/db_bloc.dart';
import 'package:windows_apps_time_measurements_app/functions.dart';
import 'package:windows_apps_time_measurements_app/main_page.dart';

import 'bloc/db_bloc/data_selection/data_selection_bloc.dart';
import 'bloc/db_bloc/data_selection/highlighted_data_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  addAppToStartup();
  await initSystemTray();
  sqfliteFfiInit();

  runApp(const MyApp());
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1200, 720);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "App Measurment";
    win.show();
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
        BlocProvider(create: (state) => DataSelectionBloc()),
        BlocProvider(create: (state) => HighlightedDataCubit())
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
                Row(children: [
                  Expanded(
                      child: Container(
                    height: 40,
                    color: darkenColor(AppColors.mainColor, -0.1),
                    child: MoveWindow(),
                  )),
                  Container(
                    height: 40,
                    width: 500,
                    color: darkenColor(AppColors.sideColor, -0.1),
                    child: Row(
                      children: [
                        Expanded(child: MoveWindow()),
                        Row(
                          children: [
                            SizedBox(
                              height: 40,
                              child: MinimizeWindowButton(
                                  colors: WindowButtonColors(
                                      iconNormal: AppColors.snowishColor,
                                      mouseOver: const Color(0xFFF6A00C),
                                      mouseDown: const Color(0xFF805306),
                                      iconMouseOver: const Color(0xFF805306),
                                      iconMouseDown: const Color(0xFFFFD500))),
                            ),
                            SizedBox(
                              height: 40,
                              child: MaximizeWindowButton(
                                  colors: WindowButtonColors(
                                      iconNormal: AppColors.snowishColor,
                                      mouseOver: const Color(0xFFF6A00C),
                                      mouseDown: const Color(0xFF805306),
                                      iconMouseOver: const Color(0xFF805306),
                                      iconMouseDown: const Color(0xFFFFD500))),
                            ),
                            SizedBox(
                              height: 40,
                              child: CloseWindowButton(
                                  colors: WindowButtonColors(
                                      iconNormal: AppColors.snowishColor,
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
                ]),
              ],
            )),
      ),
    );
  }
}
