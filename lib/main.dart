import 'package:flutter/material.dart';
import 'package:hn_reader/hn_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hn_reader/hn_widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HN Reader',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.purple,
      ),
      home: const MyHomePage(title: 'HN Reader'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<List<Story>> loadingStories = getStories();
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          backgroundColor: Colors.purple,
          title: Text(widget.title),
        ),
        body: Center(
            child: FutureBuilder<List<Story>>(
          future: loadingStories,
          builder:
              ((BuildContext context, AsyncSnapshot<List<Story>> snapshot) {
            if (snapshot.hasData) {
              var stories = snapshot.data;
              return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: stories!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return StoryHeadline(story: stories[index]);
                  });
            } else {
              return const CircularProgressIndicator();
            }
          }),
        )));
  }
}
