import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
  FlutterForegroundTask.initCommunicationPort();
}

class MyTaskHandler extends TaskHandler {
  int secondsLeft = 0;

  void setDuration(int seconds) {
    secondsLeft = seconds;
  }

  String formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // inizializzazione minima
  }

  @override
  void onReceiveData(Object data) {
    secondsLeft = data as int;
  }

  @override
  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    secondsLeft--;

    await FlutterForegroundTask.updateService(
      notificationTitle: '⏰ Sveglia',
      notificationText: formatTime(secondsLeft),
    );

    if (secondsLeft <= 0) {
      await FlutterForegroundTask.stopService();
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // cleanup (vuoto per ora)
  }
}
