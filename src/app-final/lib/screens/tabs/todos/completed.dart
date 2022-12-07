// @dart=2.9

import 'package:app_final/components/add_task.dart';
import 'package:app_final/components/todo_item_tile.dart';
import 'package:app_final/data/todo_fetch.dart';
import 'package:app_final/data/todo_list.dart';
import 'package:app_final/model/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../components/utils.dart';

class Completed extends StatefulWidget {
  Completed({Key key}) : super(key: key);

  @override
  _CompletedState createState() => _CompletedState();
}

class _CompletedState extends State<Completed> {
  VoidCallback refetchQuery;

  fetchState(context) {
    var client = GraphQLProvider.of(context).value;
    client.mutate(
      MutationOptions(
        document: gql(TodoFetch.fetchCompleted),
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
                todoList.addTodo(value);
              },
            );
          },
        ),
        Expanded(
          child: Query(
            options: QueryOptions(
              document: gql(TodoFetch.fetchCompleted),
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

              final List<Object> todos = result.data['completedTodos'];

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
