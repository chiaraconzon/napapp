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

  // da eliminare
  String queryString() {
    return date.toString().substring(0, 10);
  }
}