// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soXialz/pages/home.dart';
import 'package:soXialz/widgets/bezier_container.dart';
import 'package:soXialz/widgets/progress.dart';
import 'package:soXialz/widgets/simple_world_widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class AddCreditToAccount extends StatefulWidget {
  final String? userId;

  const AddCreditToAccount({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  _AddCreditToAccountState createState() => _AddCreditToAccountState();
}

class _AddCreditToAccountState extends State<AddCreditToAccount> {
  final _formkey = GlobalKey<FormState>();
  String? username;
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getcurrentusername();
    addcredit();
  }

  getcurrentusername() async {
    usersRef.doc(globalID).get().then(
          (value) => setState(() {
            username = value["username"];
          }),
        );
  }

  addcredit() async {
    usersRef.doc(globalID).update({
      "credit_points": 500,
    });
  }

  submit() {
    Timer(const Duration(seconds: 0), () {
      Navigator.pop(context);
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => Home(
            userId: globalID,
          ),
        ),
      );
    });
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Welcome $username!',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headline4,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color.fromARGB(255, 57, 86, 156),
                const Color.fromARGB(255, 57, 86, 156)
              ])),
      child: const Text(
        'Continue',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    ).onTap(() {
      submit();
    });
  }

  @override
  Widget build(BuildContext parentContext) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SizedBox(
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned(
              top: -height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: const BezierContainer()),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .25),
                  _title(),
                  Text(
                    'You have received 500 credit points \n  as a welcome gift',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    child: Image.asset('assets/images/getcredit.png',
                        width: context.width(),
                        height: context.height() * 0.5,
                        fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 20),
                  _submitButton(),
                ],
              ),
            ),
          ),
          isLoading == true ? Center(child: circularProgress()) : Container(),
        ],
      ),
    ));
  }
}
