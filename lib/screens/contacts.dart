import 'dart:math';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Contacts extends StatefulWidget {
  const Contacts({Key? key});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  List<Contact> contacts = [];
  final List<Contact> _searchlist=[];
  bool _isSearching  = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getContactPermission();
  }

  void getContactPermission() async {
    if (await Permission.contacts.isGranted) {
      fetchContacts();
    } else {
      await Permission.contacts.request();
    }
  }

  void fetchContacts() async {
    contacts = (await ContactsService.getContacts()).toList();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching?TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Enter Name...",
          ),
          autofocus: true,
          style: TextStyle(fontSize: 17,letterSpacing: 0.5),
          onChanged: (val){
            //search logic
            _searchlist.clear();
            for(var i in contacts){
              if(i.givenName!.toLowerCase().contains(val.toLowerCase())){
                _searchlist.add(i);
              }
              setState(() {
                _searchlist;
              });
            }
          },
        ):Text("Contacts"),
        leading: Icon(Icons.perm_contact_cal_rounded
          ,size: 26,),
        actions: [
          IconButton(onPressed: () {
            setState(() {
              _isSearching=!_isSearching;
            });
          }, icon: Icon(_isSearching?CupertinoIcons.clear_circled_solid:Icons.search,size: 26,)),
          IconButton(onPressed: () {
            // Navigator.push(context, MaterialPageRoute(builder: (context) => Profilescreen(user: APIs.me),));
          }, icon: Icon(Icons.more_vert,size: 26,)),
        ],
        backgroundColor: Colors.blueAccent,

      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _isSearching
            ? _searchlist.length
            :contacts.length,
        itemBuilder: (context, index) {
          final contact = _isSearching
              ? _searchlist[index]
              : contacts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor:Colors.primaries[Random().nextInt(
                  Colors.primaries.length)],
              radius: 22,
              child: Text(
                contact.givenName?.isNotEmpty == true
                    ? contact.givenName![0]
                    : '',
                style: TextStyle(
                  fontSize: 23,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            title: Text(
              contact.givenName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
            subtitle: Text(
              contact.phones?.isNotEmpty == true
                  ? contact.phones!.first.value ?? ''
                  : '',
              style: TextStyle(
                fontSize: 11,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: InkWell(
              onTap: () async {
              },
                borderRadius: BorderRadius.circular(43),
                child: Icon(Icons.phone, size: 26)),
          );
        },
      ),
    );
  }
}
