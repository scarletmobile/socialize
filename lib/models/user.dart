// ignore_for_file: non_constant_identifier_names

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // or other relevant imports
import 'package:simpleworld/models/user.dart';

class GloabalUser {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;
  final String website;
  final String facebook;
  final String instagram;
  final int credit_points;
  final String coverUrl;
  final bool userIsVerified;
  final bool no_ads;
  String activeVipId = '';

  GloabalUser({
    required this.id,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.displayName,
    required this.bio,
    required this.website,
    required this.facebook,
    required this.instagram,
    required this.credit_points,
    required this.no_ads,
    required this.coverUrl,
    required this.userIsVerified,
  });

  /// Set Active VIP Subscription ID
  // void setActiveVipId(String subscriptionId) {
  //   this.activeVipId = subscriptionId;
  //   notifyListeners();
  // }

  // factory GloabalUser.fromDocument(DocumentSnapshot doc) {
  //   print("id: ${doc['id']}");
  //   print("email: ${doc['email']}");
  //   print("username: ${doc['username']}");
  //   print("photoUrl: ${doc['photoUrl']}");
  //   print("displayName: ${doc['displayName']}");
  //   print("bio: ${doc['bio']}");
  //   print("website: ${doc['website']}");
  //   print("facebook: ${doc['facebook']}");
  //   print("instagram: ${doc['instagram']}");
  //   print("credit_points: ${doc['credit_points']}");
  //   print("coverUrl: ${doc['coverUrl']}");
  //   print("userIsVerified: ${doc['userIsVerified']}");
  //   print("no_ads: ${doc['no_ads']}");
  //   return GloabalUser(
  //     id: doc['id'],
  //     email: doc['email'],
  //     username: doc['username'],
  //     photoUrl: doc['photoUrl'],
  //     displayName: doc['displayName'],
  //     bio: doc['bio'],
  //     website: doc['website'],
  //     facebook: doc['facebook'],
  //     instagram: doc['instagram'],
  //     credit_points: doc['credit_points'],
  //     coverUrl: doc['coverUrl'],
  //     userIsVerified: doc['userIsVerified'],
  //     no_ads: doc['no_ads'],
  //   );
  // }
  factory GloabalUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    final id = data?['id'] as String? ?? '';
    final email = data?['email'] as String? ?? '';
    final username = data?['username'] as String? ?? '';
    final photoUrl = data?['photoUrl'] as String? ?? '';
    final displayName = data?['displayName'] as String? ?? '';
    final bio = data?['bio'] as String? ?? '';
    final website = data?['website'] as String? ?? '';
    final facebook = data?['facebook'] as String? ?? '';
    final instagram = data?['instagram'] as String? ?? '';
    final creditPoints = data?['credit_points'] as int?;
    final coverUrl = data?['coverUrl'] as String? ?? '';
    final userIsVerified = data?['userIsVerified'] as bool?;
    final noAds = data?['no_ads'] as bool?;

    return GloabalUser(
      id: id,
      email: email,
      username: username,
      photoUrl: photoUrl,
      displayName: displayName,
      bio: bio,
      website: website,
      facebook: facebook,
      instagram: instagram,
      credit_points: creditPoints ?? 0, // Provide a default value if it's null
      coverUrl: coverUrl,
      userIsVerified: userIsVerified ?? false, // Provide a default value if it's null
      no_ads: noAds ?? false, // Provide a default value if it's null
    );
  }


  factory GloabalUser.fromMap(Map<String, dynamic> map) {
    return GloabalUser(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      username: map['username'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      website: map['website'] as String? ?? '',
      facebook: map['facebook'] as String? ?? '',
      instagram: map['instagram'] as String? ?? '',
      credit_points: map['credit_points'],
      coverUrl: map['coverUrl'] as String? ?? '',
      userIsVerified: map['userIsVerified'],
      no_ads: map['no_ads'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'photoUrl': photoUrl,
      'displayName': displayName,
      'bio': bio,
      'website': website,
      'facebook': facebook,
      'instagram': instagram,
      'credit_points': credit_points,
      'searchIndexes': searchIndexes,
      'coverUrl': coverUrl,
      'userIsVerified': userIsVerified,
      'no_ads': no_ads,
    };
  }

  List<String> get searchIndexes {
    final indices = <String>[];
    for (final s in [username, displayName]) {
      for (var i = 1; i < s.length; i++) {
        indices.add(s.substring(0, i).toLowerCase());
      }
    }
    return indices;
  }

  static final usersCol =
      FirebaseFirestore.instance.collection('users').withConverter<GloabalUser>(
            fromFirestore: (e, _) => GloabalUser.fromMap(e.data()!),
            toFirestore: (m, _) => m.toMap(),
          );
  static DocumentReference<GloabalUser> userDoc([String? id]) =>
      usersCol.doc(id ?? id);

  static Future<GloabalUser?> fetchUser([String? id]) async {
    final doc = await userDoc(id ?? id).get();
    return doc.data();
  }
}
