import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
<<<<<<< Updated upstream
import 'package:flutter_downloader/flutter_downloader.dart';
=======
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_filex/open_filex.dart';

import 'package:weversedl/split_downloader.dart';
import 'package:weversedl/noti.dart';
>>>>>>> Stashed changes

String testUrl = "https://weverse.io/lesserafim/live/2-119098585";
String testUrl2 = "https://weverse.io/fromis9/live/4-123117312";
String loginUrl =
    "https://account.weverse.io/ko/signup?authType=redirect&client_id=weverse&redirect_uri=https%3A%2F%2Fweverse.io%2FloginResult%3Ftopath%3D%252F";
String loginUrlLessrafim = "https://weverse.io/lesserafim/live";
//String loginUrlLessrafim = "https://weverse.io/fromis9/live/4-123117312";

const Color colorWeverse = Color.fromARGB(255, 22, 218, 179);
// Function? _snackBar;
SplitDownload downloader = SplitDownload();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      kDebugMode &&
      defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

<<<<<<< Updated upstream
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      // optional: set to false to disable printing logs to console (default: true)
      debug: true,
      // option: set to false to disable working with http links (default: false)
      ignoreSsl: true);
=======
  // WidgetsFlutterBinding.ensureInitialized();
  // await FlutterDownloader.initialize(
  //     // optional: set to false to disable printing logs to console (default: true)
  //     debug: true,
  //     // option: set to false to disable working with http links (default: false)
  //     ignoreSsl: true);
>>>>>>> Stashed changes

  runApp(const MaterialApp(
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: MyApp()));
}

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) async {
  final SendPort? send =
      IsolateNameServer.lookupPortByName("downloader_send_port");
  send!.send([id, status, progress]);
  print("asdf callback: $id, $status, $progress");
  if (status == DownloadTaskStatus.complete.index) {
    print("asdf callback $id : Downloaded");
    await FlutterDownloader.remove(taskId: id);
  } else {
    // print("$id, $status, $progress");
  }
  // ResourcesPathHandler
}

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

  late SharedPreferences _prefs; // SharedPreferences 객체
  List<String> _key = [];
  int webviewProgrss = -1;
  // final ReceivePort _port = ReceivePort();
  Map<int, List<dynamic>> listLastDownloadStatus = {};

  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

<<<<<<< Updated upstream
    FlutterDownloader.registerCallback(downloadCallback);
=======
    // FlutterDownloader.registerCallback(downloadCallback);
    downloader.registerCallback(taskCallback);
    // _snackBar = showMySnackbar;
