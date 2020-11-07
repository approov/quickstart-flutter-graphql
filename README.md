# Approov Quickstart: Flutter GraphQL Todo App

[Approov](https://approov.io) is an API security solution used to verify that requests received by your backend services originate from trusted versions of your mobile apps.

This is an Approov integration quickstart example for a mobile app built with Flutter and using GraphQL. If you are looking for another mobile app integration you can check our list of [quickstarts](https://approov.io/docs/latest/approov-integration-examples/mobile-app/), and if you don't find what you are looking for, then please let us know [here](https://approov.io/contact).

## TOC

* [Overview](#overview)
    + [What you will need](#what-you-will-need)
    + [What you will learn](#what-you-will-learn)
* [Todo App](#todo-app):
    + [Without Approov](#try-the-todo-app-without-approov)
    + [With Approov](#enable-approov-in-the-todo-app)
* [Approov Integration Quickstart](#approov-integration-quickstart-in-your-app)
    + [Approov Plugin Setup](#approov-plugin-setup)
    + [Approov Http Client](#approov-http-client)
    + [Mobile App Binary Registration](#mobile-app-binary-registration)
* [Next Steps](#next-steps)
* [Credits](#credits)


## Overview

### What You Will Need

* Access to either the demo account ([request access here](https://info.approov.io/demo-token)) or a trial/paid Approov account
* The `approov` command line tool [installed](https://approov.io/docs/latest/approov-installation/) with `APPROOV_MANAGEMENT_TOKEN` set with your account access token
* Flutter installed. This quickstart uses version:

  ```text
  flutter --version
  Flutter 1.22.2 • channel stable • https://github.com/flutter/flutter.git
  Framework • revision 84f3d28555 (3 weeks ago) • 2020-10-15 16:26:19 -0700
  Engine • revision b8752bbfff
  Tools • Dart 2.10.2
  ```

[TOC](#toc)

### What You Will Learn

* How to integrate Approov into a real app in a step by step fashion
* How to register your app to get valid tokens from Approov
* A solid understanding of how to integrate Approov into your own app that uses Flutter with GraphQL
* Some pointers to other Approov features

[TOC](#toc)


## Todo App

### Try the Todo App without Approov

Clone this repo:

```text
git clone https://github.com/approov/quickstart-flutter-graphql-todo-app.git
```

Move inside it:

```text
cd quickstart-flutter-graphql-todo-app/src/app-final
```

Run the Flutter app:

```
flutter run
```

[TOC](#toc)

### Enable Approov in the Todo App

First, make sure you are inside the folder `src/app-final`:

```text
cd src/app-final
```

Now, follow the instructions for the [Approov Plugin Setup](#approov-plugin-setup), and return here when you arrive to the instruction to edit the `pubspec.yml` file.

Next, while inside the `src/app-final` folder, open this files:

* `pubspec.yaml`
* `lib/config/client.dart`
* `android/app/src/debug/AndroidManifest.xml`

For each of the opened files:

* Comment out the line below any occurrence of `COMMENT OUT FOR APPROOV`.
* Uncomment the line below any occurrence of `UNCOMMENT FOR APPROOV`.

Fetch your new dependencies:

```text
flutter pub get
```

Build the mobile app binary:

```text
flutter build apk --debug
```

Before you can run the Todo App you need to register the APK with the Approov Cloud Service:

```text
approov registration -add build/app/outputs/flutter-apk/app-debug.apk --expireAfter 1h
```

Finally, run the Flutter app:

```
flutter run --no-fast-start
```

[TOC](#toc)


## Approov Integration Quickstart in your App

### Approov Plugin Setup

Clone the Approov Flutter library:

```text
git clone https://github.com/approov/quickstart-flutter-httpclient.git src/plugins/flutter-httpclient
```

Add the Approov SDK to the Approov plugin:

```text
approov sdk -getLibrary src/plugins/flutter-httpclient/approovsdkflutter/android/approovsdk/approovsdk.aar
```

Retrieve the `approov-initial.config` file and save it to the root of your project:

```
approov sdk -getConfig approov-initial.config
```

Edit your `pubspec.yaml` and add the Approov SDK and the `approov-initial.config` to it:

```yml
dependencies:
  approovsdkflutter:
    path: ./../plugins/flutter-httpclient/approovsdkflutter

flutter:
  assets:
    - approov-initial.config
```

[TOC](#toc)


### Approov Http Client

The last step is to use the Approov Http Client in your code. This is a drop in replacement for the Flutter native Http Client.

Now, to use it from your GraphQL project:

```dart
import 'package:approovsdkflutter/approovsdkflutter.dart';

final HttpLink httpLink = HttpLink(
    uri: 'http://10.0.2.2:8002',
    httpClient: ApproovClient()
);

final AuthLink authLink = AuthLink(
  getToken: () async => "YOUR-AUTH-TOKEN-HERE",
);

final Link link = authLink.concat(httpLink);

ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(
    cache: InM
    emoryCache(),
    link: link
  ),
);
```

[TOC](#toc)


### Mobile App Binary Registration

In order to use your mobile app with Approov you need to register the mobile app binary each time you build it.

First, build the mobile app:

```text
flutter build <YOUR-OPTIONS-AND-ARGS-HERE>
```

For development:

```
approov registration -add build/app/outputs/flutter-apk/app-debug.apk --expireAfter 1h
```

For a production release:

```
approov registration -add build/app/outputs/flutter-apk/app-debug.apk
```

Always use `--no-fast-start` when restarting the Flutter app, after registering it with Approov:

```text
flutter run --no-fast-start
```

[TOC](#toc)


## Next Steps

This quick start guide has shown you how to integrate Approov with your existing app. Now you might want to explore some other Approov features:

* Managing your app [registrations](https://approov.io/docs/latest/approov-usage-documentation/#managing-registrations)
* Manage the [pins](https://approov.io/docs/latest/approov-usage-documentation/#public-key-pinning-configuration) on the API domains to ensure that no Man-in-the-Middle attacks on your app's communication are possible.
* Update your [Security Policy](https://approov.io/docs/latest/approov-usage-documentation/#security-policies) that determines the conditions under which an app will be given a valid Approov token.
* Learn how to [Manage Devices](https://approov.io/docs/latest/approov-usage-documentation/#managing-devices) that allows you to change the policies on specific devices.
* Understand how to issue and revoke your own [Management Tokens](https://approov.io/docs/latest/approov-usage-documentation/#management-tokens) to control access to your Approov account.
* Use the [Metrics Graphs](https://approov.io/docs/latest/approov-usage-documentation/#metrics-graphs) to see live and accumulated metrics of devices using your account and any reasons for devices being rejected and not being provided with valid Approov tokens. You can also see your billing usage which is based on the total number of unique devices using your account each month.
* Use [Service Monitoring](https://approov.io/docs/latest/approov-usage-documentation/#service-monitoring) emails to receive monthly (or, optionally, daily) summaries of your Approov usage.
* Consider using [Token Binding](https://approov.io/docs/latest/approov-usage-documentation/#token-binding). The method `<AppClass>.approovService!!.setBindingHeader` takes the name of the header holding the value to be bound. This only needs to be called once but the header needs to be present on all API requests using Approov.
* Investigate other advanced features, such as [Offline Security Mode](https://approov.io/docs/latest/approov-usage-documentation/#offline-security-mode), [DeviceCheck Integration](https://approov.io/docs/latest/approov-usage-documentation/#apple-devicecheck-integration) and [Android Automated Launch Detection](https://approov.io/docs/latest/approov-usage-documentation/#android-automated-launch-detection).

[TOC](#toc)


## Credits

The base for this Todo app is borrowed from the [hasura/learn-graphql](https://github.com/hasura/learn-graphql/tree/c39f7731c609fb24c10a66c8ee574b4cb02f9a41/tutorials/mobile/flutter-graphql/app-final) repo, that has a [MIT license](https://github.com/hasura/learn-graphql/blob/c39f7731c609fb24c10a66c8ee574b4cb02f9a41/LICENSE), that is also on this repo. The Hasura repo is full of tutorials and examples that can be useful to start learning GraphQL or to sharp your knowledge on it.

[TOC](#toc)
