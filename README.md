# Approov Quickstart: Flutter GraphQL Todo App

[Approov](https://approov.io) is an API security solution used to verify that requests received by your backend services originate from trusted versions of your mobile apps.

This is an Approov integration quickstart example for a mobile app built with Flutter and using GraphQL. If you are looking for another mobile app integration you can check our list of [quickstarts](https://approov.io/docs/latest/approov-integration-examples/mobile-app/), and if you don't find what you are looking for, then please let us know [here](https://approov.io/contact).


## TOC

* [Overview](#overview)
    + [What you will need](#what-you-will-need)
    + [What you will learn](#what-you-will-learn)
* [Approov Integration Quickstart](#approov-integration-quickstart-in-your-app)
    + [Approov Plugin Setup](#approov-plugin-setup)
    + [Approov Http Client](#approov-http-client)
    + [Mobile API Registration](#mobile-api-registration)
    + [Mobile App Binary Registration](#mobile-app-binary-registration)
* [Todo App Example](/src/app-final/README.md)
* [Next Steps](#next-steps)


## Overview

### What You Will Need

* Access to a trial or paid Approov account
* The `approov` command line tool [installed](https://approov.io/docs/latest/approov-installation/) with access to your account
* Flutter installed. This quickstart uses version:

  ```text
  flutter --version
  Flutter 2.0.6 • channel stable • https://github.com/flutter/flutter.git
  Framework • revision 1d9032c7e1 (12 days ago) • 2021-04-29 17:37:58 -0700
  Engine • revision 05e680e202
  Tools • Dart 2.12.3
  ```

[TOC](#toc)

### What You Will Learn

* How to integrate Approov into a real app in a step by step fashion
* How to register your app to get valid tokens from Approov
* A solid understanding of how to integrate Approov into your own app that uses Flutter with GraphQL
* Some pointers to other Approov features

[TOC](#toc)


## Approov Integration Quickstart in your App

This quickstart is for any developer looking to integrate Approov in their own mobile app. For an hands-on ready mobile app example you can follow the [guide](/src/app-final/README.md) for the Todo app example included in this repo.

### Approov Plugin Setup

At the root of your project create a folder named `approov`:

```text
mkdir approov
```

Clone the Approov Flutter plugin into the `approov` folder:

```text
git clone https://github.com/approov/quickstart-flutter-httpclient.git approov/flutter-httpclient
```
> **NOTE:** The Approov Flutter plugin will be located at `your-project/approov` folder

Download the Android Approov SDK and add it to the Approov HTTP Client plugin:

```text
approov sdk -getLibrary approov/flutter-httpclient/approov_http_client/android/approov-sdk.aar
```
> **NOTE:** The approov command is downloading the Approov SDK into the folder `your-project/approov/flutter-httpclient/approov_http_client/android/approov-sdk.aar`

Do the same for iOS:

```text
approov sdk -getLibrary approov/flutter-httpclient/approov_http_client/ios/Approov.xcframework
```
> **NOTE:** The approov command is downloading the Approov SDK into the folder `your-project/approov/flutter-httpclient/approov_http_client/ios`

Retrieve the `approov-initial.config` file and save it to the root of your project:

```
approov sdk -getConfig approov-initial.config
```
> **NOTE:** The Approov initial config will be located at `your-project/approov-initial.config`

Edit your `pubspec.yaml` and add the Approov SDK and the `approov-initial.config` to it:

```yml
dependencies:
  approov_http_client:
    path: ./approov/flutter-httpclient/approov_http_client

flutter:
  assets:
    - ./approov-initial.config
```

[TOC](#toc)


### Approov Http Client

The last step is to use the Approov Http Client in your code. This is a drop in replacement for the Flutter native Http Client.

So, wherever you have your HttpLink defined, you should add the Approov HttpClient to it:

```dart
import 'package:approov_http_client/approov_http_client.dart';

static final approovClient = ApproovClient();

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
import 'package:approov_http_client/approov_http_client.dart';

class PinnedHttp {

  // Will be set when calling PinnedHttp.initializeClient(token)
  static String _userAuthToken;

  static String apiBaseUrl = 'YOUR_API_SERVER_BASE_URL_HERE';

  static final approovClient = ApproovClient();

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

Usage example for protecting the user signup/login requests with Approov:

```dart
// similar to: src/app-final/lib/services/auth.dart

class UserAuth {
  final http = PinnedHttp.approovClient;

  // code omitted for brevity

  Response response = await http
    .post(
      "${PinnedHttp.apiBaseUrl}/auth/login",
      headers: {"content-type": "application/json"},
      body: jsonEncode(credentials),
    )
    .catchError((onError) {
      print(onError);
      return null;
    });

  // code omitted for brevity

}
```

Usage example from a Widget:

```dart
// similar to: src/app-final/lib/screens/dashboard.dart

// code omitted for brevity

if (snapshot.hasData) {
  children = GraphQLProvider(
    client: PinnedHttp.initializeClient(snapshot.data),

   // code omitted for brevity
  )
}
```

[TOC](#toc)


### Mobile API Registration

Approov needs to know the domain name of the API for which it will issue tokens.

Add it with:

```text
approov api -add your.api.domain.com
```

> **NOTE:** This only needs to be done one time per API, not for every time you register a mobile app binary.

The Approov cloud service will not issue Approov tokens for your mobile app if you forget this step, even if the mobile app binary is registered and no tampering is detected with the binary or the environment is running on.

Adding the API domain also configures the [dynamic certificate pinning](https://approov.io/docs/latest/approov-usage-documentation/#approov-dynamic-pinning) setup, out of the box. Approov Dynamic Pinning secures the communication channel between your app and your API with all the benefits of traditional pinning but without the drawbacks.

> **NOTE:** By default, the pin is extracted from the public key of the leaf certificate served by the domain, as visible to the box executing the Approov CLI command and the Approov servers.

[TOC](#toc)

### Mobile App Binary Registration

In order to use your mobile app with Approov you need to register the mobile app binary each time you build it.

First, build the mobile app by hitting the correspondent button in your IDE.

After the build is finished you can then register the resulting binary with the Approov CLI tool.

#### For Development:

For Android: from the root of your project execute:

```text
approov registration -add build/app/outputs/flutter-apk/app-debug.apk --expireAfter 1h
```

For iOS it is necessary to build an app archive (.ipa extension), to sign and to export it. Install the app's .ipa on the device in order to ensure that the installed version and the registered version are the same. Assuming you exported your .ipa to `Runner/app.ipa` at the root of your project, the registration command is:

```text
approov registration -add Runner/app.ipa --expireAfter 1h
```

> **IMPORTANT:** During development always use the `--expireAfter` flag with an expiration that best suits your needs, using `h` for hours and `d` for days. By default, an app registration is permanent and will remain in the Approov cloud database until it is explicitly removed. Permanent app registrations should be used to identify apps that are being published to production. Read more in our docs at [Managing Registrations](https://approov.io/docs/latest/approov-usage-documentation/#managing-registrations).

This registration step is required for each time you change your code, even if you are just commenting out a line of code or fixing a typo in a variable.

The Flutter hot reload functionality doesn't write to the disk any changes made to the code, therefore you cannot re-register the mobile app without stopping it and starting it again, thus for a better development work-flow you may want to [whitelist](https://approov.io/docs/latest/approov-usage-documentation/#adding-a-device-security-policy) your mobile device with the Approov cloud service. This way the mobile app always get valid Approov tokens without the need to re-register it for each modification made to the code.

For example:

```text
approov device -add h4gubfCFzJu81j/U2BJsdg== -policy default,whitelist,all
```

The value `h4gubfCFzJu81j/U2BJsdg==` is the device id, and you can read on our docs the section [Extracting the Device ID](https://approov.io/docs/latest/approov-usage-documentation/#extracting-the-device-id) for more details how you can do it.

#### For Production

For a production release, you can refer to the [Managing Registration](https://approov.io/docs/latest/approov-usage-documentation/#managing-registrations) section of our docs for instructions on the several methods that can be used for Android and iOS.


[TOC](#toc)


## Next Steps

This quick start guide has shown you how to integrate Approov with your existing app. Now you might want to explore some other Approov features:

* Managing your app [registrations](https://approov.io/docs/latest/approov-usage-documentation/#managing-registrations)
* Manage the [pins](https://approov.io/docs/latest/approov-usage-documentation/#public-key-pinning-configuration) on the API domains to ensure that no Man-in-the-Middle attacks on your app's communication are possible.
* Update your [Security Policy](https://approov.io/docs/latest/approov-usage-documentation/#security-policies) that determines the conditions under which an app will be given a valid Approov token.
* Learn how to [Manage Devices](https://approov.io/docs/latest/approov-usage-documentation/#managing-devices) that allows you to change the policies on specific devices.
* Understand how to provide access for other [Users](https://approov.io/docs/latest/approov-usage-documentation/#user-management) of your Approov account.
* Use the [Metrics Graphs](https://approov.io/docs/latest/approov-usage-documentation/#metrics-graphs) to see live and accumulated metrics of devices using your account and any reasons for devices being rejected and not being provided with valid Approov tokens. You can also see your billing usage which is based on the total number of unique devices using your account each month.
* Use [Service Monitoring](https://approov.io/docs/latest/approov-usage-documentation/#service-monitoring) emails to receive monthly (or, optionally, daily) summaries of your Approov usage.
* Consider using [Token Binding](https://approov.io/docs/latest/approov-usage-documentation/#token-binding). The method `<AppClass>.approovService!!.setBindingHeader` takes the name of the header holding the value to be bound. This only needs to be called once but the header needs to be present on all API requests using Approov.
* Learn about [automated approov CLI usage](https://approov.io/docs/latest/approov-usage-documentation/#automated-approov-cli-usage).
* Investigate other advanced features, such as [Offline Security Mode](https://approov.io/docs/latest/approov-usage-documentation/#offline-security-mode), [DeviceCheck Integration](https://approov.io/docs/latest/approov-usage-documentation/#apple-devicecheck-integration), [SafetyNet Integration](https://approov.io/docs/latest/approov-usage-documentation/#google-safetynet-integration) and [Android Automated Launch Detection](https://approov.io/docs/latest/approov-usage-documentation/#android-automated-launch-detection).

[TOC](#toc)

