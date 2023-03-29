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
  List<User> filterdUsers = [];
  int length = 0;
  bool loading = false;

  @override
  void initState() {
    getUsers();
    searchController.addListener(() {
      checkLength();
    });

    super.initState();
  }

  void getUsers() async {
    loading = true;
    users = await ApiService.fetchGitHubUserData();
    if (users.isNotEmpty) {
      loading = false;
      length = users.length;
    }
    setState(() {});
  }

  void filterUsers(String query) {
    filterdUsers =
        users.where((element) => element.name!.contains(query)).toList();
    setState(() {});
  }

  void checkLength() {
    if (searchController.text.isEmpty) {
      length = users.length;
    } else {
      length = filterdUsers.length;
    }
    setState(() {});
  }

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
              onChanged: ((value) {
                filterUsers(value);
              }),
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
                CircularProgressIndicator()
              ] else ...[
                NotificationListener(
                  onNotification: (notification) {
                    print(scrollController.offset);
                    return true;
                  },
                  child: ListView.builder(
                      controller: scrollController,
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: length,
                      itemBuilder: ((context, index) {
                        User user = searchController.text.isEmpty
                            ? users[index]
                            : filterdUsers[index];
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
  void getRepoLength(String repoUrl) async {
    repoLength = await ApiService.fetchGitHubUserRepositoryLength(repoUrl);
    notifyListeners();
  }
}

class GithubUserItem extends StatelessWidget {
  const GithubUserItem({required this.user, super.key});

  final User user;

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
              title: Text(user.name.toString()),
              trailing:
                  Consumer<UserProvider>(builder: ((context, value, child) {
                value.getRepoLength(user.reposUrl.toString());
                return Text(value.repoLength.toString());
              }))),
        ));
  }
}
