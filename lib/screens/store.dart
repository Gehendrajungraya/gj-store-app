import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api.dart';
import '../widgets/product_card.dart';

class StoreScreen extends StatefulWidget { const StoreScreen({super.key}); @override State<StoreScreen> createState()=>_StoreScreenState(); }
class _StoreScreenState extends State<StoreScreen>{
  final controller=TextEditingController(); Future<List<Product>>? future;
  void search(){setState(()=>future=ApiService.products(search:controller.text.trim()));}
  @override void initState(){super.initState();future=ApiService.products();}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Store'),bottom:PreferredSize(preferredSize:const Size.fromHeight(64),child:Padding(padding:const EdgeInsets.fromLTRB(16,0,16,10),child:TextField(controller:controller,onSubmitted:(_)=>search(),decoration:InputDecoration(hintText:'Search plugins...',prefixIcon:const Icon(Icons.search),filled:true,border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide.none))))),),body:FutureBuilder<List<Product>>(future:future,builder:(c,s){if(s.hasError)return Center(child:Text('${s.error}'));if(s.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());final p=s.data??[];if(p.isEmpty)return const Center(child:Text('No plugins found.'));return GridView.builder(padding:const EdgeInsets.all(16),itemCount:p.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:12,mainAxisSpacing:12,childAspectRatio:.72),itemBuilder:(c,i)=>ProductCard(product:p[i]));}));
}
