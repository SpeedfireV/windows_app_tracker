import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:windows_apps_time_measurements_app/bloc/db_bloc/data_selection/expanded_cubit.dart';
import 'package:windows_apps_time_measurements_app/bloc/db_bloc/data_selection/switch_all_cubit.dart';
import 'package:windows_apps_time_measurements_app/models/chart_data/chart_data.dart';

import 'app_colors.dart';
import 'bloc/db_bloc/data_selection/data_selection_bloc.dart';

class DataSelection extends StatefulWidget {
  const DataSelection({super.key});

  @override
  State<DataSelection> createState() => _DataSelectionState();
}

class _DataSelectionState extends State<DataSelection> {
  bool selected = true;
  late final ScrollController selectionController;
  @override
  void initState() {
    super.initState();
    selectionController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    selectionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (state) => ExpandedCubit()),
        BlocProvider(create: (state) => SwitchAllCubit())
      ],
      child: BlocBuilder<DataSelectionBloc, DataSelectionState>(
        builder: (context, state) {
          if (state is DataSelectionDataSelected) {
            List<TreeViewItem> selectionItems = [];
            for (ChartData chartData in state.chartData) {
              List<TreeViewItem> subList = [];
              for (String task in chartData.mapOfTasks.keys) {
                subList.add(TreeViewItem(
                    selected: chartData.isTaskActive(task),
                    value: task,
                    onInvoked: (item, reason) async {
                      print(
                          "New expanded list is ${context.read<ExpandedCubit>().state}");
                      if (reason == TreeViewItemInvokeReason.selectionToggle) {
                        context.read<DataSelectionBloc>().add(
                            DataSelectionUpdateData(
                                adding: item.selected!,
                                appName: chartData.appName,
                                taskName: task,
                                currentData: state.chartData));
                        print("CLICKED $item");
                      }
                    },
                    content: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              task,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Text(chartData.mapOfTasks[task]!.time.toString() +
                              " s")
                        ],
                      ),
                    )));
              }
              final TreeViewItem appTreeViewItem = TreeViewItem(
                  value: chartData,
                  expanded: context
                      .read<ExpandedCubit>()
                      .state
                      .contains(chartData.appName),
                  onInvoked: (item, reason) async {
                    print(
                        "New expanded list is ${context.read<ExpandedCubit>().state}");
                    if (reason == TreeViewItemInvokeReason.selectionToggle) {
                      context.read<DataSelectionBloc>().add(
                          DataSelectionUpdateData(
                              adding: item.selected!,
                              currentData: state.chartData,
                              appName: chartData.appName));
                      print("CLICKED $item");
                    } else if (reason ==
                        TreeViewItemInvokeReason.expandToggle) {
                      context
                          .read<ExpandedCubit>()
                          .addExpanded(chartData.appName);
                    }
                  },
                  children: subList,
                  content: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            chartData.appName,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Text(
                            "${chartData.getActiveTasksTime()} s (Total: ${chartData.getTotalTime()} s)")
                      ],
                    ),
                  ));
              selectionItems.add(appTreeViewItem);
            }
            return Flexible(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(flex: 5, child: Container()),
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Container()),
                          Expanded(
                            flex: 6,
                            child: Container(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Apps & Tasks",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        BlocBuilder<SwitchAllCubit, bool>(
                                          builder: (context, state) {
                                            return Checkbox(
                                              checked: context
                                                  .read<SwitchAllCubit>()
                                                  .state,
                                              onChanged: (v) {
                                                context
                                                    .read<SwitchAllCubit>()
                                                    .switchSelection();
                                                context
                                                    .read<DataSelectionBloc>()
                                                    .add(DataSelectionSwitchAll(
                                                        currentData: context
                                                            .read<
                                                                DataSelectionBloc>()
                                                            .chartData,
                                                        turnOn: context
                                                            .read<
                                                                SwitchAllCubit>()
                                                            .state));
                                              },
                                              content: Text("Switch All"),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 1,
                                    color: AppColors.mainColor,
                                  ),
                                  Expanded(
                                    child: BlocBuilder<ExpandedCubit,
                                        List<String>>(
                                      builder: (context, state) {
                                        return TreeView(
                                            scrollController:
                                                selectionController,
                                            shrinkWrap: true,
                                            selectionMode:
                                                TreeViewSelectionMode.multiple,
                                            items: selectionItems);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15)),
                              margin: EdgeInsets.only(bottom: 16, right: 16),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ));
          } else {
            return Text("Loading Data");
          }
        },
      ),
    );
  }
}
