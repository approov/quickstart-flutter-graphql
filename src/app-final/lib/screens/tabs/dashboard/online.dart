// @dart=2.9

import 'package:app_final/config/absinthe_socket.dart';
import 'package:app_final/config/client.dart';
import 'package:app_final/data/online_fetch.dart';
import 'package:app_final/model/online_item.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Online extends StatefulWidget {
  Online({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _OnlineUsersPageState createState() => _OnlineUsersPageState();
}

class _OnlineUsersPageState extends State<Online> {
  final notifierKey = "fetchOnlineUsers";

  Map<String, String> onlineUsers = {};

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchOnlineUsers();
    _subscribeToOnlineUsers();
  }

  void _fetchOnlineUsers() {
    var client = Config.buildGraphQLClient();

    var result = client.query(QueryOptions(document: gql(OnlineFetch.fetchOnlineUsers)));

     result.then((payload) {
       if (mounted == true && payload != null) {
         setState(() {
           onlineUsers = OnlineUserItem.fromResponse(payload);
         });
       }
     });
  }

  _subscribeToOnlineUsers() async {
    Absinthe.connect();

    return Absinthe.subscribe(
      this.notifierKey,
      OnlineFetch.subscribeOnlineUsers,
      onResult: (payload) async {

        if (mounted == true && payload != null) {
          setState(() {
            onlineUsers[payload['data']['fetchOnlineUsers']['name']] = payload['data']['fetchOnlineUsers']['last_seen'];
          });
        }
      },
      onError: (error) {
        print('---> GraphQL Subscription Error: $error');
      },
      onCancel: () {
        print("---> GraphQL Subscription cancelled");
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
