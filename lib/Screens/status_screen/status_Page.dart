import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_new/Screens/status_screen/StatusViewScreen.dart';
import 'package:whatsapp_new/Widgets/Image_preview_screen.dart';
import 'package:whatsapp_new/services/Storage/Storage_services.dart';
import 'package:whatsapp_new/services/supabase/Supabase_Storage_service.dart';

class StatusPage extends StatefulWidget {
  final String senderId;

  final String userName;
  final String photo;
  StatusPage({
    Key? key,
    required this.senderId,
    required this.userName,
    required this.photo,
  }) : super(key: key);

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  Future<void> uploadStatus() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    // // upload to Supabase
    // final imageUrl = await SupabaseStorageService().uploadStatusImage(file, widget.senderId);

    // await FirebaseFirestore.instance.collection('status').add({
    //   'userId': widget.senderId,
    //   'userName': widget.userName,
    //   'userPhoto': widget.photo,
    //   'imageUrl': imageUrl,
    //   'caption': '',
    //   'createdAt': FieldValue.serverTimestamp(),
    //   'expiresAt': Timestamp.fromDate(
    //     DateTime.now().add(Duration(hours: 24)),
    //   ),
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImagePreviewScreen(
          imageFile: File(pickedFile.path),
          senderId: widget.senderId,
          userName: widget.userName,
          photo: widget.photo,
          type: PreviewType.status,
        ),
      ),
    );
  }

  Future<void> sendStatus(File file, String caption) async {
  final imageUrl = await SupabaseStorageService()
      .uploadChatOrStatusImage(
        file: file,
        userId: widget.senderId,
        folder: 'status',
      );

  await FirebaseFirestore.instance.collection('status').add({
    'userId': widget.senderId,
    'userName': widget.userName,
    'userPhoto': widget.photo,
    'imageUrl': imageUrl,
    'caption': caption, // ✅ FIXED
    'createdAt': FieldValue.serverTimestamp(),
    'expiresAt':
        Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24))),
  });
}



  void initState() {
    super.initState();
    Future.microtask(() => context.read<StorageServices>().fetchImages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PreferredSize(
          preferredSize: Size.fromHeight(500),
          child: Column(
            children: [Text("Status", style: TextStyle(fontSize: 20))],
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search_outlined)),
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(child: Text("Create channel")),
                PopupMenuItem(child: Text("Status privacy")),
                PopupMenuItem(child: Text("Starred")),
                PopupMenuItem(child: Text("Settings")),
                PopupMenuItem(child: Text("More")),
              ];
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: Icon(Icons.camera_alt),
        onPressed: () {
          uploadStatus();
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('status')
            .where('expiresAt', isGreaterThan: Timestamp.now())
            .orderBy('expiresAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No status available',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          Map<String, List<QueryDocumentSnapshot>> groupedStatus = {};

          final myUserId = widget.senderId;

          for (var doc in docs) {
            final userId = doc['userId'];
            groupedStatus.putIfAbsent(userId, () => []);
            groupedStatus[userId]!.add(doc);
          }

          final myStatusEntry = groupedStatus.entries.firstWhere(
            (e) => e.key == myUserId,
            orElse: () => MapEntry('', []),
          );

          final otherStatusEntries = groupedStatus.entries
              .where((e) => e.key != myUserId)
              .toList();

          return ListView(
            children: [
              // ---- My Status ----
              if (myStatusEntry.key.isNotEmpty &&
                  myStatusEntry.value.isNotEmpty)
                ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(
                      myStatusEntry.value.last['imageUrl'],
                    ),
                  ),
                  title: const Text("My Status"),
                  subtitle: Text(
                    myStatusEntry.value.last['createdAt'] != null
                        ? DateFormat('h:mm a').format(
                            myStatusEntry.value.last['createdAt'].toDate(),
                          )
                        : '',
                  ),
                  onTap: () {
                  
                    final statuses = List<QueryDocumentSnapshot>.from(
                      myStatusEntry.value,
                    );
                    statuses.sort(
                      (a, b) => a['createdAt'].compareTo(b['createdAt']),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StatusViewScreen(
                          // time: statuses.first['createdAt'],
                          statuses: statuses,
                          userName: "My Status",
                        ),
                      ),
                    );
                  },
                ),

              const Divider(
                thickness: 1,
                color: Colors.grey,
                indent: 10,
                endIndent: 10,
              ),

              // ---- Others Status ----
              ...otherStatusEntries.map((entry) {
                final statuses = entry.value;
                final latest = statuses.first;

                return ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(latest['imageUrl']),
                  ),
                  title: Text(latest['userName']),
                  subtitle: Text(
                    DateFormat('h:mm a').format(latest['createdAt'].toDate()),
                  ),
                  onTap: () {
                    final statuses = List<QueryDocumentSnapshot>.from(
                      entry.value,
                    );
                    statuses.sort(
                      (a, b) => a['createdAt'].compareTo(b['createdAt']),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StatusViewScreen(
                          statuses: statuses,
                          userName: latest['userName'],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}

///-----------------grouped status---------------------only test
//           return ListView(
//             children: [
              
//               ...groupedStatus.entries.map((entry) {
//               final statuses=entry.value;
//               final latest =statuses.first;

//              // final Timestamp createdAt = statuses.first['createdAt'] ;
                
//               return ListTile(
//                 leading: CircleAvatar(
//                   radius: 28,
//                   backgroundImage: NetworkImage(latest['imageUrl']),
//                 ),
//                 title: Text(latest['userName']),
//                 subtitle:  Text(
//                   DateFormat('h:mm a').format(latest['createdAt'].toDate()),
//                 ),
//                 onTap: () {
//                    final statuses = List<QueryDocumentSnapshot>.from(entry.value);

//   statuses.sort(
//     (a, b) => a['createdAt'].compareTo(b['createdAt']),
//   );

//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => StatusViewScreen(
//                        time:latest['createdAt'],
//                        statuses: statuses,
//                         userName: latest['userName'],
//                        // userId: latest['userId'],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }).toList(),
            
//             ],
//           );
//         },
//       ),
//     );
//   }
// }





//---------------old-----------------
// {
//     return Consumer<StorageServices>(
//       builder:(context,storageServices,child) {
//         return Scaffold(
//           appBar: AppBar(title: Text("Storage"),),
//             floatingActionButton: FloatingActionButton(
//             onPressed: () => storageServices.uploadImage(),

            
//             child: Icon(Icons.upload),),
//           body:Column(
//             children: [
//               if(storageServices.isUploading)
//               const Padding(padding:EdgeInsets.all(8.0),child:Text('Uploading...'),),

//               Expanded(child:    storageServices
//             .isLoading
//             ? Center(child: CircularProgressIndicator(),)
//             : GridView.builder(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,
//               mainAxisSpacing: 8,
//               crossAxisSpacing: 8),
//               itemCount: storageServices.images.length,
//               itemBuilder: (context, index) {
//   final imageUrl = storageServices.images[index];

//   return Container(
//     decoration: BoxDecoration(
//       color: Colors.grey.shade300,
//       borderRadius: BorderRadius.circular(8),
//     ),
//     child: imageUrl.isEmpty
//         ? const Icon(Icons.person, size: 40, color: Colors.white)
//         : Image.network(
//             imageUrl,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               return const Icon(
//                 Icons.person,
//                 size: 40,
//                 color: Colors.white,
//               );
//             },
//           ),
//   );
// },),
//               ),    

//             ]
//           ),
        
          
        
//           );
//       }
      
//     );
//   }
// }