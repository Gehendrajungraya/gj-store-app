import 'package:flutter/material.dart';
import '../services/api.dart';
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Notifications')),
    body:FutureBuilder<dynamic>(future:ApiService.notifications(),builder:(c,s){
      if(s.hasError)return Center(child:Padding(padding:const EdgeInsets.all(20),child:Text('Could not load notifications.\n${s.error}',textAlign:TextAlign.center)));
      if(s.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());
      final raw=s.data; final list=raw is List?raw:(raw is Map&&raw['notifications'] is List?raw['notifications']:const []);
      if(list.isEmpty)return const Center(child:Text('No notifications yet.'));
      return ListView.separated(itemCount:list.length,separatorBuilder:(_,__)=>const Divider(height:1),itemBuilder:(c,i){
        final n=Map<String,dynamic>.from(list[i]); return ListTile(leading:const CircleAvatar(child:Icon(Icons.notifications)),title:Text('${n['title']??'Notification'}'),subtitle:Text('${n['message']??n['body']??''}'),);
      });
    }));
}
