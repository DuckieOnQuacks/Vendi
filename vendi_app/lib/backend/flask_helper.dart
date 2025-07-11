import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

double castedJson = 0;

Future<bool> predict(XFile file) async {
  http.StreamedResponse response;
  var responseJson;
  var request = http.MultipartRequest(
      'POST', Uri.parse('http://174.87.212.210:5050/image'));
  request.files.add(await http.MultipartFile.fromPath('image', file.path));

  try {
    response = await request.send();
    responseJson = jsonDecode(await response.stream.bytesToString());
    print(responseJson);
    castedJson = responseJson.toDouble();
  } catch (e) {
    print('Error occurred while sending request: $e');
    return false;
  }

  if (responseJson < 0.5) {
    return true;
  } else {
    return false;
  }
}

double getJson() {
  return castedJson;
}
