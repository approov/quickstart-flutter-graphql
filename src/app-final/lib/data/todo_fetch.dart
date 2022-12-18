// @dart=2.9

class TodoFetch {
  static String fetchAll = """
  query {
    allTodos {
      id,
      title,
      is_completed
    }
  }
  """;

  static String fetchActive = """query {
    activeTodos {
      id,
      title,
      is_completed
    }
  }
  """;

  static String fetchCompleted = """query {
    completedTodos {
      id,
      title,
      is_completed
    }
  }
  """;

  static String addTodo = """
  mutation createTodo(\$title: String!, \$isPublic: Boolean!) {
    createTodo(title: \$title, isPublic: \$isPublic) {
      id,
      title,
      is_completed
    }
  }
  """;

  static String toggleTodo = """
    mutation toggleTodo(\$id: Int!, \$isCompleted: Boolean!) {
      toggleTodo(id: \$id, isCompleted: \$isCompleted) {
        isCompleted
      }
    }
  """;

  static String deleteTodo = """mutation deleteTodo(\$id:Int!) {
      deleteTodo(id: \$id) {
        id
      }
    }
  """;
}
