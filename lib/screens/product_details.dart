import 'package:flutter/material.dart';
import '../models/product.dart';
class ProductDetailsScreen extends StatelessWidget{
  final Product product; const ProductDetailsScreen({super.key,required this.product});
  @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Product')),bottomNavigationBar:SafeArea(child:Padding(padding:const EdgeInsets.all(12),child:Row(children:[
    Expanded(child:OutlinedButton(onPressed:(){},child:const Text('Add to Cart'))),
    const SizedBox(width:10),Expanded(child:FilledButton(onPressed:(){},child:const Text('Buy Now'))),
  ]))),body:ListView(children:[
    AspectRatio(aspectRatio:16/10,child:product.image.isEmpty?Container(color:Colors.deepPurple.shade50,child:const Icon(Icons.extension,size:70)):Image.network(product.image,fit:BoxFit.cover)),
    Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(product.title,style:const TextStyle(fontSize:26,fontWeight:FontWeight.w900)),
      const SizedBox(height:8),Text(product.price,style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
      const SizedBox(height:18),Text(product.description.isEmpty?'No description available.':product.description,style:const TextStyle(height:1.5)),
    ]))
  ]));
}
