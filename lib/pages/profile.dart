// ignore_for_file: unnecessary_this

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:soXialz/models/user.dart';
import 'package:soXialz/pages/comming_soon_page.dart';
import 'package:soXialz/pages/disliked_list.dart';
import 'package:soXialz/pages/followers_list.dart';
import 'package:soXialz/pages/following_users_list.dart';
import 'package:soXialz/pages/home.dart';
import 'package:soXialz/pages/auth/login_page.dart';
import 'package:soXialz/pages/create_post/post_box.dart';
import 'package:soXialz/pages/chat/soXialz_chat.dart';
import 'package:soXialz/pages/edit_profile.dart';
import 'package:soXialz/pages/liked_list.dart';
import 'package:soXialz/pages/menu/dialogs/store_products.dart';
import 'package:soXialz/pages/ppviewed_list.dart';
import 'package:soXialz/story/add_story.dart';
import 'package:soXialz/widgets/header.dart';
import 'package:soXialz/widgets/multi_manager/flick_multi_manager.dart';
import 'package:soXialz/widgets/progress.dart';
import 'package:soXialz/widgets/simple_world_widgets.dart';
import 'package:soXialz/widgets/single_post.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Profile extends StatefulWidget {
  final String? profileId;
  final List<Reaction<String>> reactions;

  Profile({
    required this.profileId,
    required this.reactions,
  });

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String? currentUserId = globalID;
  String postOrientation = "list";
  bool isFollowing = false;
  bool isLiked = false;
  bool isDisliked = false;
  bool isLoading = false;
  int currentusercredit = 0;
  int postCount = 0;
  int followerCount = 0;
  int likedCount = 0;
  int dislikedCount = 0;
  int ppviewCount = 0;
  int followingCount = 0;
  final ImagePicker _picker = ImagePicker();
  File? storyfile;
  File? imageFileAvatar;
  File? imageFileCover;
  String? imageFileAvatarUrl;
  String? imageFileCoverUrl;
  bool showHeart = false;
  late FlickMultiManager flickMultiManager;
  List<SinglePost> posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
    flickMultiManager = FlickMultiManager();
    checkIfLiked();
    checkIfDislikedLiked();
    getLikedusers();
    getcurrentusercredits();
    getDisLikedusers();
    viewMyProfile();
    getppviwedusers();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  checkIfLiked() async {
    DocumentSnapshot doc = await likedRef
        .doc(widget.profileId)
        .collection('userlikes')
        .doc(currentUserId)
        .get();
    setState(() {
      isLiked = doc.exists;
    });
  }

  checkIfDislikedLiked() async {
    DocumentSnapshot doc = await dislikedRef
        .doc(widget.profileId)
        .collection('userDislikes')
        .doc(currentUserId)
        .get();
    setState(() {
      isDisliked = doc.exists;
    });
  }

  getLikedusers() async {
    QuerySnapshot snapshot =
        await likedRef.doc(widget.profileId).collection('userlikes').get();
    setState(() {
      likedCount = snapshot.docs.length;
    });
  }

  getDisLikedusers() async {
    QuerySnapshot snapshot = await dislikedRef
        .doc(widget.profileId)
        .collection('userDislikes')
        .get();
    setState(() {
      dislikedCount = snapshot.docs.length;
    });
  }

  getppviwedusers() async {
    QuerySnapshot snapshot =
        await ppviewsRef.doc(widget.profileId).collection('userviews').get();
    setState(() {
      ppviewCount = snapshot.docs.length;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      followerCount = snapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => SinglePost.fromDocument(doc)).toList();
    });
  }

  getcurrentusercredits() async {
    usersRef.doc(globalID).get().then(
          (value) => setState(() {
            currentusercredit = value["credit_points"];
          }),
        );
  }

  viewMyProfile() {
    bool isProfileOwner = currentUserId == widget.profileId;
    isProfileOwner
        ? Container()
        : ppviewsRef.doc(widget.profileId).collection('userviews').doc().set({
            'userId': currentUserId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          });
  }

  Future handleChooseFromGallery() async {
    final navigator = Navigator.of(context);
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (mounted) {
      setState(() async {
        this.storyfile = storyfile;
        if (pickedFile != null) {
          storyfile = File(pickedFile.path);

          await navigator
              .push(MaterialPageRoute(builder: (context) => AddStory()));
        } else {
          // print('No image selected.');
        }
      });
    }
  }

  buildCountColumn(String label, int count, Function() onTap) {
    double maxWidth = MediaQuery.of(context).size.width * 0.2;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 4.0),
            width: maxWidth,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ).onTap(onTap);
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  buildProfileButton() {
    double maxWidth = MediaQuery.of(context).size.width * 0.4;

    bool isProfileOwner = currentUserId == widget.profileId;

    if (isProfileOwner) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            height: 38,
            width: maxWidth,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 57, 86, 156),
              borderRadius: const BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.add_story,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.0,
                  color: Colors.white,
                ),
              ),
            ),
          ).onTap(
            () {
              handleChooseFromGallery();
            },
          ),
          const SizedBox(width: 10),
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            height: 38,
            width: maxWidth,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.edit_profile,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.0,
                  color: Colors.black,
                ),
              ),
            ),
          ).onTap(
            () {
              editProfile();
            },
          )
        ],
      );
    } else if (isFollowing) {
      return Container(
        margin: const EdgeInsets.only(top: 10.0),
        height: 38,
        width: (context.width() - (3 * 16)) * 0.4,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 57, 86, 156),
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.unfollow,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 0.0,
              color: Colors.white,
            ),
          ),
        ),
      ).onTap(() {
        handleUnfollowUser();
      });
    } else if (!isFollowing) {
      return Container(
        margin: const EdgeInsets.only(top: 10.0),
        height: 38,
        width: (context.width() - (3 * 16)) * 0.4,
        decoration: BoxDecoration(
          color: Colors.blue[700],
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.follow,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 0.0,
              color: Colors.white,
            ),
          ),
        ),
      ).onTap(() {
        handleFollowUser();
      });
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({'userId': currentUserId});
    ;
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({'userId': widget.profileId});
    ;
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": globalName,
      "userId": currentUserId,
      "userProfileImg": globalImage,
      "timestamp": timestamp,
      "isSeen": false,
    });
  }

  handleLikeUser() {
    if (isLiked) {
      setState(() {
        isLiked = false;
        likedCount--;
      });
      likedRef
          .doc(widget.profileId)
          .collection('userlikes')
          .doc(currentUserId)
          .delete();
    } else {
      if (isDisliked) {
        setState(() {
          isDisliked = false;
          dislikedCount--;
        });
        dislikedRef
            .doc(widget.profileId)
            .collection('userDislikes')
            .doc(currentUserId)
            .delete();
      }
      likedRef
          .doc(widget.profileId)
          .collection('userlikes')
          .doc(currentUserId)
          .set({'userId': currentUserId});
      setState(() {
        isDisliked = false;
        isLiked = true;
        likedCount++;
      });
    }
  }

  handleDislikeLikeUser() {
    if (isDisliked) {
      setState(() {
        isDisliked = false;
        dislikedCount--;
      });
      dislikedRef
          .doc(widget.profileId)
          .collection('userDislikes')
          .doc(currentUserId)
          .delete();
    } else {
      if (isLiked) {
        setState(() {
          isLiked = false;
          likedCount--;
        });
        likedRef
            .doc(widget.profileId)
            .collection('userlikes')
            .doc(currentUserId)
            .delete();
      }
      dislikedRef
          .doc(widget.profileId)
          .collection('userDislikes')
          .doc(currentUserId)
          .set({'userId': currentUserId});
      setState(() {
        isDisliked = true;
        isLiked = false;
        dislikedCount++;
      });
    }
  }

  Future getavatarImage() async {
    final newImageFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      this.imageFileAvatar = imageFileAvatar;
      if (newImageFile != null) {
        imageFileAvatar = File(newImageFile.path);
        // print(newImageFile.path);
      } else {
        // print('No image selected.');
      }
    });

    uploadAvatar(imageFileAvatar);
  }

  Future uploadAvatar(imageFileAvatar) async {
    String mFileName = globalID!;
    Reference storageReference =
        FirebaseStorage.instance.ref().child("avatar_$mFileName.jpg");
    UploadTask storageUploadTask = storageReference.putFile(imageFileAvatar!);
    String downloadUrl = await (await storageUploadTask).ref.getDownloadURL();
    imageFileAvatarUrl = downloadUrl;
    setState(() {
      isLoading = false;
      usersRef.doc(widget.profileId).update({"photoUrl": imageFileAvatarUrl});

      SnackBar snackbar =
          const SnackBar(content: Text("Profile Photo updated!"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });
  }

  Future getcoverImage() async {
    final newImageFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      this.imageFileCover = imageFileCover;
      if (newImageFile != null) {
        imageFileCover = File(newImageFile.path);
        // print(newImageFile.path);
      } else {
        // print('No image selected.');
      }
    });

    uploadCover(imageFileCover);
  }

  Future uploadCover(imageFileCover) async {
    String mFileName = globalID!;
    Reference storageReference =
        FirebaseStorage.instance.ref().child("cover_$mFileName.jpg");
    UploadTask storageUploadTask = storageReference.putFile(imageFileCover!);
    String downloadUrl = await (await storageUploadTask).ref.getDownloadURL();
    imageFileCoverUrl = downloadUrl;
    setState(() {
      isLoading = false;
      usersRef.doc(widget.profileId).update({"coverUrl": imageFileCoverUrl});

      SnackBar snackbar = const SnackBar(content: Text("Cover Photo updated!"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });
  }

  consentSheet(
      BuildContext context, String title, String subtitle, Function() accept) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context,
            StateSetter setState /*You can rename this!*/) {
          return Wrap(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: radius(4)),
                      height: 4,
                      width: 100,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                title: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 15.0),
                ),
              ),
              ListTile(
                title: Text(
                  subtitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 15.0),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  ElevatedButton(
                    child: Text(
                      AppLocalizations.of(context)!.accept,
                    ),
                    onPressed: accept,
                  )
                ],
              )
            ],
          );
        });
      },
    );
  }

  buildProfileHeader() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: FutureBuilder<GloabalUser?>(
        future: GloabalUser.fetchUser(widget.profileId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          final user = snapshot.data;
          final bool isProfileOwner = currentUserId == widget.profileId;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(children: <Widget>[
                (imageFileCover == null)
                    ? user!.coverUrl.isEmpty
                        ? Image.asset(
                            'assets/images/defaultcover.png',
                            alignment: Alignment.center,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            height: 200,
                          )
                        : SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: CachedNetworkImage(
                              imageUrl: user.coverUrl,
                              fit: BoxFit.cover,
                            ),
                          )
                    : Material(
                        child: Image.file(
                          imageFileCover!,
                          width: double.infinity,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        clipBehavior: Clip.hardEdge,
                      ),
                isProfileOwner
                    ? Container()
                    : SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: Container(
                          alignment: const Alignment(-0.8, 1.5),
                          child: Stack(
                            children: [
                              isLiked
                                  ? Container(
                                      // alignment: Alignment.center,
                                      width: 60,
                                      padding: const EdgeInsets.all(10.0),
                                      margin: const EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                        'assets/images/likedpp.png',
                                        width: 40,
                                      ),
                                    ).onTap(() {
                                      handleLikeUser();
                                    })
                                  : Container(
                                      width: 60,
                                      padding: const EdgeInsets.all(10.0),
                                      margin: const EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                        'assets/images/likepp.png',
                                        width: 40,
                                      ),
                                    ).onTap(() {
                                      handleLikeUser();
                                    })
                            ],
                          ),
                        ),
                      ),
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Container(
                    alignment: const Alignment(0.0, 2.5),
                    child: Stack(
                      children: [
                        (imageFileAvatar == null)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: user!.photoUrl == null ||
                                        user.photoUrl.isEmpty
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF003a54),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        child: Image.asset(
                                          'assets/images/defaultavatar.png',
                                          width: 120,
                                        ),
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: user.photoUrl,
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      ),
                              )
                            : Material(
                                child: Image.file(
                                  imageFileAvatar!,
                                  width: 120.0,
                                  height: 120.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                        isProfileOwner
                            ? SvgPicture.asset(
                                'assets/images/photo.svg',
                                width: 40,
                              ).onTap(() {
                                getavatarImage();
                              })
                            : const Text(''),
                      ],
                    ),
                  ),
                ),
                isProfileOwner
                    ? Container()
                    : SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: Container(
                          alignment: const Alignment(0.8, 1.5),
                          child: Stack(
                            children: [
                              isDisliked
                                  ? Container(
                                      width: 60,
                                      padding: const EdgeInsets.all(10.0),
                                      margin: const EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                        'assets/images/dislikedpp.png',
                                        width: 40,
                                      ),
                                    ).onTap(() {
                                      handleDislikeLikeUser();
                                    })
                                  : Container(
                                      width: 60,
                                      padding: const EdgeInsets.all(10.0),
                                      margin: const EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                        'assets/images/dislikepp.png',
                                        width: 40,
                                      ),
                                    ).onTap(() {
                                      handleDislikeLikeUser();
                                    }),
                            ],
                          ),
                        ),
                      ),
                isProfileOwner
                    ? Positioned(
                        bottom: 0,
                        right: 0,
                        child: SvgPicture.asset(
                          'assets/images/photo.svg',
                          width: 40,
                        ).onTap(() {
                          getcoverImage();
                        }))
                    : Container(),
              ]),
              const SizedBox(height: 70),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user!.username.capitalize(),
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontSize: 16),
                  ),

                  /// Show verified badge
                  user.userIsVerified
                      ? Container(
                          margin: const EdgeInsets.only(right: 5),
                          child: Image.asset('assets/images/verified_badge.png',
                              width: 30, height: 30))
                      : Container(width: 0, height: 0),
                ],
              ),
              const SizedBox(height: 3),
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
                  child: Text(user.bio,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(fontSize: 14))),
              const SizedBox(height: 1),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                  child: Text(user.website,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(fontSize: 14))),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                  child: Text(user.facebook,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(fontSize: 14))),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Text(user.instagram,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(fontSize: 14))),
              if (isProfileOwner)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 35),
                      child: Row(
                        children: [
                          Text(AppLocalizations.of(context)!.you_have,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(fontSize: 14)),
                          Text(user.credit_points.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(fontSize: 14)),
                          Text(AppLocalizations.of(context)!.credits,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 42),
                      child: Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        height: 38,
                        width: (context.width() - (3 * 18)) * 0.46,
                        decoration: const BoxDecoration(
                          color: Color(0xffE5E6EB),
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.buy_credits,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ).onTap(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Upgrade(),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildProfileButton(),
                  const SizedBox(width: 10),
                  if (!isProfileOwner)
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          height: 38,
                          width: (context.width() - (3 * 16)) * 0.4,
                          decoration: const BoxDecoration(
                            color: Color(0xffE5E6EB),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.message,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: 0.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ).onTap(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Chat(
                                receiverId: user.id,
                                receiverAvatar: user.photoUrl,
                                receiverName: user.username,
                                key: null,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    buildCountColumn(
                      AppLocalizations.of(context)!.posts,
                      postCount,
                      () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const CommimgSoon(),
                        ),
                      ),
                    ),
                    buildCountColumn(
                      AppLocalizations.of(context)!.followers,
                      followerCount,
                      () {
                        if (isProfileOwner) {
                          bool noCredit = user.credit_points < 10;
                          consentSheet(
                            context,
                            AppLocalizations.of(context)!.followed_consent1,
                            AppLocalizations.of(context)!.followed_consent2,
                            () async {
                              if (noCredit) {
                                Navigator.of(context).pop();
                                soXialztoast(
                                    AppLocalizations.of(context)!.error,
                                    AppLocalizations.of(context)!
                                        .not_enough_credit_10,
                                    context);
                              } else {
                                Navigator.of(context).pop();
                                usersRef.doc(widget.profileId).update({
                                  "credit_points": FieldValue.increment(-10),
                                });

                                //##Uncomment the below code to get user id of followers
                                // var querySnapshots = await followersRef
                                //     .doc(user.id)
                                //     .collection('userFollowers')
                                //     .get();
                                // for (var doc in querySnapshots.docs) {
                                //   await doc.reference.update({
                                //     "userId": doc.id,
                                //   });
                                // }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => followersList(
                                      userId: user.id,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        } else {
                          bool noCredit = currentusercredit < 20;
                          consentSheet(
                            context,
                            AppLocalizations.of(context)!.followed_consent3,
                            AppLocalizations.of(context)!.followed_consent4,
                            () async {
                              if (noCredit) {
                                Navigator.of(context).pop();
                                soXialztoast(
                                    AppLocalizations.of(context)!.error,
                                    AppLocalizations.of(context)!
                                        .not_enough_credit_20,
                                    context);
                              } else {
                                Navigator.of(context).pop();

                                usersRef.doc(globalID).update({
                                  "credit_points": FieldValue.increment(-20),
                                });

                                //##Uncomment the below code to get user id of followers
                                // var querySnapshots = await followersRef
                                //     .doc(user.id)
                                //     .collection('userFollowers')
                                //     .get();
                                // for (var doc in querySnapshots.docs) {
                                //   await doc.reference.update({
                                //     "userId": doc.id,
                                //   });
                                // }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => followersList(
                                      userId: user.id,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        }
                      },
                    ),
                    buildCountColumn(
                      AppLocalizations.of(context)!.following,
                      followingCount,
                      () {
                        if (isProfileOwner) {
                          bool noCredit = user.credit_points < 10;
                          consentSheet(
                            context,
                            AppLocalizations.of(context)!.following_consent1,
                            AppLocalizations.of(context)!.following_consent2,
                            () async {
                              if (noCredit) {
                                Navigator.of(context).pop();
                                soXialztoast(
                                    AppLocalizations.of(context)!.error,
                                    AppLocalizations.of(context)!
                                        .not_enough_credit_10,
                                    context);
                              } else {
                                Navigator.of(context).pop();
                                usersRef.doc(widget.profileId).update({
                                  "credit_points": FieldValue.increment(-10),
                                });

                                //##Uncomment the below code to get user id of following users
                                // var querySnapshots = await followingRef
                                //     .doc(user.id)
                                //     .collection('userFollowing')
                                //     .get();
                                // for (var doc in querySnapshots.docs) {
                                //   await doc.reference.update({
                                //     "userId": doc.id,
                                //   });
                                // }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => followingList(
                                      userId: user.id,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        } else {
                          bool noCredit = currentusercredit < 20;
                          consentSheet(
                            context,
                            AppLocalizations.of(context)!.following_consent3,
                            AppLocalizations.of(context)!.following_consent4,
                            () async {
                              if (noCredit) {
                                Navigator.of(context).pop();
                                soXialztoast(
                                    AppLocalizations.of(context)!.error,
                                    AppLocalizations.of(context)!
                                        .not_enough_credit_20,
                                    context);
                              } else {
                                Navigator.of(context).pop();

                                usersRef.doc(globalID).update({
                                  "credit_points": FieldValue.increment(-20),
                                  // 'userIsVerified': true,
                                });
                                //##Uncomment the below code to get user id of following users

                                // var querySnapshots = await followingRef
                                //     .doc(user.id)
                                //     .collection('userFollowing')
                                //     .get();
                                // for (var doc in querySnapshots.docs) {
                                //   await doc.reference.update({
                                //     "userId": doc.id,
                                //   });
                                // }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => followingList(
                                      userId: user.id,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    buildCountColumn(
                      "Views",
                      ppviewCount,
                      () {
                        if (isProfileOwner) {
                          bool noCredit = user.credit_points < 10;
                          consentSheet(
                            context,
                            'Would you like to see users who viewed your Profile?',
                            'Spent 10 Credits to see users who viewed your Profile',
                            () {
                              if (noCredit) {
                                Navigator.of(context).pop();
                                soXialztoast(
                                    "Error",
                                    "Does not have enough credits, please get more then 10 credits",
                                    context);
                              } else {
                                Navigator.of(context).pop();
                                usersRef.doc(widget.profileId).update({
                                  "credit_points": FieldValue.increment(-10),
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UsersViewedMyProfileList(
                                      userId: user.id,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        } else {
                          bool noCredit = currentusercredit < 20;
                          consentSheet(
                            context,
                            'Would you like to see users who viewed  this Profile?',
                            'Spent 20 Credits to see users who viewed this Profile',
                            () {
                              if (noCredit) {
                                Navigator.of(context).pop();
                                soXialztoast(
                                    "Error",
                                    "Does not have enough credits, please get more then 20 credits",
                                    context);
                              } else {
                                Navigator.of(context).pop();

                                usersRef.doc(globalID).update({
                                  "credit_points": FieldValue.increment(-20),
                                });

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UsersViewedMyProfileList(
                                      userId: user.id,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        }
                      },
                    ),
                    buildCountColumn("Likes", likedCount, () {
                      if (isProfileOwner) {
                        bool noCredit = user.credit_points < 10;
                        consentSheet(
                          context,
                          'Would you like to see users who liked your Profile?',
                          'Spent 10 Credits to see users who liked your Profile',
                          () {
                            if (noCredit) {
                              Navigator.of(context).pop();
                              soXialztoast(
                                  "Error",
                                  "Does not have enough credits, please get more then 10 credits",
                                  context);
                            } else {
                              Navigator.of(context).pop();
                              usersRef.doc(widget.profileId).update({
                                "credit_points": FieldValue.increment(-10),
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UsersLikedMyProfileList(
                                    userId: user.id,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      } else {
                        bool noCredit = currentusercredit < 20;
                        consentSheet(
                          context,
                          'Would you like to see users who liked  this Profile?',
                          'Spent 20 Credits to see users who liked this Profile',
                          () {
                            if (noCredit) {
                              Navigator.of(context).pop();
                              soXialztoast(
                                  "Error",
                                  "Does not have enough credits, please get more then 20 credits",
                                  context);
                            } else {
                              Navigator.of(context).pop();

                              usersRef.doc(globalID).update({
                                "credit_points": FieldValue.increment(-20),
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UsersLikedMyProfileList(
                                    userId: user.id,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }
                    }),
                    buildCountColumn("Dislikes", dislikedCount, () {
                      if (isProfileOwner) {
                        bool noCredit = user.credit_points < 10;
                        consentSheet(
                          context,
                          'Would you like to see users who Disliked your Profile?',
                          'Spent 10 Credits to see users who Disliked your Profile',
                          () {
                            if (noCredit) {
                              Navigator.of(context).pop();
                              soXialztoast(
                                  "Error",
                                  "Does not have enough credits, please get more then 10 credits",
                                  context);
                            } else {
                              Navigator.of(context).pop();
                              usersRef.doc(widget.profileId).update({
                                "credit_points": FieldValue.increment(-10),
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UsersDisLikedMyProfileList(
                                    userId: user.id,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      } else {
                        bool noCredit = currentusercredit < 20;
                        consentSheet(
                          context,
                          'Would you like to see users who Disliked  this Profile?',
                          'Spent 20 Credits to see users who Disliked this Profile',
                          () {
                            if (noCredit) {
                              Navigator.of(context).pop();
                              soXialztoast(
                                  "Error",
                                  "Does not have enough credits, please get more then 20 credits",
                                  context);
                            } else {
                              Navigator.of(context).pop();

                              usersRef.doc(globalID).update({
                                "credit_points": FieldValue.increment(-20),
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UsersDisLikedMyProfileList(
                                    userId: user.id,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              PostBox(currentUser: currentUser),
              const Divider(),
              buildProfilePosts()
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: header(
        context,
        titleText: AppLocalizations.of(context)!.profile,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: buildProfileHeader(),
      ),
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/no_content.svg',
            height: 260.0,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              "No Posts",
              style: TextStyle(
                color: const Color.fromARGB(255, 57, 86, 156),
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else if (postOrientation == "list") {
      return Column(
        children: posts,
      );
    }
  }
}
