import 'package:flutter/material.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({Key? key});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tournament'),
      ),
    );
  }
}
