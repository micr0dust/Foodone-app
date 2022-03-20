import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Store> fetchStore() async {
  final response = await http.get(
      Uri.parse(
          'https://hello-cycu-delivery-service.herokuapp.com/member/store'),
      headers: {
        "token":
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhbGdvcml0aG0iOiJIUzI1NiIsImV4cCI6MTY0Nzc2NDIzNSwiZGF0YSI6IjYxYzAwYzVlOTMxOTQ3MzFiZGU4OWE2ZiIsImlhdCI6MTY0Nzc2MjQzNX0.EUky4T3sOjVbu-Mz3IGOO75z13jtOcJujFL9R-miyfg",
        "Content-Type": "application/x-www-form-urlencoded"
      });
  if (response.statusCode == 200) {
    return Store.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load store');
  }
}

class Store {
  String? status;
  bool? code;
  List<Result>? result;

  Store({this.status, this.code, this.result});

  Store.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(new Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['code'] = this.code;
    if (this.result != null) {
      data['result'] = this.result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Result {
  String? name;
  String? address;
  String? id;

  Result({this.name, this.address, this.id});

  Result.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    address = json['address'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['address'] = this.address;
    data['id'] = this.id;
    return data;
  }
}

Widget _card() {
  return Card(
      child: Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      const ListTile(
        leading: Icon(Icons.album),
        title: Text('The Enchanted Nightingale'),
        subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.end),
    ],
  ));
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Store> futureStore;

  @override
  void initState() {
    super.initState();
    futureStore = fetchStore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FutureBuilder<Store>(
                  future: futureStore,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      List data = snapshot.data.result;
                      return Center(
                          child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.event_seat),
                            title: Text('${data[index].name}'),
                            subtitle: Text('${data[index].address}'),
                          );
                        },
                      ));
                    }
                  })
            ],
          ),
        ));
  }
}
