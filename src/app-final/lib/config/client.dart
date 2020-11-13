import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// COMMENT OUT FOR APPROOV
import 'package:http/http.dart' as http;

// UNCOMMENT FOR APPROOV
// import 'package:approovsdkflutter/approovsdkflutter.dart';

class Config {
  static String _token;

  static String get localhost {
    if (Platform.isAndroid) {
      return '10.0.2.2:8002';
    } else {
      return 'localhost:8002';
    }
  }

  // COMMENT OUT FOR APPROOV
  static String apiHost = 'unprotected.phoenix-absinthe-graphql.demo.approov.io';

  // UNCOMMENT FOR APPROOV
  // static String apiHost = 'token.phoenix-absinthe-graphql.demo.approov.io';
  // static String apiHost = 'token-binding.phoenix-absinthe-graphql.demo.approov.io';

  // static String apiBaseUrl = "http://${localhost}";
  static String apiBaseUrl = "https://${apiHost}";

  // static String websocketUrl = "ws://${localhost}";
  // static String websocketUrl = "wss://${apiHost}";

  // COMMENT OUT FOR APPROOV
  static final httpClient = new http.Client();

  // UNCOMMENT FOR APPROOV
  // static final  httpClient = ApproovClient();

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
