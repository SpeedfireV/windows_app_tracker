import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/db_bloc/db_bloc.dart';
import 'functions.dart';
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
      builder: (context, state) => Column(
        children: [
          Flexible(
              child: ListView.builder(
            itemBuilder: (context, index) =>
                Text(context.read<DbBloc>().apps.elementAt(index).appName),
            itemCount: context.read<DbBloc>().apps.length,
          )),
          Button(
            child: Text("Get Data"),
            onPressed: () {
              context.read<DbBloc>().add(DbGetRecords());
            },
          ),
        ],
      ),
      listener: (BuildContext context, state) {},
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<DbBloc>(context).add(DbInit());
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        final App? currentlyOpenApp = trackActiveApp();
        if (currentlyOpenApp != null) {
          context.read<DbBloc>().add(DbAddRecord(currentlyOpenApp));
          currentApp = currentlyOpenApp.appName;
        }
      });
    });
  }
}
