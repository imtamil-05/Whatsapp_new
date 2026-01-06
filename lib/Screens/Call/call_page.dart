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
        ],
      )
      
    );
  }
}