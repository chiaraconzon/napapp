import 'package:napapp/services/impact.dart';
import 'package:intl/intl.dart';

class SleepData {
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? minutesAsleep;

  SleepData({required this.date, required this.startTime, required this.endTime, required this.minutesAsleep});

  SleepData.fromJson(String date, Map<String, dynamic> json) :
      date = DateFormat('yyyy-MM-dd').parse(date),
      // "startTime": "05-03 22:20:00"
      startTime = _timeWithYear(date, json["startTime"]),
      endTime = _timeWithYear(date, json["endTime"]),
      minutesAsleep = json["minutesAsleep"];

  SleepData.missingData(String date) :
    date = DateFormat('yyyy-MM-dd').parse(date),
    startTime = null,
    endTime = null,
    minutesAsleep = null;

  static DateTime _timeWithYear(String date, String dateTimeWithoutYear) {
    String year = date.substring(0,4);
    // controllo per il caso 1 gennaio, nel quale startTime sarà nell'anno precedente
    if (date.substring(5,10) == "01-01") {
      year = (int.parse(year) - 1).toString();
    }
    String toParse = "$year-$dateTimeWithoutYear";
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(toParse);
  }

  @override
  String toString() {
    return 
"""
date : $date
startTime : $startTime
endTime : $endTime
minutesAsleep : $minutesAsleep
""";
  }

  String queryString() {
    return date.toString().substring(0, 10);
  }
}

class RecentSleep {
  final DateTime recentDay;
  final List<int?> sleepDuration;
  final DateTime? wakeUpTime;

  RecentSleep({required this.recentDay, required this.sleepDuration, required this.wakeUpTime});

  // RecentSleep.fromSleepData(List<SleepData> sleepList) {
  //   if (sleepList.length < 7) throw Exception("Can't create recent sleep data with less than 7 days of data.");
  //   List<SleepData> recent = sleepList.sublist(0,7); 

  //   DateTime recentDay = recent[0].date;
  //   DateTime? wakeUpTime = recent[0].endTime;

  //   List<int?> sleepDuration = [];
  //   for (int i = 0; i < 7; i++) {
  //     sleepDuration.add(recent[i].minutesAsleep);
  //   }

  //   RecentSleep(recentDay: recentDay, sleepDuration: sleepDuration, wakeUpTime: wakeUpTime);
  // }

  static Future<RecentSleep> create() async {
    List<SleepData> recent = await Impact.getN_DaysFromMostRecent(7);
    DateTime recentDay = recent[0].date;
    DateTime? wakeUpTime = recent[0].endTime;

    List<int?> sleepDuration = [];
    for (int i = 0; i < 7; i++) {
      sleepDuration.add(recent[i].minutesAsleep);
    }

    return RecentSleep(recentDay: recentDay, sleepDuration: sleepDuration, wakeUpTime: wakeUpTime);
  }

  @override
  String toString() {
    return 
"""
day : $recentDay
sleep durations in minutes in previous 7 days :
$sleepDuration
wake up time : $wakeUpTime
""";
  }
}
