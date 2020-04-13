import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:toast/toast.dart';
import 'custom_pop.dart';
class ipl extends StatefulWidget {
  @override
  _iplState createState() => _iplState();

}

// ignore: camel_case_types
class _iplState extends State<ipl> {
  bool isOn = false;
  File _image ;
  LocationData _locationData;
  LatLng _center = LatLng(0, 0);
  DateTime time;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
    var infoWindowVisible = false;
    GlobalKey<State> key = new GlobalKey();
    Opacity popup() {
      return Opacity(
        opacity: infoWindowVisible ? 1.0 : 0.0,
        child: Container(
          alignment: Alignment.bottomCenter,
          width: 279.0,
          height: 256.0,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/ic_info_window.png"),
                  fit: BoxFit.cover)),
          child: CustomPopup(key: key),
        ),
      );
    }

    Opacity marker() {
      return Opacity(
        child: Container(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/ic_marker.png',
              width: 49,
              height: 65,
            )),
        opacity: infoWindowVisible ? 0.0 : 1.0,
      );
    }
    Stack _buildCustomMarker() {
      return Stack(
        children: <Widget>[popup(), marker()],
      );
    }
    List<Marker> _buildMarkersOnMap() {
      List<Marker> markers = List<Marker>();
      var marker = new Marker(
        point: _center,
        width: 279.0,
        height: 256.0,
        builder: (context) => GestureDetector(
            onTap: () {
              setState(() {
                if (key.currentState != null &&
                    (key.currentState as CustomPopupState).controller != null &&
                    (key.currentState as CustomPopupState).controller.value !=
                        null &&
                    (key.currentState as CustomPopupState)
                        .controller
                        .value
                        .isPlaying) {
                  (key.currentState as CustomPopupState).controller.pause();
                  (key.currentState as CustomPopupState).playerIcon =
                      Icons.play_arrow;
                }
                infoWindowVisible = !infoWindowVisible;
              });
            },
            child: _buildCustomMarker()),
      );
      markers.add(marker);

      return markers;
    }



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
      isOn = true;
      time = DateTime.now();
    });
  }

  goToLocation(){}

  @override
  Widget build(BuildContext context) {
    print(_locationData);
    Random r = Random();

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
                trailing: isOn ? FlatButton(
                  child: Text('FINISH', style: TextStyle(color: Colors.blue, fontSize: 15),),
                  onPressed: (){
                    setState(() {
                      isOn = false;
                    });
                  },
                ) : SizedBox(height: 0, width: 0,)
              ),
              SizedBox(height: 15,),
              Container(
                height:170,
                child: isOn ? Stack(
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
//                            'accessToken':
                             // 'pk.eyJ1IjoibW9oYW1tYWQ1NDYiLCJhIjoiY2s4eGlnNndsMDV0dDNrbm0xeXAyMGV1MiJ9.AmyJo3b5xkJaCRABSGsUYg',
                              //'id': 'mapbox.mapbox-streets-v8'
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
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Align(
                          alignment: Alignment.topRight,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image(
                                height: 50,
                                width: 50,
                                image: NetworkImage('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
                              )
                          )
                      ),
                    ),
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
                            child: Text('Take Pictures', style: TextStyle(color: Colors.white),),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      onPressed: isOn ? goToLocation : getLocation,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Icon(isOn ? Icons.navigation : Icons.my_location, color: Colors.white,),
                          ),
                          Expanded(
                            child: Text(isOn ? 'Navigation' : 'Mark Location', style: TextStyle(color: Colors.white),),
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


}


