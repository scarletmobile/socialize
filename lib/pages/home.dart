import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:soXialz/models/user.dart';
import 'package:soXialz/pages/activity_feed.dart';
import 'package:soXialz/pages/home_screen.dart';
import 'package:soXialz/pages/menu/discover.dart';
import 'package:soXialz/pages/new_timeline.dart';
import 'package:soXialz/pages/menu/settings.dart';
import 'package:soXialz/pages/profile.dart';
import 'package:soXialz/pages/search.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:soXialz/pages/tournament_screen.dart';
import 'package:soXialz/pages/users.dart';
import 'package:soXialz/widgets/circle_button.dart';

import 'package:soXialz/widgets/count/messages_count.dart';
import 'package:soXialz/widgets/simple_world_widgets.dart';
import 'package:soXialz/data/reaction_data.dart' as Reaction;
import '../paginate_firestore/bloc/pagination_listeners.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final Reference storageRef = FirebaseStorage.instance.ref();
final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final followersRef = FirebaseFirestore.instance.collection('followers');
final likedRef = FirebaseFirestore.instance.collection('likedpp');
final dislikedRef = FirebaseFirestore.instance.collection('dislikedpp');
final ppviewsRef = FirebaseFirestore.instance.collection('ppviews');
final followingRef = FirebaseFirestore.instance.collection('following');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final msgRef = FirebaseFirestore.instance.collection('messages');
final messengerRef = FirebaseFirestore.instance.collection('messenger');
final groupsRef = FirebaseFirestore.instance.collection('groups');
final storiesRef = FirebaseFirestore.instance.collection('stories');
final reportsRef = FirebaseFirestore.instance.collection('reports');
final DateTime timestamp = DateTime.now();

class Home extends StatefulWidget {
  final String? userId;

