// @dart=2.9

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

class Config {
  static String httpProtocol = "https";
  static String websocketProtocol = "wss";

  static String auth_token;

  static String get localhost {
    httpProtocol = "http";
    websocketProtocol = "ws";

    if (Platform.isAndroid) {
      return '10.0.2.2:8002';
    } else {
      return 'localhost:8002';
    }
  }

  // Choose one of the below endpoints:
  // static String apiHost = localhost;
  static String apiHost = 'unprotected.phoenix-absinthe-graphql.demo.approov.io';

  static String get apiBaseUrl {
    // We need to call apiHost first, otherwise we get https in localhost.
    String host = apiHost;

    return "${httpProtocol}://${host}";
  }

  static final httpClient = new http.Client();

  static String get websocketUrl {
    return "${websocketProtocol}://${apiHost}/socket/websocket";
  }

  static final HttpLink httpLink = HttpLink(
      apiBaseUrl,
      httpClient: httpClient
  );

  static final AuthLink authLink = AuthLink(getToken: () => auth_token);

  static final Link link = authLink.concat(httpLink);

  static ValueNotifier<GraphQLClient> initializeClient(String token) {
    auth_token = token;
    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      ),
    );
    return client;
  }
}
