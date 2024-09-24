import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:windows_apps_time_measurements_app/activity_log.dart';
import 'package:windows_apps_time_measurements_app/app_colors.dart';
import 'package:windows_apps_time_measurements_app/charts_side.dart';
import 'package:windows_apps_time_measurements_app/data_selection.dart';

import 'bloc/db_bloc/charts_bloc.dart';
import 'bloc/db_bloc/data_selection/data_selection_bloc.dart';
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
            context
                .read<DataSelectionBloc>()
                .add(DataSelectionLoadData(context.read<DbBloc>().apps));
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
                      child:
                          BlocListener<DataSelectionBloc, DataSelectionState>(
                              listener: (context, dataSelectionState) {
                                if (dataSelectionState
                                    is DataSelectionDataSelected) {
                                  BlocProvider.of<ChartsBloc>(context).add(
                                      ChartsLoadPieChartData(
                                          dataSelectionState.chartData));
                                }
                              },
                              child: Row(
                                children: const [ChartsSide(), DataSelection()],
                              )),
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
