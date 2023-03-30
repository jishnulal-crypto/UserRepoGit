import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:project/api_service/api_service.dart';
import 'package:project/models/repo.dart';
import 'package:project/models/repo.dart';
import 'package:project/models/user.dart';
import 'package:project/screens/profile_screen/repo_search.dart';
import 'package:provider/provider.dart';

import '../../models/repo.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({required this.user_profile, super.key});

  User user_profile;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController repoSearchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  int length = 0;
  bool loading = false;
  Repo? repo;
  List<Repo> filterdRepos = [];
  List<Repo> Repos = [];

  @override
  void initState() {
    // TODO: implement initState
    getRepos();
    super.initState();
  }

  void getRepos() async {
    loading = true;
    Repos = await ApiService.fetchGitHubUserRepositories(
        widget.user_profile.reposUrl.toString());
    if (Repos.isNotEmpty) {
      loading = false;
      length = Repos.length;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Github Searcher"),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              color: Colors.grey[300],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Image.network(
                      widget.user_profile.avatarUrl.toString(),
                      width: 200,
                      height: 200,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: Colors.green,
                      width: MediaQuery.of(context).size.width / 3,
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(widget.user_profile.login.toString()),
                          Text(widget.user_profile.email.toString()),
                          Text(widget.user_profile.location.toString()),
                          Text(widget.user_profile.createdAt.toString()),
                          Text(widget.user_profile.followers.toString()),
                          Text(widget.user_profile.following.toString()),
                          Text(widget.user_profile.location.toString())
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(widget.user_profile.bio.toString()),
          Container(
            padding: EdgeInsets.all(10),
            width: 400,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.lightGreen[200],
                borderRadius: BorderRadius.circular(10)),
            child: TextField(
              controller: repoSearchController,
              // onChanged: ((value) {
              //   // filterUsers(value);
              // }),
              decoration: InputDecoration(
                  hintText: "search for users",
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none),
            ),
          ),
          if (loading) ...[
            CircularProgressIndicator()
          ] else ...[
            repoSearchController.text.isNotEmpty
                ? NotificationListener(
                    onNotification: (notification) {
                      return true;
                    },
                    child: ListView.builder(
                        controller: scrollController,
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filterdRepos.length,
                        itemBuilder: ((context, index) {
                          Repo repo = filterdRepos[index];
                          return GithubRepoItem(user: repo);
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
                        itemCount: Repos.length,
                        itemBuilder: ((context, index) {
                          Repo repo = Repos[index];
                          return GithubRepoItem(user: repo);
                        })),
                  )
          ]
        ],
      ),
    );
  }
}

class RepoProvider extends ChangeNotifier {
  int repoLength = 0;
  // StreamController streamController = StreamController();

  // Stream<int> getRepoLength(String repoUrl) async* {
  //   repoLength = await ApiService.fetchGitHubUserRepositoryLength(repoUrl);
  //   yield repoLength;
  //   notifyListeners();
  // }

  // Stream<int> productsStream(String url) async* {
  //   while (true) {
  //     // await Future.delayed(Duration(milliseconds: 500));
  //     int someProduct = await ApiService.fetchGitHubUserRepositoryLength(url);
  //     notifyListeners();
  //     yield someProduct;
  //   }
  // }
}

class GithubRepoItem extends StatelessWidget {
  GithubRepoItem({required this.user, super.key});

  final Repo user;
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
                leading: Text("reponame"),
                trailing: Column(
                  children: [
                    Text("forks"),
                    Text("stars"),
                  ],
                )
                //     Consumer<RepoProvider>(builder: ((context, value, child) {
                //   // return StreamBuilder(
                //   //     stream: value.productsStream(user.reposUrl.toString()),
                //   //     builder: ((context, snapshot) {
                //   //       return Text(snapshot.data.toString());
                //   //     }));
                // }))),
                )));
  }
}
