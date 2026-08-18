import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/product.dart';
import '../models/banner_model.dart';
import '../models/category.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState()=>_HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  Future<List<StoreBanner>>? bs; Future<List<StoreCategory>>? cs; Future<List<Product>>? ps;
  @override void initState(){super.initState(); _load();}
  void _load(){ bs=ApiService.banners(); cs=ApiService.categories(); ps=ApiService.products(); }
  @override Widget build(BuildContext context)=>RefreshIndicator(
    onRefresh:() async=>setState(_load),
    child:ListView(padding:const EdgeInsets.all(16),children:[
      Row(children:[const Expanded(child:Text('GJ STORE',style:TextStyle(fontSize:26,fontWeight:FontWeight.w900))),IconButton(onPressed:(){},icon:const Icon(Icons.notifications_none))]),
      const SizedBox(height:12),
      TextField(decoration:InputDecoration(hintText:'Search plugins...',prefixIcon:const Icon(Icons.search),filled:true,border:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:BorderSide.none))),
      const SizedBox(height:18),
      FutureBuilder<List<StoreBanner>>(future:bs,builder:(c,s)=>SizedBox(height:190,child:s.hasError?const Center(child:Text('Unable to load banners')):s.connectionState!=ConnectionState.done?const Center(child:CircularProgressIndicator()):PageView.builder(itemCount:s.data!.length,itemBuilder:(c,i)=>ClipRRect(borderRadius:BorderRadius.circular(20),child:Stack(fit:StackFit.expand,children:[Image.network(s.data![i].image,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(color:Colors.deepPurple)),Container(padding:const EdgeInsets.all(20),alignment:Alignment.bottomLeft,decoration:const BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.transparent,Colors.black87])),child:Text('${s.data![i].title}\n${s.data![i].subtitle}',style:const TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.bold)))]))))),
      const SizedBox(height:22),
      const Text('Categories',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
      const SizedBox(height:10),
      SizedBox(height:92,child:FutureBuilder<List<StoreCategory>>(future:cs,builder:(c,s)=>s.connectionState!=ConnectionState.done?const Center(child:CircularProgressIndicator()):ListView.separated(scrollDirection:Axis.horizontal,itemCount:s.data?.length??0,separatorBuilder:(_,__)=>const SizedBox(width:10),itemBuilder:(c,i)=>Container(width:110,padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)),child:Center(child:Text(s.data![i].name,textAlign:TextAlign.center)))))),
      const SizedBox(height:22),
      const Text('Featured / Latest',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
      const SizedBox(height:10),
      FutureBuilder<List<Product>>(future:ps,builder:(c,s)=>s.connectionState!=ConnectionState.done?const Center(child:CircularProgressIndicator()):GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:s.data?.length??0,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:12,mainAxisSpacing:12,childAspectRatio:.72),itemBuilder:(c,i)=>ProductCard(product:s.data![i]))),
    ]),
  );
}
