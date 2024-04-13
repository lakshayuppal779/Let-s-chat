import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_chat/API/apis.dart';
import 'package:lets_chat/models/chat_user.dart';

class ScheduledMessageScreen extends StatefulWidget {
  final ChatUser user;

  const ScheduledMessageScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ScheduledMessageScreenState createState() => _ScheduledMessageScreenState();
}

class _ScheduledMessageScreenState extends State<ScheduledMessageScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  TextEditingController messageController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  void _scheduleMessage() {
    final DateTime scheduledDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    if (messageController.text.isNotEmpty) {
      // Schedule the message
      String scheduledMessage = messageController.text;
      APIs.sendScheduledMessage(widget.user, scheduledMessage, scheduledDateTime);
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Please enter a message."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Schedule Message"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 110,
              ),
              InkWell(
                onTap: () => _selectDate(context),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,size: 25,color: Colors.blueAccent,),
                    SizedBox(width: 10),
                    Text(
                      'Selected Date: ${selectedDate.year}-${selectedDate.month}-${selectedDate.day}', style: TextStyle(color: Colors.black, fontSize: 18)
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              InkWell(
                onTap: () => _selectTime(context),
                child: Row(
                  children: [
                    Icon(Icons.access_time,size: 27,color: Colors.blueAccent,),
                    SizedBox(width: 10),
                    Text(
                      'Selected Time: ${selectedTime.hour}:${selectedTime.minute}', style: TextStyle(color: Colors.black, fontSize: 18)
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              TextField(
                style: TextStyle(color: Colors.black, fontSize: 16),
                controller: messageController,
                decoration: InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
          
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 310,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.schedule_send,color: Colors.white,size: 28,),
                      onPressed: _scheduleMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: ContinuousRectangleBorder(),
                      ),
                      label: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
