import 'package:flutter/material.dart';
import 'package:offline_support_for_db/backend.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Backend.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
  final Backend _backend = Backend.instance;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        children: [
          StreamBuilder(
            initialData: const [],
            stream: _backend.watchExamples(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              List<dynamic> examples = snapshot.data;

              return SizedBox(
                height: 500,
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      color: Colors.grey.shade200,
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(examples[index].id.toString()),
                          Text(examples[index].text.toString()),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(examples[index]
                                  .updatedAt
                                  .toString()
                                  .split('T')[0]),
                              Text(examples[index]
                                  .createdAt
                                  .toString()
                                  .split('T')[0]),
                              Text(examples[index]
                                  .syncedAt
                                  .toString()
                                  .split('T')[0]),
                            ],
                          ),
                          ElevatedButton(
                              onPressed: () {
                                _backend.updateExample(examples[index]);
                              },
                              child: const Text('Update')),
                          ElevatedButton(
                              onPressed: () {
                                _backend.deleteExample(examples[index].id);
                              }, child: const Text('Delete')),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
          ElevatedButton(
              onPressed: () {
                _backend.createExample();
              },
              child: const Text('Create')),
          ElevatedButton(
              onPressed: () {
                _backend.clearDatabase();
              },
              child: const Text('Clear examples')),
          ElevatedButton(
              onPressed: () {
                _backend.syncExamplesToServer();
              },
              child: const Text('SyncExamples')),
        ],
      ),
    );
  }
}
