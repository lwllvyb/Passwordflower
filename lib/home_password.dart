import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flora_key/configuration_page.dart';
import 'package:flora_key/login_screen.dart';
import 'package:flora_key/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  late final userEmail;
  // ignore: prefer_typing_uninitialized_variables
  late final key;
  // ignore: prefer_typing_uninitialized_variables
  late final zone;

  late Set<PasswordItem> itemsSet = {};
  late List<PasswordItem> items = [];
  @override
  void dispose() {
    _controllerKey.dispose();
    _controllerApp.dispose();
    _controllerZone.dispose();
    _controllerPwd.dispose();
    super.dispose();
  }

  Future<bool> checkLocalVarAndNavigate() async {
    final keyTmp = await loadData("key");
    final zoneTmp = await loadData("zone");
    print("${_controllerKey.text} ${_controllerZone.text}");
    if (!(keyTmp != null && keyTmp.isNotEmpty) ||
        !(zoneTmp != null && zoneTmp.isNotEmpty)) {
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ConfigurationPage()),
        (Route<dynamic> route) => false,
      );
      return false;
    }
    setState(() {
      _controllerKey.text = keyTmp;
      _controllerZone.text = zoneTmp;
    });
    key = keyTmp.toString();
    zone = zoneTmp.toString();
    return true;
  }

  void initItems() async {
    await checkLocalVarAndNavigate();
    var user = "flower/$userId";
    DatabaseReference ref = FirebaseDatabase.instance.ref(user);

    ref.onChildAdded.listen((event) {
      Map<String, dynamic> item = event.snapshot.value as Map<String, dynamic>;
      var password = getPassword(key, item['app'] + zone) + item['special'];
      itemsSet.add(PasswordItem(
          alias: item['alias'],
          name: item['app'],
          key: key,
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
    final currentUser = FirebaseAuth.instance.currentUser;
    userId = currentUser?.uid;
    userEmail = currentUser?.email;
    initItems();
    _focusKey.addListener(() {
      if (!_focusKey.hasFocus && _controllerKey.text.isNotEmpty) {
        saveData("key", _controllerKey.text);
        setState(() {});
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to FloraKey"),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              accountName:
                  const Text('UserInfo', style: TextStyle(color: Colors.white)),
              accountEmail: Text(userEmail.toString()),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.asset(
                  'assets/icons/flower.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListTile(
              title: const Text('Config'),
              leading: const Icon(Icons.settings),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const ConfigurationPage()),
              ), // 点击时调用_signOut方法
            ),
            ListTile(
              title: const Text('Log Out'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () => _signOut(context), // 点击时调用_signOut方法
            ),
          ],
        ),
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(paddingWidth)),
          // add tow rows, first row is input key, second row is input app and zone, and a button. when click, it will check input and call getPassword, two rows have same width

          // Padding(padding: EdgeInsets.all(paddingWidth)),
          Wrap(
            alignment: WrapAlignment.center,
            children: <Widget>[
              // 两个输入框相同宽度，并且之间有一定间距
              Container(
                height: height,
                width: 200,
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
                width: 100,
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
              Container(
                height: height,
                width: 100,
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

          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            // padding: EdgeInsets.symmetric(vertical: 10),
            child: const Center(
              child: Text("历史记录"),
            ),
          ),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 2),
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
                  child: GestureDetector(
                    onLongPressStart: (details) {
                      final Offset position =
                          details.globalPosition; // 获取长按的全局坐标
                      showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(
                            position.dx, position.dy, position.dx, position.dy),
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
                              child: Center(child: Text(items[index].special))),
                          Expanded(
                              child:
                                  Center(child: Text(items[index].updateTime))),
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
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

  _signOut(BuildContext context) {
    // 方法用于处理用户退出登录
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseAuth.instance.signOut();
    }

    // 退出登录后返回登录界面
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
