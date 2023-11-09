import 'package:flora_key/home_password.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigurationPage extends StatefulWidget {
  final bool fromLogin;
  const ConfigurationPage({super.key, this.fromLogin = false});

  @override
  // ignore: library_private_types_in_public_api
  _ConfigurationPageState createState() => _ConfigurationPageState();
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

class _ConfigurationPageState extends State<ConfigurationPage> {
  final FocusNode _focusKey = FocusNode();
  final _controllerKey = TextEditingController();
  final FocusNode _focusZone = FocusNode();
  final _controllerZone = TextEditingController();
  bool _isDone = true;
  @override
  void initState() {
    super.initState();
    setLocalVars();
  }

  void setLocalVars() async {
    final key = await loadData("key");
    final zone = await loadData("zone");
    if (key != null && key.isNotEmpty && zone != null && zone.isNotEmpty) {
      setState(() {
        _controllerKey.text = key;
        _controllerZone.text = zone;
      });
      if (widget.fromLogin) {
        checkInputAndNavigate();
      }
    }
  }

  void _saveConfiguration() async {
    if (_controllerKey.text.isEmpty || _controllerZone.text.isEmpty) {
      // 弹出警告框
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('错误'),
            content: const Text('Key和Value都不能为空。'),
            actions: <Widget>[
              // 用户点击按钮后关闭对话框
              TextButton(
                child: const Text('好的'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      await saveData("key", _controllerKey.text);
      await saveData("zone", _controllerZone.text);
      // ignore: use_build_context_synchronously
      checkInputAndNavigate();
    }
  }

  void checkInputAndNavigate() async {
    final key = await loadData("key");
    final zone = await loadData("zone");
    print("${widget.fromLogin} ${_controllerKey.text} ${_controllerZone.text}");
    if (key != null && key.isNotEmpty && zone != null && zone.isNotEmpty) {
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePassword()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配置页面'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: SizedBox(
                  width: 200,
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
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _controllerZone,
                    focusNode: _focusZone,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '区号',
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _saveConfiguration,
                child: const Text('确认'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
