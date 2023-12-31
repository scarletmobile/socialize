import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soXialz/config/palette.dart';
import 'package:soXialz/pages/home.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:soXialz/pages/post_screen.dart';
import 'package:soXialz/pages/profile.dart';
import 'package:soXialz/widgets/anchored_adaptive_ads.dart';
import 'package:soXialz/widgets/header.dart';
import 'package:soXialz/widgets/simple_world_widgets.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:soXialz/data/reaction_data.dart' as Reaction;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ActivityFeed extends StatefulWidget {
  const ActivityFeed({Key? key}) : super(key: key);

  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  final String? currentUserId = globalID;

  List<ActivityFeedItem> feedItem = [];

  @override
  void initState() {
    super.initState();
    updatefeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: header(context,
          titleText: AppLocalizations.of(context)!.notifications,
          removeBackButton: false),
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 15,
              ),
              child: Container(
                child: activityfeedList(currentUserId!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget activityfeedList(String userData) {
    return StreamBuilder(
      stream: activityFeedRef
          .doc(globalID)
          .collection('feedItems')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: snapshot.data!.docs.isNotEmpty
                ? Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: ListView.separated(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, int index) {
                            List feedItem = snapshot.data!.docs;
                            return buildItem(feedItem, index);
                          },
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                        ),
                      ),
                      AnchoredAd(),
                    ],
                  )
                : const Center(
                    child: Text("Currently you don't have any messages"),
                  ),
          );
        }
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: const <Widget>[
                CupertinoActivityIndicator(),
              ]),
        );
      },
    );
  }

  updatefeed() async {
    QuerySnapshot activityFeedSnapshot =
        await activityFeedRef.doc(currentUserId).collection("feedItems").get();
    activityFeedSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.update({
          "isSeen": true,
        });
      }
    });
  }

  Widget buildItem(List feedItem, int index) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Container(
          child: ListTile(
            title: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(
                      profileId: feedItem[index]['userId'],
                      reactions: Reaction.reactions,
                    ),
                  ),
                ).then((value) => setState(() {}));
              },
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Palette.soXialzText,
                    ),
                    children: [
                      TextSpan(
                        text: feedItem[index]['username'],
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              fontSize: 16,
                            ),
                      ),
                      TextSpan(
                        text: feedItem[index]['type'] != null &&
                                feedItem[index]['type'] == 'like'
                            ? " reacted to your post"
                            : feedItem[index]['type'] != null &&
                                    feedItem[index]['type'] == 'follow'
                                ? " is following you"
                                : feedItem[index]['type'] != null &&
                                        feedItem[index]['type'] == 'comment'
                                    ? " Commented on your post: " +
                                        feedItem[index]['commentData']
                                    : feedItem[index]['type'] != null &&
                                            feedItem[index]['type'] == 'message'
                                        ? " Sent you a message: " +
                                            feedItem[index]['contentMessage']
                                        : " Error: Unknown type " +
                                            feedItem[index]['type'],
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                              fontSize: 15,
                            ),
                      ),
                    ]),
              ),
            ),
            subtitle: Text(
              timeago.format(feedItem[index]['timestamp'].toDate()),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12.0,
              ),
            ),
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(
                      profileId: feedItem[index]['userId'],
                      reactions: Reaction.reactions,
                    ),
                  ),
                ).then((value) => setState(() {}));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: feedItem[index]['userProfileImg'] == null ||
                        feedItem[index]['userProfileImg'].isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF003a54),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Image.asset(
                          'assets/images/defaultavatar.png',
                          width: 50,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: feedItem[index]['userProfileImg'],
                        height: 50.0,
                        width: 50.0,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            trailing: feedItem[index]['type'] == 'like' ||
                    feedItem[index]['type'] == 'comment'
                ? feedItem[index]['mediaUrl'] != null
                    ? SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                    feedItem[index]['mediaUrl']),
                              ),
                            ),
                          ),
                        ),
                      ).onTap(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostScreen(
                              userId: currentUserId,
                              postId: feedItem[index]['postId'],
                            ),
                          ),
                        );
                      })
                    : mediaPreview = const Text('')
                : mediaPreview = const Text(''),
          ),
        ));
  }
}

Widget? mediaPreview;
String? activityItemText;

class ActivityFeedItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  final String? username;
  final String? userId;
  final String? type;
  final String? mediaUrl;
  final String? postId;
  final String? userProfileImg;
  final String? commentData;
  final Timestamp? timestamp;

  const ActivityFeedItem({
    Key? key,
    this.username,
    this.userId,
    this.type,
    this.mediaUrl,
    this.postId,
    this.userProfileImg,
    this.commentData,
    this.timestamp,
  }) : super(key: key);

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc['username'],
      userId: doc['userId'],
      type: doc['type'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],
      mediaUrl: doc['mediaUrl'],
    );
  }
}

showProfile(BuildContext context, {String? profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
        reactions: Reaction.reactions,
      ),
    ),
  );
}
