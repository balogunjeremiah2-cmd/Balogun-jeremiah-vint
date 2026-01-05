import 'dart:async'; // Required for the Splash Screen
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ------------------- DATA MODEL -------------------
// This class defines what a "Task" looks like.
class Task {
  String title;
  String description;
  String priority; // 'High', 'Medium', 'Low'
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.priority,
    this.isCompleted = false,
  });
}

// ------------------- MAIN APP WIDGET -------------------
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(), // App starts here
    );
  }
}

// ------------------- 1. SPLASH SCREEN -------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 3 seconds, then navigate to Home Screen
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'My Task Manager',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ------------------- 2. HOME SCREEN (List of Tasks) -------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // This List stores our data in memory (RAM)
  List<Task> tasks = [
    // Adding one dummy task so the list isn't empty initially
    Task(
        title: "Study Flutter",
        description: "Complete the mobile engineering assignment.",
        priority: "High"),
  ];

  // Function to handle navigating to Add Task Screen
  void _navigateToAddScreen() async {
    // We wait for the result from the AddTaskScreen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );

    // If a task was returned, add it to our list
    if (result != null && result is Task) {
      setState(() {
        tasks.add(result);
      });
      // Show Snackbar feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added successfully!')),
      );
    }
  }

  // Function to delete a task with confirmation
  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Close dialog
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                tasks.removeAt(index);
              });
              Navigator.pop(ctx); // Close dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task deleted.')),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: Colors.blue.shade100,
      ),
      // Floating Action Button to Add Task
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddScreen,
        child: const Icon(Icons.add),
      ),
      body: tasks.isEmpty
          ? const Center(child: Text("No tasks yet. Add one!"))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (bool? value) {
                        setState(() {
                          task.isCompleted = value!;
                        });
                      },
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text("Priority: ${task.priority}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTask(index),
                    ),
                    onTap: () {
                      // Navigate to Details Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailScreen(task: task),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

// ------------------- 3. ADD TASK SCREEN -------------------
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedPriority = 'Medium';

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      // Create a new Task object
      Task newTask = Task(
        title: _titleController.text,
        description: _descController.text,
        priority: _selectedPriority,
      );

      // Pass the new task back to the previous screen (Home)
      Navigator.pop(context, newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title Input
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Description Input
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Priority Dropdown
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: ['High', 'Medium', 'Low'].map((String priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedPriority = newValue!;
                  });
                },
              ),
              const SizedBox(height: 24),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Save Task"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------- 4. TASK DETAILS SCREEN -------------------
class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task Details")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Chip(
              label: Text(
                task.priority,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: task.priority == 'High'
                  ? Colors.red
                  : (task.priority == 'Medium' ? Colors.orange : Colors.green),
            ),
            const SizedBox(height: 20),
            const Text(
              "Description:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              task.description.isEmpty
                  ? "No description provided."
                  : task.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              "Status: ${task.isCompleted ? 'Completed' : 'Pending'}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: task.isCompleted ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}