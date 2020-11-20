# Todo App

This is an Approov integration quickstart example for a Todo mobile app built with Flutter and using GraphQL. [Approov](https://approov.io) is an API security solution used to verify that requests received by your backend services originate from trusted versions of your mobile app, and you will see how simple is to integrate it in your mobile app with this example. For a generic Approov quickstart for Flutter GraphQL please check the [README.md](/README.md) at the root of this repo.

The base for this Todo app is derived, with gratitude from the [hasura/learn-graphql](https://github.com/hasura/learn-graphql/tree/c39f7731c609fb24c10a66c8ee574b4cb02f9a41/tutorials/mobile/flutter-graphql/app-final) repo, that has a [MIT license](https://github.com/hasura/learn-graphql/blob/c39f7731c609fb24c10a66c8ee574b4cb02f9a41/LICENSE), that is also on this repo. The Hasura repo is full of tutorials and examples that can be useful to start learning GraphQL or to sharpen your knowledge on it.


## Try the Todo App without Approov

First, clone this repo:

```text
git clone https://github.com/approov/quickstart-flutter-graphql.git
```

Next, open your IDE on the folder `quickstart-flutter-graphql/src/app-final`.

Now, use the correspondent button of your IDE to get the dependencies.

Finally, you can build and run the Flutter Todo App by hitting the correspondent button in your IDE.

> **NOTE:** The app will run against this live backend `https://unprotected.phoenix-absinthe-graphql.demo.approov.io`, and the code for it is in this [Github repo](https://github.com/approov/quickstart-elixir-phoenix-absinthe-graphql-token-check).

[TOC](/README.md#toc)


## Enable Approov in the Todo App

First, ensure you have the Approov CLI installed by typing in your terminal `approov`. If not, you can follow [these instructions](https://approov.io/docs/latest/approov-installation/) to install it.

### Approov Plugin Setup

All commands to execute from a terminal will assume that you are inside the `src/app-final` folder, thus make sure you are inside it:

```text
cd src/app-final
```

Now, from inside the `src/app-final` folder create the `approov` folder:

```text
mkdir approov
```

Clone the Approov Flutter plugin into the `src/app-final/approov` folder, by executing from `src/app-final`:

```text
git clone https://github.com/approov/quickstart-flutter-httpclient.git approov/flutter-httpclient
```

Download the Android Approov SDK and add it to the Approov plugin, by executing from `src/app-final` folder:

```text
approov sdk -getLibrary approov/flutter-httpclient/approovsdkflutter/android/approovsdk/approovsdk.aar
```
> **NOTE:** The approov command is downloading the Approov SDK into the folder `src/app-final/approov/flutter-httpclient/approovsdkflutter/android/approovsdk/approovsdk.aar`

Do the same for iOS by executing from `src/app-final` folder:

```text
approov sdk -getLibrary approov.zip
unzip approov.zip -d approov/flutter-httpclient/approovsdkflutter/ios
rm -rf approov.zip
```
> **NOTE:** The unzip command is unzipping the Approov library into `src/app/final/approov/flutter-httpclient/approovsdkflutter/ios`

Retrieve the `approov-initial.config` and save it into `src/app-final/approov-initial.config`. From inside the `src/app-final` folder execute:

```text
approov sdk -getConfig approov-initial.config
```

Time to enable Approov, by replacing two files, and we do this by executing from `src/app-final`:

```text
cp pubspec.yaml.approov-example pubspec.yaml
cp lib/config/client.dart.approov-example lib/config/client.dart
```

Lets's check what have changed to enable Approov in each file...

For `pubspec.yml` we execute from `src/app-final`:

```text
git diff pubspec.yaml
```

The output:

```text
@@ -23,6 +23,8 @@ dependencies:
   toast: ^0.1.5
   shared_preferences: ^0.5.7+3
   graphql_flutter: ^3.0.1
+  approovsdkflutter:
+    path: ./approov/flutter-httpclient/approovsdkflutter

   # The following adds the Cupertino Icons font to your application.
   # Use with the CupertinoIcons class for iOS style icons.
@@ -39,6 +41,9 @@ dev_dependencies:
 # The following section is specific to Flutter.
 flutter:

+ assets:
+   - ./approov-initial.config
+
   # The following line ensures that the Material Icons font is
```

Next, lets check the `client.dart` file by executing from the `src/app-final` folder:

```text
git diff lib/config/client.dart
```

The output:

```text
@@ -1,7 +1,7 @@
 import 'dart:io';
 import 'package:flutter/material.dart';
 import 'package:graphql_flutter/graphql_flutter.dart';
-import 'package:http/http.dart' as http;
+import 'package:approovsdkflutter/approovsdkflutter.dart';

 class Config {
   static String _token;
@@ -14,7 +14,9 @@ class Config {
     }
   }

-  static String apiHost = 'unprotected.phoenix-absinthe-graphql.demo.approov.io';
+  // Choose one of the below endpoints:
+  static String apiHost = 'token.phoenix-absinthe-graphql.demo.approov.io';
+  // static String apiHost = 'token-binding.phoenix-absinthe-graphql.demo.approov.io';

   // static String apiBaseUrl = "http://${localhost}";
   static String apiBaseUrl = "https://${apiHost}";
@@ -22,7 +24,7 @@ class Config {
   // static String websocketUrl = "ws://${localhost}";
   // static String websocketUrl = "wss://${apiHost}";

-  static final httpClient = new http.Client();
+  static final  httpClient = ApproovClient();

   static final HttpLink httpLink = HttpLink(
```

The Git difference shows that adding Approov into an existing project is as simple as a few lines of code to add the dependency and then require and use it in the code.

Now, open the Todo app in your IDE, from the `src/app-final` folder, and then use the correspondent button of your IDE to fetch your new dependencies, but don't build or run the Todo app yet.

### Mobile API Registration

The app will run against [this backend](https://github.com/approov/quickstart-elixir-phoenix-absinthe-graphql-token-check), that is live at `token.phoenix-absinthe-graphql.demo.approov.io`, thus we also need to let the Approov cloud service know the API domain for it:

```text
approov api -add token.phoenix-absinthe-graphql.demo.approov.io
```
> **NOTE:** This command only needs to be executed the first time you register an APK with Approov.

The Approov cloud service will not issue Approov tokens for your mobile app if you forget this step, even if the mobile app binary is registered and no tampering is detected with the binary or the environment is running on.

Adding the API domain also configures the [dynamic certificate pinning](https://approov.io/docs/latest/approov-usage-documentation/#approov-dynamic-pinning) setup, out of the box. Approov Dynamic Pinning secures the communication channel between your app and your API with all the benefits of traditional pinning but without the drawbacks.

> **NOTE:** By default, the pin is extracted from the public key of the leaf certificate served by the domain, as visible to the box executing the Approov CLI command and the Approov servers.

If you want to run the mobile app against a backend you have control off, then you need to follow the [deployment guide](https://github.com/approov/quickstart-elixir-phoenix-absinthe-graphql-token-check/blob/master/DEPLOYMENT.md) for the backend of this Todo App. Remember that this backend needs to be reachable from the Internet, otherwise, the mobile app will not get Approov tokens, because the Approov cloud service will not be able to get the pins for configuring the dynamic pinning, that you get out of the box when you integrate Approov in a mobile app.

### Mobile App Binary Registration

In order to use your mobile app with Approov you need to register the mobile app binary each time you build it.

First, launch the Todo app by hitting the correspondent button in your IDE.

> **IMPORTANT:** If you already have attempted to follow this guide, and have the Todo app installed in your device, then you **MUST** uninstall it first, because Flutter seems to preserve state from previous attempts.

After the Todo app has been launched in the device you can then register the resulting binary with the Approov CLI tool.

For development execute from inside the `src/app-final` folder:

```
approov registration -add build/app/outputs/flutter-apk/app-debug.apk --expireAfter 1h
```
> **IMPORTANT:** During development always use the `--expireAfter` flag with an expiration that best suits your needs, using `h` for hours and `d` for days. By default, an app registration is permanent and will remain in the Approov cloud database until it is explicitly removed. Permanent app registrations should be used to identify apps that are being published to production. Read more in our docs at [Managing Registrations](https://approov.io/docs/latest/approov-usage-documentation/#managing-registrations).

Finally, you can now use the Todo app and play with it.


#### Development Work-flow

The registration step is required for each time you change your code, even if you are just commenting out a line of code or fixing a typo in a variable.

The Flutter hot reload functionality doesn't write to the disk any changes made to the code, therefore you cannot re-register the mobile app without stopping it and start it again, thus for a better development work-flow you may want to [whitelist](https://approov.io/docs/latest/approov-usage-documentation/#adding-a-device-security-policy) your mobile device with the Approov cloud service. This way the mobile app always get valid Approov tokens without the need to re-register it for each modification made to the code.

For example:

```text
approov device -add h4gubfCFzJu81j/U2BJsdg== -policy default,whitelist,all
```

The value `h4gubfCFzJu81j/U2BJsdg==` is the device id, and you can read on our docs the section [Extracting the Device ID](https://approov.io/docs/latest/approov-usage-documentation/#extracting-the-device-id) for more details how you can do it.

[TOC](/README.md#toc)
