import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import 'imageView.dart';
class ipl extends StatefulWidget {
  @override
  _iplState createState() => _iplState();

}

class _iplState extends State<ipl> {
  bool isLocationOn = false;
  bool isImageOn = false;
  bool isImageViewOn = false;
  File _image ;
  LocationData _locationData;
  LatLng _center = LatLng(0, 0);
  DateTime time;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if(image!= null)
      setState(() {
        isImageOn = true;
      });
    setState(() {
      _image = image;
    });



  }

  Future getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

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

    setState(() {
      isLocationOn = true;
      time = DateTime.now();
    });
  }

  static Future<void> goToLocation(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(

          padding: EdgeInsets.fromLTRB(20, 50, 20, 50),
          child: Column(
            children: <Widget>[
              SizedBox(height: 250,),
              ListTile(
                  leading: Text('PARKING LOCATION', style: TextStyle(color: Colors.white70, fontSize: 15),),
                trailing: isLocationOn ? FlatButton(
                  child: Text('FINISH', style: TextStyle(color: Colors.blue, fontSize: 15),),
                  onPressed: (){
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Are you sure you want to stop this parking session?'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('CANCEL'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text('FINISH'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                isLocationOn = false;
                                isImageOn = false;
                              });
                            },
                          ),
                        ],
                      ),
                      barrierDismissible: false
                    );
                  },
                ) : SizedBox(height: 0, width: 0,)
              ),
              SizedBox(height: 15,),
              Container(
                height:170,
                child: isLocationOn ? Stack(
                  children: <Widget>[
                    FlutterMap(
                      options: new MapOptions(
                        minZoom: 15.0,
                        center: _locationData == null ? _center : LatLng(_locationData.latitude, _locationData.longitude),
                        interactive: true,
                      ),
                      layers: [
                        new TileLayerOptions(
                            urlTemplate:
                            "https://api.mapbox.com/styles/v1/loredana/cjwhjt50d005k1dplt10c8e5r/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibG9yZWRhbmEiLCJhIjoiY2p1dXk3ZHl4MG53OTN5bWhxZjYxYzJodSJ9.TyqzGK0TjNAIDF6B5FwNyA",
                            additionalOptions: {
                              'accessToken':
                              'pk.eyJ1IjoibG9yZWRhbmEiLCJhIjoiY2p1dXk3ZHl4MG53OTN5bWhxZjYxYzJodSJ9.TyqzGK0TjNAIDF6B5FwNyA',
                              'id': 'mapbox.mapbox-streets-v8'
//                          
                            }),
                        MarkerLayerOptions(
                          markers: [
                            new Marker(
                              width: 80.0,
                              height: 80.0,
                              point: _locationData == null ? _center : LatLng(_locationData.latitude, _locationData.longitude),
                              builder: (ctx) =>
                              new Container(
                                child: new Icon(Icons.location_on, color: Colors.red,),
                              ),
                            ),
                          ],
                        ),
                      ]),
                    isImageOn ? FlatButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ViewImage(_image)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Align(
                            alignment: Alignment.topRight,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image(
                                  fit: BoxFit.fill,
                                  height: 50,
                                  width: 50,
                                  image: FileImage(_image),
                                )
                            )
                        ),
                      ),
                    ) : Container(),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: double.infinity,
                        child: Container(
                          color: Colors.white60,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(100, 5, 0, 5),
                            child: Text('Parking Duration: 0 minutes', style: TextStyle(color:  Colors.white),),
                          ),
                        ),
                      ),
                    )
                  ],
                ) : Column(
                      children: <Widget>[
                        Text('Parking Location Service', style: TextStyle(color: Colors.white),),
                        SizedBox(height: 20,),
                        Text("Record your vehicle's parking location, making it easier to"
                        "be found later. Mobile data and GPS must be turned on to"
                        "mark your vehicle's location. For indoor parking, use the"
                        "'Take Pictures' function, as indoor location recording isn't"
                        "currently available", style: TextStyle(color: Colors.white70, fontSize: 12),),
                      ],
                    ),
              ),
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
                            child: Text(isImageOn ? 'Retake Picture' : 'Take Picture', style: TextStyle(color: Colors.white),),
                          )
                        ],
                      ),
                    ),
                  ),
                  !isLocationOn ? Expanded(
                    child: FlatButton(
                      onPressed: getLocation,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Icon(isLocationOn ? Icons.navigation : Icons.my_location, color: Colors.white,),
                          ),
                          Expanded(
                            child: Text(isLocationOn ? 'Navigation' : 'Mark Location', style: TextStyle(color: Colors.white),),
                          )
                        ],
                      ),
                    ),
                  ) : Expanded(
                    child: FlatButton(
                      onPressed:() async {
                        goToLocation(_locationData.latitude, _locationData.longitude);
                      },
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Icon(isLocationOn ? Icons.navigation : Icons.my_location, color: Colors.white,),
                          ),
                          Expanded(
                            child: Text(isLocationOn ? 'Navigation' : 'Mark Location', style: TextStyle(color: Colors.white),),
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
      ),
      // This trailing comma makes auto-formatting nicer for build methods.

    );


  }

  Future<void> areYouSure() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rewind and remember'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to stop'),
                Text('This parking session?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('FINISH'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


}


