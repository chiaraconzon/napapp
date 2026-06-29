import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class MyTaskHandler extends TaskHandler {
  int secondsLeft = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print("🟢 TASK STARTED");
  }

  @override
  void onReceiveData(Object data) {
    print("📩 DATA RECEIVED: $data");
    secondsLeft = data as int;
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    print("⏱️ TICK $secondsLeft");

    secondsLeft--;

    await FlutterForegroundTask.updateService(
      notificationTitle: 'TEST',
      notificationText: '$secondsLeft',
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print("TASK DESTROYED");
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}