>>>>>>> Stashed changes

    _initSharedPreferences();
    initNotification();
  }

  // SharedPreferences 초기화 함수
  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 데이터를 저장하는 함수
  Future<void> _saveData(List<String> list) async {
    await _prefs.setStringList('key', list); // 'myData' 키에 데이터 저장
    if (kDebugMode) {
      print("asdf save key : $list");
    }
  }

  // 데이터를 로드하는 함수
  List<String> _loadData() {
    List<String> tmp = [];
    if (_prefs.containsKey('key')) {
      tmp = _prefs.getStringList('key')!;
    }
    if (tmp.runtimeType == List<String>) {
      _key = _prefs.getStringList('key')!; // 'myData' 키에 저장된 데이터 로드
      if (kDebugMode) {
        print("asdf load key : $_key");
      }
      // grantedSavePath = _key!;
    } else {
      _prefs.remove('key');
      _key = [];
    }

    return _key;
  }

  @pragma('vm:entry-point')
  void notiCallBack(NotificationResponse details) {
    if (details.payload != null && details.payload!.startsWith("/")) {
      print("OpenFilex.open : ${details.payload}");
      OpenFilex.open("${details.payload}", type: "video/mp4");
    } else if (details.payload != null) {
      int progress = int.tryParse(details.payload!) ?? -1;
      if (mounted && progress >= 0) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                // title: Text('제목'),
                content: const SingleChildScrollView(
                  child: ListBody(
                    //List Body를 기준으로 Text 설정
                    children: <Widget>[
                      Text("Stop Download?"),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      downloader.remove(details.id!);
                      cancelNotification(details.id!);
                    },
                  ),
                  TextButton(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      }
    }
  }

  @pragma('vm:entry-point')
  void taskCallback(
      int taskId, int status, int progress, SplitDownloadTask task) {
    setNotiCallBack(notiCallBack);
    Future<List<ActiveNotification>> notiList = getNotifications();
    notiList.then((value) {
      for (ActiveNotification noti in value) {
        bool isRunningTask = false;
        for (SplitDownloadTask task in downloader.loadTasks()) {
          if (noti.id == task.id) {
            isRunningTask = true;
            break;
          }
        }
        if (isRunningTask == false) {
          cancelNotification(noti.id!);
          print("asdf cancel noti : ${noti.id}");
        }
      }
    });

    if (kDebugMode) {
      print(
          "asdf callback: ${DateTime.now()}, $taskId, $status, $progress, ${task.downloadSize}");
    }
    String filenameWithoutExt =
        task.saveFilename.substring(0, task.saveFilename.lastIndexOf(".ts"));
    if (status == SplitDownloadTask.init) {
      showNotification(taskId, filenameWithoutExt, "");
    } else if (status == SplitDownloadTask.running) {
      String speedStr = "";
      try {
        if (listLastDownloadStatus[taskId] != null) {
          DateTime lastTime = listLastDownloadStatus[taskId]![0];
          int downloadSize =
              task.downloadSize - (listLastDownloadStatus[taskId]![1]);
          speedStr = (downloadSize /
                  ((DateTime.now().difference(lastTime)).inMilliseconds * 1000))
              .toStringAsFixed(2);
        }
      } catch (e) {}
      showNotification(taskId, filenameWithoutExt, "$progress% ${speedStr}MiB/s",
          progress: progress);
      try {
        listLastDownloadStatus[taskId] = [DateTime.now(), task.downloadSize];
      } catch (e) {}
    } else if (status == SplitDownloadTask.complete) {
      // _snackBar!("Download complete. $speedstr MiB/s");

      showNotification(taskId, filenameWithoutExt,
          "Finish. ${((task.downloadSize >> 20) / task.endTime.difference(task.startTime).inMilliseconds * 1000).toStringAsFixed(2)}MiB/s",
          filepath: task.pathAbsolute);
    }
  }

  void doDownload(
<<<<<<< Updated upstream
      {required String url,
      required String? savepath,
=======
      {required List<String> tsurls,
      required String savepath,
>>>>>>> Stashed changes
      int filesize = -1,
      String filename = ""}) async {
    // var tasks = downloader.loadTasks();
    // for (var item in tasks) {
    //   print("asdf : ${await item}");
    //   downloader.remove(item.id);
    // }
    // tasks = downloader.loadTasks();

    //write file
<<<<<<< Updated upstream
    String filenameFromUrl = url.split("/").last.split("?").first;
    String filenameAbs = "${savepath!}/$filenameFromUrl";

    if (kDebugMode) {
      print(
          "asdf : $storagePermission\n${DateTime.now()}\n$url\n${"-" * 40}\n$filesize, ${filesize >> 20}MiB\n${"-" * 40}\n$savepath");
    }
    showMySnackbar(
        "$storagePermission\n${DateTime.now()}\n$url\n${"-" * 40}\n$filesize, ${filesize>> 20}MiB\n${"-" * 40}\n$filenameAbs");

    final alltasks = await FlutterDownloader.loadTasks();
    int restart = -1;
    String restartTaskId = "";
    // bool alreadyexsist = false;
    for (var item in alltasks!) {
      if (kDebugMode) {
        print("asdf filename : ${item.filename}");
      }
      if (item.status == DownloadTaskStatus.complete ||
          item.status == DownloadTaskStatus.failed) {
        print("asdf remove : $item.taskId");
        FlutterDownloader.remove(taskId: item.taskId);
      } else if (item.status == DownloadTaskStatus.running &&
          item.filename == filenameFromUrl) {
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
                        Text("Already downloading.\nRestart?"),
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

        break;
=======
    String filenameFromUrl = tsurls[0].split("/").last.split("?").first;
    String filenameAbsolute = "";
    String newfilename = "";
    if (filename.contains(" - ")) {
      List<String> tmp = filename.split(" - ");
      String date = tsurls[0].substring(
          tsurls[0].indexOf("/weverse_20") + "/weverse_".length,
          tsurls[0].indexOf("/weverse_20") + "weverse_2023_06_28_".length + 1);

      {
        String html = "";
        await webViewController?.getHtml().then((value) => {html = value!});
        html = html.substring(html.indexOf("HeaderView_info__"));
        var tmp = RegExp(r"(?<=HeaderView_info__.*)\d{2}\.\d{2}\. \d{2}:\d{2}")
            .firstMatch(html)!;
        reqs["time"] = tmp[0]!.split(" ")[1].replaceFirst(":", ".");
      }
      newfilename =
          "${tmp[1]}-${date.replaceAll("_", ".")}${reqs["time"]!}-${tmp[0]}.ts";
    }
    filenameAbsolute =
        "$savepath/${newfilename != "" ? newfilename : filenameFromUrl}";

    // if (kDebugMode) {
    //   print(
    //       "asdf : $storagePermission\n${DateTime.now()}\n$url\n${"-" * 40}\n$filesize, ${filesize >> 20}MiB\n${"-" * 40}\n$savepath");
    // }

    // print("asdf do download: ${tsurls[0] + ", " + tsurls[1]}");

    final alltasks = downloader.loadTasks();
    int restart = -1;
    // int fileexists = -1;
    int restartTaskId = -1;
    bool alreadyRunning = false;
    // for (SplitDownloadTask item in List.from(alltasks)) {
    {
      List tmp = List.from(alltasks);
      for (int i = 0; i < tmp.length; i++) {
        SplitDownloadTask item = tmp[i];
        if (item.status == SplitDownloadTask.running &&
            item.saveFilename ==
                (newfilename != "" ? newfilename : filenameFromUrl)) {
          alreadyRunning = true;
        }
        if (alreadyRunning && mounted) {
          await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                // title: Text('제목'),
                content: SingleChildScrollView(
                  child: ListBody(
                    //List Body를 기준으로 Text 설정
                    children: <Widget>[
                      Text("Already downloading. ${item.progress}%"),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text('Restart'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      restartTaskId = item.id;
                      restart = 1;
                    },
                  ),
                  TextButton(
                    child: const Text('Cancel it'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      downloader.remove(item.id);
                      cancelNotification(item.id);
                      restart = 0;
                    },
                  ),
                  TextButton(
                    child: const Text('Keep going'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      restart = 0;
                    },
                  ),
                ],
              );
            },
          );
        }
>>>>>>> Stashed changes
      }
    }
    if (restart == 1 || restart == -1) {
      if (restart == 1) {
        if (kDebugMode) {
          print("asdf restart : $restart");
        }
<<<<<<< Updated upstream
        FlutterDownloader.remove(taskId: restartTaskId);
=======
        // FlutterDownloader.remove(taskId: restartTaskId);
        downloader.remove(restartTaskId);
        cancelNotification(restartTaskId);
>>>>>>> Stashed changes
      }
      // restart = -1;
      File file = File(filenameAbsolute);
      if (restart != 1 && file.existsSync()) {
        restart = -1;
        if (mounted) {
          await showDialog(
              barrierDismissible: false,
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
<<<<<<< Updated upstream
        // final taskId =
        await FlutterDownloader.enqueue(
          url: url,
          headers: {}, // optional: header send with url (auth token etc)
          savedDir: "$savepath/",
          fileName:
              "${filename}_$filenameFromUrl", //url.split("/").last.split("?").first,
          // show download progress in status bar (for Android)
          showNotification: true,
          // click on notification to open downloaded file (for Android)
          openFileFromNotification: true,
          allowCellular: true,
          // saveInPublicStorage: true,
        );
=======
        downloader.enqueue(SplitDownloadTask(tsurls, savepath,
            newfilename != "" ? newfilename : filenameAbsolute));

        // showMySnackbar(
        //     "$savepath/${newfilename != "" ? newfilename : filenameAbsolute}");
>>>>>>> Stashed changes
      }
    }
  }

  void showMySnackbar(String msg) async {
    if (mounted) {
      const int maxlen = 1000;
      final int timeSec = (msg == "No video." ? 1 : 3);
      var snackBar = SnackBar(
        content:
            Text(msg.substring(0, msg.length < maxlen ? msg.length : maxlen)),
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

    try {
      if (reqs["dataurl"]!.isNotEmpty) {
        http.Response response = await http.get(Uri.parse(reqs["dataurl"]!));
        if (response.statusCode == 200) {
<<<<<<< Updated upstream
          List videolist = jsonDecode(response.body)["videos"]["list"];
          if (videolist.toString() != "null") {
            String downloadUrl = "";
            int downloadSize = -1;
            videolist.sort((i, j) => j["size"].compareTo(i["size"]));
            downloadUrl = videolist[0]["source"];
            downloadSize = videolist[0]["size"];
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
=======
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
          if (kDebugMode) {
            print("asdf max resol m3u8 : $maxm3u8url");
          }

          response = await http.get(Uri.parse(maxm3u8url));
          if (response.statusCode == 200) {
            List<dynamic> listtsFile = RegExp(r".*\.ts.*")
                .allMatches(String.fromCharCodes(response.bodyBytes))
                .toList();
            List<String> listtsurl = [];
            for (var item in listtsFile) {
              listtsurl.add(reqs["dataurl"]!.replaceFirst(
                  RegExp(r"[^/]*m3u8(?!.*\/[^/]*m3u8)"), item[0]));
            }

            if (listtsurl.isNotEmpty) {
              var downloadUrl = listtsurl;
              if (notificationPermission != PermissionStatus.granted) {
                requestNotificationsPermission();
              }
              if (storagePermission != PermissionStatus.granted) {
                await requestStoragePermission();
                if (kDebugMode) {
                  print("asdf permi 2 ${storagePermission.toString()}");
                }
              }
              if (storagePermission == PermissionStatus.granted &&
                  notificationPermission == PermissionStatus.granted) {
                //pick dir
                String selectedDirectory = "";
                if (_prefs.containsKey("key")) {
                  _key = _loadData();
                  grantedSavePath = _key;
                }
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
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
                  selectedDirectory = await getSaveDirPath();
=======
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
                    // filename: downloadUrl[0].split("/").last.split("?").first,
                    filename: reqs["title"] ??
                        downloadUrl[0].split("/").last.split("?").first,
                  );
>>>>>>> Stashed changes
                }
              } else {
                selectedDirectory = grantedSavePath[grantedSavePath.length - 1];
              }
              if (selectedDirectory != "Access denied") {
                doDownload(
                    url: downloadUrl,
                    savepath: selectedDirectory,
                    filesize: downloadSize,
                    filename: downloadUrl
                        .split("/")
                        .elementAt(downloadUrl.split("/").length - 2));
              }
            } else {
              showMySnackbar("permission denied. Try again.");
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

      if (selectedDirectory != null) {
        if (!grantedSavePath.contains(selectedDirectory)) {
          grantedSavePath.add(selectedDirectory);
        } else {
          grantedSavePath.remove(selectedDirectory);
          grantedSavePath.add(selectedDirectory);
        }
        _saveData(grantedSavePath);
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
                    url: WebUri(loginUrlLessrafim),
                  ),
                  initialSettings: InAppWebViewSettings(
                      userAgent:
                          "Mozilla/5.0 (windows nt 10.0 win64 x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36 Edg/115.0.1901.188"),
                  shouldInterceptRequest: (controller, request) async {
                    String nowurl =
                        (await webViewController!.getUrl()).toString();
                    if (reqs["originurl"] != nowurl &&
                        request.url.toString().contains("rmcnmv") &&
                        request.url.toString().contains("key")) {
                      reqs["dataurl"] = request.url.toString();
                      reqs["originurl"] =
                          (await webViewController!.getUrl()).toString();
                    }
                    return null;
                  },
                  onProgressChanged: (controller, progress) async {
                    webviewProgrss = progress;
                    if (kDebugMode) {
                      print("asdf onProgressChanged:$progress");
                    }
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
                      if (kDebugMode) {
                        print(
                            "asdf onLoadResource: $webviewProgrss, ${res.url.toString()}");
                      }
                      while (await controller.zoomOut()) {}
                    }
                    // if (res.url.toString().contains(".ts") != true &&
                    //     res.url.toString().contains(".m3u8") != true) {
                    //   print("asdf onLoadResource:${res.url.toString()}");
                    //   while (await controller.zoomOut()) {}
                    // }
                  },
                  onTitleChanged: (controller, title) async {
                    // print("asdf " + str!);
                    if (reqs.isNotEmpty) {
                      reqs.clear();
                    }
                    {
                      int lastIndex = title!.lastIndexOf(" Weverse");
                      reqs["title"] =
                          title.substring(0, lastIndex < 0 ? 0 : lastIndex);
                      reqs["title"] =
                          reqs["title"]!.replaceAll(RegExp(r"[<>:/\|?*]"), '');
                      // reqs["title"] = reqs["title"]!.replaceAll(emojiregex.reg, '');
                      print(
                          "asdf title :${reqs["title"]}, ${reqs['title']?.length}");
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
                // alignment: Alignment.topRight,
                alignment: Alignment(
                    Alignment.topRight.x - 0.05, Alignment.topRight.y + 0.025),
                child: FloatingActionButton(
                  onPressed: onDownloadBtnPressed,
                  backgroundColor: colorWeverse,
                  child: const Icon(Icons.download),
                ),
              ),
              Align(
                alignment: Alignment(
                    Alignment.topRight.x - 0.45, Alignment.topRight.y + 0.025),
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
