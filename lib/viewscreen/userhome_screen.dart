// ignore_for_file: use_build_context_synchronously

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/Notification_controller.dart';
import 'package:lesson3/controller/auth_controller.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photo_comment.dart';
import 'package:lesson3/model/photo_memo.dart';
import 'package:lesson3/viewscreen/addphotomemo_screen.dart';
import 'package:lesson3/viewscreen/comment_screen.dart';
import 'package:lesson3/viewscreen/detailedview_screen.dart';
import 'package:lesson3/viewscreen/filter_screen.dart';
import 'package:lesson3/viewscreen/notification_screen.dart';
import 'package:lesson3/viewscreen/sharedwith_screen.dart';
import 'package:lesson3/viewscreen/view/view_util.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/userHomeScreen';

   UserHomeScreen(
      {required this.user, required this.photoMemoList, Key? key})
      : super(key: key);

  final User user;
  List<PhotoMemo> photoMemoList;
  @override
  State<StatefulWidget> createState() {
    return _UserHomeState();
  }
}

class _UserHomeState extends State<UserHomeScreen> {
  late _Controller con;
  late String email;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    email = widget.user.email ?? 'No email';
  }

  void render(fn) => setState(fn);

  bool decending=false;
  var notificationStream=NotificationController.getUnSeenNotifications();
  @override
  Widget build(BuildContext context) {

    if(decending){
      con.photoMemoList.sort((b, a) => a.title.compareTo(b.title));
    }else{
      con.photoMemoList.sort((a, b) => a.title.compareTo(b.title));
    }
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          // title: const Text('User Home'),
          actions: [
            con.selected.isEmpty
                ? Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Search (empty for all)',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          autocorrect: true,
                          onSaved: con.saveSearchKey,
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: con.cancel,
                  ),
            con.selected.isEmpty
                ? IconButton(
                    onPressed: con.search,
                    icon: const Icon(Icons.search),
                  )
                : IconButton(
                    onPressed: con.delete,
                    icon: const Icon(Icons.delete),
                  ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Badge(
                  badgeContent: Center(child: StreamBuilder<QuerySnapshot>(
                    stream: notificationStream,
                    builder: (context, snapshot) {
                      if(!snapshot.hasData){
                        return Text('');
                      }
                      return Text('${snapshot.data!.size}',);
                    }
                  )),
                  alignment: Alignment.topCenter,
                  position: BadgePosition.topStart(),
                  elevation: 0,
                  child: IconButton(onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  NotificationScreen(),),
                    );
                  }, icon: Icon(Icons.notifications_active))),
            )
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: const Icon(
                  Icons.person,
                  size: 70.0,
                ),
                accountName: const Text('no profile'),
                accountEmail: Text(email),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Shared With'),
                onTap: con.sharedWith,
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: con.signOut,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: con.addButton,
        ),
        body: con.photoMemoList.isEmpty
            ? Text(
                'No PhotoMemo Found!',
                style: Theme.of(context).textTheme.headline6,
              )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(onPressed: (){
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return FilterScreen(
                        decending: decending,
                        onSelect: (val){
                          setState(() {
                            decending=val;
                          });
                        },
                      );
                    },
                  );
                }, icon: Icon(Icons.filter_alt_outlined,color: Colors.blue,)),
                Expanded(
                  child: ListView.builder(
                      itemCount: con.photoMemoList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ListTile(
                              selected: con.selected.contains(index),
                              selectedTileColor: Colors.blue[100],
                              // titleColor: Colors.grey,
                              leading: WebImage(
                                url: con.photoMemoList[index].photoURL,
                                context: context,
                              ),
                              // trailing: IntrinsicWidth(
                              //   child: Row(
                              //     children: [
                              //       const Icon(Icons.thumb_down),
                              //       SizedBox(
                              //         width: 7,
                              //       ),
                              //       Text("81"),
                              //       SizedBox(
                              //         width: 7,
                              //       ),
                              //       const Icon(Icons.thumb_up_alt),
                              //       SizedBox(
                              //         width: 7,
                              //       ),
                              //       Text("81"),
                              //       SizedBox(
                              //         // color: Colors.amber,
                              //         height: 40,
                              //         width: 40,
                              //         child: Stack(
                              //           children: [
                              //             const Align(
                              //                 alignment: Alignment.center,
                              //                 child: const Icon(Icons.comment_bank)),
                              //             Align(
                              //               alignment: Alignment.topRight,
                              //               child: Container(
                              //                 // height: 30,
                              //                 // width: 30,
                              //                 padding: const EdgeInsets.all(3),
                              //                 constraints:
                              //                     const BoxConstraints(maxHeight: 80),
                              //                 decoration: BoxDecoration(
                              //                     color: Colors.grey[400],
                              //                     borderRadius:
                              //                         BorderRadius.circular(100)),
                              //                 child: Text("81"),
                              //               ),
                              //             )
                              //           ],
                              //         ),
                              //       ),
                              //       const Icon(Icons.arrow_right),
                              //     ],
                              //   ),
                              // ),
                              title: Text(con.photoMemoList[index].title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        // width: 150,
                                        constraints: BoxConstraints(maxWidth: 150),
                                        child: Text(
                                          con.photoMemoList[index].memo.length >= 40
                                              ? con.photoMemoList[index].memo
                                                      .substring(0, 40) +
                                                  '...'
                                              : con.photoMemoList[index].memo,
                                        ),
                                      ),
                                      IntrinsicWidth(
                                        child: Row(
                                          children: [
                                            const Icon(Icons.thumb_down),
                                            const SizedBox(
                                              width: 7,
                                            ),
                                            Text(
                                                "${con.photoMemoList[index].dislikeCount}"),
                                            const SizedBox(
                                              width: 7,
                                            ),
                                            const Icon(Icons.thumb_up_alt),
                                            const SizedBox(
                                              width: 7,
                                            ),
                                            // Text("${con.newCount}"),
                                            Text(
                                                "${con.photoMemoList[index].likesCount}"),
                                            GestureDetector(
                                              onTap: () {
                                                // Navigator.pushNamed(
                                                //     context, CommentScreen.routeName);
                                                con.postCommentScreen(index);

                                              },
                                              child: SizedBox(
                                                // color: Colors.amber,
                                                height: 30,
                                                width: 60,
                                                child: Stack(
                                                  children: [
                                                    const Align(
                                                        alignment: Alignment.center,
                                                        child: const Icon(
                                                            Icons.comment_bank)),
                                                    Align(
                                                      alignment: Alignment.topRight,
                                                      child: Container(
                                                        height: 25,
                                                        width: 25,
                                                        padding: const EdgeInsets.all(3),
                                                        constraints: const BoxConstraints(
                                                            maxHeight: 80),
                                                        decoration: BoxDecoration(
                                                            color: Colors.grey[400],
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    100)),
                                                        child: Center(
                                                          child: Text(
                                                              "${con.photoMemoList[index].commentCount}"),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Icon(Icons.arrow_right),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                      'Created By: ${con.photoMemoList[index].createdBy}'),
                                  Text(
                                      'Shared With: ${con.photoMemoList[index].sharedWith}'),
                                  Text(
                                      'Timestamp: ${con.photoMemoList[index].timestamp}'),
                                ],
                              ),
                              onTap: () => con.onTap(index),
                              onLongPress: () => con.onLongPress(index),
                            ),
                            if(index==con.photoMemoList.length-1)
                              Visibility(
                                visible: con.photoMemoList.length>7,
                                child: TextButton(onPressed: () async {
                                  if(!isLast) {
                                    setState(() {
                                      gettingMore = true;
                                    });
                                    List<
                                        PhotoMemo> newPhotoMemoList = await FirestoreController
                                        .getMorePhotoMemoList();
                                    if (newPhotoMemoList.isNotEmpty) {
                                      con.photoMemoList = con.photoMemoList +
                                          newPhotoMemoList;
                                    } else {
                                      isLast = true;
                                    }
                                    setState(() {
                                      gettingMore = false;
                                    });
                                  }
                                }, child: Text(gettingMore?'Loading...':isLast?'No more data':'Load More')),
                              )
                          ],
                        );
                      },
                    ),
                ),
              ],
            ),
      ),
    );
  }
}

