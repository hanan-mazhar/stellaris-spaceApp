import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:stellaris/HomeScreen.dart';

import 'package:flutter/services.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  
  // Splash ke baad bars ko wapas lane ke liye
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(DevicePreview(builder: (context)=>Stellaris()));
}
class Stellaris extends StatelessWidget{
  const Stellaris({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stellaris - space app',
      home: Homescreen(),
    );
 
 
 
  }
}