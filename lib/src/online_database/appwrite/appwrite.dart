import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:offline_support_for_db/src/isar_appwrite.dart';
import 'package:offline_support_for_db/src/local_database/isar/collections/example/example_collection.dart';

class AppwriteRepository extends BackendMethods {
  static final AppwriteRepository instance = AppwriteRepository();

  final Client client = Client(
          endPoint:
              'https://8080-appwrite-integrationfor-52tyj68ojp0.ws-eu67.gitpod.io/v1')
      .setProject('632da69f3cc14b8f209c')
      .setSelfSigned(status: true);

  late final Databases databaseExamples;

  Future<void> init() async {
    databaseExamples = Databases(client);
    Account(client).listSessions();
    IsarAppwrite.instance;
  }

  watchExample() {}

  @override
  Future<void> createExample({required Example example}) async {
    models.Document exampleDoc = await databaseExamples.createDocument(
        databaseId: 'ExampleDatabase',
        collectionId: 'Examples',
        documentId: example.id!.toString(),
        data: {'text': example.text, '\$createdAt': example.createdAt});
  }

  @override
  deleteExample({required Example example}) {
    // TODO: implement deleteExample
    throw UnimplementedError();
  }

  @override
  updateExample({required Example example}) {
    // TODO: implement updateExample
    throw UnimplementedError();
  }



  Future<List<Example>> getExamples() async {
    models.DocumentList list = await databaseExamples.listDocuments(databaseId: 'ExampleDatabase', collectionId: 'Examples');
   List<Example> listExamples = [];
    list.documents.forEach((element) {
      listExamples.add(documentToExample(element));
    });
    print(listExamples);

    IsarAppwrite.instance.updateAllExamples();
    return listExamples;
  }

  watchExamples(){
   // Realtime(client).subscribe([]).stream.listen((event) { });
  }

  Example documentToExample(models.Document document){

    return Example(text: document.data['text']);
  }
}
