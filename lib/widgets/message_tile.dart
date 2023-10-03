import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageTile extends StatelessWidget {
  final int? index;
  final String? message;
  final int? time;
  final String? sender;
  final bool? sentByMe;

  const MessageTile({
    Key? key,
    this.message,
    this.sender,
    this.sentByMe,
    this.time,
    this.index,
  }) : super(key: key);

  Widget buildRichTextWithLinks(String text, BuildContext context) {
    final RegExp regExp = RegExp(r'https?://\S+');
    final Iterable<Match> matches = regExp.allMatches(text);

    final List<InlineSpan> children = [];

    int currentStart = 0;

    for (final match in matches) {
      final url = match.group(0)!;

      if (match.start > currentStart) {
        children.add(
          TextSpan(
            text: text.substring(currentStart, match.start),
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
              fontSize: 15,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
          ),
        );
      }

      children.add(
        TextSpan(
          text: url,
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _launchURL(url); // Open the URL
            },
        ),
      );

      currentStart = match.end;
    }

    if (currentStart < text.length) {
      children.add(
        TextSpan(
          text: text.substring(currentStart),
          style: Theme.of(context).textTheme.subtitle2!.copyWith(
            fontSize: 15,
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: children),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: sentByMe! ? 0 : 24,
        right: sentByMe! ? 24 : 0,
      ),
      alignment: sentByMe! ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: sentByMe!
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 10,
          right: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: sentByMe!
              ? Theme.of(context).secondaryHeaderColor
              : Theme.of(context).secondaryHeaderColor,
        ),
        child: Column(
          crossAxisAlignment:
          sentByMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            sentByMe!
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Stack(
                  children: [
                    buildRichTextWithLinks(message!, context),
                  ],
                ),
                Text(
                  DateFormat('kk:mm').format(
                    DateTime.fromMillisecondsSinceEpoch(
                      int.parse(time.toString()),
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  sender!.toUpperCase(),
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 7.0),
                buildRichTextWithLinks(message!, context),
                Text(
                  DateFormat('kk:mm').format(
                    DateTime.fromMillisecondsSinceEpoch(
                      int.parse(time.toString()),
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
