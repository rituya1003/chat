import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatRoom extends StatefulWidget {
  const ChatRoom({Key? key}) : super(key: key);

  @override
  ChatRoomState createState() => ChatRoomState();
}

class ChatL10nJa extends ChatL10n {
  const ChatL10nJa({
    String? unreadMessagesLabel, // Nullable parameter
    String attachmentButtonAccessibilityLabel = '画像アップロード',
    String emptyChatPlaceholder = 'メッセージがありません。',
    String fileButtonAccessibilityLabel = 'ファイル',
    String inputPlaceholder = 'メッセージを入力してください',
    String sendButtonAccessibilityLabel = '送信',
  }) : super(
          attachmentButtonAccessibilityLabel:
              attachmentButtonAccessibilityLabel,
          emptyChatPlaceholder: emptyChatPlaceholder,
          fileButtonAccessibilityLabel: fileButtonAccessibilityLabel,
          inputPlaceholder: inputPlaceholder,
          sendButtonAccessibilityLabel: sendButtonAccessibilityLabel,
          unreadMessagesLabel: unreadMessagesLabel ??
              '', // Use null-aware operator to convert to non-null value
        );
}

class ChatRoomState extends State<ChatRoom> {
  final List<types.Message> _messages = [];
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );

  // 相手
  final _other = const types.User(
      id: 'delivery',
      firstName: "クロネコヤマト",
      lastName: "宅急便",
      imageUrl:
          "https://cdn-xtrend.nikkei.com/atcl/contents/casestudy/00012/00600/03.png?__scale=w:600,h:403&_sh=01f0690a70");

  @override
  void initState() {
    super.initState();
    _addMessage(types.TextMessage(
      author: _other,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: "クロネコヤマトです",
    ));
    _addMessage(types.TextMessage(
      author: _other,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: "お荷物をお届けに来ました",
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          transform: Matrix4.translationValues(22.5, 300.0, 0.0),
          padding: EdgeInsets.all(1.0),
          width: 320.0,
          height: 340.0,
          decoration: BoxDecoration(
            border: Border.all(width: 1.0),
            // color: Colors.white,
            // borderRadius: BorderRadius.circular(34.0),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Chat(
                    theme: const DefaultChatTheme(
                        sendButtonIcon: Icon(
                          Icons.send, // 送信ボタンに表示するアイコン
                          color: Colors.grey, // アイコンの色を指定
                        ),
                        primaryColor: Colors.blue, // メッセージの背景色の変更
                        userAvatarNameColors: [Colors.blue], // ユーザー名の文字色の変更
                        inputContainerDecoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(20)), // 角丸にするための設定
                          color: Colors.blueGrey, // コンテナの背景色を指定
                        ),
                        attachmentButtonIcon: Icon(Icons.list_alt)), //定型文のアイコン
                    messages: _messages,
                    onSendPressed: _handleSendPressed,
                    user: _user,
                    showUserAvatars: true,
                    showUserNames: true,
                    l10n: const ChatL10nJa(),
                    //onAttachmentPressed: () {}, // 定型文のアイコンを表示
                    onAttachmentPressed: _handleAttachmentPressed,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            width: 320.0,
            height: 300.0,
            child: Padding(
              padding: EdgeInsets.all(30.0),
              child: Container(
                width: 250.0,
                height: 250.0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('template')
                      .orderBy('text')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (snapshot.hasError) {
                      return Text('データの取得中にエラーが発生しました');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Text('データがありません');
                    }

                    // データを表示するウィジェットを作成する
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        // ドキュメントデータを取得
                        var data = snapshot.data!.docs[index].data();

                        // ドキュメント内のフィールドにアクセスする例
                        var text = data['text'] as String?;

                        return Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onPressed: () {
                              // ボタンが押された時の処理
                            },
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Text(
                                text ?? '',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage);
  }
}
