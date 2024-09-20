import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:system_tray/system_tray.dart';
import 'package:win32/win32.dart';

Future<void> initSystemTray() async {
  String path =
      Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png';

  final AppWindow appWindow = AppWindow();
  final SystemTray systemTray = SystemTray();

  // We first init the systray menu
  await systemTray.initSystemTray(
    title: "system tray",
    iconPath: path,
  );

  // create context menu
  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(label: 'Show', onClicked: (menuItem) => appWindow.show()),
    MenuItemLabel(label: 'Hide', onClicked: (menuItem) => appWindow.hide()),
    MenuItemLabel(label: 'Exit', onClicked: (menuItem) => appWindow.close()),
  ]);

  // set context menu
  await systemTray.setContextMenu(menu);

  // handle system tray event
  systemTray.registerSystemTrayEventHandler((eventName) {
    debugPrint("eventName: $eventName");
    if (eventName == kSystemTrayEventClick) {
      Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
    } else if (eventName == kSystemTrayEventRightClick) {
      Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
    }
  });
}

// Define constants for process access
const PROCESS_QUERY_INFORMATION = 0x0400;
const PROCESS_VM_READ = 0x0010;

String trackActiveApp() {
  // Get the handle of the currently active window
  final hWnd = GetForegroundWindow();

  // Get the process ID associated with the active window
  final processIdPtr = calloc<Uint32>();
  GetWindowThreadProcessId(hWnd, processIdPtr);
  final processId = processIdPtr.value;
  calloc.free(processIdPtr);

  // Open the process to retrieve the executable name
  final hProcess = OpenProcess(
      PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, processId);

  if (hProcess == NULL) {
    print('Failed to open process.');
    return "";
  }

  // Allocate a buffer for the executable name as Uint16 and cast to Utf16
  final buffer = calloc<Uint16>(256).cast<Utf16>();
  GetWindowText(hWnd, buffer, 256);
  final exePathBuffer =
      calloc<Uint16>(260).cast<Utf16>(); // 260 is the MAX_PATH size in Windows

  // Load psapi.dll and get the GetModuleFileNameEx function
  final psapi = DynamicLibrary.open('psapi.dll');
  final GetModuleFileNameEx = psapi.lookupFunction<
      Uint32 Function(IntPtr hProcess, IntPtr hModule,
          Pointer<Utf16> lpFilename, Uint32 nSize),
      int Function(int hProcess, int hModule, Pointer<Utf16> lpFilename,
          int nSize)>('GetModuleFileNameExW');

  // Get the executable name of the process
  final result = GetModuleFileNameEx(hProcess, NULL, exePathBuffer, 260);

  if (result > 0) {
    // Convert the executable path to a Dart string
    final exePath = exePathBuffer.toDartString();

    // Extract just the file name from the full path
    final exeName = p.basename(exePath);
    final windowTitle = buffer.toDartString();
    print('Active window: $windowTitle');
    print('Active app executable: $exeName');
    return windowTitle.toString();
  } else {
    print('Failed to get executable name.');
    return 'Failed to get executable name.';
  }

  // Clean up
  calloc.free(exePathBuffer);
  CloseHandle(hProcess);
}
