import 'package:currency_convertor/currency_converter_cupertino_page.dart';
import 'package:currency_convertor/currency_converter_material_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main(){
  runApp(const MyApp()); //telling flutter to run the app
}


class MyApp extends StatelessWidget{
  const MyApp({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: CurrencyConverterMaterialPage()
    );
  }
}
class MyCupertinoApp extends StatelessWidget {
  const MyCupertinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      home: CurrencyConverterCupertinoPage(),
      );
    
  }
}