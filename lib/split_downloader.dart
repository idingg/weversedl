import 'dart:io'
    show File, FileMode, FileSystemEntityType, Platform, RandomAccessFile;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

List<SplitDownloadTask> _queue = [];
Function? _callBack;

class SplitDownloadTask {
  static const int failed = -1;
  static const int init = 1;
  static const int running = 2;
  static const int complete = 3;
  late int _id;
  int _status = 0;
  int _progress = -1;
  late List<Uri> uriList;
  late final String saveDir;
  late final String saveFilename;
  late final int _uriLength;
  late final RandomAccessFile _fp;
  List<Uint8List> data = [];
  int _downloadSize = 0;
  late DateTime _startTime;
  late DateTime _endTime;

  late String pathAbsolute;

  get id => _id;
  get status => _status;
  get progress => _progress;
  get downloadSize => _downloadSize;
  get startTime => _startTime;
  get endTime => _endTime;

  SplitDownloadTask(dynamic url, this.saveDir, this.saveFilename) {
    pathAbsolute = "$saveDir/$saveFilename";
    if (kDebugMode) {
      print("asdf savepath :$pathAbsolute");
    }

    try {
      File file = File(pathAbsolute);
      if (!file.isAbsolute ||
          file.statSync().type == FileSystemEntityType.directory) {
        throw Exception("Not a file path.");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
        return;
      }
    }

    {
      bool duplicate = false;
      do {
        _id = Random.secure().nextInt(0xFFFFFFF);
        for (SplitDownloadTask item in _queue) {
          if (item.id == id) {
            duplicate = true;
            break;
          }
        }
      } while (duplicate == true);
    }

    if (url.runtimeType == String) {
      uriList = [url];
    } else if (url.runtimeType == List<String>) {
      List<Uri> newuri = List.empty(growable: true);
      for (String item in url) {
        newuri.add(Uri.parse(item));
      }
      uriList = newuri;
    }
    _uriLength = uriList.length;
  }

  Future<Uint8List> getData(Uri uri, {Uint8List? bytes, int? index}) async {
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      if (index != null) {
        data[index] = response.bodyBytes;
      } else {
        return response.bodyBytes;
      }
    }
    return Uint8List(0);
  }

  Future<void> start() async {
    _fp = File(pathAbsolute).openSync(mode: FileMode.writeOnly);
    _status = SplitDownloadTask.running;
    _startTime = DateTime.now();
    _callBack?.call(_id, _status, _progress, this);

    {
      int start = 0;
      int end = Platform.numberOfProcessors;
      int cnt = 0;
      data = List<Uint8List>.generate(
          Platform.numberOfProcessors, (_) => Uint8List(0));
      while (start < _uriLength) {
        List<Future> httptasks = <Future>[];
        List<Uri> listPart =
            uriList.sublist(start, end > _uriLength ? _uriLength : end);
        for (Uri item in listPart) {
          httptasks.add(getData(item, index: listPart.indexOf(item)));
        }
        await Future.wait(httptasks);

        for (int i = 0; i < httptasks.length; i++) {
          try {
            _fp.writeFromSync(data[i]);
          } catch (e) {
            if (kDebugMode) {
              print("File closed");
            }
            return;
          }
          _downloadSize += data[i].length;
          _progress = ++cnt * 100 ~/ _uriLength;
        }

        start = end;
        end += Platform.numberOfProcessors;
        _callBack?.call(id, _status, _progress, this);
        // print("asdf download size : $_downloadSize, (${(_downloadSize >> 20)}MiB)");
      }
    }

    // DateTime test21 = DateTime.now();
    // {
    // RandomAccessFile _fp2 =
    //     File(pathAbsolute + ".(1).ts").openSync(mode: FileMode.writeOnly);
    //   for (var item in uriList) {
    //     //   _data[uriList.indexOf(item)] = await compute(getData, item);
    //     Uint8List tmp = await compute(getData, item);
    //     _downloadSize += tmp.length;
    //     _fp2.writeFromSync(tmp);
    //     _progress = ((uriList.indexOf(item) + 1) / _uriLength * 100).toInt();
    //     _callBack?.call(id, _status, _progress);
    //     if (kDebugMode) {
    //       print(
    //           "asdf download size : $_downloadSize, (${(_downloadSize >> 20)}MiB)");
    //     }
    //   }
    // _fp2.closeSync();
    // }
    // print("asdf time2 : ${DateTime.now().difference(test21)}");

    _fp.closeSync();

    _endTime = DateTime.now();
    _status = SplitDownloadTask.complete;
    _progress = 100;

    _callBack?.call(id, _status, _progress, this);
  }
}

class SplitDownload {
  void registerCallback(Function callBack) {
    _callBack = callBack;
  }

  int enqueue(SplitDownloadTask task) {
    task._status = SplitDownloadTask.init;
    task._progress = 0;

    _callBack?.call(task.id, task.status, task.progress, task);
    _queue.add(task);

    task.start();
    return task.id;
  }

  List<SplitDownloadTask> loadTasks() {
    return _queue;
  }

  void remove(int taskId) {
    for (int i = 0; i < _queue.length; i++) {
      if (_queue[i].id == taskId) {
        try {
          _queue[i]._fp.closeSync();
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
        _queue.removeAt(i);

        // break;
      }
    }
  }

  void removeTaskAll() {
    _queue.clear();
  }

  SplitDownload() {
    // throw UnimplementedError();
  }
}
