
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _auth=FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {
  static const String id= 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messagecontroller =TextEditingController();
  final _firestore= Firestore.instance;

  FirebaseUser logedInUser;
  String message;
  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

 void getCurrentUser() async{
   final currentUser = await _auth.currentUser();
   try {
     if (currentUser != null) {
       logedInUser = currentUser;
       print(logedInUser.email);

     }
   }
   catch(e){
     print(e);
   }
 }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
               _auth.signOut();
               Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').orderBy('time', descending: true).snapshots(),
                // ignore: missing_return
                builder:  (context, snapshot)  {
                  if(!snapshot.hasData){
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    );
                  }
                    final messages =  snapshot.data.documents;
                    List<MessageBubble> messageWidgets =[];

                    for(var message in messages)  {
                      final messageText = message.data['text'];
                      final messageSender = message.data['sender'];
                      final presentUser = logedInUser.email;

                      final messageWidget = MessageBubble(
                        messageText: messageText,
                        messageSender: messageSender,
                        isMe: presentUser == messageSender,

                      );

                      messageWidgets.add(messageWidget);

                    }

                      return Expanded(
                        child: ListView(
                          reverse: true,
                          padding: EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                          children: messageWidgets,
                        ),
                      );


                }

            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messagecontroller,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      onChanged: (value) {
                        message=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messagecontroller.clear();
                      _firestore.collection('messages').add({
                        'text': message,
                        'sender': logedInUser.email,
                        'time': DateTime.now(),
                      },);
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
  MessageBubble({this.messageText,this.messageSender,this.isMe});
  final messageText,messageSender;
  final bool isMe;


  @override
  Widget build(BuildContext context) {

    return
        Padding(
          padding: const EdgeInsets.all(10.0),

          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Text(messageSender,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),),
              Material(
                elevation: 5,
                borderRadius: BorderRadius.only(
                  topLeft: isMe ? Radius.circular(30) : Radius.circular(0) ,
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  topRight: !isMe ? Radius.circular(30) : Radius.circular(0) ,
                ),
                color: isMe ? Colors.lightBlueAccent : Colors.white70 ,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8,horizontal: 15),
                  child: Text('$messageText ',
                    style: TextStyle(
                      color:isMe? Colors.white: Colors.black54,
                      fontSize: 20,
                    ),

                  ),
                ),
              ),
            ],
          ),
        );
  }
}
