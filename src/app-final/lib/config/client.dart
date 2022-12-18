// @dart=2.9

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// COMMENT LINE BELOW IF USING APPROOV
import 'package:http/http.dart' as http;

// UNCOMMENT LINE BELOW IF USING APPROOV
//import 'package:approov_service_flutter_httpclient/approov_service_flutter_httpclient.dart';

class Config {
  static String httpProtocol = "https";
  static String websocketProtocol = "wss";

  static String auth_token;

  static String get localhost {
    httpProtocol = "http";
    websocketProtocol = "ws";

    if (Platform.isAndroid) {
      // When using a real mobile device you need to use the wifi IP address,
      // and have the computer and the mobile device connected to it.
      // Find your wifi IP on Linux with: ip address | grep -i wlp -
      return '10.0.2.2:8002';
    } else {
      return 'localhost:8002';
    }
  }

  // Choose one of the below endpoints:
  // IF RUNNING GRAPHQL SERVER LOCALLY
  // static String apiHost = localhost;
  // IF USING THE UNPROTECTED GRAPHQL SERVER BEFORE ADDING APPROOV
  static String apiHost = 'unprotected.phoenix-absinthe-graphql.demo.approov.io';
  // IF USING THE PROTECTED GRAPHQL SERVER WHEN USING APPROOV
  //static String apiHost = 'token.phoenix-absinthe-graphql.demo.approov.io';

  static String get apiBaseUrl {
    String host = apiHost;
    return "${httpProtocol}://${host}";
  }

  // COMMENT LINE BELOW IF USING APPROOV
  static final httpClient = new http.Client();

  // UNCOMMENT LINES BELOW IF USING APPROOV
  // static final httpClient = () {
  //   var approovClient = ApproovClient('<your config string here>');
  //   // We use a custom header "X-Approov-Token" rather than just "Approov-Token"
  //   ApproovService.setApproovHeader("X-Approov-Token", "");
  //   return approovClient;
  // }();

  static String get websocketUrl {
    return "${websocketProtocol}://${apiHost}/socket/websocket";
  }

  static final HttpLink httpLink = HttpLink(
      apiBaseUrl,
      httpClient: httpClient
  );

  static Stream<Response> handleLinkException(
      Request request,
      NextLink forward,
      LinkException exception,
      ) async* {
        print('HANDLE EXCEPTION ON LINK: ' + exception.toString());
  }

  static final AuthLink authLink = AuthLink(getToken: () => auth_token);

  static final Link link = ErrorLink(onException: handleLinkException).concat(authLink.concat(httpLink));

  static GraphQLClient buildGraphQLClient() {
    return GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }

  static ValueNotifier<GraphQLClient> initializeClient(String token) {
    auth_token = token;
    ValueNotifier<GraphQLClient> client = ValueNotifier(buildGraphQLClient());
    return client;
  }
}
