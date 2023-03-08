import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

Future<bool> predict(XFile file) async
{
  http.StreamedResponse response;
  var responseJson;
  final image = File(file.path);
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://71.94.11.69:5050/image')
  );
  request.files.add(await http.MultipartFile.fromPath('image', file.path));

  try {
    response = await request.send();
    responseJson = jsonDecode(await response.stream.bytesToString());
    print(responseJson);
    double castedJson = responseJson.toDouble();
  }catch (e){
    print('Error occurred while sending request: $e');
    return false;
  }

    if(responseJson < 0.5) {
      return true;
    } else {
      return false;
    }
  }
