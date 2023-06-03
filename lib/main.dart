// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_application_2/control_button.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  
const MyApp({ super.key});
@override
  Widget build(BuildContext context) {
    return  MaterialApp(
     
         title: 'Flutter Demo',
         theme: ThemeData (
          
              primarySwatch: Colors.blue ,

           ), 

       // ignore: sort_child_properties_last
       home: const MyHomePage (title: 'Flutter Demo Home Page')
                
                 
         );


        
   
          


}

 
}
class MyHomePage extends StatefulWidget
{
const MyHomePage({super.key, required this.title});
final String title;
@override
State<MyHomePage> createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage>
{

 late final WebViewController controller;
 @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse('https://flutter.dev'),
      );
  }
@override
Widget build(BuildContext context)
{
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
       body: WebViewWidget(
        controller: controller,
      ),
      
  );
}


}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  final List<BluetoothDevice> _devicesList = [];
  List<BluetoothService>? bluetoothServices;
  List<ControlButton> controlButtons = [];
  String? readableValue;

  @override
  void initState() {
    initBleList();
    super.initState();
  }

  Future initBleList() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothAdvertise.request();
    flutterBlue.connectedDevices.asStream().listen((devices) {
      for (var device in devices) {
        _addDeviceTolist(device);
      }
    });
    flutterBlue.scanResults.listen((scanResults) {
      for (var result in scanResults) {
        _addDeviceTolist(result.device);
      }
    });
    flutterBlue.startScan();
  }

  void _addDeviceTolist(BluetoothDevice device) {
    if (!_devicesList.contains(device)) {
      setState(() {
        _devicesList.add(device);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Bluetooth')), body: bluetoothServices == null ? _buildListViewOfDevices() : _buildControlButtons() );
  }

  ListView _buildListViewOfDevices() {
    List<Widget> containers = [];
    for (BluetoothDevice device in _devicesList) {
      containers.add(
        SizedBox(
          height: 60,
          child: Row(
            children: <Widget>[
              Expanded(child: Column(children: <Widget>[Text(device.name), Text(device.id.toString())])),
              ElevatedButton(
                child: const Text('Connect', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  {
                      await device.connect();
                       const Text('Connected Succsesfuly');
                      List<BluetoothService> services = await device.discoverServices();
                      setState(() {
                        bluetoothServices = services;
                      });
                    } 
                      await device.disconnect();
                
                  }
              ),
              
              ElevatedButton(
                child: const Text('disconnect', style: TextStyle(color: Colors.white)),

                onPressed: () async {
                  {
                      await device.disconnect();
                        const Text('disconnect');
                      
                    } 
                     
                
                  }
              )

              
            ],
          ),
        ),
      );
    }
    return ListView(padding: const EdgeInsets.all(8), children: <Widget>[...containers]);
  }

  Widget _buildControlButtons() {
    return Column(
      children: [
        Wrap(
          children: controlButtons
              .map((e) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ElevatedButton(onPressed: e.onTap, child: Text(e.buttonName)),
                  ))
              .toList(),
        ),
        Center(child: Text(readableValue ?? '')),
      ],
    );
  }



}
