import 'dart:async';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
      listener: (BuildContext context, state) {
        if (state is DbAddedRecord) context.read<DbBloc>().add(DbGetRecords());
      },
      builder: (context, state) {
        final Iterable<App> apps = context.read<DbBloc>().apps;
        return Container(
          color: Colors.purple.dark,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                        child: PieChart(
                      PieChartData(sections: [
                        PieChartSectionData(value: 10, title: "Values"),
                        PieChartSectionData(value: 15, title: "Values3")
                      ]),
                      swapAnimationDuration:
                          Duration(milliseconds: 150), // Optional
                      swapAnimationCurve: Curves.linear,
                    )),
                    Flexible(
                        child: ListView.builder(
                      itemBuilder: (context, index) => Text(
                          context.read<DbBloc>().apps.elementAt(index).appName),
                      itemCount: context.read<DbBloc>().apps.length,
                    )),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white),
                width: 400,
                child: Column(
                  children: [
                    Text("Activity Log"),
                    Expanded(
                      child: ListView.builder(
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
