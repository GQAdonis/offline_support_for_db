
class PendingRepository {
  final Isar isarPending;

  PendingRepository() {
  }

  init() async {
    InternetConnectionCheckerPlus().onStatusChange.listen((status) {
      print(status);
      StreamSubscription? isarPendingStream;
      if (status == InternetConnectionStatus.connected) {
        if(isarPendingStream == null) {
          isarPendingStream =
              isarPending.userModels.watchLazy().listen((event) {
                syncUsersWithServer();
              });
        }else{
          if(isarPendingStream.isPaused) {
            isarPendingStream.resume();
          }
        }
      }else{
        if(isarPendingStream != null){
          isarPendingStream.pause();
        }
      }
    });
  }

  syncUsersWithServer() async {
    InternetConnectionStatus status = await InternetConnectionCheckerPlus().connectionStatus;
    if(status == InternetConnectionStatus.connected){
      List<UserModel> userModels =
      await isarPending.userModels.where().findAll();
      userModels.first;
      // response = await backend method;
      bool wasComitedToServer = await ref.read(appwriteRepositoryProvider).createUser(userModels.first);
      // response success = delete object
      if (wasComitedToServer) {
        isarPending.userModels.delete(userModels.first.id!);
      }
    }
  }
