# Approov Quickstart: Flutter GraphQL

[Approov](https://approov.io) is an API security solution used to verify that requests received by your backend services originate from trusted versions of your mobile apps.

This is an Approov integration quickstart example for a mobile app built with Flutter and using GraphQL and specificaly a dart client for GraphQL subscriptions via [Absinthe](http://absinthe-graphql.org/) sockets. If you are looking for another mobile app integration you can check our list of [quickstarts](https://approov.io/docs/latest/approov-integration-examples/mobile-app/), and if you don't find what you are looking for, then please let us know [here](https://approov.io/contact). A more detailed step-by-step guide using a [Todo App](https://github.com/approov/quickstart-flutter-graphql/blob/master/TODO-APP.md) is also available.


## ADDING Approov Enabled Flutter GraphQL

Approov Enabled Flutter GraphQL is available via [`Github`](https://github.com/approov/approov-flutter-packages.git) package. This allows inclusion into the project by simply specifying a dependency in the `pubspec.yaml` files for the app. In the `dependencies:` section of `pubspec.yaml` file add the following package reference:

```yaml
absinthe_socket:
  git:
    url: https://github.com/approov/approov-flutter-packages.git
    path: absinthe_socket
approov_service_flutter_httpclient:
  git: https://github.com/approov/approov-service-flutter-httpclient.git
```

The `absinthe_socket` package uses a predefined header to forward the Approov Token and also forwards the Approov SDK initialization string to the `approov_web_socket` package by using a `PhoenixChannel` socket. The `approov_web_socket` package interacts with the `approov_service_flutter_httpclient` by means of an `ApproovHttpClient` object.

The `approov_service_flutter_httpclient` package is actually an open source wrapper layer that allows you to easily use Approov with `Flutter`. This has a further dependency to the closed source [Android Approov SDK](https://github.com/approov/approov-android-sdk) and [iOS Approov SDK](https://github.com/approov/approov-ios-sdk) packages. Those are automatically added as dependencies for the platform specific targets.

The `approov_service_flutter_httpclient` package declares four classes:

1. ApproovService and TokenFetchResult provide the SDK native binding
2. ApproovHttpClient which is a drop-in replacement for the Dart IO library's HttpClient and calls the ApproovService
3. ApproovClient which is a drop-in replacement for Client from the Flutter http package (https://pub.dev/packages/http)
    and uses internally an ApproovHttpClient object

### ANDROID

The `approov_service_flutter_httpclient` adds an additional repository to the `build.gradle` project file:

```gradle
maven { url 'https://jitpack.io' }
```

and two implementation dependecies:

```gradle
dependencies {
    implementation 'com.squareup.okhttp3:okhttp:4.9.3'
    implementation 'com.github.approov:approov-android-sdk:2.9.0'
}
```

### ANDROID MANIFEST CHANGES

The following app permissions need to be available in the manifest of your application to be able to use Approov:

```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
```

Note that the minimum SDK version you can use with the Approov package is 21 (Android 5.0). 

Please [read this](https://approov.io/docs/latest/approov-usage-documentation/#targetting-android-11-and-above) section of the reference documentation if targetting Android 11 (API level 30) or above.

### IOS

The `approov_service_flutter_httpclient` generates a [Cocoapods](https://cocoapods.org) dependency file which must be installed by executing:

```Bash
pod install
```

in the directory containing the ios project files.

## Initializing and Using the AbsintheSocket

You need to instantiate the `AbsintheSocket` with an additional parameter:

```Dart
_socket = AbsintheSocket(
      Config.websocketUrl,
      "<your config string here>",
      socketOptions: AbsintheSocketOptions(
          params: {"Authorization": Config.auth_token}),
    );
```

The `<enter-your-config-string-here>` is a custom string that configures your Approov account access. This will have been provided in your Approov onboarding email.


### Approov Http Client

The last step is to use the Approov Http Client in your code. This is a drop in replacement for the Flutter native Http Client.

So, wherever you have your HttpClient defined, you should replace it with the drop-in Approov HttpClient:

```dart
import 'package:approov_service_flutter_httpclient/approov_service_flutter_httpclient.dart';

//static final httpClient = new http.Client();
http.Client client = ApproovClient('<enter-your-config-string-here>');
```

Full example code for a Phoenix Channels mobile app:

```dart
import 'package:approov_service_flutter_httpclient/approov_service_flutter_httpclient.dart';

class PinnedHttp {
  static String apiBaseUrl = 'YOUR_API_SERVER_BASE_URL_HERE';

  http.Client client = ApproovClient('<enter-your-config-string-here>');
}
```

So, wherever you have your HttpLink defined, you should add the Approov HttpClient to it:

```dart
import 'package:approov_service_flutter_httpclient/approov_service_flutter_httpclient.dart';

static final approovClient = ApproovClient('<enter-your-config-string-here>');

final HttpLink httpLink = HttpLink(
    uri: apiBaseUrl,
    httpClient: approovClient
);
```

Full example code for a GraphQL project:

```dart
// similar to: src/app-final/lib/config/client.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:approov_service_flutter_httpclient/approov_service_flutter_httpclient.dart';

class PinnedHttp {

  // Will be set when calling PinnedHttp.initializeClient(token)
  static String _userAuthToken;

  static String apiBaseUrl = 'YOUR_API_SERVER_BASE_URL_HERE';

  static final approovClient = ApproovClient('<enter-your-config-string-here>');

  final HttpLink httpLink = HttpLink(
      uri: apiBaseUrl,
      httpClient: approovClient
  );

  final AuthLink authLink = AuthLink(
    getToken: () async => _userAuthToken,
  );

  final Link link = authLink.concat(httpLink);

  static ValueNotifier<GraphQLClient> initializeClient(String token) {
      _userAuthToken = token;

      ValueNotifier<GraphQLClient> client = ValueNotifier(
        GraphQLClient(
          cache: OptimisticCache(dataIdFromObject: typenameDataIdFromObject),
          link: link,
        ),
      );

      return client;
  }
}
```

## Checking it Works

Initially you won't have set which API domains to protect, so the interceptor will not add anything. It will have called Approov though and made contact with the Approov cloud service. You will see logging from Approov saying `UNKNOWN_URL`.

Your Approov onboarding email should contain a link allowing you to access [Live Metrics Graphs](https://approov.io/docs/latest/approov-usage-documentation/#metrics-graphs). After you've run your app with Approov integration you should be able to see the results in the live metrics within a minute or so. At this stage you could even release your app to get details of your app population and the attributes of the devices they are running upon.

However, to actually protect your APIs there are some further steps you can learn about in [Next Steps](https://github.com/approov/quickstart-flutter-graphql/blob/master/NEXT-STEPS.md).
