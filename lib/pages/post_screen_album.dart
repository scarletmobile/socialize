import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:soXialz/pages/home.dart';
import 'package:soXialz/widgets/album_posts.dart';
import 'package:soXialz/widgets/header.dart';
import 'package:soXialz/widgets/progress.dart';

class PostScreenAlbum extends StatelessWidget {
  final String? userId;
  final String? postId;

  PostScreenAlbum({this.userId, this.postId});

  Future<List<AlbumPosts>> getPostList() async {
    try {
      QuerySnapshot snapshot = await postsRef
          .doc(userId)
          .collection('userPosts')
          .doc(postId)
          .collection("albumposts")
          .orderBy('type', descending: true)
          .get();
      List<AlbumPosts> feedItems = [];
      snapshot.docs.forEach((doc) {
        feedItems.add(AlbumPosts.fromDocument(doc));
      });

      return feedItems;
    } catch (error) {
      print(error);
      return <AlbumPosts>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: header(context, titleText: ''),
      body: FutureBuilder<List<AlbumPosts>>(
        future: getPostList(),
        builder: (context, AsyncSnapshot<List<AlbumPosts>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("You have an error in loading data"));
          }
          if (snapshot.hasData) {
            return ListView(
              shrinkWrap: true,
              children: snapshot.data!,
            );
          }
          return circularProgress();
        },
      ),
    );
  }
}
