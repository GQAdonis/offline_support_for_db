import 'package:flutter/material.dart';
import 'package:offline_support_for_db/src/isar_appwrite.dart';
import 'package:offline_support_for_db/src/local_database/isar/collections/example/example_collection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarAppwrite.instance.init();
  runApp( MyApp());
}
class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }


}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Example> testOnline = [];
  List<Example> testPending = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Test'),
        ),
        body: Column(
          children: [
            Text('Synced'),
            StreamBuilder(
              stream: IsarAppwrite.instance.watchExamples(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                print(snapshot);
                return Container(
                  height: 300,
                  child: ListView.builder(
                    itemCount: testPending.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(testPending[index].text),
                        subtitle: Text(testPending[index].syncedAt.toString()),
                        onLongPress: (){

                        },
                        onTap: (){

                        },
                      );
                    },
                  ),
                );
              },

            ),
            Text('Pending'),
            StreamBuilder(
              stream: IsarAppwrite.instance.watchPendingExamples(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                print(snapshot);
              return Container(
                height: 300,
                child: ListView.builder(
                  itemCount: testPending.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(testPending[index].text),
                      subtitle: Text(testPending[index].syncedAt.toString()),
                      onLongPress: (){

                      },
                      onTap: (){

                      },
                    );
                  },
                ),
              );
            },

            ),
            Row(
              children: [
                ElevatedButton(onPressed: (){
                  TextEditingController id = TextEditingController();
                  TextEditingController text = TextEditingController();
                  showDialog(context: context, builder: (BuildContext context) {
                    return Dialog(
                      child: Container(
                        height: 500,
                        child: Column(
                          children: [
                            Text('Create'),
                            TextField(
                              controller: id,
                            ),
                            TextField(
                              controller: text,
                            ),
                            ElevatedButton(onPressed: (){
                              Example example = Example(text: text.text)..id = id.text.length
                              ..createdAt = DateTime.now().toIso8601String();
                              IsarAppwrite.instance.createExample(example: example);
                            }, child: Text('create'))
                          ],
                        ),
                      ),

                    );
                  },);
                }, child: Text('Create')),
                ElevatedButton(onPressed: (){}, child: Text('Update')),
                ElevatedButton(onPressed: (){}, child: Text('Delete')),
                ElevatedButton(onPressed: (){}, child: Text('Sync')),
              ],
            )
          ],
        ));
  }
}
