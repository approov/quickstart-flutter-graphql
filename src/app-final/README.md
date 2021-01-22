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

Now, from inside the `src/app-final` folder, clone the Approov Flutter supporting packages into the `src/app-final/approov` folder, by executing from `src/app-final`:

```text
git clone https://github.com/approov/approov-flutter-packages.git approov
```

> **NOTE:** The Approov Flutter supporting packages _must_ be cloned first, then the Approov HTTP Client package or `git clone` will fail with the error: `src/app-final/approov` directory not empty.

Clone the Approov HTTP Client package into the `src/app-final/approov` folder, by executing from `src/app-final`:

```text
git clone https://github.com/approov/quickstart-flutter-httpclient.git approov/flutter-httpclient
```

Download the Android Approov SDK and add it to the Approov plugin, by executing from `src/app-final` folder:

```text
approov sdk -getLibrary approov/flutter-httpclient/approov_http_client/android/approov-sdk.aar
```
> **NOTE:** The approov command is downloading the Approov SDK into the folder `src/app-final/approov/flutter-httpclient/approov_http_client/android/approov-sdk.aar`

Do the same for iOS by executing from `src/app-final` folder:

```text
approov sdk -getLibrary approov.zip
unzip approov.zip -d approov/flutter-httpclient/approov_http_client/ios
rm -rf approov.zip
```
> **NOTE:** The unzip command is unzipping the Approov library into `src/app/final/approov/flutter-httpclient/approov_http_client/ios`

Retrieve the `approov-initial.config` and save it into `src/app-final/approov-initial.config`. From inside the `src/app-final` folder execute:

```text
approov sdk -getConfig approov-initial.config
```

Time to enable Approov, by replacing two files, and we do this by executing from `src/app-final`:

```text
cp pubspec.yaml.approov-example pubspec.yaml
cp lib/config/client.dart.approov-example lib/config/client.dart
```

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

After the Todo app has been launched in the device it should open in the **signin/signup** screen. If not, then it means you have done previous attempts to follow this guide, and have not unisntalled the mobile app as instructed in the above **IMPORTANT** alert.

Now, you can go ahead and register the resulting binary with the Approov CLI tool. For development execute from inside the `src/app-final` folder:

```
approov registration -add build/app/outputs/flutter-apk/app-debug.apk --expireAfter 1h
```

Or for iOS by executing from `src/app-final` folder (assuming you have built an app archive, signed it and exported it to `src/app-final/Runner 2020-10-12 09-24-57/app-final.ipa):
```
approov registration -add Runner\ 2020-10-12\ 09-24-57/app-final.ipa --expireAfter 1h
```

> **IMPORTANT:** During development always use the `--expireAfter` flag with an expiration that best suits your needs, using `h` for hours and `d` for days. By default, an app registration is permanent and will remain in the Approov cloud database until it is explicitly removed. Permanent app registrations should be used to identify apps that are being published to production.

Finally, you can now use the Todo app and play with it, but you need to restart it in order for the mobile to get a valid Approov token, because in the first launch it was not yet registered with the Approov cloud service.

> **NOTE:** To not have to restart the mobile app you can try to build the mobile app, then register it with Approov and then launch it, but this often leads to a failure in Approov not recognizing the mobile app as registered, because the way Flutter works it seems that in development it always build the mobile app when you hit the run button, even when no code changes had taken place, thus resulting in a different binary(maybe a timestamp is added in the build process), therefore not the same you had registered previously. This is also true for when using the `flutter` cli.

For a **production release** be rest assured that you don't need to launch the mobile app, just build it and register it. Please read our docs at [Managing Registrations](https://approov.io/docs/latest/approov-usage-documentation/#managing-registrations) for more details in how to proceed.


#### Development Work-flow

The registration step is required for each time you change your code, even if you are just commenting out a line of code or fixing a typo in a variable.

The Flutter hot reload functionality doesn't write to the disk any changes made to the code, therefore you cannot re-register the mobile app without stopping it and start it again, thus for a better development work-flow you may want to [whitelist](https://approov.io/docs/latest/approov-usage-documentation/#adding-a-device-security-policy) your mobile device with the Approov cloud service. This way the mobile app always get valid Approov tokens without the need to re-register it for each modification made to the code.

For example:

```text
approov device -add h4gubfCFzJu81j/U2BJsdg== -policy default,whitelist,all
```

The value `h4gubfCFzJu81j/U2BJsdg==` is the device id, and you can read on our docs the section [Extracting the Device ID](https://approov.io/docs/latest/approov-usage-documentation/#extracting-the-device-id) for more details how you can do it.

[TOC](/README.md#toc)


### Approov Integration Code Difference

Lets's check what have changed to enable Approov in each file...

For `pubspec.yaml` we execute from `src/app-final`:

```text
git diff pubspec.yaml
```

The output:

```text
@@ -23,6 +23,8 @@ dependencies:
   toast: ^0.1.5
   shared_preferences: ^0.5.7+3
   graphql_flutter: ^3.0.1
+  approov_http_client:
+    path: ./approov/flutter-httpclient/approov_http_client

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
+import 'package:approov_http_client/approov_http_client.dart';

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

[TOC](/README.md#toc)
