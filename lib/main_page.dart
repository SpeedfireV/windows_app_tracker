import 'dart:async';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
  late ScrollController activityLogController;
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
          activityLogController
              .jumpTo(activityLogController.position.maxScrollExtent);
        }
      },
      builder: (context, dbState) {
        final Iterable<App> apps = context.read<DbBloc>().apps;
        return Container(
          color: Color(0xffE8998D),
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
                                    flex: 3,
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
                                                milliseconds: 150), // Optional
                                            swapAnimationCurve: Curves.linear,
                                          ),
                                        ),
                                      ],
                                    )),
                                Flexible(flex: 2, child: Text("Hello"))
                              ],
                            );
                          } else {
                            print("STATE ELSE!");
                            return Text("Loading");
                          }
                        },
                      ),
                    ),
                    Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            Container(
                              child: Text("Data"),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(color: Color(0xffEED2CC), boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                        0.25), // Add some transparency to soften the shadow
                    offset:
                        Offset(-10, 0), // The horizontal offset for the shadow
                    blurRadius: 20, // Increases blur for a smoother shadow
                    spreadRadius: 5, // Controls the spread of the shadow
                  )
                ]),
                width: 400,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffEED2CC),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Activity Log",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Expanded(child: Container()),
                          Row(
                            children: [
                              Checkbox(
                                  content: Text("Scroll To The Bottom"),
                                  checked: true,
                                  onChanged: (v) {}),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 0.4,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        controller: activityLogController,
                        itemBuilder: (context, index) {
                          return ListTile(
                            // leading: Image(
                            //   image: AssetImage(apps.elementAt(index).iconPath),
                            // ),
                            title: Text(apps.elementAt(index).appName),
                            subtitle: Text(apps.elementAt(index).appTask),
                            trailing: Text(DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(apps.elementAt(index).createdAt)),
                          );
                        },
                        itemCount: apps.length,
                      ),
                    ),
                  ],
                ),
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
    activityLogController = ScrollController();
    BlocProvider.of<DbBloc>(context).add(DbInit());
    Timer.periodic(Duration(seconds: 1), (timer) {
      context.read<DbBloc>().add(DbAddRecord());
    });
  }

  @override
  void dispose() {
    super.dispose();
    activityLogController.dispose();
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
