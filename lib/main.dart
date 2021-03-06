import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Product> fetchStore() async {
  final response = await http.get(
      Uri.parse(
          'https://hello-cycu-delivery-service.herokuapp.com/member/store/product'),
      headers: {
        "token":
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhbGdvcml0aG0iOiJIUzI1NiIsImV4cCI6MTY0Nzg1MjY3OSwiZGF0YSI6IjYxYzk3NzQxMzdlMWJhNGJlY2JiZTFjNyIsImlhdCI6MTY0Nzg1MDg3OX0.WOwAjjJ6iKQEEL3tCkMJaenLDQMNWj9d040Dz5MDEy0",
        "id": "8y3un9ka",
        "Content-Type": "application/x-www-form-urlencoded"
      });
  if (response.statusCode == 200) {
    return Product.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load store');
  }
}

class Product {
  String? status;
  bool? code;
  List<Result>? result;

  Product({this.status, this.code, this.result});

  Product.fromJson(Map<String, dynamic> json) {
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
  String? price;
  String? describe;
  String? type;

  Result({this.name, this.price, this.describe, this.type});

  Result.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    describe = json['describe'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['price'] = this.price;
    data['describe'] = this.describe;
    data['type'] = this.type;
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
  late Future<Product> futureStore;

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
              FutureBuilder<Product>(
                  future: futureStore,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      List data = snapshot.data.result;
                      data = data
                          .where((product) => product.type.contains("??????"))
                          .toList();
                      return Center(
                          child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.event_seat),
                            title: Text('${data[index].name}'),
                            subtitle: Text('${data[index].price}'),
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
