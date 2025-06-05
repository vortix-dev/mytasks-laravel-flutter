import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  bool isOffline = false;
  final TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    fetchTasks();
  }

  Future<void> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isOffline = connectivityResult == ConnectivityResult.none;
    });
  }

  Future<void> fetchTasks() async {
    setState(() => loading = true);
    try {
      final fetchedTasks = await ApiService.fetchTasks();
      setState(() {
        tasks = fetchedTasks;
        loading = false;
        isOffline = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        isOffline = true;
      });
    }
  }

  Future<void> addTask() async {
    final taskText = taskController.text.trim();
    if (taskText.isEmpty) return;

    try {
      final newTask = await ApiService.addTask(taskText);
      if (newTask != null) {
        setState(() {
          tasks.add(newTask);
          taskController.clear();
          isOffline = false;
        });
      }
    } catch (e) {
      setState(() => isOffline = true);
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      final success = await ApiService.deleteTask(id);
      if (success) {
        setState(() {
          tasks.removeWhere((task) => task['id'] == id);
          isOffline = false;
        });
      }
    } catch (e) {
      setState(() => isOffline = true);
    }
  }

  Future<void> editTask(int id, String currentTask) async {
    final TextEditingController editController = TextEditingController(
      text: currentTask,
    );

    final updated = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E3C),
        title: const Text('Edit Task', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        content: TextField(
          controller: editController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          decoration: InputDecoration(
            labelText: 'Task',
            labelStyle: const TextStyle(color: Color(0xFFA0A0C0), fontFamily: 'Poppins'),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF6E44FF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF00E5FF)),
            ),
          ),
          onSubmitted: (_) =>
              Navigator.of(context).pop(editController.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFA0A0C0), fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E44FF),
            ),
            onPressed: () =>
                Navigator.of(context).pop(editController.text.trim()),
            child: const Text('Save', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );

    if (updated != null && updated.isNotEmpty && updated != currentTask) {
      try {
        final success = await ApiService.updateTask(id, updated);
        if (success) {
          setState(() {
            final index = tasks.indexWhere((task) => task['id'] == id);
            if (index != -1) {
              tasks[index]['task'] = updated;
              isOffline = false;
            }
          });
        }
      } catch (e) {
        setState(() => isOffline = true);
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
      backgroundColor: const Color(0xFF070710),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A14),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.task_alt, color: Color(0xFF00E5FF)),
            const SizedBox(width: 10),
            const Text(
              'MyTasks',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFA0A0C0)),
            onPressed: logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: isOffline
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off,
                    color: Color(0xFFA0A0C0),
                    size: 60,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Internet Connection',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please check your connection and try again',
                    style: TextStyle(
                      color: Color(0xFFA0A0C0),
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6E44FF),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: fetchTasks,
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: taskController,
                            onSubmitted: (_) => addTask(),
                            style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                            decoration: InputDecoration(
                              labelText: 'Add a new task',
                              labelStyle: const TextStyle(color: Color(0xFFA0A0C0), fontFamily: 'Poppins'),
                              filled: true,
                              fillColor: const Color(0xFF1E1E3C),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(color: Color(0xFF00E5FF)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6E44FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                          ),
                          onPressed: addTask,
                          child: const Text(
                            'Add',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: loading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF00E5FF),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: fetchTasks,
                            color: const Color(0xFF00E5FF),
                            backgroundColor: const Color(0xFF1E1E3C),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return Card(
                                  color: const Color(0xFF1E1E3C),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    title: Text(
                                      task['task'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins', // Fixed: Changed Poppins to 'Poppins'
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Color(0xFF00E5FF),
                                          ),
                                          onPressed: () => editTask(
                                              task['id'], task['task']),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Color(0xFFFF4D94),
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