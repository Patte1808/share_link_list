import 'package:flutter/material.dart';
import '../database/share_provider.dart';
import '../content_preview_card.dart';
import 'package:rxdart/rxdart.dart';
import '../util/og_parser.dart';

class CreateShare extends StatefulWidget {
  @override
  _CreateShareState createState() => _CreateShareState();
}

class _CreateShareState extends State<CreateShare> {
  final _formKey = GlobalKey<FormState>();
  PublishSubject<String> _onTextChanged = PublishSubject<String>();
  PublishSubject<Share> _onShareCreated = PublishSubject<Share>();
  String hashtags = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a new share"),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  hintText: 'URL to website',
                ),
                onChanged: (val) => _onTextChanged.add(val),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Hashtags',
                ),
                onChanged: (val) => hashtags = val,
              ),
              StreamBuilder(
                stream: _onShareCreated.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return RaisedButton(
                      child: Text("Save Share"),
                      onPressed: () {
                        snapshot.data.hashtags = hashtags.split(" ").map((hashtagName) => Hashtag(hashtagName)).toList();
                        ShareProvider.get().insert(snapshot.data).then((share) {
                          Navigator.pop(context);
                        });
                      },
                    );
                  }

                  return RaisedButton(
                    child: Text("Provide valid URL"),
                  );
                },
              ),
              StreamBuilder(
                stream: _onTextChanged.debounce(const Duration(seconds: 1,),),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return FutureBuilder(
                      future: OGParser().getOgTags(snapshot.data),
                      builder: (context, data) {
                        if (data.hasData) {
                          _onShareCreated.add(Share.fromMetaData(data.data));
                          return ContentPreviewCard(Share.fromMetaData(data.data));
                        } else if (data.hasError) {
                          return Text(data.error.toString());
                        }

                        return Text("NO OG Data");
                      },
                    );
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
                  }

                  return Container();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _onTextChanged.close();
    super.dispose();
  }


}
