import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:project/models/repo.dart';
import 'package:project/models/user.dart';
import 'package:project/screens/home_screen/home_screen.dart';

class ApiService {
  static String token = "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";
  static int fetchContentLength = 50;
  static String? email;
  static String? password;

  static void saveCredentials(String email, password) {
    ApiService.email = email;
    ApiService.password = password;
  }

  static Future<Map<String, dynamic>> fetchGitHubUserData() async {
    List<User> allusers = [];
    List<User> limitedUser = [];
    int statusCode = 200;
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/users'),
        headers: {
          'Authorization': 'Bearer${token}',
        },
      );

      if (response.statusCode != 200) {
        statusCode = response.statusCode;
      }

      if (response.statusCode == 200) {
        List result = json.decode(response.body);
        allusers = result.map((e) => User.fromJson(e)).toList();
        limitedUser = allusers.getRange(0, 10).toList();
        // print(result);
      }
    } catch (e) {
      log(e.toString());
    }
    return {'statusCode': statusCode, 'users': allusers};
  }

  static Future<int> fetchGitHubUserRepositoryLength(String repoURl) async {
    int repoLength = 0;
    try {
      final response = await http.get(
        Uri.parse(repoURl),
        headers: {
          'Authorization': 'Bearer${token}',
        },
      );
      if (response.statusCode == 200) {
        List result = json.decode(response.body);
        List<Repo> allrepos = result.map((e) => Repo.fromJson(e)).toList();
      }
    } catch (e) {}
    return repoLength;
  }

  static Future<List<Repo>> fetchGitHubUserRepositories(String repoURl) async {
    List<Repo> allrepos = [];
    try {
      final response = await http.get(
        Uri.parse(repoURl),
        headers: {
          'Authorization': 'Bearer${token}',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        List result = json.decode(response.body);
        allrepos = result.map((e) => Repo.fromJson(e)).toList();
      }
    } catch (e) {
      log(e.toString());
    }

    return allrepos;
  }

  static Future<void> handleLogin(
      String Uemail, String Upassword, BuildContext context) async {
    final headers = {
      'Authorization': 'token $token',
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'request'
    };
    try {
      final response = await http.get(
          Uri.parse(
            'https://api.github.com/users?email=$Uemail&password=$Upassword',
          ),
          // headers: {
          //   'Authorization':
          //       'Basic ' + base64Encode(utf8.encode('${Uemail}:${Upassword}')),
          // },
          headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        // Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
        //   return HomeScreen();
        // })));
        // Use the user info here (e.g., save to local storage or navigate to a new screen)
      } else {
        throw Exception(response.statusCode);
      }
    } catch (e) {
      print("$e");
    } finally {}
  }
}


// for (var i = 0; i < result.length; i++) {
//   Allusers.add(User.fromJson(result[i]));
//   if (Allusers.length >= fetchContentLength) {
//     break;
//   }
// }