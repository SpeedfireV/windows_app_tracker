import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:windows_apps_time_measurements_app/bloc/db_bloc/data_selection/expanded_cubit.dart';
import 'package:windows_apps_time_measurements_app/bloc/db_bloc/data_selection/highlighted_data_cubit.dart';
import 'package:windows_apps_time_measurements_app/bloc/db_bloc/data_selection/switch_all_cubit.dart';
import 'package:windows_apps_time_measurements_app/models/chart_data/chart_data.dart';
import 'package:windows_apps_time_measurements_app/utils/time_formatter.dart';

import 'app_colors.dart';
import 'bloc/db_bloc/data_selection/data_selection_bloc.dart';

class DataSelection extends StatefulWidget {
  const DataSelection({super.key});

  @override
  State<DataSelection> createState() => _DataSelectionState();
}

class _DataSelectionState extends State<DataSelection> {
  final double _taskHeight = 32;
  final double _appHeight = 36;
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
          return BlocBuilder<HighlightedDataCubit, ChartData?>(
            builder: (context, hightlightedState) {
              if (state is DataSelectionDataSelected) {
                return BlocBuilder<ExpandedCubit, String?>(
                    builder: (context, expandedState) {
                  List<TreeViewItem> selectionItems = [];
                  int expandedElements = 0;
                  for (ChartData chartData in state.chartData) {
                    List<TreeViewItem> subList = [];
                    bool anyTaskHighlighted = false;
                    int numberOfElements = 0;
                    for (String task in chartData.mapOfTasks.keys) {
                      numberOfElements += 1;
                      bool taskHighlited;
                      if (hightlightedState != null &&
                          hightlightedState.mapOfTasks.isNotEmpty &&
                          hightlightedState.mapOfTasks.keys.first == task) {
                        taskHighlited = true;
                        anyTaskHighlighted = true;
                        expandedElements = numberOfElements;

                        context
                            .read<ExpandedCubit>()
                            .addExpanded(chartData.appName);
                      } else {
                        taskHighlited = false;
                      }
                      subList.add(TreeViewItem(
                          selected: chartData.isTaskActive(task),
                          value: task,
                          onInvoked: (item, reason) async {
                            print(
                                "New expanded list is ${context.read<ExpandedCubit>().state}");
                            if (reason ==
                                TreeViewItemInvokeReason.selectionToggle) {
                              context.read<DataSelectionBloc>().add(
                                  DataSelectionUpdateData(
                                      adding: item.selected!,
                                      appName: chartData.appName,
                                      taskName: task,
                                      currentData: state.chartData));
                              print("CLICKED $item");
                            }
                          },
                          content: SizedBox(
                            height: _taskHeight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  right: 12.0, top: 0, bottom: 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      task,
                                      style: TextStyle(
                                          fontSize: taskHighlited ? 13 : 12,
                                          fontWeight: taskHighlited
                                              ? FontWeight.w600
                                              : FontWeight.w400),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                    formatDuration(
                                        chartData.mapOfTasks[task]!.time),
                                  )
                                ],
                              ),
                            ),
                          )));
                    }
                    bool appHighlighted;
                    if (hightlightedState != null &&
                        hightlightedState.mapOfTasks.isEmpty &&
                        hightlightedState.active &&
                        hightlightedState.appName == chartData.appName) {
                      appHighlighted = true;
                    } else {
                      appHighlighted = false;
                    }
                    bool isExpanded = context.read<ExpandedCubit>().state ==
                        chartData.appName;

                    final TreeViewItem appTreeViewItem = TreeViewItem(
                        value: chartData,
                        expanded: isExpanded,
                        onInvoked: (item, reason) async {
                          if (reason ==
                              TreeViewItemInvokeReason.selectionToggle) {
                            context.read<DataSelectionBloc>().add(
                                DataSelectionUpdateData(
                                    adding: item.selected!,
                                    currentData: state.chartData,
                                    appName: chartData.appName));
                          } else if (reason ==
                              TreeViewItemInvokeReason.expandToggle) {
                            if (context.read<ExpandedCubit>().state !=
                                chartData.appName) {
                              context
                                  .read<ExpandedCubit>()
                                  .addExpanded(chartData.appName);
                            } else {
                              context.read<ExpandedCubit>().closeExpanded();
                            }
                          }
                        },
                        children: subList,
                        content: SizedBox(
                          height: _appHeight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    chartData.appName,
                                    style: TextStyle(
                                        fontSize: appHighlighted ? 15 : 13,
                                        fontWeight: appHighlighted
                                            ? FontWeight.w600
                                            : FontWeight.w400),
                                  ),
                                ),
                                Text(
                                    "${formatDuration(chartData.getActiveTasksTime())} s (Total: ${formatDuration(chartData.getTotalTime())})")
                              ],
                            ),
                          ),
                        ));
                    selectionItems.add(appTreeViewItem);
                    if (isExpanded &&
                        !appHighlighted &&
                        expandedElements == 0) {
                      expandedElements = subList.length;
                    }
                    if (appHighlighted || anyTaskHighlighted) {
                      print(
                          "There are $expandedElements expanded elements which take ${expandedElements * _taskHeight} height and additional ${(expandedElements) * 4} space between them");
                      print(
                          "There are ${selectionItems.length - 1} selected items which totally take ${(selectionItems.length - 1) * _appHeight} space & additional ${(selectionItems.length - 1) * 4} space between them");
                      double totalSpaceBetween =
                          (selectionItems.length + expandedElements - 1) * 4;
                      double totalHeight =
                          (selectionItems.length - 1) * _appHeight +
                              (expandedElements * _taskHeight);

                      selectionController
                          .jumpTo(totalHeight + totalSpaceBetween);
                    }
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
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              BlocBuilder<SwitchAllCubit, bool>(
                                                builder: (context, state) {
                                                  return Checkbox(
                                                    checked: context
                                                        .read<SwitchAllCubit>()
                                                        .state,
                                                    onChanged: (v) {
                                                      context
                                                          .read<
                                                              SwitchAllCubit>()
                                                          .switchSelection();
                                                      context
                                                          .read<
                                                              DataSelectionBloc>()
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
                                            child: TreeView(
                                                scrollController:
                                                    selectionController,
                                                shrinkWrap: true,
                                                selectionMode:
                                                    TreeViewSelectionMode
                                                        .multiple,
                                                items: selectionItems)),
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    margin:
                                        EdgeInsets.only(bottom: 16, right: 16),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ));
                });
              } else {
                return Text("Loading Data");
              }
            },
          );
        },
      ),
    );
  }
}
