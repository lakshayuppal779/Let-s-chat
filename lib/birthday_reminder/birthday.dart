import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_chat/screens/loginpage.dart';
import 'birthday_model.dart';
import 'package:flutter/material.dart';
import 'utils.dart';
import 'events_table.dart';

class BirthdayReminderApp extends StatefulWidget {
  @override
  _BirthdayReminderAppState createState() => _BirthdayReminderAppState();
}

class _BirthdayReminderAppState extends State<BirthdayReminderApp> {
  TextEditingController nameController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  List<Birthday> birthdays = [];
  DateTime selectedDate = DateTime.now();
  List<Event> eventList = [];
  var event;

  late int date = 1;
  late int month = 1;
  late int year = 2023;

  _showSnackBar(message){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
            backgroundColor: Colors.blue.withOpacity(.8),
            behavior: SnackBarBehavior.floating,
        )
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text = selectedDate.toString();
      });
    }
  }

  setEvent(name, date) {
    event = Event(name + " Birthday");
    if (kEventSource[date] == null) {
      eventList = [event];
      kEventSource
        ..addAll({
          date: eventList,
        });

      setState(() {
        kEvents = kEvents;
      });
    } else {
      kEventSource[date]!.add(event);
      setState(() {
        kEvents..addAll(kEventSource);
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Birthday Reminder'),
      ),
      resizeToAvoidBottomInset: false,
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/birthday.jpg"), fit: BoxFit.cover),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('birthdays').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // or any loading indicator
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final birthdayDocs = snapshot.data!.docs;
            birthdays = birthdayDocs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Birthday(
                name: data['name'],
                date: (data['date'] as Timestamp).toDate(),
              );
            }).toList();

            return ListView.builder(
              itemCount: birthdays.length,
              itemBuilder: (context, index) {
                Birthday birthday = birthdays[index];
                return GestureDetector(
                  onLongPress: (){
                    _showDeleteConfirmationDialog(birthday);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: const Offset(1.0, 1.0),
                          blurRadius: 2.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(birthday.name),
                      subtitle: Text(
                        '${birthday.date.day}/${birthday.date.month}/${birthday.date.year}',
                      ),
                      trailing: const Icon(Icons.cake,color: Colors.pink),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          nameController.text = "";
          dateController.text = "";
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                scrollable: true,
                title: const Text('Add new Birthday?'),
                content: SizedBox(
                  height: 265,
                  child: Column(
                    children: [
                      Row(
                          children: [
                        const Icon(Icons.person_2_rounded,size: 26,),
                        const SizedBox(width: 10),
                        Flexible(
                          child: TextField(
                            controller: nameController,
                            decoration: InputDecoration(labelText: 'Name'),
                          ),
                        )
                      ]),
                      Row(
                        children: [
                          GestureDetector(
                            child: Icon(Icons.calendar_today,size: 26,),
                            onTap: () {
                              _selectDate(context);
                            },
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: TextField(
                              controller: dateController,
                              decoration:
                              InputDecoration(labelText: 'Picked Date'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isEmpty ||
                              dateController.text.isEmpty) {
                            _showSnackBar('Make sure both name and date is provided!');
                          } else {
                            DateTime? parsedDate =
                            DateTime.tryParse(dateController.text);
                            if (parsedDate != null) {
                              Birthday newBirthday = Birthday(
                                  name: nameController.text,
                                  date: parsedDate);
                              setState(() {
                                birthdays.add(newBirthday);
                              });
                              Navigator.pop(context);
                              saveBirthdayToFirestore(nameController.text, parsedDate!);
                              setEvent(nameController.text, parsedDate);
                            } else {
                              _showSnackBar('Invalid Date!');
                            }
                          }
                        },
                        child: const Text('Add Birthday'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        child: const Text("View Events"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => EventsTable()),
                          );
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        tooltip: "Add Birthday",
        child: const Icon(Icons.add),
      ),
    );
  }

  // Function to save birthday to Firestore
  void saveBirthdayToFirestore(String name, DateTime date) {
    FirebaseFirestore.instance.collection('birthdays').add({
      'name': name,
      'date': date,
    }).then((value) {
      _showSnackBar('Birthday added');
    }).catchError((error) {
      _showSnackBar("Failed to add birthday: $error");
    });
  }

  void _showDeleteConfirmationDialog(Birthday birthday) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Birthday"),
          content: Text("Are you sure you want to delete ${birthday.name}'s birthday reminder?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Call function to delete from Firestore and local list
                deleteBirthdayFromFirestore(birthday);
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // Function to delete birthday from Firestore and local list
  void deleteBirthdayFromFirestore(Birthday birthday) {
    FirebaseFirestore.instance.collection('birthdays').where('name', isEqualTo: birthday.name).where('date', isEqualTo: birthday.date).get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    }).then((value) {
      _showSnackBar('Birthday deleted');
    }).catchError((error) {
      _showSnackBar("Failed to delete birthday: $error");
    });
  }

}
