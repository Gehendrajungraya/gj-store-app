import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/product_details.dart';
class ProductCard extends StatelessWidget{
  final Product product; const ProductCard({super.key,required this.product});
  @override Widget build(BuildContext context)=>Card(clipBehavior:Clip.antiAlias,elevation:1,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Expanded(child:product.image.isEmpty?Container(color:Colors.deepPurple.shade50,child:const Icon(Icons.extension,size:50)):Image.network(product.image,width:double.infinity,fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(color:Colors.deepPurple.shade50,child:const Icon(Icons.extension,size:50)))),
    Padding(padding:const EdgeInsets.fromLTRB(10,9,10,4),child:Text(product.title,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.bold))),
    Padding(padding:const EdgeInsets.symmetric(horizontal:10),child:Text(product.price.isEmpty?'View price':product.price,style:const TextStyle(fontWeight:FontWeight.w800))),
    Padding(padding:const EdgeInsets.all(8),child:SizedBox(width:double.infinity,child:OutlinedButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ProductDetailsScreen(product:product))),child:const Text('View Product'))))
  ]));
}
