import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _amtsavedcontroller = TextEditingController();
  final TextEditingController _totalamtcontroller = TextEditingController();
  // List that holds user's saving goals
  final List<Widget> _goals = [];

  // Adds goal to list of saving goals
  void _addSavingsGoal() {
    String name = _namecontroller.text;
    String amtsaved = _amtsavedcontroller.text;
    String totalamt = _totalamtcontroller.text;
    setState(() {
      _goals.add(
        ListTile(
          key: ValueKey(_goals.length + 1),
          title: Text(name),
          subtitle: Text('\$$amtsaved of \$$totalamt saved!'),
          tileColor: const Color.fromARGB(255, 253, 241, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.black.withOpacity(0.75)),
          ),
        ),
      );
    });
  }

  void _updateMyItems(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final plan = _goals.removeAt(oldIndex);
      _goals.insert(newIndex, plan);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular Progress Indicator
            SizedBox(
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    // increases size of the progress indicator
                    scale: 4,
                    child: CircularProgressIndicator(
                      value: 0.8, // placeholder value
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.deepPurpleAccent,
                      ),
                      backgroundColor: const Color.fromARGB(255, 214, 213, 213),
                      strokeWidth: 2,
                    ),
                  ),
                  Container(
                    alignment: Alignment.topCenter,
                    width: 50,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Text('\$1,600'), // Temporary value
                  ),
                ],
              ),
            ),
            Expanded(
              // List of saving goals that can be reordered by the user
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    _updateMyItems(oldIndex, newIndex);
                  });
                },
                children: _goals,
              ),
            ),
            // Opens bottom sheet
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return buildFullScreenSheet(
                      _namecontroller,
                      _amtsavedcontroller,
                      _totalamtcontroller,
                      _addSavingsGoal,
                    );
                  },
                );
              },
              child: Text('Add New Savings Goal'),
            ),
          ],
        ),
      ),
    );
  }
}

// Flutter Bottom Sheet to add saving goal
Widget buildFullScreenSheet(
  TextEditingController nameController,
  TextEditingController amtsavedController,
  TextEditingController totalamtController,
  Function addSavingsGoal,
) {
  return DraggableScrollableSheet(
    initialChildSize: 1, // sheet takes up available screen height
    maxChildSize: 1, // maximum sheet height
    minChildSize: 0.75, // minimum sheet size, collapses at 75% screen height
    builder: (context, scrollController) {
      return Container(
        color: const Color.fromARGB(255, 251, 245, 252),
        child: ListView(
          controller: scrollController,
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Add a New Savings Goal",
                style: TextStyle(fontSize: 28),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Ex: Vacation, Car, Expenses',
                  labelText: 'Enter your goal name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: TextField(
                controller: amtsavedController,
                decoration: InputDecoration(
                  labelText: 'Amount saved',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: TextField(
                controller: totalamtController,
                decoration: InputDecoration(
                  labelText: 'Total amount needed to save',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  addSavingsGoal();
                  Navigator.pop(context);
                },
                child: Text("Add New Savings Goal"),
              ),
            ),
          ],
        ),
      );
    },
  );
}
