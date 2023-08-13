import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final notifications = FlutterLocalNotificationsPlugin();
late Function _notiCallBack;

void setNotiCallBack(Function notiCallBack) {
  _notiCallBack = notiCallBack;
}

@pragma('vm:entry-point')
void notificationTap(NotificationResponse details) {
  _notiCallBack(details);
}

//1. 앱로드시 실행할 기본설정
initNotification() async {
  //안드로이드용 아이콘파일 이름
  var androidSetting = const AndroidInitializationSettings('icon_t');

  //ios에서 앱 로드시 유저에게 권한요청하려면
  var iosSetting = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  var initializationSettings =
      InitializationSettings(android: androidSetting, iOS: iosSetting);
  await notifications.initialize(
    initializationSettings,
    //알림 누를때 함수실행하고 싶으면
    //onSelectNotification: 함수명추가
    onDidReceiveNotificationResponse: notificationTap,
    onDidReceiveBackgroundNotificationResponse: notificationTap,
  );
}

//2. 이 함수 원하는 곳에서 실행하면 알림 뜸
showNotification(int id, String title, String body,
    {int? progress, String? filepath}) async {
  late AndroidNotificationDetails androidDetails;
  if (filepath != null) {
    androidDetails = const AndroidNotificationDetails(
      'com.idingg.weversedl',
      'download',
      // priority: Priority.high,
      // importance: Importance.max,
      priority: Priority.min,
      importance: Importance.none,
      color: Color.fromARGB(255, 22, 218, 179),
      playSound: false,
      enableVibration: false,
      //   fullScreenIntent: true,
      //   visibility: NotificationVisibility.public,
      onlyAlertOnce: true,
    );
  } else {
    //running
    androidDetails = AndroidNotificationDetails(
      'com.idingg.weversedl',
      'download',
      // priority: Priority.high,
      // importance: Importance.max,
      category: AndroidNotificationCategory.progress,
      //   priority: Priority.min,
      //   importance: Importance.none,
      color: const Color.fromARGB(255, 22, 218, 179),
      playSound: false,
      enableVibration: false,
      //   fullScreenIntent: true,
      //   visibility: NotificationVisibility.public,
      onlyAlertOnce: true,
      ongoing: true,
      autoCancel: false,
      showProgress: true,
      maxProgress: 100,
      progress: progress ?? -1,
      //   indeterminate: true,
    );
  }

  var iosDetails = const DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: false,
    presentSound: false,
  );
  final NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails, iOS: iosDetails);

  // 알림 id, 제목, 내용 맘대로 채우기
  await notifications.show(id, title, body, notificationDetails,
      payload: filepath ?? (progress != null ? progress.toString() : ""));
}

void cancelNotification(int id) {
  notifications.cancel(id);
}

Future<List<ActiveNotification>> getNotifications() {
  return notifications.getActiveNotifications();
}
