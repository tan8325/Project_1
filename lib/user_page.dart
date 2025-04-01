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
  final TextEditingController _addamtcontroller = TextEditingController();

  // List that holds user's saving goals
  final List<Map> _goals = [];

  // Adds or edits goal to list of saving goals
  void _addSavingsGoal({int? index}) {
    String name = _namecontroller.text;
    String amtsaved = _amtsavedcontroller.text;
    String totalamt = _totalamtcontroller.text;
    setState(() {
      if (index != null) {
        _goals[index] = {
          'name': name,
          'amtsaved': amtsaved,
          'totalamt': totalamt,
        };
      } else {
        _goals.add({'name': name, 'amtsaved': amtsaved, 'totalamt': totalamt});
      }
    });

    // clears the text fields
    _namecontroller.clear();
    _amtsavedcontroller.clear();
    _totalamtcontroller.clear();
  }

  // Adds amount to saved amount
  void _addAmount({int? index}) {
    String name = _namecontroller.text;
    String totalamt = _totalamtcontroller.text;
    String addamt = _addamtcontroller.text;
    if (index == null) return;

    // Perform addition (unless add value is null)
    double saved = double.parse(_goals[index]['amtsaved']);
    double added = (addamt.isNotEmpty) ? double.parse(addamt) : 0.0;
    double sumamt = saved + added;
    String result = sumamt.toStringAsFixed(2);
    setState(() {
      _goals[index] = {'name': name, 'amtsaved': result, 'totalamt': totalamt};
    });
    _addamtcontroller.clear();
  }

  void _updateMyItems(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final plan = _goals.removeAt(oldIndex);
      _goals.insert(newIndex, plan);
    });
  }

  // deletes goal
  void _deleteSavingsGoal({int? index}) {
    setState(() {
      if (index != null) {
        // To remove a goal in the list
        _goals.removeAt(index);
      }
    });

    _namecontroller.clear();
    _amtsavedcontroller.clear();
    _totalamtcontroller.clear();
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
              height: 225,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    // increases size of the progress indicator
                    scale: 4,
                    child: CircularProgressIndicator(
                      value: // value changes based on values from first goal in list
                          _goals.isNotEmpty
                              ? (double.tryParse(_goals[0]['amtsaved']) ?? 0) /
                                  (double.tryParse(_goals[0]['totalamt']) ?? 1)
                              : 0,
                      backgroundColor: Colors.purple.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.purple.shade700,
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _goals.isNotEmpty ? '\$${_goals[0]['amtsaved']}' : '\$0',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              // List of saving goals that can be reordered by the user
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    key: ValueKey(_goals[index]),
                    onTap: () {
                      // On tap, users can edit a goal
                      _namecontroller.text = _goals[index]['name'];
                      _amtsavedcontroller.text = _goals[index]['amtsaved'];
                      _totalamtcontroller.text = _goals[index]['totalamt'];
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return buildFullScreenEditSheet(
                            _namecontroller,
                            _amtsavedcontroller,
                            _totalamtcontroller,
                            _addamtcontroller,
                            () => _addSavingsGoal(index: index),
                            () => _addAmount(index: index),
                            () => _deleteSavingsGoal(index: index),
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                      child: ListTile(
                        title: Text(_goals[index]['name']),
                        subtitle: Text(
                          '\$${_goals[index]['amtsaved']} saved of \$${_goals[index]['totalamt']}',
                        ),
                        tileColor: const Color.fromARGB(255, 253, 241, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Colors.black.withOpacity(0.10),
                          ),
                        ),
                        trailing: ReorderableDragStartListener(
                          index: index,
                          child: Icon(Icons.drag_handle),
                        ),
                      ),
                    ),
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    _updateMyItems(oldIndex, newIndex);
                  });
                },
              ),
            ),
            // Opens bottom sheet when presssed by user
            ElevatedButton(
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
                      _deleteSavingsGoal,
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Add New Savings Goal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 15),
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
  Function deleteSavingsGoal,
) {
  return DraggableScrollableSheet(
    initialChildSize: 1, // sheet takes up available screen height
    maxChildSize: 1, // maximum sheet height
    minChildSize: 0.75, // minimum sheet size, collapses at 75% screen height
    builder: (context, scrollController) {
      return Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 251, 245, 252),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollController,
          children: [
            Padding(
              padding: EdgeInsets.all(25),
              child: Text(
                "Add a New Savings Goal",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Ex: Vacation, Car, Expenses',
                  labelText: 'Goal Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.yellow,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: amtsavedController,
                decoration: InputDecoration(
                  labelText: 'Amount saved',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: Icon(Icons.savings_rounded, color: Colors.pink),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: TextField(
                controller: totalamtController,
                decoration: InputDecoration(
                  labelText: 'Total Amount Needed',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: Icon(
                    Icons.attach_money_rounded,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    addSavingsGoal();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(Icons.check),
                  label: Text("Add New Saving Goal"),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: Colors.red),
                  ),
                  icon: Icon(Icons.cancel_outlined),
                  label: Text("Cancel"),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

// Flutter Bottom Sheet to edit saving goal
Widget buildFullScreenEditSheet(
  TextEditingController nameController,
  TextEditingController amtsavedController,
  TextEditingController totalamtController,
  TextEditingController addamtController,
  Function addSavingsGoal,
  Function addAmount,
  Function deleteSavingsGoal,
) {
  return DraggableScrollableSheet(
    initialChildSize: 1, // sheet takes up available screen height
    maxChildSize: 1, // maximum sheet height
    minChildSize: 0.75, // minimum sheet size, collapses at 75% screen height
    builder: (context, scrollController) {
      return Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 251, 245, 252),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollController,
          children: [
            Padding(
              padding: EdgeInsets.all(25),
              child: Text(
                "Edit Savings Goal",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Ex: Vacation, Car, Expenses',
                  labelText: 'Goal Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.yellow,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: amtsavedController,
                decoration: InputDecoration(
                  labelText: 'Amount saved',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: Icon(Icons.savings_rounded, color: Colors.pink),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: TextField(
                controller: totalamtController,
                decoration: InputDecoration(
                  labelText: 'Total Amount Needed',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: Icon(
                    Icons.attach_money_rounded,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: TextField(
                controller: addamtController,
                decoration: InputDecoration(
                  labelText: 'Add Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: Icon(Icons.add_circle, color: Colors.blue),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Save Goal Button
                ElevatedButton.icon(
                  onPressed: () {
                    addAmount();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(Icons.check),
                  label: Text("Save Goal"),
                ),

                // Cancel Button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: Colors.red),
                  ),
                  icon: Icon(Icons.cancel_outlined),
                  label: Text("Cancel"),
                ),

                // Delete Goal Button
                ElevatedButton.icon(
                  onPressed: () {
                    deleteSavingsGoal();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  label: Text("Delete Goal"),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
