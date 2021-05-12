// @dart=2.9

import 'package:absinthe_socket/absinthe_socket.dart';
import 'package:flutter/widgets.dart';

import 'client.dart';

class Absinthe {
  static bool _connected = false;
  static AbsintheSocket _socket;
  static Map<String, Notifier> _notifiers = {};

  static connect() {

    if(_connected) {
      return;
    }

    _socket = AbsintheSocket(
      Config.websocketUrl,
      socketOptions: AbsintheSocketOptions(
          params: {"Authorization": Config.auth_token}),
    );

    _connected = true;
  }

  static subscribe(String notifierKey,
    String query,
    {
      onResult,
      onError,
      onCancel,
      onStart,
      onAbort,
    }) {

    connect();

    Observer _observer = Observer(
      onAbort: onAbort,
      onCancel: onCancel,
      onError: onError,
      onResult: onResult,
      onStart: onStart,
    );

    GqlRequest gqlRequest = GqlRequest(operation: query);

    var notifier = _socket.send(gqlRequest);
    notifier.observe(_observer);

    // Track notifiers to cancel them when flutter widget is disposed of
    _notifiers[notifierKey] = notifier;
  }

  static unsubscribe(String notifierKey) {
    _socket.unsubscribe(_notifiers[notifierKey]);
    _notifiers.remove(notifierKey);
  }

  static cancel(String notifierKey) {
    _socket.cancel(_notifiers[notifierKey]);
    _notifiers.remove(notifierKey);
  }

  static disconnect(String notifierKey) {
    _notifiers.forEach((String notifierKey, Notifier notifier) => _socket.cancel(notifier));
    _notifiers.clear();
    _socket.disconnect();
    _connected = false;
  }
}
