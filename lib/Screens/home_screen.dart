import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/task.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late TextEditingController _taskController;
  List<Task> _tasks = [];
  List<bool> _taskDone = [];

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController();
    _getTask();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void saveData() async {
    if (_taskController.text.isEmpty) {
      return;
    }
    SharedPreferences preference = await SharedPreferences.getInstance();
    Task tsk = Task.fromString(_taskController.text);
    String? tasks = preference.getString('task');
    List<dynamic> list = (tasks == null) ? [] : json.decode(tasks);
    list.add(tsk.getMap());
    preference.setString('task', json.encode(list));
    _taskController.text = '';
    Navigator.of(context).pop();
    _getTask();
  }

  void _getTask() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    String? tasks = preference.getString('task');
    List list = (tasks == null) ? [] : json.decode(tasks);
    _tasks = list.map((map) => Task.fromMap(map)).toList();
    _taskDone = List.generate(_tasks.length, (index) => false);
    setState(() {});
  }

  void updatePendingTask() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    List<Task> pendingTasks = [];
    for (int i = 0; i < _tasks.length; i++) {
      if (!_taskDone[i]) {
        pendingTasks.add(_tasks[i]);
      }
    }
    var pendingTasksEncoded =
        List.generate(pendingTasks.length, (i) => pendingTasks[i].getMap());
    preference.setString('task', json.encode(pendingTasksEncoded));
    _getTask(); // Refresh tasks after updating
  }

  void deleteAll() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    preference.setString('task', json.encode([]));
    _getTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Task Manager",
          style: GoogleFonts.oswald(),
        ),
        actions: [
          IconButton(onPressed: updatePendingTask, icon: Icon(Icons.save)),
          IconButton(onPressed: deleteAll, icon: Icon(Icons.delete))
        ],
        backgroundColor: Color.fromARGB(255, 106, 206, 40),
      ),
      body: (_tasks.isEmpty)
          ? const Center(child: Text("No task yet...."))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  padding: const EdgeInsets.only(left: 10.0),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        color: Colors.black,
                        width: 0.5,
                      )),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_tasks[index].task, style: GoogleFonts.oswald()),
                      Checkbox(
                        value: _taskDone[index],
                        onChanged: (value) {
                          setState(() {
                            _taskDone[index] = value!;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
          color: Color.fromARGB(255, 5, 5, 5),
        ),
        backgroundColor: Colors.amber,
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (BuildContext context) => Container(
            padding: const EdgeInsets.all(10.0),
            color: Colors.green,
            width: double.maxFinite,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Add Task",
                      style:
                          GoogleFonts.oswald(color: Colors.white, fontSize: 20),
                    ),
                    GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(Icons.close))
                  ],
                ),
                const Divider(
                  thickness: 5,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(240, 100, 150, 190))),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Type task here',
                      hintStyle: GoogleFonts.oswald()),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 150,
                  width: 550,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: MaterialButton(
                          onPressed: saveData,
                          child: Text(
                            "Add",
                            style: GoogleFonts.oswald(),
                          ),
                          color: Color.fromARGB(255, 43, 151, 170),
                        ),
                      ),
                      Container(
                        child: MaterialButton(
                          onPressed: () {
                            _taskController.text = '';
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Reset",
                            style: GoogleFonts.oswald(),
                          ),
                          color: Color.fromARGB(255, 238, 111, 72),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
