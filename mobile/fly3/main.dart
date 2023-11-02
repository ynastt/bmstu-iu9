import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mysql1/mysql1.dart';

Future aaa(String x_name, String x_email, int x_age) async {
  print(x_name);
  print(x_email);
  print(x_age);
  // conn
  final conn = await MySqlConnection.connect(ConnectionSettings(
      host: 'students.yss.su',
      port: 3306,
      user: 'iu9mobile',
      db: 'iu9mobile',
      password: 'bmstubmstu123'));

  // data
  await conn.query(
      'insert into Yarovikova (name, email, age) values (?, ?, ?)',
      [x_name, x_email, x_age]);

  // Finally, close the connection
  await conn.close();
}

Future bbb() async {
  String data = "";
  String r = "";
  // conn
  final conn = await MySqlConnection.connect(ConnectionSettings(
      host: 'students.yss.su',
      port: 3306,
      user: 'iu9mobile',
      db: 'iu9mobile',
      password: 'bmstubmstu123'));

  //query data
  var results = await conn.query('select * from Yarovikova');
  for (var row in results) {
    r = "Name: ${row[1]}, Email: ${row[2]}, Age: ${row[3]}";
    print(r);
    data = "$data\n$r";
  }

  // Finally, close the connection
  await conn.close();
  return data;
}


class MyForm extends StatefulWidget {
  const MyForm({super.key});

  @override
  State<StatefulWidget> createState() => MyFormState();
}

class MyFormState extends State {
  final _formKey = GlobalKey<FormState>();
  String _body = "";
  String _body_name = "";
  int _body_age = 0;
  String _body_email = "";

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        child: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              const Text('Имя:', style: TextStyle(fontSize: 20.0),),
              TextFormField(validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'поле "Имя"- не заполнено!';
                } else {
                  print('name---->'+value);
                  _body_name = value;
                }
              }),
              const SizedBox(height: 20.0),
              const Text('Почта:', style: TextStyle(fontSize: 20.0),),
              TextFormField(validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'поле "Почта"- не заполнено!';
                } else {
                  print('email---->'+value);
                  _body_email = value;
                }
              }),
              const SizedBox(height: 20.0),
              const Text('Возраст:', style: TextStyle(fontSize: 20.0),),
              TextFormField(validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'поле "Возраст"- не заполнено!';
                } else {
                  print('age----> $value');
                  _body_age = int.parse(value);
                }
              }),
              const SizedBox(height: 20.0),
              ElevatedButton(
                child: const Text('send'),
                onPressed: () async {
                  if(_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Форма заполнена!'),
                      backgroundColor: Colors.blue,
                    ));
                    print("ok - data was sent");
                  }
                  // insert data
                  await aaa(_body_name, _body_email, _body_age);
                  // query data
                  _body = await bbb();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold)
                ),
              ),
              Text(_body)
            ],
            )
        )
    );
  }
}

Future main() async {
  // create table
  final conn = await MySqlConnection.connect(ConnectionSettings(
      host: 'students.yss.su',
      port: 3306,
      user: 'iu9mobile',
      db: 'iu9mobile',
      password: 'bmstubmstu123'));

  // check if exists -> if not -> create table
  var result = await conn.query(
      'CREATE TABLE IF NOT EXISTS Yarovikova(name char(255), email char(255), age int)');
  await conn.close();

  // input data  form -> insert data
  return runApp(MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
              appBar: AppBar(title: new Text('IU9 - Форма ввода')),
              body: MyForm()
          )
      )
  );
}