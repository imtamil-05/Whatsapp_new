import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CallPage extends StatefulWidget {
  const CallPage({ Key? key }) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calls"),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.search_outlined)),
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem(child: Text("Clear call log")),
              PopupMenuItem(child: Text("Scheduled calls")),
              PopupMenuItem(child: Text("Settings")),
              PopupMenuItem(child: Text("More")),
            ];
          })
        ],),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(child: Icon( Icons.call_outlined,)),
              Icon( Icons.calendar_month,),
             Icon(Icons.dialpad,),
             Icon(Icons.favorite_border_outlined,)
            ],
          ),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: Text("Recent",style: TextStyle(fontSize: 20),),
             ),
            ],
          ),
         Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('call_logs')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data!.docs;

          if (logs.isEmpty) {
            return const Center(child: Text("No call history"));
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final data = logs[index];

              final duration = data['duration'] ?? "00:00";
              final type = data['type'] ?? "audio";

              final isMissed = duration == "00:00";

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isMissed
                      ? Colors.red
                      : Colors.green,
                  child: Icon(
                    type == "video"
                        ? Icons.videocam
                        : Icons.call,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  "${data['callerId']} → ${data['receiverId']}",
                ),
                subtitle: Text(
                  isMissed
                      ? "Missed Call"
                      : "Duration: $duration",
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              );
            },                // need to update this page in git
          );
        },
      ),
    ),    
  ],
),
    );
  }
}