import 'package:flutter/material.dart';
import 'package:whatsapp_new/Screens/Auth/Login_page.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({ Key? key }) : super(key: key);

  @override
  _GetStartedState createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Welcome to WhatsApp",style: TextStyle(color: Colors.teal,fontWeight: FontWeight.bold)),),),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsetsGeometry.all(10),
              child: Container(
                height: 400,
                width: 400,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/whatsappbgimage.jpg'),
                ),
              ),
              ),
              Padding(padding: EdgeInsetsGeometry.all(10),
              child: Column(
                children: [
                  Text(
                    'Tap "Agree and continue" to accept the  ',style: TextStyle(fontSize:15,),
                  ),
                  Text(
                'WhatsApp Terms of Service and the Privacy Policy',style: TextStyle(fontSize: 15,color: Colors.lightBlueAccent),
              ),
                ],
              ),),
              Padding(padding: EdgeInsetsGeometry.all(10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: (){ 
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
              }, child: Text('Get Started',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
              ),
              ),
          
            ],
          ),
        ),
      ),
    );
  }
}