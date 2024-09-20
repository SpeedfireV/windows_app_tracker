import 'dart:async';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'functions.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String currentApp = "";
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
            child: Text(
          currentApp,
          style: TextStyle(color: Colors.blue),
        )),
        Button(
          child: Text("Hide"),
          onPressed: () {
            if (appWindow.isVisible) {
              appWindow.hide();
            } else {
              appWindow.show();
            }
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        final String newWindow = trackActiveApp();
        print("Set State: " + newWindow);
        currentApp = newWindow;
      });
    });
  }
}
