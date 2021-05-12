// @dart=2.9

import 'package:app_final/model/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class TodoItemTile extends StatelessWidget {
  final TodoItem item;
  final String toggleDocument;
  final Map<String, dynamic> toggleRunMutaion;
  final String deleteDocument;
  final Map<String, dynamic> deleteRunMutaion;
  final Function refetchQuery;

  TodoItemTile({
    Key key,
    this.refetchQuery,
    @required this.item,
    @required this.toggleDocument,
    @required this.toggleRunMutaion,
    @required this.deleteDocument,
    @required this.deleteRunMutaion,
  }) : super(key: key);

  Map<String, Object> extractTodoData(Object data) {
    final Map<String, Object> returning =
        (data as Map<String, Object>)['action'] as Map<String, Object>;

    if (returning == null) {
      // return null;
      return data;
    }

    List<Object> list = returning['returning'];
    return list[0] as Map<String, Object>;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: ListTile(
          contentPadding: EdgeInsets.all(0),
          title: Text(item.task,
              style: TextStyle(
                  decoration: item.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none)),
          leading: Mutation(
            options: MutationOptions(
              document: gql(toggleDocument),
              update: (GraphQLDataProxy cache, QueryResult result) {
                if (result.hasException) {
                  print(result.exception);
                } else {
                  final Map<String, Object> updated =
                      Map<String, Object>.from(item.toJson())
                        ..addAll(extractTodoData(result.data));
////// Previous version of write to cache
//////            cache.write(typenameDataIdFromObject(updated), updated);
////// where typenameDataIdFromObject is
//////   String typenameDataIdFromObject(Object object) {
//////     if (object is Map<String, Object> &&
//////         object.containsKey('__typename') &&
//////         object.containsKey('id')) {
//////       return "${object['__typename']}/${object['id']}";
//////     }
//////     return null;
//////   }

////// This cache write example is from: https://github.com/zino-app/graphql-flutter/blob/dab2ed42592efed31e713dbaf8dc2b19c7e208d1/packages/graphql_flutter/example/lib/graphql_widget/main.dart#L190
                  cache.writeFragment(Fragment(document: gql(
                    '''
                      fragment fields on Repository {
                        id
                        title
                        is_completed
                      }
                    ''',),).asRequest(idFields: {
                      '__typename': updated['__typename'],
                      'id': updated['id'],
                    }),
                    data: updated, /*false*/);

                }
                return cache;
              },

////// Also see
//////   https://pub.dev/packages/graphql_flutter#mutations
//////   https://github.com/zino-app/graphql-flutter/blob/master/changelog-v3-v4.md#cache-overhaul

              onCompleted: (onValue) {
                refetchQuery();
              },
            ),
            builder: (
              RunMutation runMutation,
              QueryResult result,
            ) {
              return InkWell(
                onTap: () {
                  runMutation(
                    toggleRunMutaion,
                    optimisticResult: {
                      "action": {
                        "returning": [
                          {"is_completed": !item.isCompleted}
                        ]
                      }
                    },
                  );
                },
                child: Container(
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(!item.isCompleted
                      ? Icons.radio_button_unchecked
                      : Icons.radio_button_checked),
                ),
              );
            },
          ),
          trailing: Mutation(
            options: MutationOptions(
              document: gql(deleteDocument),
              onCompleted: (onValue) {
                refetchQuery();
              },
            ),
            builder: (
              RunMutation runMutation,
              QueryResult result,
            ) {
              return InkWell(
                onTap: () {
                  runMutation(deleteRunMutaion);
                },
                child: Container(
                    decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: Colors.grey))),
                    width: 60,
                    height: double.infinity,
                    child: Icon(Icons.delete)),
              );
            },
          ),
        ),
      ),
    );
  }
}
