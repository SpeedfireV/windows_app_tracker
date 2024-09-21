import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:system_tray/system_tray.dart';
import 'package:win32/win32.dart';

import 'models/app.dart';

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
// Define constants for SHGetFileInfo flags
const int SHGFI_ICON = 0x000000100; // Retrieves the handle to the icon
const int SHGFI_LARGEICON = 0x000000000; // Retrieves the large icon
const int SHGFI_SMALLICON = 0x000000001; // Retrieves the small icon

Future<App?> trackActiveApp() async {
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
    return null;
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
    print(exePath.toString());
    extractIcon(exePath);

    // Now get the icon using SHGetFileInfo
    final shInfo = calloc<SHFILEINFO>();

    final shell32 = DynamicLibrary.open('shell32.dll');
    final SHGetFileInfo = shell32.lookupFunction<
        IntPtr Function(Pointer<Utf16> pszPath, Uint32 dwFileAttributes,
            Pointer<SHFILEINFO> psfi, Uint32 cbFileInfo, Uint32 uFlags),
        int Function(
            Pointer<Utf16> pszPath,
            int dwFileAttributes,
            Pointer<SHFILEINFO> psfi,
            int cbFileInfo,
            int uFlags)>('SHGetFileInfoW');

    // Call SHGetFileInfo with SHGFI_ICON to get the icon handle (HICON)
    final res = SHGetFileInfo(exePathBuffer, 0, shInfo, sizeOf<SHFILEINFO>(),
        SHGFI_ICON | SHGFI_LARGEICON);

    String iconPath = '';

    if (res != 0) {
      final hIcon = shInfo.ref.hIcon;
      if (hIcon != NULL) {
        // Here you could convert the hIcon to an image (or store the path).
        // Currently, we'll just print that the icon was fetched successfully.
        print('Icon fetched for $exeName.');

        // Optionally save icon as a file, or display it using a suitable package.
        iconPath =
            'assets/icons/${exeName.substring(0, exeName.length - 4)}'; // Placeholder for icon file path or handle.
      }
    } else {
      print('Failed to retrieve icon for $exeName.');
    }

    // Clean up
    calloc.free(shInfo);

    return App(
        appName: exeName,
        appTask: windowTitle,
        createdAt: DateTime.now(),
        iconPath:
            iconPath); // Returning the iconPath (or image data if processed)
  } else {
    print('Failed to get executable name.');
    return null;
  }

  // Clean up
  calloc.free(exePathBuffer);
  CloseHandle(hProcess);
}

Future<String?> extractIcon(String exePath) async {
  // Initialize COM library
  final shell32 = DynamicLibrary.open('shell32.dll');
  final SHGetFileInfo = shell32.lookupFunction<
      IntPtr Function(Pointer<Utf16> pszPath, Uint32 dwFileAttributes,
          Pointer<SHFILEINFO> psfi, Uint32 cbFileInfo, Uint32 uFlags),
      int Function(
          Pointer<Utf16> pszPath,
          int dwFileAttributes,
          Pointer<SHFILEINFO> psfi,
          int cbFileInfo,
          int uFlags)>('SHGetFileInfoW');

  // Allocate memory for SHFILEINFO structure
  final shInfo = calloc<SHFILEINFO>();

  final exePathPtr = exePath.toNativeUtf16();
  final iconPath = await _getIconPath(exePath);

  final res = SHGetFileInfo(
    exePathPtr,
    0,
    shInfo,
    sizeOf<SHFILEINFO>(),
    SHGFI_ICON | SHGFI_LARGEICON,
  );

  calloc.free(exePathPtr);

  if (res != 0) {
    final hIcon = shInfo.ref.hIcon;

    if (hIcon != NULL) {
      final file = File(iconPath);
      if (await file.exists()) {
        calloc.free(shInfo);
        return iconPath;
      } else {
        // Save icon to file using Image package
        await saveIconAsPng(hIcon, iconPath);
        calloc.free(shInfo);
        return iconPath;
      }
    }
  }

  calloc.free(shInfo);
  return null;
}

Future<void> saveIconAsPng(int hIcon, String execName) async {
  // Allocate memory for ICONINFO
  final iconInfo = calloc<ICONINFO>();
  if (GetIconInfo(hIcon, iconInfo) == 0) {
    print("Failed to get icon info.");
    calloc.free(iconInfo);
    return;
  }

  // Get screen DC and compatible DC
  final screenDC = GetDC(NULL);
  final hdc = CreateCompatibleDC(screenDC);

  // Allocate memory for BITMAP structure
  final bm = calloc<BITMAP>();
  if (GetObject(iconInfo.ref.hbmColor, sizeOf<BITMAP>(), bm.cast()) == 0) {
    print("Failed to get bitmap object.");
    calloc.free(bm);
    calloc.free(iconInfo);
    return;
  }

  // Create a new bitmap in memory for the icon image
  final bmpWidth = bm.ref.bmWidth;
  final bmpHeight = bm.ref.bmHeight;
  final bitsPerPixel = 32;

  // Allocate memory for BITMAPINFOHEADER
  final biHeader = calloc<BITMAPINFOHEADER>();
  biHeader.ref.biSize = sizeOf<BITMAPINFOHEADER>();
  biHeader.ref.biWidth = bmpWidth;
  biHeader.ref.biHeight = -bmpHeight; // Negative to indicate a top-down bitmap
  biHeader.ref.biPlanes = 1;
  biHeader.ref.biBitCount = bitsPerPixel;
  biHeader.ref.biCompression = BI_RGB;

  // Allocate memory for the bitmap data
  final bmpData = calloc<Uint8>(bmpWidth * bmpHeight * 4);
  GetDIBits(hdc, iconInfo.ref.hbmColor, 0, bmpHeight, bmpData.cast(),
      biHeader.cast(), DIB_RGB_COLORS);

  // Convert raw bitmap data to a Flutter Image object using the `image` package
  final byteData =
      bmpData.asTypedList(bmpWidth * bmpHeight * 4); // 4 bytes per pixel (ARGB)

// Now pass the buffer of Uint8List to the image package
  final image = img.Image.fromBytes(
    width: bmpWidth,
    height: bmpHeight,
    //TODO: Fix buffer
    bytes: byteData.buffer.asUint8List().buffer,
  );

  // Get the path to the documents directory
  final directory = await getApplicationDocumentsDirectory();

  // Define the path where the PNG file will be saved
  final iconPath = p.join(directory.path, 'icons', '$execName.png');

  // Ensure the 'icons' directory exists
  final dir = Directory(p.join(directory.path, 'icons'));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  // Encode the image as a PNG and save it
  final pngData = img.encodePng(image);
  final file = File(iconPath);
  await file.writeAsBytes(pngData);

  print('Icon saved at $iconPath');

  // Clean up
  DeleteDC(hdc);
  ReleaseDC(NULL, screenDC);
  DeleteObject(iconInfo.ref.hbmColor);
  DeleteObject(iconInfo.ref.hbmMask);
  calloc.free(bmpData);
  calloc.free(bm);
  calloc.free(biHeader);
  calloc.free(iconInfo);
}

// Helper function to get the icon path in the app's directory
Future<String> _getIconPath(String exeName) async {
  final directory = await getApplicationDocumentsDirectory();
  final appName = p.basenameWithoutExtension(exeName);
  final iconPath = p.join(directory.path, 'icons', '$appName.png');
  return iconPath;
}
