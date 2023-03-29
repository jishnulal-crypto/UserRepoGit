import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:project/models/user.dart';
import 'package:project/screens/profile_screen/repo_search.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({required this.user_profile, super.key});

  User user_profile;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController repoSearchController = TextEditingController();

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
                          Text(widget.user_profile.email.toString()),
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
          RepoSearchWidget(
            repoUrl: widget.user_profile.reposUrl.toString(),
          )
        ],
      ),
    );
  }
}
