import 'package:dispute/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TweetWidget extends StatelessWidget {
  final String avatar;
  final String pseudonym;
  final String pubkey;
  final int timestamp;
  final String text;

  const TweetWidget({
    super.key,
    required this.avatar,
    required this.pseudonym,
    required this.pubkey,
    required this.timestamp,
    required this.text,
  });

  String timeAgo(int secondsUnixTimestamp) {
    final timestamp =
        DateTime.fromMillisecondsSinceEpoch(secondsUnixTimestamp * 1000);
    final duration = DateTime.now().difference(timestamp);
    String timeAgo;
    if (duration.inDays > 365) {
      timeAgo = '${(duration.inDays / 365).floor()} years ago';
    } else if (duration.inDays > 30) {
      timeAgo = '${(duration.inDays / 30).floor()} months ago';
    } else if (duration.inDays > 7) {
      timeAgo = '${(duration.inDays / 7).floor()} weeks ago';
    } else if (duration.inDays > 1) {
      timeAgo = '${duration.inDays} days ago';
    } else if (duration.inHours > 1) {
      timeAgo = '${duration.inHours} hours ago';
    } else if (duration.inMinutes > 1) {
      timeAgo = '${duration.inMinutes} minutes ago';
    } else {
      timeAgo = '${duration.inSeconds} seconds ago';
    }
    return timeAgo;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.teal,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(10.0),
              child: InkWell(
                child: const CircleAvatar(
                    // FIXME: backgroundImage: NetworkImage(avatar),
                    ),
                onTap: () {
                  displaySnackBar(context, "Soon In sha'Allah");
                },
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 5.0),
                        child: InkWell(
                          child: Text(pubkey.substring(0, 8)),
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: pubkey));
                            displaySnackBar(
                                context, 'Copied to clipboard: $pubkey');
                          },
                        ),
                      ),
                      Text(
                        '@$pseudonym · ${timeAgo(timestamp)}',
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.sailing,
                          size: 14.0,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          displaySnackBar(
                            context,
                            "I'm useless for the moment",
                          );
                        },
                      ),
                    ],
                  ),
                  SelectableText(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
