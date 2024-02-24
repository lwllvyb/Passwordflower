import 'package:firebase_auth/firebase_auth.dart';
import 'package:flora_key/configuration_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_login/flutter_login.dart';
// import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  var _isPasswordVisible = false;
  final users = {
    'dribbble@gmail.com': '12345',
    'hunter@gmail.com': 'hunter',
  };
  // const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) {
    debugPrint('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) async {
      // if (!users.containsKey(data.name)) {
      //   return 'User not exists';
      // }
      // if (users[data.name] != data.password) {
      //   return 'Password does not match';
      // }
      try {
        final credential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: data.name,
          password: data.password,
        );
        if (credential.user == null) {
          return 'User not exists';
        }
      } on FirebaseAuthException catch (e) {
        // Handle the error
        // ignore: use_build_context_synchronously
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(e.message ?? 'An error occurred')),
        // );
        return 'Login fail!';
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', data.name);
      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  Future<String?> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'User not exists';
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Flora',
      logo: const AssetImage('images/ecorp-lightblue.png'),
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const ConfigurationPage(
            fromLogin: true,
          ),
        ));
      },
      onRecoverPassword: _recoverPassword,
    );

    // return Scaffold(
    //   appBar: AppBar(title: const Text('FloraKey')),
    //   body: Align(
    //     alignment: Alignment.center,
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
    //       child: Column(
    //         children: [
    //           SizedBox(
    //             width: 250,
    //             child: TextField(
    //               controller: _emailController,
    //               decoration: const InputDecoration(labelText: 'Email'),
    //               keyboardType: TextInputType.emailAddress,
    //               autofocus: true,
    //             ),
    //           ),
    //           SizedBox(
    //             width: 250,
    //             child: TextField(
    //               controller: _passwordController,
    //               decoration: InputDecoration(
    //                 labelText: 'Password',
    //                 suffixIcon: IconButton(
    //                   icon: Icon(
    //                     // Based on passwordVisible state choose the icon
    //                     _isPasswordVisible
    //                         ? Icons.visibility
    //                         : Icons.visibility_off,
    //                   ),
    //                   onPressed: () => setState(() {
    //                     _isPasswordVisible = !_isPasswordVisible;
    //                   }),
    //                 ),
    //               ),
    //               obscureText: !_isPasswordVisible,
    //             ),
    //           ),
    //           Padding(
    //             padding: const EdgeInsets.all(20.0),
    //             child: ElevatedButton(
    //               onPressed: () async {
    //                 await signIn();
    //               },
    //               child: const Text('Login'),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  Future<void> signIn() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (credential.user != null) {
        // Save the user session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', _emailController.text.trim());
        // Navigate to the next screen
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const ConfigurationPage(
                    fromLogin: true,
                  )),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle the error
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
