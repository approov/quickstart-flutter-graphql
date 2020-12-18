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

class _OnlineUsersPageState extends State<Online> {
  final notifierKey = "fetchOnlineUsers";

  List<String> onlineUsers = [];

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    Absinthe.connect();
    _subscribeToOnlineUsers();

    setState(() {
      onlineUsers.insert(0, "Waiting for Users to come online...");
    });

    super.initState();
  }

  _subscribeToOnlineUsers() async {
    return Absinthe.subscribe(
      this.notifierKey,
      OnlineFetch.fetchUsers,
      onResult: (payload) async {
        print("---> PAYLOAD:");
        print(payload['data']['fetchOnlineUsers']['name']);

        if (payload != null) {
          setState(() {
            // @TODO Change how we do this, because now it adds the user each he does login
            onlineUsers.insert(0, payload['data']['fetchOnlineUsers']['name']);
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
                print("---->> INDEX: ${index}");
                print(onlineUsers);

                return Card(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                            leading: Icon(Icons.person),
                            title: Text(onlineUsers[index])
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
