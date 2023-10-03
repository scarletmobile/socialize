import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simpleworld/models/user.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/pages/auth/login_page.dart';
import 'package:simpleworld/pages/profile.dart';
import 'package:simpleworld/widgets/progress.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';
import 'package:simpleworld/data/reaction_data.dart' as Reaction;

class EditProfile extends StatefulWidget {
  final String? currentUserId;

  const EditProfile({Key? key, this.currentUserId}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool isLoading = false;
  late GloabalUser user;
  bool _displayNameValid = true;
  bool _bioValid = true;
  bool _websiteValid = true;
  bool _instagramValid = true;
  bool _facebookValid = true;
  bool _countryValid = true;
  bool _phoneValid = true;
  final ImagePicker _picker = ImagePicker();
  File? imageFileAvatar;
  File? imageFileCover;
  String? imageFileAvatarUrl;
  String? imageFileCoverUrl;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    log('data Error : $doc');
    user = GloabalUser.fromDocument(doc);

    log('data : $user');
    // displayNameController.text = DisplayName!;
    // websiteController.text = globalWebsite!;
    // facebookController.text = globalFacebook!;
    // instagramController.text = globalInstagram!;
    // bioController.text = globalBio!;
    // countryController.text = globalCountry!;
    displayNameController.text = user.displayName;
    websiteController.text = user.website;
    facebookController.text = user.facebook;
    instagramController.text = user.instagram;
    bioController.text = user.bio;
    countryController.text = globalCountry!;


    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: TextField(
            maxLength: 50,
            controller: displayNameController,
            decoration: InputDecoration(
              hintText: "Update Display Name",
              errorText: _displayNameValid ? null : "Display Name too short",
              border: InputBorder.none,
              label: const Text('Name'),
            ),
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: TextField(
            maxLength: 255,
            maxLines: 4,
            minLines: 1,
            controller: bioController,
            decoration: InputDecoration(
              hintText: "Update Bio",
              label: const Text('Bio'),
              errorText: _bioValid ? null : "Bio too long",
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  Column buildWebsiteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: TextField(
            controller: websiteController,
            decoration: InputDecoration(
              hintText: "Update Website Link",
              label: const Text('Website'),
              errorText: _websiteValid ? null : "Website link too long",
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  Column buildInstagramField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: TextField(
            controller: instagramController,
            decoration: InputDecoration(
              hintText: "Update Instagram Profile Link",
              label: const Text('Instagram Profile'),
              errorText:
                  _instagramValid ? null : "Instagram profile link too long",
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  Column buildFacebookField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: TextField(
            controller: facebookController,
            decoration: InputDecoration(
              hintText: "Update Facebook Profile Link",
              label: const Text('Facebook Profile'),
              errorText:
                  _facebookValid ? null : "Facebook profile link too long",
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  Column buildCountryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: TextField(
            controller: countryController,
            decoration: InputDecoration(
              hintText: "Update Country",
              label: const Text('Country'),
              errorText: _countryValid ? null : "Bio too long",
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  Column buildPhonenumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: TextField(
            controller: phoneController,
            decoration: InputDecoration(
              hintText: "Update Phone Number",
              label: const Text('Phone Number'),
              errorText: _phoneValid ? null : "Bio too long",
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  updateProfileData() async {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 250
          ? _bioValid = false
          : _bioValid = true;
      websiteController.text.trim().length > 100
          ? _websiteValid = false
          : _websiteValid = true;
      instagramController.text.trim().length > 100
          ? _instagramValid = false
          : _instagramValid = true;
      facebookController.text.trim().length > 100
          ? _facebookValid = false
          : _facebookValid = true;
      // phoneController.text.trim().length < 7
      //     ? _displayNameValid = false
      //     : _displayNameValid = true;
    });

    if (_displayNameValid && _bioValid) {
      usersRef.doc(widget.currentUserId).update({
        "displayName": displayNameController.text,
        "bio": bioController.text,
        "website": websiteController.text,
        "instagram": instagramController.text,
        "facebook": facebookController.text,
        "country": countryController.text
      });

      SnackBar snackbar = const SnackBar(content: Text("Profile updated!",),
      duration: Duration(seconds: 2),);
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  Future getavatarImage() async {
    final newImageFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      imageFileAvatar = imageFileAvatar;
      if (newImageFile != null) {
        imageFileAvatar = File(newImageFile.path);
        // print(newImageFile.path);
      } else {
        // print('No image selected.');
      }
    });

    uploadAvatar(imageFileAvatar);
  }

  Future deleteAvatar() async {
    try {
      await FirebaseStorage.instance.refFromURL(imageFileAvatarUrl!).delete();
      SnackBar snackbar =
          const SnackBar(content: Text("Profile Photo deleted!"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } catch (e) {
      print("Error deleting db from cloud: $e");
    }
  }

  Future uploadAvatar(imageFileAvatar) async {
    String? mFileName = globalID;
    Reference storageReference =
        FirebaseStorage.instance.ref().child("avatar_$mFileName.jpg");
    UploadTask storageUploadTask = storageReference.putFile(imageFileAvatar!);
    String downloadUrl = await (await storageUploadTask).ref.getDownloadURL();
    imageFileAvatarUrl = downloadUrl;
    setState(() {
      isLoading = false;
      usersRef
          .doc(widget.currentUserId)
          .update({"photoUrl": imageFileAvatarUrl});

      SnackBar snackbar =
          const SnackBar(content: Text("Profile Photo updated!"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });
  }

  Future getcoverImage() async {
    final newImageFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      imageFileCover = imageFileCover;
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
    String? mFileName = globalID;
    Reference storageReference =
        FirebaseStorage.instance.ref().child("cover_$mFileName.jpg");
    UploadTask storageUploadTask = storageReference.putFile(imageFileCover!);
    String downloadUrl = await (await storageUploadTask).ref.getDownloadURL();
    imageFileCoverUrl = downloadUrl;
    setState(() {
      isLoading = false;
      usersRef
          .doc(widget.currentUserId)
          .update({"coverUrl": imageFileCoverUrl});

      SnackBar snackbar = const SnackBar(content: Text("Cover Photo updated!"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        iconTheme: IconThemeData(
            color: Theme.of(context).appBarTheme.iconTheme!.color),
        title: Text(
          "Edit Profile",
          style: Theme.of(context).textTheme.headline5!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: () => updateProfileData(),
              child: Text(
                'Save',
                style: TextStyle(
                    color: const Color.fromARGB(255, 57, 86, 156),
                    fontWeight: FontWeight.bold),
              ))
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Stack(
                      children: [
                        SizedBox(
                          height: 250,
                          child: Stack(
                            children: <Widget>[
                              (imageFileCover == null)
                                  ? (user.coverUrl != "")
                                      ? Material(
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) =>
                                                Container(
                                              child:
                                                  const CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        const Color.fromARGB(
                                                            255, 90, 200, 250)),
                                              ),
                                              height: 200.0,
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                            ),
                                            imageUrl: user.coverUrl,
                                            width: double.infinity,
                                            height: 200.0,
                                            fit: BoxFit.cover,
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                        )
                                      : Image.asset(
                                          'assets/images/defaultcover.png',
                                          alignment: Alignment.center,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          height: 200,
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
                              Positioned(
                                  bottom: 30,
                                  right: 10,
                                  child: SvgPicture.asset(
                                    'assets/images/photo.svg',
                                    width: 40,
                                  ).onTap(() {
                                    getcoverImage();
                                  }))
                            ],
                          ),
                          width: double.infinity,
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Center(
                            child: Stack(
                              children: <Widget>[
                                (imageFileAvatar == null)
                                    ? (user.photoUrl != "")
                                        ? Material(
                                            child: CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Container(
                                                child:
                                                    const CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Colors
                                                              .deepPurpleAccent),
                                                ),
                                                width: 120.0,
                                                height: 120.0,
                                                padding:
                                                    const EdgeInsets.all(20.0),
                                              ),
                                              imageUrl: user.photoUrl,
                                              width: 120.0,
                                              height: 120.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(15.0)),
                                            clipBehavior: Clip.hardEdge,
                                          )
                                        : Container(
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
                                IconButton(
                                  alignment: Alignment.bottomRight,
                                  color: const Color.fromARGB(255, 57, 86, 156),
                                  icon: SvgPicture.asset(
                                    'assets/images/photo.svg',
                                    width: 40,
                                  ),
                                  onPressed: getavatarImage,
                                  padding: const EdgeInsets.all(0.0),
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.grey,
                                  iconSize: 130,
                                ),
                                // IconButton(
                                //   alignment: Alignment.bottomLeft,
                                //   color: const Color.fromARGB(255, 57, 86, 156),
                                //   icon: SvgPicture.asset(
                                //     'assets/images/cross.svg',
                                //     width: 25,
                                //   ),
                                //   onPressed: deleteAvatar,
                                //   padding: const EdgeInsets.all(0.0),
                                //   splashColor: Colors.transparent,
                                //   highlightColor: Colors.grey,
                                //   iconSize: 130,
                                // )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            height: 50,
                            alignment: Alignment.centerLeft,
                            color: Theme.of(context).shadowColor,
                            child: const Padding(
                              padding: EdgeInsets.all(14.0),
                              child: Text(
                                'Profile Info',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                          buildDisplayNameField(),
                          const Divider(
                            thickness: 2,
                          ),
                          buildBioField(),
                          const Divider(
                            thickness: 2,
                          ),
                          buildWebsiteField(),
                          const Divider(
                            thickness: 2,
                          ),
                          buildInstagramField(),
                          const Divider(
                            thickness: 2,
                          ),
                          buildFacebookField(),
                          const Divider(
                            thickness: 2,
                          ),
                          buildCountryField(),
                          const Divider(
                            thickness: 2,
                          ),
                          // buildPhonenumberField(),
                          // const Divider(
                          //   thickness: 2,
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ],
            ),
    );
  }
}
