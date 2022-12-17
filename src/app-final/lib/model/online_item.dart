// @dart=2.9

class OnlineUserItem {
  static Map<String, String> fromResponse(response) {
    Map<String, String> users = {};

    response.data['online_users'].forEach((user) {
      users[user['name']] = user['last_seen'];
    });

    return users;
  }
}
