import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

void predict(XFile imageFile) async
{
  final image = File(imageFile.path);
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://192.168.1.217:5000/image')
  );
  request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

  var response = await request.send();
  var responseJson = jsonDecode(response.toString());
  print(responseJson['result']);
}