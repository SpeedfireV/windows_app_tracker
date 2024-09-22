import 'dart:async';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:windows_apps_time_measurements_app/activity_log.dart';
import 'package:windows_apps_time_measurements_app/app_colors.dart';

import 'bloc/db_bloc/charts_bloc.dart';
import 'bloc/db_bloc/db_bloc.dart';
import 'models/app.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String currentApp = "";

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DbBloc, DbState>(
      listener: (BuildContext context, dbState) {
        if (dbState is DbInitialized) {
          print("DB INITIALIZED!");
          BlocProvider.of<ChartsBloc>(context)
              .add(ChartsLoadPieChartData(context.read<DbBloc>().apps));
        }
        if (dbState is DbAddedRecord) {
          context.read<DbBloc>().add(DbGetRecords());
        }
      },
      builder: (context, dbState) {
        final Iterable<App> apps = context.read<DbBloc>().apps;
        return Container(
          color: AppColors.mainColor,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: BlocBuilder<ChartsBloc, ChartsState>(
                        builder: (context, state) {
                          if (state is ChartsPieChartDataLoaded) {
                            print("STATE LOADED!");
                            print(state.data.toString());
                            return Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Stack(
                                        children: [
                                          PieChart(
                                            PieChartData(
                                              sections: state.data,
                                            ),
                                            swapAnimationDuration: Duration(
                                                milliseconds: 150), // Optional
                                            swapAnimationCurve: Curves.linear,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(64.0),
                                            child: PieChart(
                                              PieChartData(
                                                sections: state.data,
                                              ),
                                              swapAnimationDuration: Duration(
                                                  milliseconds:
                                                      150), // Optional
                                              swapAnimationCurve: Curves.linear,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                Flexible(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        Expanded(flex: 5, child: Container()),
                                        Expanded(
                                          flex: 4,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  flex: 1, child: Container()),
                                              Expanded(
                                                flex: 6,
                                                child: Container(
                                                  child: ListView(
                                                    children: [
                                                      Text("HELLO"),
                                                    ],
                                                  ),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15)),
                                                  margin: EdgeInsets.only(
                                                      bottom: 16, right: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ))
                              ],
                            );
                          } else {
                            print("STATE ELSE!");
                            return Text("Loading");
                          }
                        },
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      height: 2,
                    ),
                    Flexible(
                        flex: 1,
                        child: Container(
                          color: Color(0xff0E0F27),
                          width: double.infinity,
                          height: double.infinity,
                          child: Column(
                            children: [
                              Container(
                                child: Text("Data"),
                              ),
                            ],
                          ),
                        ))
                  ],
                ),
              ),
              ActivityLog(
                apps: apps,
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<DbBloc>(context).add(DbInit());
    Timer.periodic(Duration(seconds: 1), (timer) {
      context.read<DbBloc>().add(DbAddRecord());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class AppIconWidget extends StatelessWidget {
  final String iconPath;

  AppIconWidget({required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return iconPath.isNotEmpty
        ? Image.file(File(iconPath)) // If the icon is saved to disk
        : Icon(
            FluentIcons.app_icon_default); // Fallback if the icon path is empty
  }
}
