import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/RoundedButton.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
class LoginScreen extends StatefulWidget {

  static const String id = 'login screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        backgroundColor: Color(0xff1f1f1f),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xffffe070)),
                  onChanged: (value) {
                    email = value;
                    },
                  decoration: kInputDicoration.copyWith(
                    hintText: 'Enter your email',
                  )
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xffffe070)),
                  onChanged: (value) {
                    password = value;
                    },
                  decoration: kInputDicoration.copyWith(
                    hintText: 'Enter your password',
                  )
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                Color: Color(0xffffc800),
                Function: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  final user = await _auth.signInWithEmailAndPassword(email: email, password: password);
                  try{
                  if (user != null) {
                    Navigator.pushNamed(context, ChatScreen.id);
                  }
                    setState(() {
                      showSpinner = false;
                    });
                  }catch(e){
                    print("something wrong with login screen");
                  }
                },
                text: 'Log in',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
