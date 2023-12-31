import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:soXialz/pages/home.dart';
import 'package:soXialz/widgets/circle_button.dart';
import '../../pages/chat/soxialz_chat_main.dart';

class MessagesCount extends StatefulWidget {
  final String? currentUserId;
  // final String receiverId;

  const MessagesCount({
    Key? key,
    this.currentUserId,
    // required this.receiverId,
  }) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  MessagesState createState() => MessagesState(
        currentUserId: currentUserId,
        // receiverId: receiverId,
      );
}

class MessagesState extends State<MessagesCount> {
  final String? currentUserId;
  String sum = '0';

  MessagesState({
    this.currentUserId,
  });

  @override
  void initState() {
    super.initState();
  }

  Stream<QuerySnapshot> requestCount() {
    return messengerRef
        .doc(currentUserId)
        .collection(currentUserId!)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: requestCount(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var ds = snapshot.data!.docs;
          int sum = 0;
          for (int i = 0; i < ds.length; i++) {
            sum += (int.parse(ds[i]['badge']));
          }
          if (sum > 0) {
            return badges.Badge(
              position: badges.BadgePosition.topEnd(top: 0, end: 3),
              badgeContent: Text(
                '$sum',
                style: const TextStyle(color: Colors.white),
              ),
              badgeAnimation: const badges.BadgeAnimation.slide(
                animationDuration: Duration(milliseconds: 300),
              ),
              child: CircleButton(
                icon: MdiIcons.facebookMessenger,
                iconSize: 25.0,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const soXialzChat()),
                  );
                },
              ),
            );
          }
          return CircleButton(
            icon: MdiIcons.facebookMessenger,
            iconSize: 25.0,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const soXialzChat()),
              );
            },
          );
        } else if (!snapshot.hasData) {}
        return const Center(
          child: CupertinoActivityIndicator(),
        );
      },
    );
  }
}
