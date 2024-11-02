import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp()); //Chạy ứng dụng với widget MainApp
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner:
          false, //Tắt biểu tượng debug ở góc phải màn hình
      title: 'Ứng dụng full-stack flutter đơn giản',
      home: MyHomePage(),
    );
  }
}

// Widget MyHomePage là trang chính của ứng dụng, sử dugnj StatefulWidget
// Để quản lý trạng thái do có nội dung cần thay đổi trên trang này

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Controller de lay du lieu tu Widget TextField
  final controller = TextEditingController();
  //Bien de luu thong diep phan hoi tu server
  String responseMessage = '';

  //Ham de gui ten toi server
  Future<void> sendName() async {
    final name = controller.text;

    //Sau khi lay duoc ten thi xoa noi dung controller
    controller.clear();
    //Endpoint Submit
    final url = Uri.parse('http://localhost:8080/api/v1/submit');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'name': name}),
          )
          .timeout(const Duration(seconds: 10));
      //Kiem tra neu phan hoi co noi dung
      if (response.body.isNotEmpty) {
        final data = json.decode(response.body);

        //Cap nhat trang thai voi thong diep nhan duoc tu server
        setState(() {
          responseMessage = data['message'];
        });
      } else {
        responseMessage = 'Khong nhan duoc tin hieu tu server';
      }
    } catch (e) {
      setState(() {
        responseMessage = 'Da xay ra loi : ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ung dung full-stack flutter don gian')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: sendName,
              child: const Text('Send'),
            ),
            //Hien thi thong diep phan hoi tu server
            Text(
              responseMessage,
              style: Theme.of(context).textTheme.titleLarge,
            )
          ],
        ),
      ),
    );
  }
}
