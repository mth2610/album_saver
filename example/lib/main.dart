import 'dart:io';

import 'package:flutter/material.dart';
import 'package:album_saver/album_saver.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File _image;
  String _dcimPath;

  void _getDcimPath()async{
    _dcimPath = await AlbumSaver.getDcimPath();
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          children: <Widget>[
            _buildPickedImage(),
            _dcimPath != null
            ? Container(
              padding: const EdgeInsets.all(16),
              child: Text("DCIM path: $_dcimPath")
            )
            : Container(),
            _buildImagePickerButton(),
            _buildSaveToAlbumButton(),
            _buildCreateAlbumButton(),
            Platform.isAndroid==true
            ? _builGetDcimPathButton()
            : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildPickedImage(){
    return Container(
      margin: EdgeInsets.all(16),
      height: 300.0,
      child: _image!=null
        ? null
        : Center(
          child: Container(
            child: Text("No selected image"),
          ),
        ),
      decoration: _image!=null
        ? BoxDecoration(
          border: Border.all(width: 1),
          image: DecorationImage(
            image: FileImage(_image),
          )
        )
        : BoxDecoration(
          border: Border.all(width: 1)
        ),
    );
  }

  Widget _buildImagePickerButton(){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: ()async{
              var image = await ImagePicker.pickImage(source: ImageSource.camera);
              setState(() {
                _image = image;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.folder),
            onPressed: ()async{
              var image = await ImagePicker.pickImage(source: ImageSource.gallery);
              setState(() {
                _image = image;
              });
            },
          )
        ],
      ),
    );
  }

  Widget _buildSaveToAlbumButton(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: RaisedButton(
        color: Colors.blue,
        textColor: Colors.white,
        child: Text("Save to album"),
        onPressed: (){
          AlbumSaver.saveToAlbum(filePath: _image.path, albumName: "test_album_saver2");
        },
      ),
    );
  }

  Widget _buildCreateAlbumButton(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: RaisedButton(
        color: Colors.blue,
        textColor: Colors.white,
        child: Text("Create a album named MyTestAlbum"),
        onPressed: (){
          AlbumSaver.createAlbum(albumName: "MyTestAlbum");
        },
      ),
    );
  }

  Widget _builGetDcimPathButton(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: RaisedButton(
                color: Colors.blue,
        textColor: Colors.white,
        child: Text("Get Dcim path"),
        onPressed: (){
          _getDcimPath();
        },
      ),
    );
  }
}
