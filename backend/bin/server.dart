import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Cấu hình routes
final _router = Router(notFoundHandler: _notFoundHandler)
  ..get('/', _rootHandler)
  ..get('/api/v1/check', _checkHandler)
  ..get('/echo/<message>', _echoHandler)
  ..post('/api/v1/submit', _submitHandler);

//Header mặc định cho dữ liệu trả về dưới dạng JSON
final _headers = {'Content-Type': 'application/json'};

Response _notFoundHandler(Request req) {
  return Response.notFound('Khong tim thay duong dan"${req.url}" tren server');
}

Response _rootHandler(Request req) {
  return Response.ok(
    json.encode({'message': 'Hello World!'}),
    headers: _headers,
  );
}

Response _checkHandler(Request req) {
  return Response.ok(
    json.encode({'message': 'Chu Tien Son'}),
    headers: _headers,
  );
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

Future<Response> _submitHandler(Request req) async {
  try {
    final payload = await req.readAsString();
    final data = json.decode(payload);
    final name = data['name'] as String?;

    if (name != null && name.isNotEmpty) {
      final response = {'message': 'Chao mung $name'};
      return Response.ok(
        json.encode(response),
        headers: _headers,
      );
    } else {
      final response = {'message': 'Server khong nhan duoc ten cua ban'};
      return Response.ok(
        json.encode(response),
        headers: _headers,
      );
    }
  } catch (e) {
    //Xu ly ngoai le khi giai ma JSON
    final response = {'message': 'Yeu cau khong hop le.Loi ${e.toString()}'};

    //Tra ve phan hoi voi statusCode 400
    return Response.badRequest(
      body: json.encode(response),
      headers: _headers,
    );
  }
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  final corsHeader = createMiddleware(
    requestHandler: (req) {
      if (req.method == "OPTIONS") {
        return Response.ok('', headers: {
          //Cho phep moi nguoi truy cap
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,PATCH,HEAD',
          'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        });
      }
      return null; //Tiep tuc xu ly cac yeu cau khac
    },
    responseHandler: (res) {
      return res.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,PATCH,HEAD',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
      });
    },
  );

  // Cấu hình 1 pipeline để logs các requests và middleware
  final handler = Pipeline()
      .addMiddleware(corsHeader)
      .addMiddleware(logRequests())
      .addHandler(_router.call);

  // Để chạy trong các container, chúng ta sẽ sử dụng biến môi trường PORT.
  //Nếu biến môi trường không được thiết lập nó sẽ sử dụng giá trị từ biến
  // môi trường này;nếu không ,nó sẽ sử dụng giá trị mặc định là 8080
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
