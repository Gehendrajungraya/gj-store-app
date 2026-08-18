import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login.dart';
import 'notifications.dart';

class AccountScreen extends StatefulWidget { const AccountScreen({super.key}); @override State<AccountScreen> createState()=>_AccountScreenState(); }
class _AccountScreenState extends State<AccountScreen>{
  bool logged=false;
  @override void initState(){super.initState();_check();}
  Future<void> _check() async {final x=await AuthService.isLoggedIn();if(mounted)setState(()=>logged=x);}
  Future<void> _login() async {final ok=await Navigator.push<bool>(context,MaterialPageRoute(builder:(_)=>const LoginScreen()));if(ok==true)_check();}
  @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('My Account')),body:ListView(padding:const EdgeInsets.all(16),children:[
    const CircleAvatar(radius:38,child:Icon(Icons.person,size:42)),const SizedBox(height:10),
    Center(child:Text(logged?'Signed in':'Guest User',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold))),
    const SizedBox(height:20),
    for(final x in ['Orders','Licenses','Downloads','Wishlist'])ListTile(leading:const Icon(Icons.chevron_right),title:Text(x),onTap:logged?(){}:null),
    ListTile(leading:const Icon(Icons.notifications_outlined),title:const Text('Notifications'),onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>const NotificationsScreen()))),
    if(logged)ListTile(leading:const Icon(Icons.logout),title:const Text('Logout'),onTap:()async{await AuthService.logout();_check();})
    else FilledButton.icon(onPressed:_login,icon:const Icon(Icons.login),label:const Text('Login / Register')),
  ]));
}