  const Home({Key? key, this.userId}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController pageController = PageController(initialPage: 0);
  late TabController _tabController;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  var currentUser = FirebaseAuth.instance.currentUser;
  bool isFollowing = false;
  late List<GloabalUser> users;
  bool showElevatedButtonBadge = true;
  PaginateRefreshedChangeListener refreshChangeListener =
  PaginateRefreshedChangeListener();

  @override
  void initState() {
    super.initState();
    getUserData();
    getAllUsers();
    getAllStories();

    _tabController = TabController(vsync: this, length: 6);
    FirebaseMessaging.instance.getInitialMessage().then((message) {});
    _tabController.addListener(_handleTabSelection);
  }


  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {});
  }

  getAllStories() async {
    QuerySnapshot<Map<String, dynamic>> doc = await storiesRef.get();
    print('storiess');
    // print(doc.);
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(globalID)
        .collection('userFollowers')
        .doc(globalID)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getAllUsers() async {
    QuerySnapshot snapshot =
    await usersRef.orderBy('timestamp', descending: true).get();
    List<GloabalUser> users =
    snapshot.docs.map((doc) => GloabalUser.fromDocument(doc)).toList();
    setState(() {
      this.users = users;
    });
  }

  getUserData() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      usersRef.doc(user.uid).get().then((peerData) {
        if (peerData.exists) {
          if (mounted) {
            setState(() {
              globalID = user.uid;
              globalName = peerData['username'];
              globalImage = peerData['photoUrl'];
              globalBio = peerData['bio'];
              globalCover = peerData['coverUrl'];
              globalDisplayName = peerData['displayName'];
              globalCountry = peerData['country'];
              globalCredits = peerData['credit_points'].toString();
            });
          }
        }
      });
    }
  }

  AnimatedTheme buildAuthScreen() {
    final mode = AdaptiveTheme.of(context).mode;

    return AnimatedTheme(
      duration: const Duration(milliseconds: 300),
      data: Theme.of(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          automaticallyImplyLeading: false,
          shape: Border(
            bottom: BorderSide(
              color: Theme.of(context).shadowColor,
              width: 1.0,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'soXialz',
                    style: GoogleFonts.portLligatSans(
                      textStyle: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // LanguagePickerWidget(),
            Container(
              alignment: Alignment.center,
              width: 40,
              margin: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: Theme.of(context).secondaryHeaderColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  if (mode == AdaptiveThemeMode.light) {
                    AdaptiveTheme.of(context).setDark();
                  } else {
                    AdaptiveTheme.of(context).setLight();
                  }
                },
                icon: mode == AdaptiveThemeMode.light
                    ? const Icon(Icons.light_mode)
                    : const Icon(Icons.dark_mode),
              ),
            ),
            CircleButton(
              icon: Icons.search,
              iconSize: 25.0,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Search()),
                );
              },
            ),
            MessagesCount(
              currentUserId: widget.userId,
            ),
          ],
          elevation: 0.0,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            refreshChangeListener.refreshed = true;
          },
          child: PageView(
            controller: pageController,
            children: [
              //  NewTimeline(
              //   UserId: widget.userId,
              //   reactions: Reaction.reactions,
              // ),
              HomeScreen(UserId: widget.userId),
              Discover(UserId: globalID),
              UsersList(userId: widget.userId),
              Profile(
                profileId: widget.userId,
                reactions: Reaction.reactions,
              ),
              //const ActivityFeed(),
              TournamentScreen(),
              SettingsPage(currentUserId: widget.userId),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tabController.index,
          onTap: (int index) {
            setState(() {
              _tabController.index = index;
              pageController.animateToPage(index,
                  duration: Duration(milliseconds: 300), curve: Curves.ease);
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: _tabController.index == 0
                  ? const Icon(
                IconlyBold.home,
                color: Color(0xFF39569C),
              )
                  : const Icon(IconlyLight.home,
                  color: Color(0xFF39569C),),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _tabController.index == 1
                  ? const Icon(
                Icons.find_in_page,
                color: Color(0xFF39569C),
              )
                  : const Icon(Icons.find_in_page,
                color: Color(0xFF39569C),),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _tabController.index == 2
                  ? const Icon(
                Icons.person_add_alt_1_rounded,
                color: Color(0xFF39569C,),
              )
                  : const Icon(Icons.person_add_alt_1_rounded,
                color: Color(0xFF39569C),),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _tabController.index == 3
                  ? const Icon(
                Icons.contact_mail,
                color: Color(0xFF39569C,),
              )
                  : const Icon(Icons.contact_mail,
                color: Color(0xFF39569C),),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _tabController.index == 4
                  ? const Icon(
                Icons.emoji_events,
                size: 26,
                color: Color(0xFF39569C),
              )
                  : const Icon(Icons.emoji_events,
                color: Color(0xFF39569C),),
              label: '',
              //backgroundColor: Theme.of(context).tabBarTheme.labelColor,
            ),
            BottomNavigationBarItem(
              icon: _tabController.index == 5
                  ? const Icon(
                IconlyBold.category,
                color: Color(0xFF39569C),
              )
                  : const Icon(IconlyLight.category,
                color: Color(0xFF39569C),),
              label: '',
              //backgroundColor: Theme.of(context).tabBarTheme.labelColor,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildAuthScreen();
  }
}



// import 'package:adaptive_theme/adaptive_theme.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:iconly/iconly.dart';
// import 'package:soXialz/models/user.dart';
// import 'package:soXialz/pages/activity_feed.dart';
// import 'package:soXialz/pages/new_timeline.dart';
// import 'package:soXialz/pages/menu/settings.dart';
// import 'package:soXialz/pages/profile.dart';
// import 'package:soXialz/pages/search.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:soXialz/pages/users.dart';
// import 'package:soXialz/widgets/circle_button.dart';
// import 'package:soXialz/widgets/count/feeds_count.dart';
// import 'package:soXialz/widgets/count/messages_count.dart';
// import 'package:soXialz/widgets/simple_world_widgets.dart';
// import 'package:soXialz/data/reaction_data.dart' as Reaction;
//
// import '../paginate_firestore/bloc/pagination_listeners.dart';
//
// final GoogleSignIn googleSignIn = GoogleSignIn();
// final Reference storageRef = FirebaseStorage.instance.ref();
// final usersRef = FirebaseFirestore.instance.collection('users');
// final postsRef = FirebaseFirestore.instance.collection('posts');
// final commentsRef = FirebaseFirestore.instance.collection('comments');
// final activityFeedRef = FirebaseFirestore.instance.collection('feed');
// final followersRef = FirebaseFirestore.instance.collection('followers');
// final likedRef = FirebaseFirestore.instance.collection('likedpp');
// final dislikedRef = FirebaseFirestore.instance.collection('dislikedpp');
// final ppviewsRef = FirebaseFirestore.instance.collection('ppviews');
// final followingRef = FirebaseFirestore.instance.collection('following');
// final timelineRef = FirebaseFirestore.instance.collection('timeline');
// final msgRef = FirebaseFirestore.instance.collection('messages');
// final messengerRef = FirebaseFirestore.instance.collection('messenger');
// final groupsRef = FirebaseFirestore.instance.collection('groups');
// final storiesRef = FirebaseFirestore.instance.collection('stories');
// final reportsRef = FirebaseFirestore.instance.collection('reports');
// final DateTime timestamp = DateTime.now();
//
//
// class Home extends StatefulWidget {
//   final String? userId;
//
//   const Home({Key? key, this.userId}) : super(key: key);
//
//   @override
//   _HomeState createState() => _HomeState();
// }
//
// class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//
//
//   final PageController pageController = PageController(initialPage: 0);
//   int pageIndex = 0;
//   late TabController _tabController;
//   final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//   var currentUser = FirebaseAuth.instance.currentUser;
//   bool isFollowing = false;
//   late List<GloabalUser> users;
//   bool showElevatedButtonBadge = true;
//   PaginateRefreshedChangeListener refreshChangeListener =
//   PaginateRefreshedChangeListener();
//
//   @override
//   void initState() {
//     super.initState();
//     getUserData();
//     getAllUsers();
//     getAllStories();
//
//     _tabController = TabController(vsync: this, length: 5);
//     FirebaseMessaging.instance.getInitialMessage().then((message) {});
//     _tabController.addListener(_handleTabSelection);
//   }
//
//   @override
//   void dispose() {
//     pageController.dispose();
//     super.dispose();
//   }
//
//   void _handleTabSelection() {
//     setState(() {});
//   }
//
//   getAllStories() async {
//     QuerySnapshot<Map<String, dynamic>> doc = await storiesRef.get();
//     print('storiess');
//     // print(doc.);
//   }
//
//   checkIfFollowing() async {
//     DocumentSnapshot doc = await followersRef
//         .doc(globalID)
//         .collection('userFollowers')
//         .doc(globalID)
//         .get();
//     setState(() {
//       isFollowing = doc.exists;
//     });
//   }
//
//   getAllUsers() async {
//     QuerySnapshot snapshot =
//         await usersRef.orderBy('timestamp', descending: true).get();
//     List<GloabalUser> users =
//         snapshot.docs.map((doc) => GloabalUser.fromDocument(doc)).toList();
//     setState(() {
//       this.users = users;
//     });
//   }
//
//   getUserData() async {
//     User? user = firebaseAuth.currentUser;
//     if (user != null) {
//       usersRef.doc(user.uid).get().then((peerData) {
//         if (peerData.exists) {
//           if (mounted) {
//             setState(() {
//               globalID = user.uid;
//               globalName = peerData['username'];
//               globalImage = peerData['photoUrl'];
//               globalBio = peerData['bio'];
//               globalCover = peerData['coverUrl'];
//               globalDisplayName = peerData['displayName'];
//               globalCountry = peerData['country'];
//               globalCredits = peerData['credit_points'].toString();
//             });
//           }
//         }
//       });
//     }
//   }
//
//   AnimatedTheme buildAuthScreen() {
//     final mode = AdaptiveTheme.of(context).mode;
//
//     return AnimatedTheme(
//       duration: const Duration(milliseconds: 300),
//       data: Theme.of(context),
//       child: Scaffold(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         key: _scaffoldKey,
//         appBar: AppBar(
//           backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
//           automaticallyImplyLeading: false,
//           shape: Border(
//             bottom: BorderSide(
//               color: Theme.of(context).shadowColor,
//               width: 1.0,
//             ),
//           ),
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Row(
//                 children: <Widget>[
//                   Text(
//                     'soXialz',
//                     style: GoogleFonts.portLligatSans(
//                       textStyle: Theme.of(context).textTheme.headline4,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           actions: [
//             // LanguagePickerWidget(),
//             Container(
//               alignment: Alignment.center,
//               width: 40,
//               margin: const EdgeInsets.all(6.0),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).secondaryHeaderColor,
//                 shape: BoxShape.circle,
//               ),
//               child: IconButton(
//                 onPressed: () {
//                   if (mode == AdaptiveThemeMode.light) {
//                     AdaptiveTheme.of(context).setDark();
//                   } else {
//                     AdaptiveTheme.of(context).setLight();
//                   }
//                 },
//                 icon: mode == AdaptiveThemeMode.light
//                     ? const Icon(Icons.light_mode)
//                     : const Icon(Icons.dark_mode),
//               ),
//             ),
//             CircleButton(
//               icon: Icons.search,
//               iconSize: 25.0,
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const Search()),
//                 );
//               },
//             ),
//             MessagesCount(
//               currentUserId: widget.userId,
//             ),
//           ],
//           elevation: 0.0,
//           bottom: TabBar(
//             indicator: UnderlineTabIndicator(
//               borderSide: BorderSide(
//                   width: 4.0, color: const Color.fromARGB(255, 57, 86, 156)),
//             ),
//             controller: _tabController,
//             unselectedLabelColor:
//                 Theme.of(context).tabBarTheme.unselectedLabelColor,
//             labelColor: Theme.of(context).tabBarTheme.labelColor,
//             tabs: [
//               Tab(
//                 icon: _tabController.index == 0
//                     ? const Icon(
//                         IconlyBold.home,
//                         color: Color(0xFF39569C),
//                       )
//                     : const Icon(IconlyLight.home),
//               ),
//               Tab(
//                 icon: _tabController.index == 1
//                     ? const Icon(
//                         IconlyBold.plus,
//                         color: Color(0xFF39569C),
//                       )
//                     : const Icon(IconlyLight.plus),
//               ),
//               Tab(
//                 icon: _tabController.index == 2
//                     ? const Icon(
//                         IconlyBold.profile,
//                         color: Color(0xFF39569C),
//                       )
//                     : const Icon(IconlyLight.profile),
//               ),
//               FeedsCount(
//                 userId: widget.userId,
//                 tabController: _tabController,
//               ),
//               Tab(
//                 icon: _tabController.index == 4
//                     ? const Icon(
//                         IconlyBold.category,
//                         color: Color(0xFF39569C),
//                       )
//                     : const Icon(IconlyLight.category),
//               ),
//             ],
//           ),
//         ),
//         body: RefreshIndicator(
//           onRefresh: () async {
//             refreshChangeListener.refreshed = true;
//           },
//           child: TabBarView(
//             controller: _tabController,
//             children: [
//               NewTimeline(
//                 UserId: widget.userId,
//                 reactions: Reaction.reactions,
//               ),
//               UsersList(userId: widget.userId),
//               Profile(
//                 profileId: widget.userId,
//                 reactions: Reaction.reactions,
//               ),
//               const ActivityFeed(),
//               SettingsPage(currentUserId: widget.userId),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return buildAuthScreen();
//   }
// }
