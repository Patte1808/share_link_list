import 'package:flutter/material.dart';
import 'content_preview_card.dart';
import 'database/share_provider.dart';
import 'screens/create_share.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Share> shares = [];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: FutureBuilder(
            future: ShareProvider.get().getAll(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    print("title: " + snapshot.data[index].title);
                    return ContentPreviewCard(snapshot.data[index]);
                  },
                );
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              return CircularProgressIndicator();
            }
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(icon: Icon(Icons.search), onPressed: () {},),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton.extended(
        elevation: 4.0,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateShare())),
        label: Text('Add new Link'),
        icon: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
