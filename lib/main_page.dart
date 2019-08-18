import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'globals.dart' as globals;
import 'Restaurant_detail.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

class MainPage extends StatefulWidget {
  @override
  State createState() => new MainPageState();
}

class MainPageState extends State<MainPage> {
  int index = 1;

  bool currentlySearching = false;
  Icon _searchIcon = new Icon(Icons.search);
  List names = new List();
  List ids = new List();
  List filteredNames = new List();
  Widget _appBarTitle = new Text('Search');


  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  LocationData currentLocation;
  var location = new Location();
  String error = '';
  double long, lat;

  MainPageState(){
    _filter.addListener((){
      if (_filter.text.isEmpty){
        setState((){
          _searchText = "";
        });
      } else {
        setState((){
          _searchText = _filter.text;
        });
      }
    });
  }

  getLoc() async {
    print("Getting the location ...");
    try {
      currentLocation = await location.getLocation();
      print("Got the location " + currentLocation.toString());
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED"){
        error = "Permission denied";
      }
      currentLocation = null;
      print("Failed to get the location ...");
    }
    long = currentLocation.longitude;
    lat = currentLocation.latitude;
  }

  @override
  void initState() {

    super.initState();
    getLoc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _makeAppBar(),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Text("Restaurants near Me:"),
                  SizedBox(height: 20.0),
                  Container(
                    height: 300.0,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: 12,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildCard("McDonaldss", 1.0);
                      },
                    ),
                  ),
                ],
              ),
            ),
            overlayContainer(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
        drawer: _buildDrawer());
  }

  Widget _buildList(){
    return new FutureBuilder(
      future: main(),
      builder: (context,snapshot){
        return ListView.builder(
          itemCount: filteredNames.length,
          itemBuilder:(BuildContext context, int index){
            return new ListTile(
              title: Text(filteredNames[index]),
              onTap:() => {
                Navigator.push(context, MaterialPageRoute(builder:(context)=> ResDetailPage())),
                globals.searchName = filteredNames[index],
                globals.searchId = ids[index],
              },
              
            );
          }
        );
      }
    );
  }

  Widget _buildCard(String name, double dist) {
    return Card(
        elevation: 0.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
            decoration: BoxDecoration(color: Colors.purpleAccent),
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              leading: Container(
                padding: EdgeInsets.only(right: 12.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        right:
                            new BorderSide(width: 1.0, color: Colors.white))),
                child: Icon(Icons.restaurant, color: Colors.white),
              ),
              title: Text("McDonalds",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('10.0' + " miles",
                  style: TextStyle(color: Colors.white70)),
              trailing: Icon(Icons.keyboard_arrow_right,
                  color: Colors.white, size: 15.0),
            )));
  }

  Widget _makeAppBar() {
    return new AppBar(centerTitle: true, title: _appBarTitle, actions: [
      new IconButton(
        alignment: Alignment.center,
        icon: _searchIcon,
        onPressed: _searchPressed,
      ),
    ]);
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search){
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(hintText: 'Searching...')
        );
        currentlySearching = true;
        
      }else{
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Search');
        _filter.clear();
        currentlySearching = false;
      }

    });
  }

  Widget overlayContainer() {
    if (currentlySearching == true){
      return Container(
        color: Colors.white,
        child: _buildList(),
      );
    }
    else
    return Container();
  }

  Widget _buildDrawer() {
    return Drawer(
        child: ListView(children: <Widget>[
      DrawerHeader(
          child: Row(
        children: <Widget>[
          Icon(Icons.cake),
          SizedBox(width: 10.0),
          Text("Hi, Nina",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        ],
      ))
    ]));
  }

  main() async {
    if (lat == null || long == null) {
      lat = 34.151275;
      long = -118.032479;
    }
    String link = "https://api.yelp.com/v3/autocomplete?text=" + _searchText + "&latitude=" + lat.toString() + "&longitude=" + long.toString();

    Uri uri = Uri.parse(link);

    var req = new http.Request("GET", uri);
    req.headers['Authorization'] = 
          'Bearer SA1fb-rkIX8AVuGQ7RjZs7Tr5XyAWDQLGE1Sjuo2rooQrbCDux5Adcv5VcQBCSyg-CalbNL4TV5mD9wFnm22GH4TlGPVkY1uQxWtB-YOt2hP3KLMrqeYRxe4DyI2XXYx';
    var res = await req.send();
    var obj = jsonDecode(await res.stream.bytesToString());
    print(obj);
    List name = [];
    List id = [];
    for (var term in obj['businesses']) {
     name.add(term['name']);
     id.add(term['id']);
    }
     
    setState((){
      names = name;
      ids = id;
      filteredNames = names;
      print(filteredNames);
    });
    }
  

  Widget _buildBottomNav() {
    return new BottomNavigationBar(
      currentIndex: 1,
      onTap: (index) {
        this.index = index;
        if (index == 0) {}
        if (index == 2) {
          // Navigator.push(context,
          //   MaterialPageRoute(builder:(context)=> MyHomePage()));
        }
      },
      items: <BottomNavigationBarItem>[
        new BottomNavigationBarItem(
          icon: new Icon(Icons.home),
          title: new Text("Home"),
        ),
        new BottomNavigationBarItem(
          icon: new Icon(Icons.search),
          title: new Text("Search"),
        ),
        new BottomNavigationBarItem(
          icon: new Icon(Icons.account_box),
          title: new Text("Profile"),
        ),
      ],
    );
  }
}
