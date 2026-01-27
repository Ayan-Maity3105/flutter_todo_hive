import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("tasksBox");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Todo App",
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(primaryColor: Color(0xFFFA5C5C)),
      home: TodoApp(),
    );
  }
}

class TodoApp extends StatefulWidget {
  @override
  State<TodoApp> createState() => TodoAppState();
}

class TodoAppState extends State<TodoApp> {
  int selectedIndex = 0;
  TextEditingController textController = TextEditingController();
  TextEditingController editTextController = TextEditingController();
  late Box tasksBox;

  @override
  void initState() {
    super.initState();
    tasksBox = Hive.box("tasksBox");
  }

  // add task
  void _addTask() {
    if(textController.text.isNotEmpty) {
      setState(() {
        tasksBox.add({
          "title" : textController.text,
          "done" : false,
        });
      });
      textController.clear();
      Navigator.pop(context);
    }
  }

  // delete task
  void _deleteTask(int index) {
    setState(() {
      tasksBox.deleteAt(index);
    });
  }

  // toggle task
  void _toggleTask(int index) {
    setState(() {
      var task = tasksBox.getAt(index);
      task["done"] = !task["done"];
      tasksBox.putAt(index, task);
    });
  }

  // edit task
  void _editTask(int index) {
    if(editTextController.text.isNotEmpty) {
      setState(() {
        var task = tasksBox.getAt(index);
        task["title"] = editTextController.text;
        tasksBox.putAt(index, task);
      });
    }
  }

  void _showEditDialog(int index) {
    var task = tasksBox.getAt(index);
    editTextController.text = task["title"];
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            "Edit Task",
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF5F9598),
            ),
          ),

          content: TextField(
            controller: editTextController,
          ),

          actions: [
            TextButton(
                onPressed: () => {
                  Navigator.pop(context),
                },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Color(0xFF1D546D),
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5F9598),
                foregroundColor: Color(0xFFF3F4F4),
              ),
              onPressed: () => {
                _editTask(index),
                Navigator.pop(context),
              },
              child: Text(
                  "Edit"
              ),
            ),
          ],
        ),
    );
  }

  // text field for entering task
  void showAddDialog() {
    showDialog(context: context,
        builder: (_) => AlertDialog(
          title: const Text(
            "Add a new task",
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF5F9598),
            ),
          ),

          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: "Enter task here..."),
          ),

          // actions on text field
          actions: [
            TextButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.green.shade900,
                ),
                onPressed: () => {
                  Navigator.pop(context),
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Color(0xFF1D546D),
                  ),
                ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5F9598),
                foregroundColor: Color(0xFFF3F4F4),
              ),
                onPressed: _addTask,
                child: Text(
                    "Add"
                ),
            ),
          ],
        ));
  }

  // main widget
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text(
            "To-Do App",
            style: TextStyle(
              color: Color(0xFF5F9598),
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
        ),
        backgroundColor: Color(0xFF1D546D),
      ),

      body: tasksBox.isEmpty ?
          const Center(
            child: Text(
              "No task yet! Add a new Task",
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF5F9598),
              ),
            ),
          ) :
          ListView.builder(itemCount: tasksBox.length , itemBuilder: (_ , index) {
            final task = tasksBox.getAt(index);

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  leading: IconButton(
                      onPressed: () => _toggleTask(index),
                      icon: task["done"] ?
                          Icon(Icons.check_circle) :
                          Icon(Icons.circle_outlined),
                      color: task["done"] ?
                          Color(0xFF1D546D) : Colors.grey,
                  ),

                  title: Text(
                    task["title"],
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green.shade900,
                      decoration: task["done"] ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _showEditDialog(index),
                        icon: Icon(Icons.edit , color: Color(0xFF5F9598),),
                      ),

                      IconButton(
                        onPressed: () => _deleteTask(index),
                        icon: Icon(Icons.delete , color: Color(0xFF980404),),
                      ),
                    ],
                  )
                ),
              ),
            );
          }),

      // drawer
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF1D546D),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          child: Text(
                            "A",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5F9598),
                              fontSize: 25,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Text(
                            "Ayan Maity",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF3F4F4),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                )
            ),

            ListTile(
              leading: Icon(
                Icons.home,
                color: Color(0xFF5F9598),
              ),
              title: Text(
                "Home",
                style: TextStyle(
                  color: Color(0xFF5F9598),
                  fontSize: 18,
                ),
              ),
              onTap: () => {
                Navigator.pop(context),
              },
            ),

            ListTile(
              leading: Icon(
                Icons.settings,
                color: Color(0xFF5F9598),
              ),
              title: Text(
                "Settings",
                style: TextStyle(
                  color: Color(0xFF5F9598),
                  fontSize: 18,
                ),
              ),
              onTap: () => {
                Navigator.pop(context),
              },
            ),

            ListTile(
              leading: Icon(
                Icons.person,
                color: Color(0xFF5F9598),
              ),
              title: Text(
                "Account",
                style: TextStyle(
                  color: Color(0xFF5F9598),
                  fontSize: 18,
                ),
              ),
              onTap: () => {
                Navigator.pop(context),
              },
            ),

            ListTile(
              leading: Icon(
                Icons.sunny,
                color: Color(0xFF5F9598),
              ),
              title: Text(
                "Theme",
                style: TextStyle(
                  color: Color(0xFF5F9598),
                  fontSize: 18,
                ),
              ),
              onTap: () => {
                Navigator.pop(context),
              },
            )
          ],
        ),
      ),


      // floating button to add new task
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        backgroundColor: Color(0xFF5F9598),
        foregroundColor: Color(0xFFF3F4F4),
        child: Icon(
          Icons.add,
          size: 30,
        ),
      ),


      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF1D546D),
        unselectedItemColor: Color(0xFF5F9598),
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home"
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: "More"
          ),
        ],
      ),
    );
  }
}