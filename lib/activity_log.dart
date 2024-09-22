import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:windows_apps_time_measurements_app/app_colors.dart';
import 'package:windows_apps_time_measurements_app/bloc/activity_log_bloc/activity_log_cubit.dart';
import 'package:windows_apps_time_measurements_app/models/app.dart';

import 'bloc/db_bloc/db_bloc.dart';

class ActivityLog extends StatefulWidget {
  const ActivityLog({super.key});

  @override
  State<ActivityLog> createState() => _ActivityLogState();
}

class _ActivityLogState extends State<ActivityLog> {
  late ScrollController activityLogController;

  @override
  void initState() {
    super.initState();
    activityLogController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    activityLogController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DbBloc, DbState>(
      builder: (context, state) {
        Iterable<App> apps = context.read<DbBloc>().apps;
        return BlocProvider(
          create: (context) => ActivityLogCubit(),
          child: BlocBuilder<ActivityLogCubit, bool>(
            builder: (context, isScrollStickedToTheBottom) {
              return BlocConsumer<DbBloc, DbState>(
                listener: (context, dbState) {
                  if (dbState is DbAddedRecord && isScrollStickedToTheBottom) {
                    activityLogController
                        .jumpTo(activityLogController.position.maxScrollExtent);
                  }
                },
                builder: (context, state) {
                  return Container(
                    decoration:
                        BoxDecoration(color: AppColors.sideColor, boxShadow: [
                      BoxShadow(
                        color: AppColors.sideColor.withOpacity(
                            0.25), // Add some transparency to soften the shadow
                        offset: Offset(
                            -10, 0), // The horizontal offset for the shadow
                        blurRadius: 10, // Increases blur for a smoother shadow
                        spreadRadius: 5, // Controls the spread of the shadow
                      )
                    ]),
                    width: 500,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Activity Log",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.snowishColor),
                              ),
                              Expanded(child: Container()),
                              Row(
                                children: [
                                  Checkbox(
                                      content: Text(
                                        "Scroll To The Bottom",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.snowishColor),
                                      ),
                                      checked: isScrollStickedToTheBottom,
                                      onChanged: (v) {
                                        context
                                            .read<ActivityLogCubit>()
                                            .switchScrollToTheBottom();
                                      }),
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 1,
                          color: AppColors.whitishColor,
                        ),
                        Expanded(
                          child: Scrollbar(
                            interactive: !isScrollStickedToTheBottom,
                            style: ScrollbarThemeData(
                                scrollbarColor: AppColors.whitishColor,
                                thickness: 8,
                                radius: Radius.zero,
                                backgroundColor:
                                    AppColors.whitishColor.withOpacity(0.1),
                                hoveringRadius: Radius.zero,
                                hoveringThickness: 16),
                            controller: activityLogController,
                            child: ListView.builder(
                              physics: isScrollStickedToTheBottom
                                  ? NeverScrollableScrollPhysics()
                                  : BouncingScrollPhysics(),
                              controller: activityLogController,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  // leading: Image(
                                  //   image: AssetImage(apps.elementAt(index).iconPath),
                                  // ),
                                  contentPadding:
                                      EdgeInsets.only(left: 0, right: 20),
                                  title: Text(
                                    apps.elementAt(index).appName,
                                    style: TextStyle(
                                        color: AppColors.snowishColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    apps.elementAt(index).appTask,
                                    style: TextStyle(
                                        color: AppColors.snowishColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  trailing: Text(
                                    DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                        apps.elementAt(index).createdAt),
                                    style: TextStyle(
                                        color: AppColors.snowishColor,
                                        fontWeight: FontWeight.w300),
                                  ),
                                );
                              },
                              itemCount: apps.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
