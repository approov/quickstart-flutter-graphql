# Todo App

This is an Approov integration quickstart example for a Todo mobile app built with Flutter and using GraphQL. [Approov](https://approov.io) is an API security solution used to verify that requests received by your backend services originate from trusted versions of your mobile app, and you will see how simple is to integrate it in your mobile app with this example. For a generic Approov quickstart for Flutter GraphQL please check the [README.md](/README.md) at the root of this repo.

The base for this Todo app is derived, with gratitude from the [hasura/learn-graphql](https://github.com/hasura/learn-graphql/tree/c39f7731c609fb24c10a66c8ee574b4cb02f9a41/tutorials/mobile/flutter-graphql/app-final) repo, that has a [MIT license](https://github.com/hasura/learn-graphql/blob/c39f7731c609fb24c10a66c8ee574b4cb02f9a41/LICENSE), that is also on this repo. The Hasura repo is full of tutorials and examples that can be useful to start learning GraphQL or to sharpen your knowledge on it.


## Try the Todo App without Approov

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

> **NOTE:** The app will run against this live backend `https://unprotected.flutter-graphql.demo.approov.io`, and the code for it is in this [Github repo](https://github.com/approov/quickstart-elixir-phoenix-absinthe-graphql-token-check).

[TOC](/README.md#toc)


## Enable Approov in the Todo App

First, make sure you are inside the folder `src/app-final`:

```text
cd src/app-final
```

Now, follow the instructions for the [Approov Plugin Setup](/README.md#approov-plugin-setup), and return here when you arrive to the instruction to edit the `pubspec.yml` file.

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

> **IMPORTANT:** During development always use the `--expireAfter` flag with an expiration that best suits your needs, using `h` for hours and `d` for days. By default, an app registration is permanent and will remain in the Approov cloud database until it is explicitly removed. Permanent app registrations should be used to identify apps that are being published to production. Read more in our docs at [Managing Registrations](https://approov.io/docs/latest/approov-usage-documentation/#managing-registrations).

Finally, run the Flutter app:

```
flutter run --no-fast-start
```

> **NOTE:** The app will run against this live backend `https://approov-token-protected.flutter-graphql.demo.approov.io`, and the code for it is in this [Github repo](https://github.com/approov/quickstart-elixir-phoenix-absinthe-graphql-token-check).

[TOC](/README.md#toc)
