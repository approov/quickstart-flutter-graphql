class OnlineFetch {

  static String fetchUsers = """
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
