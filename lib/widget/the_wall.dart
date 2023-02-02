import 'dart:convert';

import 'package:dispute/widget/tweet.dart';
import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TheWallWidget extends StatefulWidget {
  final WebSocketChannel channel;

  const TheWallWidget({super.key, required this.channel});

  @override
  TheWallState createState() => TheWallState();
}

class TheWallState extends State<TheWallWidget> {
  final List<Event> events = [];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder(
            stream: widget.channel.stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return const Text('Waiting for data...');
              }
              var data = jsonDecode(snapshot.data);
              if (data[0] == "EVENT") {
                events.add(Event.fromJson(data[2], subscriptionId: data[1]));
                events.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                //                 String log = '''
                // id     : ${data[2]['id']}
                // kind   : ${data[2]['kind']}
                // content: ${data[2]['content']}
                // loaded : ${events.length}
                //  ''';
                //                 logger.d(log);
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return TweetWidget(
                    avatar: '',
                    pseudonym: 'NotSupportedYet',
                    pubkey: events[index].pubkey,
                    timestamp: events[index].createdAt,
                    text: events[index].content,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
