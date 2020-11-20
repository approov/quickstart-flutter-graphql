import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

class Config {
  static String _token;

  static String get localhost {
    if (Platform.isAndroid) {
      return '10.0.2.2:8002';
    } else {
      return 'localhost:8002';
    }
  }

  static String apiHost = 'unprotected.phoenix-absinthe-graphql.demo.approov.io';

  // static String apiBaseUrl = "http://${localhost}";
  static String apiBaseUrl = "https://${apiHost}";

  // static String websocketUrl = "ws://${localhost}";
  // static String websocketUrl = "wss://${apiHost}";

  static final httpClient = new http.Client();

  static final HttpLink httpLink = HttpLink(
    uri: apiBaseUrl,
    httpClient: httpClient
  );

  static final AuthLink authLink = AuthLink(getToken: () => _token);

  // @DEPRECATED??? https://pub.dev/documentation/graphql/latest/legacy_socket_api_legacy_socket_link/WebSocketLink-class.html
  // Alternative seems to be https://flutter.dev/docs/cookbook/networking/web-sockets
  // static final WebSocketLink websocketLink = WebSocketLink(
  //   url: websocketUrl,
  //   config: SocketClientConfig(
  //     autoReconnect: true,
  //     inactivityTimeout: Duration(seconds: 30),
  //     // initPayload: {
  //     //   'headers': {
  //     //     'Authorization': _token
  //     //   },
  //     // },
  //   ),
  // );

  // static final Link link = authLink.concat(httpLink).concat(websocketLink);
  static final Link link = authLink.concat(httpLink);

  static ValueNotifier<GraphQLClient> initailizeClient(String token) {
    _token = token;
    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: OptimisticCache(dataIdFromObject: typenameDataIdFromObject),
        link: link,
      ),
    );
    return client;
  }
}
