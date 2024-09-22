import 'dart:async';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:windows_apps_time_measurements_app/activity_log.dart';
import 'package:windows_apps_time_measurements_app/app_colors.dart';

import 'bloc/db_bloc/charts_bloc.dart';
import 'bloc/db_bloc/db_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String currentApp = "";

  @override
  Widget build(BuildContext context) {
    return BlocListener<DbBloc, DbState>(
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
        child: Container(
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
                            Map<String, int> allApps =
                                context.read<ChartsBloc>().allApps;
                            Map<String, Map<String, int>>
                                tasksAssociatedWithTaks =
                                context.read<ChartsBloc>().allTasks;
                            List<TreeViewItem> selectionItems = [];
                            for (String appName in allApps.keys) {
                              print("App Name: " + appName);
                              List<TreeViewItem> tasksList = [];
                              for (String task
                                  in tasksAssociatedWithTaks[appName]!.keys) {
                                tasksList.add(TreeViewItem(
                                    content: Text(
                                  task,
                                  style: TextStyle(fontSize: 12),
                                )));
                              }
                              TreeViewItem appTree = TreeViewItem(
                                  lazy: true,
                                  expanded: false,
                                  content: Text(
                                    appName,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13),
                                  ),
                                  children: tasksList);
                              selectionItems.add(appTree);
                            }

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
                                              sectionsSpace: 1,
                                              sections: state.appsData,
                                            ),
                                            swapAnimationDuration: Duration(
                                                milliseconds: 150), // Optional
                                            swapAnimationCurve: Curves.linear,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(64.0),
                                            child: PieChart(
                                              PieChartData(
                                                sectionsSpace: 1,
                                                sections: state.tasksData,
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
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    16.0,
                                                                vertical: 8),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              "Apps & Tasks",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                            Checkbox(
                                                              checked: true,
                                                              onChanged: (v) {},
                                                              content: Text(
                                                                  "Switch All"),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 1,
                                                        color:
                                                            AppColors.mainColor,
                                                      ),
                                                      TreeView(
                                                          shrinkWrap: true,
                                                          selectionMode:
                                                              TreeViewSelectionMode
                                                                  .multiple,
                                                          items:
                                                              selectionItems),
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
              ActivityLog()
            ],
          ),
        ));
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