bool gettingMore=false;
bool isLast=false;


class _Controller {
  _UserHomeState state;
  late List<PhotoMemo> photoMemoList;
  String? searchKeyString;
  List<int> selected = [];

  _Controller(this.state) {
    photoMemoList = state.widget.photoMemoList;
    //print(photoMemoList.toList());
  }

  void postCommentScreen(int index) async {
    List<PhotoComment> photoCommentList = await FirestoreController.getPhotoMemoCommentList(phomemoId: state.widget.photoMemoList[index].postId);
    print(state.widget.photoMemoList[index].postId);
    print(photoCommentList.length);
    await Navigator.pushNamed(
      state.context,
      CommentScreen.routeName,
      arguments: {
        ArgKey.user: state.widget.user,
        ArgKey.onePhotoMemo: state.widget.photoMemoList[index],
        ArgKey.photoMemoCommentList: photoCommentList
      },
    );
    state.render(() {});
  }

  void sharedWith() async {
    try {
      List<PhotoMemo> photoMemoList =
          await FirestoreController.getPhotoMemoListSharedWithMe(
        email: state.email,
      );
      await Navigator.pushNamed(
        state.context,
        SharedWithScreen.routeName,
        arguments: {
          ArgKey.user: state.widget.user,
          ArgKey.photoMemoList: photoMemoList,
        },
      );
      Navigator.of(state.context).pop(); // push in the drawer
    } catch (e) {
      if (Constant.devMode) print('======= get Shared list error: $e');
      showSnackBar(
        context: state.context,
        message: 'Failed to get sharedwith list: $e',
      );
    }
  }

