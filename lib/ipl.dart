import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:toast/toast.dart';

class ipl extends StatefulWidget {
  @override
  _iplState createState() => _iplState();

}

class _iplState extends State<ipl> {
  File _image ;
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  Future getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    Toast.show(_locationData.toString(), context);
    print(_locationData);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.black,
      body: Padding(

        padding: EdgeInsets.fromLTRB(20, 50, 20, 50),
        child: Column(
          children: <Widget>[
            SizedBox(height: 250,),
            Text('Parking Location Service', style: TextStyle(color: Colors.white),),
            SizedBox(height: 15,),
            Text("Record your vehicle's parking location, making it easier to"
                "be found later. Mobile data and GPS must be turned on to"
                "mark your vehicle's location. For indoor parking, use the"
                "'Take Pictures' function, as indoor location recording isn't"
                "currently available", style: TextStyle(color: Colors.white, fontSize: 12),),
            SizedBox(height: 200,),
            Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    onPressed: getImage,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Icon(Icons.photo_camera, color: Colors.white,),
                        ),
                        Expanded(
                          child: Text('Take Pictures', style: TextStyle(color: Colors.white),),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    onPressed: getLocation,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Icon(Icons.my_location, color: Colors.white,),
                        ),
                        Expanded(
                          child: Text('Mark Location', style: TextStyle(color: Colors.white),),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


