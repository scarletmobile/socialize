import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:soXialz/data/reaction_data.dart' as reaction;
import 'package:soXialz/pages/users.dart';
import '../data/reaction_data.dart';
import '../models/user.dart';
import 'activity_feed.dart';
import 'home.dart';
import 'new_timeline.dart';

class HomeScreen extends StatefulWidget {
  final String? UserId;
  const HomeScreen({Key? key, required this.UserId,});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late GloabalUser user;
  bool isLoading = false;

  String userName = '';
  int followerCount = 0;
  int followingCount = 0;

  File? imageFileAvatar;
  String? imageFileAvatarUrl;

  @override
  void initState() {
    super.initState();
    fetchUserName(widget.UserId.toString()).then((username) {
      setState(() {
        userName = username;
      });
    });
    // Fetch and set the follower count
    fetchFollowerCount(widget.UserId.toString()).then((count) {
      setState(() {
        followerCount = count;
      });
    });
    fetchFollowingCount(widget.UserId.toString()).then((count) {
      setState(() {
        followerCount = count;
      });
    });

    getUser();
  }

  Future<String> fetchUserName(String userId) async {
    String userName = '';
    try {
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        userName = userSnapshot['username'];
        debugPrint('User name is : $userName');// Assuming 'name' is the field where the user's name is stored.
      }
    } catch (e) {
      debugPrint('Error fetching user name: $e');
    }
    return userName;
  }

  Future<int> fetchFollowerCount(String userId) async {
    try {
      QuerySnapshot followersSnapshot = await FirebaseFirestore.instance
          .collection('followers')
          .doc(userId)
          .collection('userFollowers')
          .get();

      int followerCount = followersSnapshot.docs.length;
      debugPrint('Follower Count: $followerCount');

      return followerCount;
    } catch (e) {
      debugPrint('Error fetching follower count: $e');
      return 0; // Return 0 in case of an error.
    }
  }

  Future<int> fetchFollowingCount(String userId) async {
    try {
      QuerySnapshot followersSnapshot = await FirebaseFirestore.instance
          .collection('following')
          .doc(userId)
          .collection('userFollowing')
          .get();

      int followingCount = followersSnapshot.docs.length;
      debugPrint('Following Count: $followingCount');

      return followingCount;
    } catch (e) {
      debugPrint('Error fetching following count: $e');
      return 0; // Return 0 in case of an error.
    }
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.UserId).get();
    user = GloabalUser.fromDocument(doc);

    setState(() {
      isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        toolbarHeight: 151,
        backgroundColor: Color(0xFF39569C),
        flexibleSpace: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [ // Top spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CircleAvatar(
                    maxRadius: 25,
                    backgroundColor: Colors.grey,
                    backgroundImage: AssetImage('assets/images/defaultavatar.png'),
                  ),
                  // user.photoUrl.isNotEmpty
                  // ? ClipRRect(
                  //   borderRadius: BorderRadius.circular(10.0),
                  //   child: CachedNetworkImage(
                  //     imageUrl: user.photoUrl,
                  //     height: 40,
                  //     width: 40,
                  //     fit: BoxFit.cover,
                  //   ),
                  // )
                  //     : Container(
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFF003a54),
                  //     borderRadius:
                  //     BorderRadius.circular(10.0),
                  //   ),
                  //   child: Image.asset(
                  //     'assets/images/defaultavatar.png',
                  //     width: 40,
                  //   ),
                  //),
                  IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ActivityFeed()));
                    },
                    icon: Icon(
                      Icons.notification_add,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5,),
              Text('$userName',
                style: TextStyle(color: Colors.white),),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 35,
                    width: 85,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.groups,
                          color: Color(0xFF39569C),),
                          Text('$followerCount'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 35,
                    width: 85,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.follow_the_signs,
                            color: Color(0xFF39569C),),
                          Text('$followingCount'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 35,
                    width: 85,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.stars_sharp,
                            color: Color(0xFF39569C),),
                          Text('0'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 35,
                    width: 85,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.monetization_on_sharp,
                            color: Color(0xFF39569C),),
                          Text('0'),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        actions: [

        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color:  Colors.transparent,
                  borderRadius: BorderRadius.circular(5.0)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.push(context,
                                MaterialPageRoute(builder:
                                (context) => UsersList(userId: widget.UserId,)));
                          },
                          child: Column(
                            children: [
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF935805),
                                      borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  child: Image.asset('assets/images/invite_frnd.png')
                              ),
                              Text('Invite Friend', 
                                style: TextStyle(fontSize: 12),)
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Color(0xFF57d073),
                                    borderRadius: BorderRadius.circular(18.0)
                                ),
                                child: Image.asset('assets/images/daily_bonus.png')
                            ),
                            Text('Daily Bonus',
                                style: TextStyle(fontSize: 12),),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Color(0xFF01143f),
                                    borderRadius: BorderRadius.circular(18.0)
                                ),
                                child: Image.asset('assets/images/survey.png')
                            ),
                            Text('Surveys',
                                style: TextStyle(fontSize: 12),),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                    color: Color(0xFFb3221c),
                                    borderRadius: BorderRadius.circular(18.0)
                                ),
                                child: Image.asset('assets/images/quiz2.png'),
                            ),
                            Text('Quiz',
                              style: TextStyle(fontSize: 12),)
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 30,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            InkWell(
                              onTap: (){Navigator.push(context,
                                  MaterialPageRoute(builder:
                              (context) => NewTimeline(
                                  reactions: reactions,
                                  UserId: widget.UserId,
                              )));
                                },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                    color: Color(0xFFffde59),
                                    borderRadius: BorderRadius.circular(18.0)
                                ),
                                child: Image.asset('assets/images/social_network.png')
                              ),
                            ),
                            Text('Social Network',
                              style: TextStyle(fontSize: 12),)
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                  color: Color(0xFF5ce1e6),
                                  borderRadius: BorderRadius.circular(18.0)
                              ),
                              child: Image.asset('assets/images/prediction.png')
                            ),
                            Text('Predict & Win',
                              style: TextStyle(fontSize: 12),),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                  color: Color(0xFF9896f9),
                                  borderRadius: BorderRadius.circular(18.0)
                              ),
                              child: Image.asset('assets/images/challenges.png')
                            ),
                            Text('Challenges',
                              style: TextStyle(fontSize: 12),),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                  color: Color(0xFF7be100),
                                  borderRadius: BorderRadius.circular(18.0)
                              ),
                              child: Image.asset('assets/images/video_desk.png',)
                            ),
                            Text('Video Desk',
                              style: TextStyle(fontSize: 12),),
                            // Text(globalName!.capitalize(),
                            //     style: const TextStyle(
                            //         fontSize: 16.0,
                            //         fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}