  void cancel() {
    state.render(() => selected.clear());
  }

  void delete() async {
    startCircularProgress(state.context);
    selected.sort();
    for (int i = selected.length - 1; i >= 0; i--) {
      try {
        PhotoMemo p = photoMemoList[selected[i]];
        await FirestoreController.deleteDoc(docId: p.docId!);
        await CloudStorageController.deleteFile(filename: p.photoFilename);
        state.render(() {
          photoMemoList.removeAt(selected[i]);
        });
      } catch (e) {
        if (Constant.devMode) print('========= failed to delete: $e');
        showSnackBar(
          context: state.context,
          seconds: 20,
          message: 'Failed! Sign Out and IN again to get updated list\n$e',
        );
        break; // quit further processing
      }
    }
    state.render(() => selected.clear());
    stopCircularProgress(state.context);
  }

  void saveSearchKey(String? value) {
    searchKeyString = value;
  }

  void search() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;
    currentState.save();

    List<String> keys = [];
    if (searchKeyString != null) {
      var tokens = searchKeyString!.split(RegExp('(,| )+')).toList();
      for (var t in tokens) {
        if (t.trim().isNotEmpty) keys.add(t.trim());
      }
    }
    startCircularProgress(state.context);

    try {
      late List<PhotoMemo> results;
      if (keys.isEmpty) {
        results =
            await FirestoreController.getPhotoMemoList(email: state.email);
      } else {
        results = await FirestoreController.searchImages(
          email: state.email,
          searchLabel: keys,
        );
      }
      stopCircularProgress(state.context);
      state.render(() {
        photoMemoList = results;
      });
    } catch (e) {
      stopCircularProgress(state.context);
      if (Constant.devMode) print('========= failed to search: $e');
      showSnackBar(
          context: state.context, seconds: 20, message: 'failed to search: $e');
    }
  }

  void addButton() async {
    await Navigator.pushNamed(state.context, AddPhotoMemoScreen.routeName,
        arguments: {
          ArgKey.user: state.widget.user,
          ArgKey.photoMemoList: photoMemoList,
        });
    state.render(() {}); // rerender the screen
  }

  Future<void> signOut() async {
    try {
      await AuthController.signout();
    } catch (e) {
      if (Constant.devMode) print('======== sign out error: $e');
      showSnackBar(context: state.context, message: 'Sign out error: $e');
    }
    Navigator.of(state.context).pop(); // close the drawer
    Navigator.of(state.context).pop(); // return to Start screen
  }

  void onTap(int index) async {
    if (selected.isNotEmpty) {
      onLongPress(index);
      return;
    }
    print(state.widget.photoMemoList[index].postId);
    await Navigator.pushNamed(state.context, DetailedViewScreen.routeName,
        arguments: {
          ArgKey.user: state.widget.user,
          ArgKey.onePhotoMemo: photoMemoList[index],
        });
    state.render(() {});
  }

  void onLongPress(int index) {
    state.render(() {
      if (selected.contains(index)) {
        selected.remove(index);
      } else {
        selected.add(index);
      }
    });
  }
}
