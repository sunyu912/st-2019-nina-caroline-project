import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'globals.dart' as globals;

class ResDetailPage extends StatefulWidget {
  @override
  State createState() => new ResDetailPageState();
}

class ResDetailPageState extends State<ResDetailPage> {
  int index = 1;
  bool currentlySearching = false;
  Icon _searchIcon = new Icon(Icons.search);
  List names = new List();
  List filteredNames = new List();
  Widget _appBarTitle = new Text('Search');
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _makeAppBar(),
        body: buildName(globals.searchName, globals.searchId),
        drawer: _buildDrawer());
  }

  Widget buildName(String name, String id){
    return Center(
    child: FutureBuilder(
        future: main(),
        builder: (context,snapshot){
          if(!snapshot.hasData){
            return CircularProgressIndicator();
          }
        return ListView.builder(
          itemCount: names.length,
          itemBuilder:(BuildContext context, int index){
            return new ListTile(
              title: Text(names[index]),
            );
          }
        );
      }
    ),
    );
  }
    




  Widget _makeAppBar() {
    return new AppBar(
      centerTitle: true, 
      title: _appBarTitle,
    );
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

  main() async {
    String link = "https://Food-extraction-THIS-ONE.ninaluo.repl.run" + _searchText + "&latitude=" + "34.0522" + "&longitude=" + "-118.2437";
    Uri uri = Uri.parse(link);

    var req = new http.Request("GET", uri);
    req.headers['Authorization'] = 
          'Bearer SA1fb-rkIX8AVuGQ7RjZs7Tr5XyAWDQLGE1Sjuo2rooQrbCDux5Adcv5VcQBCSyg-CalbNL4TV5mD9wFnm22GH4TlGPVkY1uQxWtB-YOt2hP3KLMrqeYRxe4DyI2XXYx';
    var res = await req.send();
    var obj = jsonDecode(await res.stream.bytesToString());
    List name = [];
    List id = [];
    for (var term in obj) {
     name.add(term['name']);
    }
     
    setState((){
      names = name;
    });
    }
}

