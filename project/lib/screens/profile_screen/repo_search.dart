import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:project/api_service/api_service.dart';
import 'package:project/models/repo.dart';

class RepoWidget extends StatelessWidget {
  const RepoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text("S");
  }
}

class RepoSearchWidget extends StatefulWidget {
  const RepoSearchWidget({required this.repoUrl, super.key});

  final String repoUrl;

  @override
  State<RepoSearchWidget> createState() => _RepoSearchWidgetState();
}

class _RepoSearchWidgetState extends State<RepoSearchWidget> {
  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<Repo> repos = [];
  List<Repo> filterdRepos = [];
  int length = 0;
  bool loading = false;
  @override
  void initState() {
    getRepositories(widget.repoUrl);
    super.initState();
  }

  void getRepositories(String url) async {
    loading = true;
    repos = await ApiService.fetchGitHubUserRepositories(url);
    if (repos.isNotEmpty) {
      loading = false;
      length = repos.length;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        title: Container(
          width: 400,
          height: 50,
          decoration: BoxDecoration(
              color: Colors.lightGreen[200],
              borderRadius: BorderRadius.circular(10)),
          child: TextField(
            controller: searchController,
            onChanged: ((value) {}),
            decoration: InputDecoration(
                hintText: "search repos",
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
                    itemCount: 10,
                    itemBuilder: ((context, index) {
                      Repo rep = searchController.text.isEmpty
                          ? repos[index]
                          : filterdRepos[index];
                      return GithubRepoItem(
                        repo: rep,
                      );
                    })),
              )
            ]
          ],
        ),
      ),
    );
  }
}

// class UserProvider extends ChangeNotifier {
//   int repoLength = 0;
//   void getRepoLength(String repoUrl) async {
//     repoLength = await ApiService.fetchGitHubUserRepositoryLength(repoUrl);
//     notifyListeners();
//   }
// }

class GithubRepoItem extends StatelessWidget {
  GithubRepoItem({required this.repo, super.key});

  final Repo repo;

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
              leading: Text(repo.fullName.toString()),
              trailing: Column(
                children: [
                  Text('forks $repo.forksCount}'),
                  Text('stars ${repo.stargazersCount}')
                ],
              ),
            )));
  }
}
