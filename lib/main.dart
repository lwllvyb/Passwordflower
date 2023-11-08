import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
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
  print("Goto save ${key} ${value}");
  await prefs.setString(key, value);
}

// 读取数据
Future<String?> loadData(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  print("Goto load ${key}");
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
      home: const HomePassword(),
    );
  }
}
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Password Flower"),
      ),
      body: 
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
  final FocusNode _focusKey = FocusNode();
  final _controllerKey = TextEditingController();
  final FocusNode _focusZone = FocusNode();
  final _controllerZone = TextEditingController();
  final _controllerPwd = TextEditingController();
  final _controllerAlias = TextEditingController();
  final _controllerApp = TextEditingController();
  final _controllerSpecial = TextEditingController();
  final height = 50.0;
  final appWidth = 100.0;
  final zoneWidth = 100.0;
  final specialWidth = 100.0;
  final paddingWidth = 10.0;
  // ignore: prefer_typing_uninitialized_variables
  late final userId;
  // ignore: prefer_typing_uninitialized_variables
  late final key;
  // ignore: prefer_typing_uninitialized_variables
  late final zone;

  late Set<PasswordItem> itemsSet = {};
  late List<PasswordItem> items = [];
  bool _isDone = true; // hide
  @override
  void dispose() {
    _controllerKey.dispose();
    _controllerApp.dispose();
    _controllerZone.dispose();
    _controllerPwd.dispose();
    super.dispose();
  }

  Future<bool> login() async {
    return await logIn("mr.liwenlong@outlook.com", "12345678");
  }

  void initItems() async {
    // if (!db.isOpen) {
    //   await db.open();
    // }
    await login();
    var user = "flower/$userId";
    const keyCode = "1QAZ3edc";
    const zone = "#123";
    DatabaseReference ref = FirebaseDatabase.instance.ref(user);
    // var dataSnapshot = await ref.get();
    // Object? data = dataSnapshot.value;
    // if (data != null) {
    //   data = data as Map<String, dynamic>;
    //   data.forEach((key, value) {
    //     var item = value;
    //     var password =
    //         getPassword(keyCode, item['app'] + zone) + item['special'];
    //     itemsSet.add(PasswordItem(
    //         alias: item['alias'],
    //         name: item['app'],
    //         key: key,
    //         zone: zone,
    //         special: item['special'],
    //         password: password,
    //         updateTime: item['update_time']));
    //     print(
    //         "load from database, ${item['app']} ${item['alias']} ${item['special']}");
    //   });
    //   setState(() {
    //     items = itemsSet.toList();
    //   });
    // }

    ref.onChildAdded.listen((event) {
      Map<String, dynamic> item = event.snapshot.value as Map<String, dynamic>;
      var password = getPassword(keyCode, item['app'] + zone) + item['special'];
      itemsSet.add(PasswordItem(
          alias: item['alias'],
          name: item['app'],
          key: keyCode,
          zone: zone,
          special: item['special'],
          password: password,
          updateTime: item['update_time']));
      setState(() {
        items = itemsSet.toList();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initItems();
    initLocalVars();
    _focusKey.addListener(() {
      if (!_focusKey.hasFocus && _controllerKey.text.isNotEmpty) {
        saveData("key", _controllerKey.text);
        setState(() {
          _isDone = true;
        });
      }
    });
    _focusZone.addListener(() {
      if (!_focusZone.hasFocus && _controllerZone.text.isNotEmpty) {
        saveData("zone", _controllerZone.text);
      }
    });
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
        content: SizedBox(height: 50.0, child: Center(child: Text(msg))),
        duration: const Duration(milliseconds: 1000),
        width: 200.0, // Width of the SnackBar.
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
    final keyWidth = appWidth +
        zoneWidth +
        specialWidth +
        paddingWidth * 2 * 2; // padding 是两边的

    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Password Flower"),
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(paddingWidth)),
          // add tow rows, first row is input key, second row is input app and zone, and a button. when click, it will check input and call getPassword, two rows have same width
          Wrap(
            alignment: WrapAlignment.center,
            children: <Widget>[
              Container(
                height: height,
                width: keyWidth,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: TextFormField(
                  controller: _controllerKey,
                  focusNode: _focusKey,
                  obscureText: _isDone,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: '记忆密码',
                    suffixIcon: InkWell(
                      child: Icon(
                        _isDone ? Icons.edit : Icons.done,
                      ),
                      onTap: () => {setState(() => _isDone = !_isDone)},
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Padding(padding: EdgeInsets.all(paddingWidth)),
          Wrap(
            alignment: WrapAlignment.center,
            children: <Widget>[
              // 两个输入框相同宽度，并且之间有一定间距
              Container(
                height: height,
                width: appWidth,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: TextField(
                  controller: _controllerAlias,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Alias',
                  ),
                ),
              ),
              Container(
                height: height,
                width: appWidth,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: TextField(
                  controller: _controllerApp,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'App',
                  ),
                ),
              ),
              // 占位符
              // Padding(padding: EdgeInsets.all(paddingWidth)),
              Container(
                height: height,
                width: zoneWidth,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: TextField(
                  controller: _controllerZone,
                  focusNode: _focusZone,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '区号',
                  ),
                ),
              ),
              // add SizedBox controller is _controllerSpecial, width is 100, height is 100, decoration is border, labelText is '特殊字符'
              // Padding(padding: EdgeInsets.all(paddingWidth)),
              Container(
                height: height,
                width: specialWidth,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                // padding: EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: _controllerSpecial,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '特殊字符',
                  ),
                ),
              ),
              // add a button, when click, it will check input and call getPassword, align center and has same height with input
            ],
          ),

          // TextField(
          //   readOnly: true,
          //   controller: _controllerPwd,
          //   textAlign: TextAlign.center,
          //   // decoration:
          //   //     InputDecoration(border: OutlineInputBorder(), labelText: '密码'),
          // ),

          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            // padding: EdgeInsets.symmetric(vertical: 10),
            child: const Center(
              child: Text("历史记录"),
            ),
          ),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  key: Key(items[index].name),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("确认删除"),
                          content: const Text("您确定要删除此项吗？"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("取消"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("删除"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) async {
                    // await db.delete(items[index].name);
                    setState(() {
                      items.removeAt(index);
                    });
                    // ignore: use_build_context_synchronously
                    showToast(context, "${items[index].name} 已删除");
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: Colors.grey[300]!),
                        bottom:
                            BorderSide(width: 1.0, color: Colors.grey[300]!),
                      ),
                    ),
                    child: GestureDetector(
                      onLongPressStart: (details) {
                        final Offset position =
                            details.globalPosition; // 获取长按的全局坐标
                        showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(position.dx,
                              position.dy, position.dx, position.dy),
                          items: [
                            const PopupMenuItem(
                                value: 'Edit', child: Text("Edit")),
                            const PopupMenuItem(
                                value: 'Copy', child: Text("Copy"))
                          ],
                        ).then((value) {
                          if (value == 'Edit') {
                            setState(() {
                              _controllerAlias.text = items[index].alias;
                              _controllerApp.text = items[index].name;
                              _controllerSpecial.text = items[index].special;
                            });
                          } else if (value == "Copy") {
                            Clipboard.setData(
                                ClipboardData(text: items[index].password));
                            showToast(
                                context, "${items[index].alias} 密码, 已复制到剪贴板");
                          }
                        });
                      },
                      child: ExpansionTile(
                        title: Row(
                          children: <Widget>[
                            // Add your widgets here
                            Expanded(
                                child: Center(child: Text(items[index].alias))),
                            Expanded(
                                child: Center(child: Text(items[index].name))),
                            Expanded(
                                child: Center(
                                    child: Text(items[index].updateTime))),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      )),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            var pwd = getPassword(_controllerKey.text,
                    _controllerApp.text + _controllerZone.text) +
                _controllerSpecial.text;
            if (_controllerApp.text.isEmpty) {
              showToast(context, "请输入App名称", color: Colors.red);
            } else {
              // // add to local database
              // await db.updateOrInsert(PasswordItem(
              //     alias: _controllerAlias.text,
              //     name: _controllerApp.text,
              //     key: _controllerKey.text,
              //     zone: _controllerZone.text,
              //     special: _controllerSpecial.text,
              //     password: pwd));
              // add to firebase realtime database
              final dbItem =
                  "flower/$userId/${_controllerAlias.text}_${_controllerApp.text}";
              DatabaseReference ref = FirebaseDatabase.instance.ref(dbItem);
              final snapshot = await ref.get();
              var createTime = DateTime.now();
              if (snapshot.exists) {
                print("exists: $dbItem ${snapshot.exists}");
                await ref.update({
                  "special": _controllerSpecial.text,
                  "update_time": createTime.toString(),
                  "update_time_unix":
                      (createTime.toUtc().millisecondsSinceEpoch / 1000)
                          .round(),
                });
              } else {
                try {
                  await ref.set({
                    "app": _controllerApp.text,
                    "special": _controllerSpecial.text,
                    "alias": _controllerAlias.text,
                    "create_time": createTime.toString(),
                    "create_time_unix":
                        (createTime.toUtc().millisecondsSinceEpoch / 1000)
                            .round(),
                    "update_time": createTime.toString(),
                    "update_time_unix":
                        (createTime.toUtc().millisecondsSinceEpoch / 1000)
                            .round(),
                  });
                } on FirebaseException catch (e) {
                  // 如果是权限被拒绝错误
                  if (e.code == 'permission-denied') {
                    print('Permission denied for this read operation');
                  } else {
                    // 处理其他类型的数据库错误
                    print('Caught a database error: $e');
                  }
                } catch (e) {
                  // 捕获其他任何类型的异常
                  print('Caught an exception: $e');
                }
              }

              setState(() {
                // var itemsTmp = await db.passwords(15);
                final index = items.indexWhere((item) =>
                    item.alias == _controllerAlias.text &&
                    item.name == _controllerApp.text);
                if (index != -1) {
                  final PasswordItem newItem = PasswordItem(
                    alias: items[index].alias,
                    name: items[index].name,
                    key: items[index].key,
                    zone: items[index].zone,
                    special: _controllerSpecial.text,
                    password: pwd,
                    updateTime: createTime.toString(),
                  );
                  items[index] = newItem;
                  print("update ${items[index]}");
                } else {
                  final PasswordItem newItem = PasswordItem(
                    alias: _controllerAlias.text,
                    name: _controllerApp.text,
                    key: _controllerKey.text,
                    zone: _controllerZone.text,
                    special: _controllerSpecial.text,
                    password: pwd,
                    updateTime: createTime.toString(),
                  );
                  items.add(newItem);
                  print("add ${items[index]}");
                }
              });
              if (snapshot.exists) {
                // ignore: use_build_context_synchronously
                showToast(context, "${_controllerApp.text} 密码已更新");
              } else {
                // ignore: use_build_context_synchronously
                showToast(context, "${_controllerApp.text} 密码已生成");
              }
            }
          },
          label: const Text("生成密码")),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // login
  Future<bool> logIn(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      userId = credential.user?.uid;
      print("login success, user id: ${userId}");
      return true; // 登录成功
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return false; // 登录失败
    }
  }

  void initLocalVars() async {
    var key = await loadData("key");
    if (key != null) {
      setState(() {
        _controllerKey.text = key;
      });
    }
    var zone = await loadData("zone");
    if (zone != null) {
      setState(() {
        _controllerZone.text = zone;
      });
    }
  }
}
