import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List tasks = [];
  bool loading = true;
  final TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    setState(() => loading = true);
    final fetchedTasks = await ApiService.fetchTasks();
    setState(() {
      tasks = fetchedTasks;
      loading = false;
    });
  }

  Future<void> addTask() async {
    final taskText = taskController.text.trim();
    if (taskText.isEmpty) return;

    final newTask = await ApiService.addTask(taskText);
    if (newTask != null) {
      setState(() {
        tasks.add(newTask);
        taskController.clear();
      });
    }
  }

  Future<void> deleteTask(int id) async {
    final success = await ApiService.deleteTask(id);
    if (success) {
      setState(() {
        tasks.removeWhere((task) => task['id'] == id);
      });
    }
  }

  Future<void> editTask(int id, String currentTask) async {
    final TextEditingController editController = TextEditingController(
      text: currentTask,
    );

    final updated = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Task',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) =>
              Navigator.of(context).pop(editController.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pop(editController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updated != null && updated.isNotEmpty && updated != currentTask) {
      final success = await ApiService.updateTask(id, updated);
      if (success) {
        setState(() {
          final index = tasks.indexWhere((task) => task['id'] == id);
          if (index != -1) {
            tasks[index]['task'] = updated;
          }
        });
      }
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // حقل الإضافة في الأعلى
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: taskController,
                      onSubmitted: (_) => addTask(),
                      decoration: const InputDecoration(
                        labelText: 'Add a new task',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: addTask, child: const Text('Add')),
                ],
              ),
            ),

            // قائمة المهام تحت حقل الإضافة و تملأ باقي الشاشة
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: fetchTasks,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(task['task']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () =>
                                        editTask(task['id'], task['task']),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => deleteTask(task['id']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
