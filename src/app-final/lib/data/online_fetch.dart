class OnlineFetch {
  static String fetchUsers00 = """
  subscription fetchOnlineUsers {
    fetchOnlineUsers {
      user {
        name
      }
    }
  }
  """;

  static String fetchUsers = """
  subscription { fetchOnlineUsers(topic: "online_users") {
	  name
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
