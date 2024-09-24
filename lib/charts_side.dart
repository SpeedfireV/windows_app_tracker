import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/db_bloc/charts_bloc.dart';

class ChartsSide extends StatefulWidget {
  const ChartsSide({super.key});

  @override
  State<ChartsSide> createState() => _ChartsSideState();
}

class _ChartsSideState extends State<ChartsSide> {
  Map<String, int> allApps = {};
  Map<String, Map<String, int>> tasksAssociatedWithTaks = {};
  List<TreeViewItem> selectionItems = [];
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChartsBloc, ChartsState>(
      listener: (context, state) {
        if (state is ChartsPieChartDataLoaded) {
          print("Charts Pie Loaded");
          allApps = context.read<ChartsBloc>().allApps;

          tasksAssociatedWithTaks = context.read<ChartsBloc>().allTasks;
          selectionItems = [];
        }
      },
      builder: (context, state) {
        if (state is ChartsPieChartDataLoaded) {
          print("STATE LOADED!");

          return Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                          sectionsSpace: 1,
                          sections: state.appsData,
                          pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {})),
                      swapAnimationDuration:
                          Duration(milliseconds: 150), // Optional
                      swapAnimationCurve: Curves.linear,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(64.0),
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 1,
                          sections: state.tasksData,
                        ),
                        swapAnimationDuration:
                            Duration(milliseconds: 150), // Optional
                        swapAnimationCurve: Curves.linear,
                      ),
                    ),
                  ],
                ),
              ));
        } else {
          print("STATE ELSE!");
          return Text(
            "Loading",
            style: TextStyle(color: Colors.white),
          );
        }
      },
    );
  }
}
