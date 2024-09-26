import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:windows_apps_time_measurements_app/app_colors.dart';
import 'package:windows_apps_time_measurements_app/bloc/db_bloc/data_selection/data_selection_bloc.dart';
import 'package:windows_apps_time_measurements_app/bloc/db_bloc/data_selection/highlighted_data_cubit.dart';
import 'package:windows_apps_time_measurements_app/models/task_info.dart';

import 'models/chart_data/chart_data.dart';
import 'utils/time_formatter.dart';

class ChartsSide extends StatefulWidget {
  const ChartsSide({super.key});

  @override
  State<ChartsSide> createState() => _ChartsSideState();
}

class _ChartsSideState extends State<ChartsSide> {
  List<TreeViewItem> selectionItems = [];
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataSelectionBloc, DataSelectionState>(
        builder: (context, state) {
      if (state is DataSelectionDataSelected) {
        return BlocBuilder<HighlightedDataCubit, ChartData?>(
            builder: (context, highlightedState) {
          List<PieChartSectionData> appsPieChartData = [];
          List<PieChartSectionData> tasksPieChartData = [];
          final stopwatch = Stopwatch();
          stopwatch.start();
          for (ChartData chartData in state.chartData) {
            bool appSelected;
            print(highlightedState);
            if (highlightedState != null &&
                highlightedState.active == true &&
                highlightedState.appName == chartData.appName &&
                highlightedState.mapOfTasks.isEmpty) {
              appSelected = true;
            } else {
              appSelected = false;
            }
            appsPieChartData.add(PieChartSectionData(
                borderSide: appSelected
                    ? const BorderSide(color: Colors.white, width: 3)
                    : BorderSide(color: Colors.white.withOpacity(0)),
                title: chartData.appName,
                badgeWidget: appSelected
                    ? Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          "${chartData.appName}\n${formatDuration(chartData.getActiveTasksTime())}",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.sideColor),
                        ),
                      )
                    : Container(),
                value: chartData.getActiveTasksTime().toDouble(),
                color: chartData.color,
                showTitle: appSelected));

            for (String task in chartData.mapOfTasks.keys) {
              bool taskSelected;

              if (highlightedState != null &&
                  highlightedState.active == false &&
                  highlightedState.appName == "" &&
                  highlightedState.mapOfTasks.isNotEmpty &&
                  highlightedState.mapOfTasks.keys.first == task) {
                print(highlightedState.mapOfTasks.keys.first);
                taskSelected = true;
              } else {
                taskSelected = false;
              }
              if (chartData.mapOfTasks[task]!.active) {
                tasksPieChartData.add(PieChartSectionData(
                    borderSide: taskSelected
                        ? const BorderSide(color: Colors.white, width: 3)
                        : BorderSide(color: Colors.white.withOpacity(0)),
                    title: task,
                    badgeWidget: taskSelected
                        ? Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15)),
                            child: Text(
                              "$task\n${formatDuration(chartData.mapOfTasks[task]!.time)}",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.sideColor),
                            ),
                          )
                        : Container(),
                    value: chartData.mapOfTasks[task]!.time.toDouble(),
                    color: chartData.mapOfTasks[task]!.color,
                    showTitle: false));
              }
            }
          }
          stopwatch.stop();
          print("It took ${stopwatch.elapsedMilliseconds} to render charts");
          return Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                          sectionsSpace: 1,
                          sections: appsPieChartData,
                          pieTouchData: PieTouchData(touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            if (!(!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null ||
                                pieTouchResponse
                                        .touchedSection!.touchedSection ==
                                    null)) {
                              context.read<HighlightedDataCubit>().selectData(
                                  ChartData(
                                      appName: pieTouchResponse.touchedSection!
                                          .touchedSection!.title,
                                      color: Colors.white,
                                      active: true,
                                      mapOfTasks: {}));
                            } else {
                              context
                                  .read<HighlightedDataCubit>()
                                  .resetSelection();
                            }
                          })),
                      swapAnimationDuration:
                          Duration(milliseconds: 150), // Optional
                      swapAnimationCurve: Curves.linear,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(120.0),
                      child: PieChart(
                        PieChartData(
                            sectionsSpace: 1,
                            sections: tasksPieChartData,
                            pieTouchData: PieTouchData(touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                              if (!(!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null ||
                                  pieTouchResponse
                                          .touchedSection!.touchedSection ==
                                      null)) {
                                print("Added TASK!");
                                context.read<HighlightedDataCubit>().selectData(
                                        ChartData(
                                            appName: "",
                                            color: Colors.white,
                                            active: false,
                                            mapOfTasks: {
                                          pieTouchResponse.touchedSection!
                                                  .touchedSection!.title:
                                              TaskInfo(
                                                  active: true,
                                                  color: Colors.white,
                                                  time: 0)
                                        }));
                              } else {
                                context
                                    .read<HighlightedDataCubit>()
                                    .resetSelection();
                              }
                            })),
                        swapAnimationDuration: Duration(milliseconds: 20), //
                        // Optional
                        swapAnimationCurve: Curves.linear,
                      ),
                    ),
                  ],
                ),
              ));
        });
      }
      return Text("Loading Data");
    });
  }
}
