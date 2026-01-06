import 'package:flutter/material.dart';
import 'package:whatsapp_new/services/supabase/supabase_User_service.dart';

class AppLifecycleService with WidgetsBindingObserver{
  static final AppLifecycleService _instance = AppLifecycleService._internal(); 
  
  factory AppLifecycleService() => _instance;
  
  AppLifecycleService._internal();


void start(){
  WidgetsBinding.instance.addObserver(this);
}

void stop(){
  WidgetsBinding.instance.removeObserver(this);
}

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if(state==AppLifecycleState.resumed){
    SupabaseUserService.updateOnlineStatus(true);
  }else if(state==AppLifecycleState.paused ||state== AppLifecycleState.inactive || state==AppLifecycleState.detached){
    SupabaseUserService.updateOnlineStatus(false);

  }

}


}