import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:whatsapp_new/Screens/Chat_Page.dart';
import 'package:whatsapp_new/Screens/Home/Chat_ListViewscreens.dart';
import 'package:whatsapp_new/Screens/Call/call_page.dart';
import 'package:whatsapp_new/Screens/status_screen/status_Page.dart';
import 'package:whatsapp_new/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{
  late String currentUserId;
  String? currentUserName;
  String? currentUserPhoto;
  int _selectedIndex = 0; 

 

  @override
  void initState(){
    super.initState();
    currentUserId=FirebaseAuth.instance.currentUser!.uid;
    fetchCurrentUser();
    
  }
  Future<void> fetchCurrentUser() async {
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .get();
  if(!mounted) return;

  setState(() {
    currentUserName = userDoc.data()?['name'];
    currentUserPhoto = userDoc.data()?['photo'];
  });
}


  @override
  void dispose(){
    updateOnlineStatus(currentUserId, false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    if(state == AppLifecycleState.paused || state == AppLifecycleState.detached){
      updateOnlineStatus(currentUserId, false);
    }
    else if(state == AppLifecycleState.resumed){
      updateOnlineStatus(currentUserId, true);
    }
  }

  Future<void> updateOnlineStatus(String userId, bool online) async{
    await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .set({
      "online": online,
      "lastSeen": online ? FieldValue.serverTimestamp() : FieldValue.serverTimestamp(),
    },
    SetOptions(merge: true),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  Widget openPopUp() {
    return PopupMenuButton(
      itemBuilder: (context) {
        return List.generate(
            3,
            (index) => const PopupMenuItem(
                  child: Text('Setting'),
                ));
      },
    );
  }
  @override

  Widget build(BuildContext context) {
    final displayName = currentUserName ?? 'User';
    final displayPhoto = currentUserPhoto ?? 'assets/images/whatsappbgimage.jpg';
    final List<Widget> _pages = <Widget>[ChatListViewscreens(currendUserId: currentUserId,),
     StatusPage(
      senderId: currentUserId,
      userName: displayName,
      photo: displayPhoto,
     ),
     CallPage()];
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar:  BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: onTabTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chats',

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Calls',
          ),
      ]),
    );
  }
}