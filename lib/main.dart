import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:background_downloader/background_downloader.dart';

String testUrl = "https://weverse.io/lesserafim/live/2-119098585";
String testUrl2 = "https://weverse.io/fromis9/live/4-123117312";
String testUrl3 = "https://weverse.io/fromis9/live/4-123919171";
String loginUrl =
    "https://account.weverse.io/ko/signup?authType=redirect&client_id=weverse&redirect_uri=https%3A%2F%2Fweverse.io%2FloginResult%3Ftopath%3D%252F";
String loginUrlLessrafim = "https://weverse.io/lesserafim/live";
// Map reqs = {};
// String reqs = "";

const Color colorWeverse = Color.fromARGB(255, 22, 218, 179);

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      kDebugMode &&
      defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  WidgetsFlutterBinding.ensureInitialized();
  // await FlutterDownloader.initialize(
  //     // optional: set to false to disable printing logs to console (default: true)
  //     debug: true,
  //     // option: set to false to disable working with http links (default: false)
  //     ignoreSsl: true);

  runApp(const MaterialApp(
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: MyApp()));
}

// @pragma('vm:entry-point')
// void downloadCallback(String id, int status, int progress) async {
//   final SendPort? send =
//       IsolateNameServer.lookupPortByName("downloader_send_port");
//   send!.send([id, status, progress]);
//   print("asdf callback: $id, $status, $progress");
//   if (status == DownloadTaskStatus.complete.index) {
//     print("asdf callback $id : Downloaded");
//     await FlutterDownloader.remove(taskId: id);
//   } else {
//     // print("$id, $status, $progress");
//   }
//   // ResourcesPathHandler
// }

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;

  List<String> grantedSavePath = [];
  Map<String, String> reqs = {};
  PermissionStatus? storagePermission;
  PermissionStatus? notificationPermission;

  int webviewProgrss = -1;
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    // IsolateNameServer.registerPortWithName(
    //     _port.sendPort, 'downloader_send_port');
    // _port.listen((dynamic data) {
    //   String id = data[0];
    //   DownloadTaskStatus status = data[1];
    //   int progress = data[2];
    //   setState(() {});
    // });

    // FlutterDownloader.registerCallback(downloadCallback);

    super.initState();
  }

  void doDownload(
      {required List<dynamic> tsurls,
      required String? savepath,
      int filesize = -1,
      String filename = ""}) async {
    // var tasks = await FlutterDownloader.loadTasks();
    // for (var item in tasks!) {
    //   print("asdf : $item");
    // }
    // tasks = await FlutterDownloader.loadTasks();
    // for (var item in tasks!) {
    //   print("asdf : $item");
    //   FlutterDownloader.remove(taskId: item.taskId);
    // }
    // tasks = await FlutterDownloader.loadTasks();
    // var aaaa = await FlutterDownloader.loadTasks();
    // url =
    //     "https://static-cdn.jtvnw.net/jtv_user_pictures/db7e5db1-c9bc-4991-8529-57e04f38430b-profile_image-70x70.png";
    //write file
    String filenameFromUrl = tsurls[0].split("/").last.split("?").first;
    String filenameAbs = "${savepath!}/$filenameFromUrl";

    // if (kDebugMode) {
    //   print(
    //       "asdf : $storagePermission\n${DateTime.now()}\n$url\n${"-" * 40}\n$filesize, ${filesize >> 20}MiB\n${"-" * 40}\n$savepath");
    // }
    // showMySnackbar(
    //     "$storagePermission\n${DateTime.now()}\n$url\n${"-" * 40}\n$filesize, ${filesize >> 20}MiB\n${"-" * 40}\n$filenameAbs");
    print("asdf do download: ${tsurls[0] + ", " + tsurls[1]}");
    List<dynamic>? listTasks = List.empty(growable: true);
    // print("asdf");
    // for (var item in tsurls) {
    //   listTasks.add(DownloadTask(
    //     url: item,
    //     filename: item.split("/").last.split("?").first,
    //     directory: savepath,
    //     updates:
    //         Updates.statusAndProgress, // request status and progress updates
    //     requiresWiFi: false,
    //     retries: 5,
    //     allowPause: true,
    //     // metaData: 'data for me',
    //   ));
    // }
    // listTasks;
    //

    // final alltasks = await FlutterDownloader.loadTasks();
    int restart = -1;
    String restartTaskId = "";
    bool alreadyexsist = false;
    // for (var item in alltasks!)
    {
      // if (kDebugMode) {
      //   print("asdf filename : ${item.filename}");
      // }
      // if (item.status == DownloadTaskStatus.complete ||
      //     item.status == DownloadTaskStatus.failed) {
      //   print("asdf remove : $item.taskId");
      //   FlutterDownloader.remove(taskId: item.taskId);
      // } else if (item.status == DownloadTaskStatus.running &&
      //     item.filename == filenameFromUrl)

      // {
      //   if (mounted) {
      //     await showDialog(
      //         context: context,
      //         builder: (BuildContext context) {
      //           return AlertDialog(
      //             // title: Text('제목'),
      //             content: const SingleChildScrollView(
      //               child: ListBody(
      //                 //List Body를 기준으로 Text 설정
      //                 children: <Widget>[
      //                   Text("Already downloading.\nRestart?"),
      //                 ],
      //               ),
      //             ),
      //             actions: [
      //               TextButton(
      //                 child: const Text('Yes'),
      //                 onPressed: () {
      //                   Navigator.of(context).pop();
      //                   restart = 1;
      //                 },
      //               ),
      //               TextButton(
      //                 child: const Text('No'),
      //                 onPressed: () {
      //                   Navigator.of(context).pop();
      //                   restart = 0;
      //                 },
      //               ),
      //             ],
      //           );
      //         });
      //   }

      //   // break;
      // }
    }
    // ignore: curly_braces_in_flow_control_structures
    if (restart == 1 || restart == -1) {
      // ignore: curly_braces_in_flow_control_structures
      if (restart == 1) {
        if (kDebugMode) {
          print("asdf restart : $restart");
        }
        // FlutterDownloader.remove(taskId: restartTaskId);
      }
      restart = -1;
      File file = File(filenameAbs);
      if (file.existsSync()) {
        if (mounted) {
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  // title: Text('제목'),
                  content: const SingleChildScrollView(
                    child: ListBody(
                      //List Body를 기준으로 Text 설정
                      children: <Widget>[
                        Text("File exsist.\nDownload again?"),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        restart = 1;
                      },
                    ),
                    TextButton(
                      child: const Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        restart = 0;
                      },
                    ),
                  ],
                );
              });
        }
      }
      if (restart == 1 || restart == -1) {
        if (file.existsSync() && restart == 1) {
          await file.delete();
        }
        // final taskId =
        // await FlutterDownloader.enqueue(
        //   url: url,
        //   headers: {}, // optional: header send with url (auth token etc)
        //   savedDir: "$savepath/",
        //   fileName:
        //       "${filename}_$filenameFromUrl", //url.split("/").last.split("?").first,
        //   // show download progress in status bar (for Android)
        //   showNotification: true,
        //   // click on notification to open downloaded file (for Android)
        //   openFileFromNotification: true,
        //   allowCellular: true,
        //   // saveInPublicStorage: true,
        // );
      }
    }
  }

  void showMySnackbar(String msg) async {
    if (mounted) {
      const int maxlen = 1000;
      final int timeSec = msg == "No video." ? 1 : 5;
      var snackBar = SnackBar(
        content:
            Text(msg.substring(0, msg.length < maxlen ? msg.length : maxlen)),
        // backgroundColor: Colors.black.withOpacity(0.8),
        backgroundColor: Theme.of(context).shadowColor.withOpacity(0.8),
        showCloseIcon: true,
        closeIconColor: Theme.of(context).primaryColorLight,
        duration: Duration(seconds: timeSec, milliseconds: 0),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      if (kDebugMode) {
        print("asdf snackbar msg: $msg");
      }
    }
  }

  void onDownloadBtnPressed() async {
    if (kDebugMode) {
      print("asdf now url ${await webViewController!.getUrl()}");
      print("asdf origin url ${reqs["originurl"]}");
      print("asdf data url ${reqs["dataurl"]}");
      print("asdf permi 1 ${storagePermission.toString()}");
    }
    String printString = "";
    try {
      if (reqs.isNotEmpty &&
          reqs["originurl"] == (await webViewController!.getUrl()).toString()) {
        printString = "Valid video url";
      } else {
        printString = "No video.";
        showMySnackbar(printString);
      }
    } catch (e) {
      printString = "$e";
    }
    // showMySnackbar(printString);

    try {
      if (reqs["dataurl"]!.isNotEmpty) {
        http.Response response = await http.get(Uri.parse(reqs["dataurl"]!));
        if (response.statusCode == 200) {
          List<dynamic> listResolution = RegExp(r"[^=]*m3u8(?!\.m3u8)")
              .allMatches(String.fromCharCodes(response.bodyBytes))
              .toList();
          listResolution.sort((i, j) =>
              int.parse(j[0]!.toString().split("\n").first.split("x").first)
                  .compareTo(int.parse(
                      i[0]!.toString().split("\n").first.split("x").first)));
          String maxm3u8url = reqs["dataurl"]!.replaceFirst(
              RegExp(r"[^/]*m3u8(?!.*\/[^/]*m3u8)"),
              listResolution[0][0]!.split("\n")[1]);
          print("asdf max resol m3u8 : $maxm3u8url");
          response = await http.get(Uri.parse(maxm3u8url));
          if (response.statusCode == 200) {
            List<dynamic> listtsFile = RegExp(r".*\.ts.*")
                .allMatches(String.fromCharCodes(response.bodyBytes))
                .toList();
            List<String> listtsurl = [];
            for (var item in listtsFile) {
              // print("asdf ts files: " + item[0]);
              // print(
              //     "asdf ts url : ${reqs["dataurl"]!.replaceFirst(RegExp(r"[^/]*m3u8(?!.*\/[^/]*m3u8)"), item[0])}");
              listtsurl.add(reqs["dataurl"]!.replaceFirst(
                  RegExp(r"[^/]*m3u8(?!.*\/[^/]*m3u8)"), item[0]));
            }

            if (listtsurl.isNotEmpty) {
              var downloadUrl = listtsurl;
              // int downloadSize = -1;
              // downloadUrl = videolist[0]["source"];
              // downloadSize = videolist[0]["size"];
              if (notificationPermission != PermissionStatus.granted) {
                requestNotificationsPermission();
              }
              if (storagePermission != PermissionStatus.granted) {
                await requestStoragePermission();
                print("asdf permi 2 ${storagePermission.toString()}");
              }
              if (storagePermission == PermissionStatus.granted &&
                  notificationPermission == PermissionStatus.granted) {
                //pick dir
                String selectedDirectory = "";
                if (grantedSavePath.isEmpty) {
                  if (mounted) {
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            // title: Text('제목'),
                            content: const SingleChildScrollView(
                              child: ListBody(
                                //List Body를 기준으로 Text 설정
                                children: <Widget>[
                                  Text("Select directory."),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              // TextButton(
                              //   child: const Text('취소'),
                              //   onPressed: () {
                              //     Navigator.of(context).pop();
                              //   },
                              // ),
                            ],
                          );
                        });

                    selectedDirectory = await getSaveDirPath();
                  }
                } else {
                  selectedDirectory =
                      grantedSavePath[grantedSavePath.length - 1];
                }
                if (selectedDirectory != "Access denied") {
                  doDownload(
                      tsurls: downloadUrl,
                      savepath: selectedDirectory,
                      // filesize: downloadSize,
                      filename:
                          downloadUrl[0].split("/").last.split("?").first);
                }
              } else {
                showMySnackbar("permission denied. Try again.");
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("err : $e");
      }
    }
  }

  Future<String> getSaveDirPath() async {
    if (storagePermission != PermissionStatus.granted) {
      await requestStoragePermission();
    }
    if (storagePermission == PermissionStatus.granted) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == "/") {
        return "Access denied";
      }

      if (selectedDirectory != null &&
          !grantedSavePath.contains(selectedDirectory)) {
        grantedSavePath.add(selectedDirectory);
        return selectedDirectory;
      }
    }
    return "Access denied";
  }

  Future<PermissionStatus?> requestStoragePermission() async {
    final AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;

    if (androidInfo.version.sdkInt <= 32) {
      /// use [Permissions.storage.status]
      storagePermission = await Permission.storage.request();
    } else {
      /// use [Permissions.photos.status]
      storagePermission = await Permission.manageExternalStorage.request();
    }
    return storagePermission!;
  }

  Future<PermissionStatus?> requestNotificationsPermission() async {
    if (notificationPermission != PermissionStatus.granted) {
      notificationPermission = await Permission.notification.request();
    }
    if (notificationPermission == PermissionStatus.permanentlyDenied &&
        mounted) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              // title: Text('제목'),
              content: const SingleChildScrollView(
                child: ListBody(
                  //List Body를 기준으로 Text 설정
                  children: <Widget>[
                    Text("Allow notification permission"),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    openAppSettings();
                  },
                ),
                // TextButton(
                //   child: const Text('취소'),
                //   onPressed: () {
                //     Navigator.of(context).pop();
                //   },
                // ),
              ],
            );
          });
    }
    return notificationPermission;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await webViewController!.canGoBack()) {
          webViewController!.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Align(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(testUrl3),
                  ),
                  initialSettings: InAppWebViewSettings(
                      userAgent:
                          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36 Edg/115.0.1901.188"),
                  shouldInterceptRequest: (controller, request) async {
                    String nowurl =
                        (await webViewController!.getUrl()).toString();
                    if (reqs["originurl"] != nowurl &&
                        // request.url.toString().contains("rmcnmv") &&
                        // request.url.toString().contains("key")) {
                        reqs["dataurl"] == null &&
                        request.url.toString().contains(".m3u8")) {
                      reqs["dataurl"] = request.url.toString();
                      // print("asdf : dataurl" + reqs["dataurl"]);
                      reqs["originurl"] =
                          (await webViewController!.getUrl()).toString();
                    }
                    return null;
                    // return null;
                  },
                  onProgressChanged: (controller, progress) async {
                    webviewProgrss = progress;
                    print("asdf onProgressChanged:$progress");
                    if (reqs.isNotEmpty) {
                      reqs.clear();
                    }
                    while (await controller.zoomOut()) {}
                    // if (reqs.isNotEmpty && progress < 50) {
                    //	 reqs.clear();
                    // }
                    // else if (progress > 99) {
                    //	 while (await controller.zoomOut()) {}
                    // }
                    // while (await controller.zoomOut()) {}
                  },
                  onLoadResource: (controller, res) async {
                    if (webviewProgrss < 100) {
                      print(
                          "asdf onLoadResource: $webviewProgrss, ${res.url.toString()}");
                      while (await controller.zoomOut()) {}
                    }
                    // if (res.url.toString().contains(".ts") != true &&
                    //     res.url.toString().contains(".m3u8") != true) {
                    //   print("asdf onLoadResource:${res.url.toString()}");
                    //   while (await controller.zoomOut()) {}
                    // }
                  },
                  onTitleChanged: (controller, str) async {
                    // print("asdf " + str!);
                    if (reqs.isNotEmpty) {
                      reqs.clear();
                    }
                    while (await controller.zoomOut()) {}
                  },
                  onWebViewCreated: (controller) async {
                    webViewController = controller;
                  },
                  key: webViewKey,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: FloatingActionButton(
                  onPressed: onDownloadBtnPressed,
                  backgroundColor: colorWeverse,
                  child: const Icon(Icons.download),
                ),
              ),
              Align(
                alignment:
                    Alignment(Alignment.topRight.x - 0.4, Alignment.topRight.y),
                child: FloatingActionButton(
                  onPressed: getSaveDirPath,
                  backgroundColor: colorWeverse,
                  child: const Icon(Icons.folder),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
