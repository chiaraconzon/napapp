import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:napapp/models/sleep.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Impact {
  static String baseUrl = "https://impact.dei.unipd.it/bwthw/";

  static String pingEndpoint = 'gate/v1/ping/';
  static String tokenEndpoint = 'gate/v1/token/';
  static String refreshEndpoint = 'gate/v1/refresh/';

  static String sleepEndpoint = 'data/v1/sleep/patients/';

  static String username = "He3oIbpv0H";
  static String password = "12345678!";
  static final patient = "Jpefaq6m58";
  // Le credenziali di default sopra sono solo placeholder.
  // La login page deve chiamare Impact.setCredentials(user, pass)
  // con le credenziali reali PRIMA di chiamare Impact.authorize().

  static void setCredentials(String user, String pass) {
    Impact.username = user;
    Impact.password = pass;
  }

  //This method allows to obtain the JWT token pair from IMPACT and store it in SharedPreferences
  static Future<int?> authorize() async {
    //Create the request
    final url = Impact.baseUrl + Impact.tokenEndpoint;
    final body = {'username': Impact.username, 'password': Impact.password};

    //Get the response
    //print('Calling: $url');
    final response = await http.post(Uri.parse(url), body: body);
    //print('authorize() status: ${response.statusCode}');
    //print('authorize() body: ${response.body}');

    //If 200, set the token
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      final sp = await SharedPreferences.getInstance();
      sp.setString('access', decodedResponse['access']);
      sp.setString('refresh', decodedResponse['refresh']);
    } //if

    //Just return the status code
    return response.statusCode;
  } //_authorize

  //This method requests data from the IMPACT server
  static Future<SleepData> requestSleepData(String day) async {
    //Initialize the result
    SleepData result;
    //print('ha chiamato request data');

    //Get the stored access token (Note that this code does not work if the tokens are null)
    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');

    //If access token is expired, refresh it
    if (access == null) {
      await authorize();
      access = sp.getString(
        'access',
      ); // BUGFIX: prima non veniva riletto -> header "Bearer null"
    } else if (isExpired(access)) {
      final refreshStatus = await _refreshTokens();
      if (refreshStatus != 200) {
        // BUGFIX: il refresh token stesso è scaduto/non valido (succede più
        // facilmente su mobile, dove l'app resta installata più a lungo
        // senza essere riaperta rispetto a una sessione Chrome appena
        // testata). _refreshTokens() in questo caso NON scrive nulla in
        // shared_preferences: se rileggessimo comunque 'access' otterremmo
        // lo stesso vecchio token scaduto di prima, causando un secondo 401
        // ("token invalid or expired") anche dopo il tentativo di refresh.
        // Serve quindi un login completo da zero con username/password.
        await authorize();
      }
      access = sp.getString('access');
    }

    // Se dopo l'autenticazione il token è ancora nullo (es. credenziali errate),
    // fallisci subito con un errore chiaro invece di mandare "Bearer null" al server.
    if (access == null) {
      throw Exception(
        "Error: unable to authenticate with IMPACT (check credentials).",
      );
    }

    //Create the (representative) request
    //final day = '2024-05-04';
    final url =
        Impact.baseUrl + Impact.sleepEndpoint + Impact.patient + '/day/$day/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    //Get the response
    //print('Calling: $url');
    final response = await http.get(Uri.parse(url), headers: headers);
    //print('requestSleepData($day) status: ${response.statusCode}');
    //print('requestSleepData($day) body: ${response.body}');

    //if OK parse the response, otherwise return null
    if (response.statusCode == 200) {
      //print('response code 200');
      final decodedResponse = jsonDecode(response.body);
      try {
        result = SleepData.fromJson(
          decodedResponse['data']['date'],
          decodedResponse['data']['data'],
        );
      } catch (e) {
        print("Error: missing data for day $day.");
        result = SleepData.missingData(day);
      }
    } //if
    else {
      throw Exception("Error: failed to obtain data.");
    } //else

    //Return the result
    return result;
  }

  //This method allows to obtain the JWT token pair from IMPACT and store it in SharedPreferences
  static Future<int> _refreshTokens() async {
    //Create the request
    final url = Impact.baseUrl + Impact.refreshEndpoint;
    final sp = await SharedPreferences.getInstance();
    final refresh = sp.getString('refresh');
    final body = {'refresh': refresh};

    //Get the respone
    //print('Calling: $url');
    final response = await http.post(Uri.parse(url), body: body);

    //If 200 set the tokens
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      final sp = await SharedPreferences.getInstance();
      sp.setString('access', decodedResponse['access']);
      sp.setString('refresh', decodedResponse['refresh']);
    } //if

    //Return just the status code
    return response.statusCode;
  } //_refreshTokens

  static bool isExpired(String accessToken) {
    return JwtDecoder.isExpired(accessToken);
  }

  static Future<SleepData?> getMostRecentData() async {
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(Duration(days: 1));
    String recent = queryString(yesterday);

    return await requestSleepData(recent);
  }

  static String queryString(DateTime date) {
    return date.toString().substring(0, 10);
  }

  // the function returns a list of the most recent n days of data, starting from the most recent (yesterday)
  static Future<List<SleepData>> getN_DaysFromMostRecent(int n) async {
    if (n < 0) throw Exception("n non può essere negativo");
    DateTime now = DateTime.now();
    DateTime recentDay = now.subtract(Duration(days: 1));

    List<SleepData> result = [];

    for (int i = 0; i < n; i++) {
      DateTime currentDay = recentDay.subtract(Duration(days: i));
      String currentDayString = queryString(currentDay);

      try {
        SleepData currentData = await requestSleepData(currentDayString);
        result.add(currentData);
      } catch (e) {
        SleepData currentData = SleepData.missingData(currentDayString);
        result.add(currentData);
      }
    }

    return result;
  }
}
