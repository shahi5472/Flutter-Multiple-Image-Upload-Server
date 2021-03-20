import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class UploadImageScreen extends StatefulWidget {
  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  String yourBearerToken, yourApiUrl;

  List<Asset> images = [];

  List<MultipartFile> _list = [];

  Dio dio = Dio();

  _save() async {
    if (images != null) {
      EasyLoading.show(status: 'loading...');
      for (int i = 0; i < images.length; i++) {
        ByteData byteData = await images[i].getByteData();
        List<int> imageData = byteData.buffer.asUint8List();

        MultipartFile multipartFile = MultipartFile.fromBytes(
          imageData,
          filename: images[i].name,
          contentType: MediaType('image', 'jpg'),
        );

        _list.add(multipartFile);
      }

      FormData formData = FormData.fromMap(
        {'category_id': 1, 'user_id': 23, 'image': _list},
      );

      var response = await dio.post(
        yourApiUrl,
        data: formData,
        options: Options(
          headers: {
            'Accept': "application/json",
            "Authorization": 'Bearer $yourBearerToken',
          },
          method: 'post',
          contentType: 'multipart/form-data;charset=UTF-8',
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode == 200) {
        print(response);
        EasyLoading.dismiss();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload'),
      ),
      body: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ignore: deprecated_member_use
                RaisedButton(
                  onPressed: loadAssets,
                  child: Text('Pick Image'),
                ),
                // ignore: deprecated_member_use
                RaisedButton(
                  onPressed: _save,
                  child: Text('Upload Image'),
                ),
              ],
            ),
            Expanded(
              child: buildGridView(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = [];

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: false,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      print(e.toString());
    }

    if (!mounted) return;

    setState(() {
      images = resultList;
    });
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 4,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }
}
