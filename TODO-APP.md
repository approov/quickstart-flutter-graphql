# Todo App

This is an Approov integration quickstart example for a Todo mobile app built with Flutter and using GraphQL. [Approov](https://approov.io) is an API security solution used to verify that requests received by your backend services originate from trusted versions of your mobile app, and you will see how simple is to integrate it in your mobile app with this example. For a generic Approov quickstart for Flutter GraphQL please check the [README.md](/README.md) at the root of this repo.

The base for this Todo app is derived, with gratitude from the [hasura/learn-graphql](https://github.com/hasura/learn-graphql/tree/c39f7731c609fb24c10a66c8ee574b4cb02f9a41/tutorials/mobile/flutter-graphql/app-final) repo, that has a [MIT license](https://github.com/hasura/learn-graphql/blob/c39f7731c609fb24c10a66c8ee574b4cb02f9a41/LICENSE), that is also on this repo. The Hasura repo is full of tutorials and examples that can be useful to start learning GraphQL or to sharpen your knowledge on it.

## WHAT YOU WILL NEED
* Access to a trial or paid Approov account
* The `approov` command line tool [installed](https://approov.io/docs/latest/approov-installation/) with access to your account
* [Android Studio](https://developer.android.com/studio) installed (version ArticFox 2020.3.1 is used in this guide) if you will build the Android app
* [Xcode](https://developer.apple.com/xcode/) installed (version 13.0 is used in this guide) to build iOS version of application
* [Cocoapods](https://cocoapods.org) installed to support iOS building (1.11.2 used in this guide)
* [Flutter](https://flutter.dev) version 2.5.3 used in this guide with Dart 2.14.4
* The contents of this repo

## Try the Todo App without Approov

First, clone this repo:

```text
git clone https://github.com/approov/quickstart-flutter-graphql.git
```

Next, open your IDE on the folder `quickstart-flutter-graphql/src/app-final`.

Now, use the correspondent button of your IDE to get the dependencies.

Finally, you can build and run the Flutter Todo App by hitting the correspondent button in your IDE.

> **NOTE:** The app will run against this live backend `https://unprotected.phoenix-absinthe-graphql.demo.approov.io`, and the code for it is in this [Github repo](https://github.com/approov/quickstart-elixir-phoenix-absinthe-graphql-token-check).

### iOS Potential Issues

If the iOS build fails with an error related to `Pods-Runner` then navigate inside `ios` folder using `cd ios` and run `pod install`.

If the iOS build fails with a signing error, open the Xcode project located in `ios/Runner.xcworkspace`:

```
$ open ios/Runner.xcworkspace
```

and select your code signing team in the _Signing & Capabilities_ section of the project.

Also ensure you modify the app's `Bundle Identifier` so it contains a unique string (you can simply append your company name). This is to avoid Apple rejecting a duplicate `Bundle Identifier` when code signing is performed. Then return to the shell and repeat the failed build step.

Please also verify the minimum iOS supported version is set to `iOS 10` if there is a supported version mismatch error.

### Android Potential Issues
If the Android build fails with `Manifest merger failed : Attribute application@label value=([...]) from AndroidManifest.xml:11:9-46 is also present at [approov-sdk.aar] AndroidManifest.xml:12:9-41 value=(@string/app_name)`, then open `android/app/src/main/AndroidManifest.xml` in an editor and make the following changes.

- Add the schema as an attribute in the `manifest` tag:

```
    <manifest ...
        xmlns:tools="http://schemas.android.com/tools"
        ... >
```
- Add the `android:label` and `tools` attributes to the `application` tag:
```
    <application ...
        android:label="@string/app_name"
        tools:replace="label"
        ... >
```

## Adding APPROOV Support

Approov protection is provided through the `approov_service_flutter_httpclient` plugin for both, Android and iOS mobile platforms. This plugin handles all Approov related functionality, such as downloading and instalation of Approov SDK library, initialization, managing of initial and update configurations, fetching of Approov tokens, adding these to API requests as necessary, and manages certificate public key pinning. The plugin also requests all necessary network permissions.

The `Absinthe` support is located in the [approov-flutter-packages](https://github.com/approov/approov-flutter-packages.git) repository and is automatically installed by replacing the original `pubspec.yaml` file with the modified `pubspec.yaml.approov-example`. Using the shell from the directory `quickstart-flutter-graphql/src/app-final`:

```Bash
cp pubspec.yaml.approov-example pubspec.yaml
```

Now you need to link the ApproovSDK to your account. This requires editing two files and replacing the originals. Edit the file `quickstart-flutter-graphql/src/app-final/lib/config/client.dart.approov-example` by finding the line that contains:

```Dart
var approovClient = ApproovClient('<enter your config here>');
```

The `<enter-your-config-string-here>` is a custom string that configures your Approov account access. This will have been provided in your Approov onboarding email.

Now edit the file `quickstart-flutter-graphql/src/app-final/lib/config/absinthe_socket.dart.approov-example` and locate this line:

```Dart
_socket = AbsintheSocket(
      Config.websocketUrl,
      "<your config string here>",
      socketOptions: AbsintheSocketOptions(
          params: {"Authorization": Config.auth_token}),
    );
```

The `<enter-your-config-string-here>` needs to be replaced by the string you obtained during account registration.

Now replace the files from the command line:

```Bash
cp pubspec.yaml.approov-example pubspec.yaml
cp lib/config/client.dart.approov-example lib/config/client.dart
cp lib/config/absinthe_socket.dart.approov-example lib/config/absinthe_socket.dart
```

Finally, open the Todo app in your IDE, from the `src/app-final` folder, and then use the correspondent button of your IDE to fetch your new dependencies, but don't build or run the Todo app yet.


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

For Android:

```text
approov registration -add build/app/outputs/flutter-apk/app-debug.apk --expireAfter 1h
```

For iOS: It is necessary to build an app archive (.ipa extension) and export it to a convenient location, for example the `quickstart-flutter-graphql` directory. Install the app's .ipa on the device in order to ensure that the installed version and the registered version are the same. Assuming you have built an app archive, signed it and exported it to `quickstart-flutter-graphql/Runner\ 2021-02-04\ 14-27-30/app-final.ipa`, the registration command is:

```text
approov registration -add ../../Runner\ 2021-02-04\ 14-27-30/app-final.ipa --expireAfter 1h
```

> **IMPORTANT:** During development always use the `--expireAfter` flag with an expiration that best suits your needs, using `h` for hours and `d` for days. By default, an app registration is permanent and will remain in the Approov cloud database until it is explicitly removed. Permanent app registrations should be used to identify apps that are being published to production.

Finally, you can now use the Todo app and play with it, but you need to restart it in order for the mobile to get a valid Approov token, because in the first launch it was not yet registered with the Approov cloud service.

> **NOTE:** To not have to restart the mobile app you can try to build the mobile app, then register it with Approov and then launch it, but this often leads to a failure in Approov not recognizing the mobile app as registered, because the way Flutter works it seems that in development it always build the mobile app when you hit the run button, even when no code changes had taken place, thus resulting in a different binary(maybe a timestamp is added in the build process), therefore not the same you had registered previously. This is also true for when using the `flutter` cli.

For a **production release** rest assured that you don't need to launch the mobile app, just build it and register it. Please read our docs at [Managing Registrations](https://approov.io/docs/latest/approov-usage-documentation/#managing-registrations) for more details in how to proceed.


#### Development Work-flow

The registration step is required for each time you change your code, even if you are just commenting out a line of code or fixing a typo in a variable.

The Flutter hot reload functionality doesn't write to the disk any changes made to the code, therefore you cannot re-register the mobile app without stopping it and start it again, thus for a better development work-flow you may want to [whitelist](https://approov.io/docs/latest/approov-usage-documentation/#adding-a-device-security-policy) your mobile device with the Approov cloud service. This way the mobile app always get valid Approov tokens without the need to re-register it for each modification made to the code.

For example:

```text
approov device -add h4gubfCFzJu81j/U2BJsdg== -policy default,whitelist,all
```

The value `h4gubfCFzJu81j/U2BJsdg==` is the device id, and you can read on our docs the section [Extracting the Device ID](https://approov.io/docs/latest/approov-usage-documentation/#extracting-the-device-id) for more details how you can do it.

[TOC](/README.md#toc)

