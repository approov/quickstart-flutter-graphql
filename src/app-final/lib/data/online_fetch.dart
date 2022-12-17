// @dart=2.9

class OnlineFetch {

  static String fetchOnlineUsers = """
    query {
      online_users {
        name,
        last_seen
      }
    }
    """;

  static String subscribeOnlineUsers = """
    subscription { fetchOnlineUsers(topic: "online_users") {
      name,
      last_seen
    }}
    """;

  static String updateStatus = """
    mutation updateLastSeen (\$name: String!) {
      updateLastSeen(name: \$name) {
        affectedRows
      }
    }
  """;
}
