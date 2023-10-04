import 'package:soXialz/models/onboarding_model.dart';

List<WalkThroughItemModel> getWalkThroughItems() {
  List<WalkThroughItemModel> walkThroughItems = [];
  walkThroughItems.add(WalkThroughItemModel(
    image: 'assets/images/walkthrough-1.png',
    title: 'Upload Photos & Videos',
    subTitle: 'Share images and videos with your friends',
  ));
  walkThroughItems.add(WalkThroughItemModel(
    image: 'assets/images/walkthrough-2.png',
    title: 'Chat',
    subTitle: 'Chat with others and make new friends all over the world.',
  ));
  walkThroughItems.add(WalkThroughItemModel(
    image: 'assets/images/walkthrough-3.png',
    title: 'Comment & React to Posts',
    subTitle: 'Comments and React to posts of users your following',
  ));
  walkThroughItems.add(WalkThroughItemModel(
    image: 'assets/images/walkthrough-4.png',
    title: 'Credit System',
    subTitle:
        'Use credit points to see users who like, dislike, view or follow your profile, also use credit points to see users who like, dislike, view or follow other users, ',
  ));
  return walkThroughItems;
}
