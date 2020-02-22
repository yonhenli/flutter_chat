import 'dart:convert';

import 'package:chat_demo/Model/SendMsgTemplate.dart';
import 'package:chat_demo/Model/chatRecordModel.dart';
import 'package:chat_demo/Model/goReceiveMsgModel.dart';
import 'package:chat_demo/Model/goWebsocketModel.dart';
import 'package:chat_demo/Tools/StaticMembers.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class GoSocketProvider with ChangeNotifier {
  IOWebSocketChannel channel;
  String socketUrl = "ws://192.168.0.2/socket";
  List<ChatRecord> records;
  var connId;
  String ava1;
  String ava2;
  IOWebSocketChannel conn;
  GoSocketProvider() {
    
    connWebSocket();
  }
  setConn(connection){
    conn=connection;
    notifyListeners();
  }

  connWebSocket() async {
    records = List<ChatRecord>();
     ava1 =
        'https://pic2.zhimg.com/v2-d2f3715564b0b40a8dafbfdec3803f97_is.jpg';
     ava2 =
        'https://pic4.zhimg.com/v2-0edac6fcc7bf69f6da105fe63268b84c_is.jpg';

    //chatRecord type 0 text 1 voice 2 image 3 video
    records.add(
        ChatRecord(avatarUrl: ava1, sender: 0, content: "你吃了么？", chatType: 0));
    records.add(
        ChatRecord(avatarUrl: ava2, sender: 1, content: "没吃呢", chatType: 0));
    records.add(ChatRecord(
        avatarUrl: ava1, sender: 0, content: "那快去吃饭吧！", chatType: 0));
    records.add(ChatRecord(
        avatarUrl: ava2,
        sender: 1,
        chatType: 0,
        content: "原来你不请我吃饭啊 \n 我还在这等你呢 \n 1231231231"));

    channel = IOWebSocketChannel.connect(socketUrl);
    channel.stream.listen((msg) {
      print(msg);
      var mapResult = json.decode(msg);
      GoReceiveMsgModel receiveMsgModel = GoReceiveMsgModel.fromJson(mapResult);
      switch (receiveMsgModel.callbackName) {
        case "onConn":
          connId = jsonDecode(receiveMsgModel.jsonResponse)["connId"];
          notifyListeners();
          break;
        case "onReceiveMsg":
          
          break;
        default:
          break;
      }
    }, onError: (err) {
      print('err is $err');
    }, onDone: () {
      print('done');
    });
  }

  invoke(String methodName, {Map<String, Object> args}) {
    args = args ?? Map<String, Object>();
    if (channel != null && channel.stream != null) {
      GoWebsocketModel socketModel =
          GoWebsocketModel(args: args, methodName: methodName);
      String jsonData = jsonEncode(socketModel);
      channel.sink.add(base64.decode(jsonData));
    }
  }

  addChatRecord(ChatRecord record) {
    records.add(record);
    notifyListeners();
  }

  sendMessage(msg) {
    records.add(ChatRecord(
        content: msg, avatarUrl: ava1, sender: SENDER.SELF, chatType: 0));
    // conn.invoke('receiveMsgAsync', args: [
    //   jsonEncode(
    //       SendMsgTemplate(fromWho: connId, toWho: '', message: msg,avatarUrl: ava1,makerName: "张三").toJson())
    // ]);

    notifyListeners();
  }

  addVoiceFromXF(String filePath) {
    records.add(ChatRecord(
      content: filePath,
      avatarUrl: ava2,
      sender: 0,
      chatType: 1,
      voiceDuration: 3,
    ));
    notifyListeners();
  }
}
