import 'package:PasswordFlower/home_password.dart';
import 'package:PasswordFlower/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

// import './db/sqlite.dart';

// final db = FlowerDB();

class PasswordItem {
  final String alias;
  final String name;
  final String key;
  final String zone;
  final String special;
  final String password;
  final String updateTime;

  PasswordItem({
    required this.alias,
    required this.name,
    required this.key,
    required this.zone,
    required this.special,
    required this.password,
    required this.updateTime,
  });
}

late final curerntUser;

void main() async {
//   db.open();
  //var db = FlowerDB("test");
  //await db.open();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

bool isNumeric(String s) {
  return double.tryParse(s) != null;
}

// ignore: constant_identifier_names
const STR3 = 'sunlovesnow1990090127xykab';
String getPassword(String inKey, String inCode) {
  var key = utf8.encode(inKey);
  var code = utf8.encode(inCode);

  var hmacMd5 = Hmac(md5, code); // HMAC-SHA256
  var one = hmacMd5.convert(key);
  hmacMd5 = Hmac(md5, utf8.encode("snow"));
  var two = hmacMd5.convert(utf8.encode("$one"));
  hmacMd5 = Hmac(md5, utf8.encode("kise"));
  var three = hmacMd5.convert(utf8.encode("$one"));
  var rule = "$three".split('');
  var source = "$two".split('');
  var pwd = "";
  // convert to upper case
  for (var i = 0; i < 32; i++) {
    if (!isNumeric(source[i])) {
      if (STR3.contains(rule[i])) {
        source[i] = source[i].toUpperCase();
      }
    }
  }
  var pwd32 = source.join('');
  var firstChar = pwd32.substring(0, 1);
  // make sure first char is not a number
  if (!isNumeric(firstChar)) {
    pwd = pwd32.substring(0, 16);
  } else {
    pwd = 'K${pwd32.substring(1, 16)}';
  }
  return pwd;
}

// 保存数据
Future<void> saveData(String key, String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

// 读取数据
Future<String?> loadData(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Flower',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

Future<bool> checkUserLoggedIn() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  return currentUser != null;
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: checkUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 当checkUserLoggedIn方法还在执行时，显示加载动画
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // 如果我们遇到错误，可以显示错误信息
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == true) {
            // 用户已登录，可以直接跳转到主屏幕
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePassword()),
              );
            });
            // 返回一个空容器，因为跳转将会发生
            return Container();
          } else {
            // 用户未登录，显示登录界面
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
