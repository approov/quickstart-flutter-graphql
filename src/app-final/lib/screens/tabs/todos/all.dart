// @dart=2.9

import 'package:app_final/components/add_task.dart';
import 'package:app_final/components/todo_item_tile.dart';
import 'package:app_final/components/utils.dart';
import 'package:app_final/data/todo_fetch.dart';
import 'package:app_final/model/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../data/online_fetch.dart';
import '../../../services/shared_preferences_service.dart';

class All extends StatefulWidget {
  All({Key key}) : super(key: key);

  @override
  _AllState createState() => _AllState();
}

class _AllState extends State<All> {
  VoidCallback refetchQuery;

  static GraphQLClient _client;
  // runOnlineMutation(context) {
  //   _client = GraphQLProvider.of(context).value;
  //   // Future.doWhile(
  //   //   () async {
  //   //     _client.mutate(
  //   //       MutationOptions(
  //   //         document: gql(OnlineFetch.updateStatus),
  //   //         variables: {
  //   //           'now': DateTime.now().toUtc().toIso8601String(),
  //   //         },
  //   //       ),
  //   //     );
  //   //     await Future.delayed(Duration(seconds: 30));
  //   //     return true;
  //   //   },
  //   // );
  // }

  fetchState(context) {
    var client = GraphQLProvider.of(context).value;
    client.mutate(
      MutationOptions(
        document: gql(TodoFetch.fetchAll),
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => fetchState(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Mutation(
          options: MutationOptions(
            document: gql(TodoFetch.addTodo),
            update: (GraphQLDataProxy cache, QueryResult result) {
              return cache;
            },
            onCompleted: (dynamic resultData) {
              refetchQuery();
            },
            onError: (Exception exception) {
              print(exception);
              // TODO: Do something with it?
            }
          ),
          builder: (
            RunMutation runMutation,
            QueryResult result,
          ) {
            return AddTask(
              onAdd: (value) {
                runMutation({'title': value, 'isPublic': false});
              },
            );
          },
        ),
        Expanded(
          child: Query(
            options: QueryOptions(
              document: gql(TodoFetch.fetchAll),
            ),
            builder: (QueryResult result,
                {VoidCallback refetch, FetchMore fetchMore}) {

              if (result.hasException) {
                UtilFs.showErrorToast('No data returned from the server.', context);
                return Text("No data available at the moment.");
              }

              if (result.isLoading) {
                return Center(child: CircularProgressIndicator());
              }

              final List<Object> todos = result.data['allTodos'];

              refetchQuery = refetch;

              return ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  dynamic responseData = todos[index];
                  return TodoItemTile(
                    item: TodoItem.fromElements(responseData["id"],
                        responseData['title'], responseData['is_completed']),
                    toggleDocument: TodoFetch.toggleTodo,
                    toggleRunMutation: {
                      'id': responseData["id"],
                      'isCompleted': !responseData['is_completed']
                    },
                    deleteDocument: TodoFetch.deleteTodo,
                    deleteRunMutation: {
                      'id': responseData["id"],
                    },
                    refetchQuery: refetch,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
