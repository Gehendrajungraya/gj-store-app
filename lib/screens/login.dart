import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override State<LoginScreen> createState()=>_LoginScreenState(); }
class _LoginScreenState extends State<LoginScreen>{
  final email=TextEditingController(), password=TextEditingController();
  bool loading=false; String? error;
  Future<void> submit() async {
    setState(()=>loading=true); error=null;
    try { final token=await AuthService.login(email.text.trim(),password.text);
      if(!mounted)return;
      if(token==null){setState(()=>error='Login response did not contain a token. Check your plugin API.');}
      else Navigator.pop(context,true);
    } catch(e){if(mounted)setState(()=>error=e.toString());}
    if(mounted)setState(()=>loading=false);
  }
  @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Login')),body:ListView(padding:const EdgeInsets.all(20),children:[
    const SizedBox(height:30),const Icon(Icons.storefront,size:70),const SizedBox(height:20),
    TextField(controller:email,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'Email',prefixIcon:Icon(Icons.email_outlined),border:OutlineInputBorder())),
    const SizedBox(height:14),TextField(controller:password,obscureText:true,decoration:const InputDecoration(labelText:'Password',prefixIcon:Icon(Icons.lock_outline),border:OutlineInputBorder())),
    if(error!=null)Padding(padding:const EdgeInsets.only(top:12),child:Text(error!,style:TextStyle(color:Theme.of(c).colorScheme.error))),
    const SizedBox(height:20),FilledButton(onPressed:loading?null:submit,child:loading?const CircularProgressIndicator():const Text('Login')),
  ]));
}
