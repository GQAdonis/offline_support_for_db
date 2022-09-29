import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';

/*
  'req' variable has:
    'headers' - object with request headers
    'payload' - request body data as a string
    'variables' - object with function variables

  'res' variable has:
    'send(text, status: status)' - function to return text response. Status code defaults to 200
    'json(obj, status: status)' - function to return JSON response. Status code defaults to 200
  
  If an error is thrown, a response with code 500 will be returned.
*/

Future<void> start(final req, final res) async {
  Client client = Client();

  // You can remove services you don't use
  Databases database = Databases(client);
  Functions functions = Functions(client);
  Storage storage = Storage(client);
  Users users = Users(client);

  if (req.variables['APPWRITE_FUNCTION_ENDPOINT'] == null ||
      req.variables['APPWRITE_FUNCTION_API_KEY'] == null) {
    print(
        "Environment variables are not set. Function cannot use Appwrite SDK.");
    res.send('client not ready');
  } else {
    client
        .setEndpoint(req.variables['APPWRITE_FUNCTION_ENDPOINT'])
        .setProject(req.variables['APPWRITE_FUNCTION_PROJECT_ID'])
        .setKey(req.variables['APPWRITE_FUNCTION_API_KEY'])
        .setSelfSigned(status: true);
    print(
        "Environment variables are not set. Function cannot use Appwrite SDK.");

    Document documentCurrentState = await database.getDocument(
        databaseId: req.variables['APPWRITE_FUNCTION_DATABASE_ID'],
        collectionId: req.variables['APPWRITE_FUNCTION_COLLECTION_ID'],
        documentId: req.payload['\$id']);

    DateTime currentDocumentUpdatedAt =
        DateTime.parse(documentCurrentState.$updatedAt);
    DateTime updatedDocument = DateTime.parse(req.payload['\$updatedAt']);
    Duration dif = currentDocumentUpdatedAt.difference(updatedDocument);
    if (dif.isNegative) {
        res.json(documentCurrentState.toMap());
    } else {
      await database.updateDocument(
          databaseId: req.variables['APPWRITE_FUNCTION_DATABASE_ID'],
          collectionId: req.variables['APPWRITE_FUNCTION_COLLECTION_ID'],
          documentId: req.payload['\$id'],
          data: req.payload).then((value) {
             res.json(value.toMap());
          },onError: (error){
            
          });

      
    }
  }
}
