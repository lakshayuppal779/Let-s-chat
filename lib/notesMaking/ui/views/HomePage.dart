
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/notesMaking/delegates/NoteSearchDelegate.dart';
import 'package:lets_chat/notesMaking/ui/list/NoteListView.dart';
import 'package:lets_chat/notesMaking/ui/views/GroupsPage.dart';
import 'package:lets_chat/notesMaking/ui/views/NoteCreationPage.dart';
import 'package:lets_chat/notesMaking/ui/views/SettingsPage.dart';
import 'package:lets_chat/notesMaking/ui/widget/BottomNoteModal.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notes'),
          leading: const Icon(
            Icons.notes,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // show search bar
                showSearch(
                  context: context,
                  delegate: NoteSearchDelegate(),
                );
              },
            )
          ],
        ),
        body: Container(
          color: Colors.white,
          child: Stack(
            children: [
              NoteListView(
                  onLongPress: (note) {
                    // Go to the edit note page
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return BottomNoteModal(
                          note: note,
                        );
                      },
                    );
                  }
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Go to the create note page
            Navigator.push(context, MaterialPageRoute(builder: (context) => const NoteCreationPage()));
          },
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      bottomNavigationBar: SizedBox(
        height: 88,
        child: CurvedNavigationBar(
          backgroundColor: Colors.blueAccent,
          animationDuration: Duration(milliseconds: 300),
          items: <Widget>[
            Icon(Icons.home, size: 27),
            Icon(Icons.group, size: 27),
            Icon(Icons.settings, size: 27),
          ],
          onTap: (index) async {
            if(index==0){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage(),));
            }
            if(index==1){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const GroupsPage(),));
            }
            if(index==2){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(),));
            }
          },
        ),
      ),
    );
  }
}
