import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:todo_demo/components/my_button.dart';
import 'package:todo_demo/models/todo.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Todo> todos = [];
  final TextEditingController controller = TextEditingController();
  final Dio dio = Dio();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    setState(() {
      isLoading = true;
    });
    try {
      final res = await dio.get(
        'https://jsonplaceholder.typicode.com/todos?_limit=10',
      );
      final data = res.data as List;
      print('data: $data');
      setState(() {
        todos.clear();
        todos.addAll(
          data.map(
            (json) => Todo(id: json['id'].toString(), title: json['title']),
          ),
        );
      });
    } catch (e) {
      print('Error fetching todos: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addTodo() async {
    if (controller.text.isEmpty) return;

    try {
      final res = await dio.post(
        'https://jsonplaceholder.typicode.com/todos',
        data: {'title': controller.text, 'completed': false},
      );
      final json = res.data;

      setState(() {
        todos.insert(0, Todo(id: json['id'].toString(), title: json['title']));
      });

      controller.clear();
    } catch (e) {
      print('Error adding todo: $e');
    }
  }

  Future<void> deleteTodo(int index) async {
    final id = todos[index].id;
    try {
      await dio.delete('https://jsonplaceholder.typicode.com/todos/$id');

      setState(() {
        todos.removeAt(index);
      });
    } catch (e) {
      print('Error deleting todo: $e');
    }
  }

  // void addTodo() {
  //   if (controller.text.isEmpty) return;

  //   setState(() {
  //     todos.add(Todo(id: DateTime.now().toString(), title: controller.text));
  //   });

  //   controller.clear();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo App')),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(child: TextField(controller: controller)),
              // IconButton(onPressed: addTodo, icon: Icon(Icons.add)),
              MyButton(label: 'Add', onPressed: addTodo),
            ],
          ),
          SizedBox(height: 10),
          // ElevatedButton(onPressed: () {
          //   context.router.push(HomePage());
          // }, child: Text('Go home')),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (_, index) {
                      return ListTile(
                        title: Text(todos[index].title),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              todos.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
