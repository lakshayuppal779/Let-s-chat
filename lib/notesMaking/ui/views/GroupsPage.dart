
import 'package:flutter/material.dart';
import 'package:lets_chat/notesMaking/ui/views/GroupCreationPage.dart';
import 'package:lets_chat/notesMaking/ui/views/GroupNotePage.dart';
import '../list/GroupListVIew.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.group,
        ),
        title: Text('Groups'),
      ),
      body: Container(
        color: Colors.white,
        child: GroupListVIew(
          onTap: (group) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => GroupNotePage(group: group!),));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        onPressed: () {
          // Go to the create group page
          Navigator.push(context, MaterialPageRoute(builder: (context) => GroupCreationPage()));

        },
        child: Icon(Icons.add),
      ),
    );
  }
}
