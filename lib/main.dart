import 'dart:io';

import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'dart:developer' as developer;

import './db/sqlite.dart';

final db = FlowerDB();

void main() async {
  db.open();
  //var db = FlowerDB("test");
  //await db.open();
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
      home: const HomePassword(),
    );
  }
}

class HomePassword extends StatefulWidget {
  const HomePassword({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePasswordState createState() => _HomePasswordState();
}

class _HomePasswordState extends State<HomePassword> {
  final _controllerKey = TextEditingController();
  final _controllerApp = TextEditingController();
  final _controllerZone = TextEditingController();
  final _controllerPwd = TextEditingController();
  late List<PasswordItem> items = <PasswordItem>[];
  bool _isObscure = true;
  @override
  void dispose() {
    _controllerKey.dispose();
    _controllerApp.dispose();
    _controllerZone.dispose();
    _controllerPwd.dispose();
    super.dispose();
  }

  void initItems() async {
    if (!db.isOpen) {
      await db.open();
    }
    db.passwords(15).then((value) => {
          setState(() {
            items = value;
          })
        });
    db.getLatestKey().then((value) => {
          setState(() {
            _controllerKey.text = value;
          })
        });
    db.getLatestZone().then((value) => {
          setState(() {
            _controllerZone.text = value;
          })
        });
  }

  @override
  void initState() {
    super.initState();
    initItems();
  }

  void showToast(context, msg, {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // action: SnackBarAction(
        //   label: 'Action',
        //   onPressed: () {
        //     // Code to execute.
        //   },
        // ),
        content: Center(child: Text(msg)),
        duration: const Duration(milliseconds: 1000),
        width: 280.0, // Width of the SnackBar.
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0, // Inner padding for SnackBar content.
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Password Flower"),
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          const Padding(padding: EdgeInsets.all(10.0)),
          // add tow rows, first row is input key, second row is input app and zone, and a button. when click, it will check input and call getPassword, two rows have same width
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            // 两个输入框相同宽度，并且之间有一定间距
            SizedBox(
              // height: 120,
              width: 320,
              child: TextFormField(
                controller: _controllerKey,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: '记忆密码',
                  suffixIcon: InkWell(
                    child: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility),
                    onTap: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),
              ),
            ),
          ]),
          const Padding(padding: EdgeInsets.all(10.0)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            // 两个输入框相同宽度，并且之间有一定间距
            SizedBox(
              // height: 100,
              width: 200,
              child: TextField(
                controller: _controllerApp,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'App',
                ),
              ),
            ),
            // 占位符
            const Padding(padding: EdgeInsets.all(10.0)),
            SizedBox(
              // height: 100,
              width: 100,
              child: TextField(
                controller: _controllerZone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '区号',
                ),
              ),
            ),
            // add a button, when click, it will check input and call getPassword, align center and has same height with input
          ]),

          TextField(
            readOnly: true,
            controller: _controllerPwd,
            textAlign: TextAlign.center,
            // decoration:
            //     InputDecoration(border: OutlineInputBorder(), labelText: '密码'),
          ),
          const Center(child: Text("历史记录")),
          SizedBox(
            height: 300,
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onLongPress: () {
                    Clipboard.setData(
                            ClipboardData(text: items[index].password))
                        .then((value) {
                      // 弹窗显示"复制成功"
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          // action: SnackBarAction(
                          //   label: 'Action',
                          //   onPressed: () {
                          //     // Code to execute.
                          //   },
                          // ),
                          content: const Center(child: Text('复制成功')),
                          duration: const Duration(milliseconds: 1000),
                          width: 280.0, // Width of the SnackBar.
                          padding: const EdgeInsets.symmetric(
                            horizontal:
                                8.0, // Inner padding for SnackBar content.
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    });
                  },
                  child: Row(children: <Widget>[
                    Expanded(child: Center(child: Text(items[index].name))),
                    Expanded(
                        child: Center(
                            child: TextFormField(
                      initialValue: items[index].password,
                      obscureText: true,
                      enableInteractiveSelection: false,
                    )))
                  ]),
                );
                // return SizedBox(
                //   height: 20,
                //   child: Row(children: <Widget>[
                //     Expanded(child: Center(child: Text(items[index].name))),
                //     Expanded(child: Center(child: Text(items[index].password)))
                //   ]),
                // );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ),
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
          tooltip: "just test",
          onPressed: () async {
            var pwd = getPassword(_controllerKey.text,
                _controllerApp.text + _controllerZone.text);
            if (_controllerApp.text.isEmpty) {
              setState(() {});
              showToast(context, "请输入App名称", color: Colors.red);
            } else {
              await db.updateOrInsert(PasswordItem(
                  name: _controllerApp.text,
                  key: _controllerKey.text,
                  code: _controllerApp.text,
                  zone: _controllerZone.text,
                  password: pwd));
              var itemsTmp = await db.passwords(15);
              setState(() {
                _controllerPwd.text = pwd;
                // log items info with developer mode
                items = itemsTmp;
                // 打印 items 信息，开发模式下
                // ignore: avoid_print
              });
              showToast(context, "${_controllerApp.text} 密码已生成");
            }
          },
          child: const Text("生成密码")),
    );
  }
}
