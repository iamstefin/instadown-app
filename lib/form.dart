import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';
import 'insta.dart' as instadart;
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';

class FormScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FormScreenState();
  }
}

class FormScreenState extends State<FormScreen> {
  String _url;
  var txt = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> allUrls = [];

  Widget _buildURL() {
    return TextFormField(
      controller: txt,
      decoration: InputDecoration(labelText: 'Post URL'),
      validator: (String value) {
        if (value.isEmpty) {
          try {
            FlutterClipboard.paste().then((value) {
              txt.text = value;
              return null;
            });
          } catch (e) {
            return "URL is required";
          }
        }

        return null;
      },
      onSaved: (String value) {
        _url = value;
      },
    );
  }

  void _pushSaved() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      allUrls = [
        ...{...allUrls}
      ];
      return Scaffold(
        appBar: AppBar(
          title: Text('Saved Posts'),
        ),
        body: ListView.builder(
          itemCount: allUrls.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                onTap: () => {launch(allUrls[index])},
                title: Text("Post " + (index + 1).toString()),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(allUrls[index]),
                ),
                trailing: IconButton(
                    icon: Icon(Icons.file_download),
                    onPressed: () async {
                      final status = await Permission.storage.request();
                      if (status.isGranted) {
                        //final externalDir = await getDownloadsDirectory();
                        final id = FlutterDownloader.enqueue(
                          url: allUrls[index],
                          savedDir: '/storage/emulated/0/Download/',
                          fileName: allUrls[index]
                                  .substring(allUrls[index].length - 5) +
                              ".jpeg",
                          showNotification: true,
                          openFileFromNotification: true,
                        );
                      } else {
                        Toast.show("Permission Denied!", context,
                            duration: Toast.LENGTH_SHORT,
                            gravity: Toast.BOTTOM);
                      }
                    }),
              ),
            );
          },
        ),
      );
    }));
  }

  void _downloadClick() async {
    if (!_formKey.currentState.validate()) {
      Toast.show("Oops! Some Error Occured!", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return;
    }
    _formKey.currentState.save();
    Toast.show("Fetching Download URL! ", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    try {
      var firstPostUrl = await instadart.getFullURLOne(_url);
      allUrls.add(firstPostUrl);
      _formKey.currentState.reset();
      await for (var fullUrl in instadart.getFullURLMultiple(_url)) {
        try {
          allUrls.add(fullUrl);
          Toast.show("Added URL to the list!", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        } catch (e) {
          Toast.show("Cannot Launch URL", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
      }
    } catch (e) {
      Toast.show(e, context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Download From Instagram"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved)
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildURL(),
              SizedBox(height: 100),
              RaisedButton(
                child: Text(
                  'Download',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: _downloadClick,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
