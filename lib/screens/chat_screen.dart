import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = FirebaseFirestore.instance;
User loggedInUser;
class ChatScreen extends StatefulWidget {

  static const String id = 'chat screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();

  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if(user != null)
      loggedInUser = user;
      print("getCurrentUser work!");
    }catch(e){
      print('error in getCurrentUser method, error type: $e');
    }
  }

  // void messageStream() async {
  //   final snapshots = _fireStore.collection('messages').snapshots();
  //   await for(var snapshot in snapshots){
  //     for(var message in snapshot.docs){
  //       print(message.data());
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff323232),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              color: Color(0xffffc800),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat', style: TextStyle(color: Color(0xffffc800)),),
        backgroundColor: Color(0xff1f1f1f),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  MaterialButton(
                    onPressed: (){
                      messageTextController.clear();
                      try {
                        final collection =_fireStore.collection('messages');
                        collection.add(
                          {
                            'text':messageText,
                            'sender':loggedInUser.email
                          }
                        ).then((value) => print("message Added")).catchError((error) => print("Failed to add message: $error"));
                      }catch(e){
                        print(e);
                      }
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MessageBubble extends StatelessWidget {

  MessageBubble({this.text,this.sender,this.isMe});

  final String text;
  final String sender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(sender,style: TextStyle(
            fontSize: 12,
            color: Color(0xff796012)
          ),),
          Material(
            elevation: 5,
            borderRadius: isMe ? BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30)
            ) : BorderRadius.only(
              topRight: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30)
            ),
            color: isMe ? Color(0xffffc800) : Color(0xff1f1f1f),
            child: Padding(
              padding:EdgeInsets.symmetric(vertical: 10,horizontal: 15),
              child: Text(text,
                style: TextStyle(
                  color: isMe ? Colors.black54 : Color(0xffffc800),
                  fontSize: 15,
                ),
               ),
            ),
            ),
        ],
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore.collection('messages').snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Color(0xffffc800),
              ),
            );
          }
          final message = snapshot.data.docs;
          List<MessageBubble> messageWidgets = [];
          for(var messages in message){
            final messageSender = messages['sender'];
            final messageText = messages['text'];

            final currentUser = loggedInUser.email;

            final messageWidget = MessageBubble(
                text: messageText,
                sender: messageSender,
                isMe: currentUser == messageSender,
            );
            messageWidgets.add(messageWidget);
          }

          return Expanded(
            child: ListView(
              reverse: true,
              children: messageWidgets,
            ),
          );
        }
    );
  }
}
