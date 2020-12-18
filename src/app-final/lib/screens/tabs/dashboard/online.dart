import 'package:app_final/config/absinthe_socket.dart';
import 'package:app_final/data/online_fetch.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Online extends StatefulWidget {
  Online({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _OnlineUsersPageState createState() => _OnlineUsersPageState();
}

class OnlineUserItem {
  String username = "";
  String last_seen = "";

  OnlineUserItem.fromElements(String username, String last_seen) {
    this.username = username;
    this.last_seen = last_seen;
  }
}

class _OnlineUsersPageState extends State<Online> {
  final notifierKey = "fetchOnlineUsers";

  Map<String, String> onlineUsers = {};

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    Absinthe.connect();
    _subscribeToOnlineUsers();

    super.initState();
  }

  _subscribeToOnlineUsers() async {
    return Absinthe.subscribe(
      this.notifierKey,
      OnlineFetch.fetchUsers,
      onResult: (payload) async {

        if (payload != null) {
          setState(() {
            // @TODO Change how we do this, because now it adds the user each he does login
            onlineUsers[payload['data']['fetchOnlineUsers']['name']] = payload['data']['fetchOnlineUsers']['last_seen'];
          });
        }
      },
      onError: (error) {
        print('Error ----> $error');
      },
      onCancel: () {
        print("cancelled subscription");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              reverse: true,
              itemBuilder: (BuildContext context, int index) {
                var onlineUserIter = onlineUsers.entries;

                return Card(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                            leading: Icon(Icons.person),
                            title: Text(onlineUserIter.elementAt(index).key),
                            subtitle: Text("Last seen: " + onlineUserIter.elementAt(index).value),
                        ),
                      ],
                    ));
              },
              itemCount: onlineUsers.length,
            ),
          ),
        ],
      ),
    );
  }
}
