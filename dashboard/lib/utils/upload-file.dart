import 'dart:convert';
import 'dart:typed_data';
import 'package:dashbord/utils/requette-by-dii.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

// ignore: invalid_use_of_visible_for_testing_member
Future getImage(int source) async => ImagePicker.platform
        // ignore: deprecated_member_use
        .getImage(
            imageQuality: 15,
            source: source == 1 ? ImageSource.gallery : ImageSource.camera)
        .then((value) async {
      if (value == null) {
        return [null, null];
      }
      return [await postpIC(image: value), await value.readAsBytes()];
    });

Future<String> postpIC({required XFile image}) async {
  var img = await (image).readAsBytes();

  Map<String, dynamic> body = {
    "image": "data:image/webp;base64,${base64Encode(img)}"
  };

  var response = await postResponse(url: '/files', body: body);

  if (response['status'] == 200) {
    return response['body']['data']['id'];
  } else {
    return "0";
  }
}

Future<String> postFile({
  required Uint8List byte,
  required String extention,
  required String name,
}) async {
  Map<String, dynamic> body = {
    "image": "data:$name?content/$extention;base64,${base64Encode(byte)}"
  };

  var response = await postResponse(url: '/files', body: body);

  if (response['status'] == 200) {
    return response['body']['data']['id'];
  } else {
    return "0";
  }
}

Future<List?> getFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    PlatformFile file = result.files.first;
    if (file.extension! == 'csv' || file.extension! == 'xlsx') {
      String v = await postFile(
          byte: file.bytes!, extention: file.extension!, name: file.name);
      dynamic vl = await getResponse(url: '/users/tel?id=$v');
      return vl['body']['tel'] as List;
    } else {
      print('veuillez entrez un type de file valide');
    }
  } else {
    // User canceled the picker
    print("Veuillez recommencer il y'a eu dez soucis interne");
  }
  return null;
}
