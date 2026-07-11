import 'package:napapp/services/impact.dart';
import 'package:intl/intl.dart';

// This class defines the object that will contain the data from the wearable device needed for the app
class SleepData {
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? minutesAsleep;

  SleepData({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.minutesAsleep,
  });

  // Constructor from a json object
  SleepData.fromJson(String date, Map<String, dynamic> json)
    : date = DateFormat('yyyy-MM-dd').parse(date),
      // "startTime": "05-03 22:20:00"
      startTime = _timeWithYear(date, json["startTime"]),
      endTime = _timeWithYear(date, json["endTime"]),
      minutesAsleep = json["minutesAsleep"];

  // Constructor in case of missing data
  SleepData.missingData(String date)
    : date = DateFormat('yyyy-MM-dd').parse(date),
      startTime = null,
      endTime = null,
      minutesAsleep = null;

  // Adds year to the DateTime object, needed for StartTime and EndTime that lack it
  static DateTime _timeWithYear(String date, String dateTimeWithoutYear) {
    String year = date.substring(0, 4);
    // controllo per il caso 1 gennaio, nel quale startTime sarà nell'anno precedente
    if (date.substring(5, 10) == "01-01") {
      year = (int.parse(year) - 1).toString();
    }
    String toParse = "$year-$dateTimeWithoutYear";
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(toParse);
  }

  @override
  String toString() {
    return """
date : $date
startTime : $startTime
endTime : $endTime
minutesAsleep : $minutesAsleep
""";
  }

  // Returns string for query, for future developments
  String queryString() {
    return date.toString().substring(0, 10);
  }
}

// The class RecentSleep defines the essential data needed for the app's algorithm
// Which are: current day, list of the minutes of sleep of the past 7 days, wake up time
class RecentSleep {
  final DateTime recentDay;
  final List<int?> sleepDuration;
  final DateTime? wakeUpTime;

  RecentSleep({
    required this.recentDay,
    required this.sleepDuration,
    required this.wakeUpTime,
  });

  // Unused constructor that builds a RecentSleep object from a list of SleepData
  // For future developments
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

  // Create object from 7 most recent days.
  // wakeUpTime is set to an alternative if current day's data is either missing or it's sunday.
  // Alternative is the wake up time of the most recent day among following: Monday to Thursday
  static Future<RecentSleep> create() async {
    List<SleepData> recent = await Impact.getN_DaysFromMostRecent(7);
    DateTime recentDay = recent[0].date;
    DateTime? wakeUpTime = recent[0].endTime;

    // in the case of the current day being either: missing or sunday, calculates an alternative
    if (wakeUpTime == null || recentDay.weekday == 7) {
      wakeUpTime = getAltWakeUpTime(recent);
    }

    List<int?> sleepDuration = [];
    for (int i = 0; i < 7; i++) {
      sleepDuration.add(recent[i].minutesAsleep);
    }

    return RecentSleep(
      recentDay: recentDay,
      sleepDuration: sleepDuration,
      wakeUpTime: wakeUpTime,
    );
  }

  @override
  String toString() {
    return """
day : $recentDay
sleep durations in minutes in previous 7 days :
$sleepDuration
wake up time : $wakeUpTime
""";
  }

  // This function returns the sleep debt, weighted on sleep deficit in the past 7 days (baseline sleep: 8 hours)
  int getSleepDebt() {
    int baselineSleep = 8 * 60; // minutes of 8 hours of sleep = 480 mins
    List<int> w = [7, 6, 5, 4, 3, 2, 1]; // weights
    int deficitSum =
        0; // sum of individual weighted deficits will be saved here
    int wSum = 0; // sum of used weights will be saved here

    for (int i = 0; i < 7; i++) {
      if (sleepDuration[i] != null) {
        int deficitTmp =
            baselineSleep -
            sleepDuration[i]!; // deficit is difference between: 480 minutes, minutes of sleep
        if (deficitTmp < 0)
          deficitTmp = 0; // if deficit is negative, set to 0 instead
        deficitSum +=
            w[i] * deficitTmp; // weighted deficit is added to the general sum
        wSum += w[i]; // weight is added to sum of used wrights
      }
    }

    if (wSum == 0) return 0;

    int sleepDebt = (deficitSum / wSum).round();

    return sleepDebt;
  }

  // Returns true if the wake up time is an alternative
  bool isWakeUpTimeAlternative() {
    if (wakeUpTime == null) return false;
    return (recentDay.day != wakeUpTime!.day ||
        recentDay.month != wakeUpTime!.month);
  }

  // Calculates the alternative Wake Up time in the 2 scenarios:
  // 1. Current day data is missing
  // 2. Current day is sunday
  // It picks the wake up time of the most recent available day among following:
  // monday, tuesday, wednesday, thursday
  static DateTime? getAltWakeUpTime(List<SleepData> recent) {
    DateTime? altWakeUpTime = null;
    int i = 1;

    while (altWakeUpTime == null && i < 7) {
      if (recent[i].endTime != null) {
        if (recent[i].date.weekday == 1 ||
            recent[i].date.weekday == 2 ||
            recent[i].date.weekday == 3 ||
            recent[i].date.weekday == 4) {
          altWakeUpTime = recent[i].endTime;
        }
      }
      i++;
    }
    return altWakeUpTime;
  }
}
