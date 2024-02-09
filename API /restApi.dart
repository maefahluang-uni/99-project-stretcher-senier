import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final app = Router();

  // Define routes
  app.get('/hello', (Request request) {
    return Response.ok('Hello, World!');
  });

  app.get('/echo/<message>', (Request request, String message) {
    return Response.ok('You said: $message');
  });

  // Create a Shelf handler
  var handler = const Pipeline()
      .addMiddleware(logRequests()) // Log all requests
      .addHandler(app);

  // Create a server and serve the handler
  var server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('Server running on localhost:${server.port}');
  await server.forEach((HttpRequest request) {
    handler(request).then((response) {
      request.response
        ..headers.contentType = MediaType('application', 'json')
        ..write(jsonEncode({
          'status': response.statusCode,
          'body': response.readAsStringSync(),
        }))
        ..close();
    });
  });
}
