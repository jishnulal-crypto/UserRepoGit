import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:project/api_service/api_service.dart';
import 'package:project/models/repo.dart';
import 'package:project/models/user.dart';
import 'package:project/screens/profile_screen/profile_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<User> users = [];
  int statusCode = 0;
  Map<String, dynamic> data = {};
  List<User> filterdUsers = [];
  int length = 0;
  bool loading = false;
  User? user;

  @override
  void initState() {
    getUsers();
    filterUsers();
    calls();
    super.initState();
  }

  void getUsers() async {
    loading = true;
    data = await ApiService.fetchGitHubUserData();
    users = data['users'];
    statusCode = data['statusCode'];
    if (users.isNotEmpty) {
      loading = false;
      length = users.length;
    }
    setState(() {});
  }

  void calls() {
    searchController.addListener(() {
      setState(() {});
    });
  }

  void filterUsers({String? query}) {
    setState(() {
      searchController.addListener(() {
        filterdUsers = users
            .where((element) => element.login!.contains(searchController.text))
            .toList();
      });
    });
  }

  int checkLength() {
    setState(() {
      if (searchController.text.isEmpty) {
        length = users.length;
      } else {
        length = filterdUsers.length;
      }
    });
    return length;
  }

  // User getUserforOutput(int index) {
  //   return searchController.text.isEmpty
  //       ? user = users[index]
  //       : user = filterdUsers[index];
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.white,
          title: Container(
            padding: EdgeInsets.all(10),
            width: 400,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.lightGreen[200],
                borderRadius: BorderRadius.circular(10)),
            child: TextField(
              controller: searchController,
              // onChanged: ((value) {
              //   // filterUsers(value);
              // }),
              decoration: InputDecoration(
                  hintText: "search for users",
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              if (loading) ...[
                Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text("${statusCode.toString()} Api limit exceded")
                      ],
                    ))
              ] else ...[
                searchController.text.isNotEmpty
                    ? NotificationListener(
                        onNotification: (notification) {
                          print(scrollController.offset);
                          return true;
                        },
                        child: ListView.builder(
                            controller: scrollController,
                            physics: ScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: filterdUsers.length,
                            itemBuilder: ((context, index) {
                              User user = filterdUsers[index];
                              return GithubUserItem(
                                user: user,
                              );
                            })),
                      )
                    : NotificationListener(
                        onNotification: (notification) {
                          print(scrollController.offset);
                          return true;
                        },
                        child: ListView.builder(
                            controller: scrollController,
                            physics: ScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: users.length,
                            itemBuilder: ((context, index) {
                              User user = users[index];
                              return GithubUserItem(
                                user: user,
                              );
                            })),
                      )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class UserProvider extends ChangeNotifier {
  int repoLength = 0;
  // StreamController streamController = StreamController();

  Stream<int> getRepoLength(String repoUrl) async* {
    repoLength = await ApiService.fetchGitHubUserRepositoryLength(repoUrl);
    yield repoLength;
    notifyListeners();
  }

  Stream<int> productsStream(String url) async* {
    while (true) {
      // await Future.delayed(Duration(milliseconds: 500));
      int someProduct = await ApiService.fetchGitHubUserRepositoryLength(url);
      notifyListeners();
      yield someProduct;
    }
  }
}

class GithubUserItem extends StatelessWidget {
  GithubUserItem({required this.user, super.key});

  final User user;
  int length = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 60,
          decoration: BoxDecoration(
              color: Colors.lightGreen[200],
              borderRadius: BorderRadius.circular(10)),
          child: ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: ((context) => ProfileScreen(
                          user_profile: user,
                        ))));
              },
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CircleAvatar(
                  radius: 25,
                  child: Image.network(user.avatarUrl.toString()),
                ),
              ),
              title: Text(user.login.toString()),
              trailing:
                  Consumer<UserProvider>(builder: ((context, value, child) {
                return StreamBuilder(
                    stream: value.productsStream(user.reposUrl.toString()),
                    builder: ((context, snapshot) {
                      return Text(snapshot.data.toString());
                    }));
              }))),
        ));
  }
}
