import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dispute/main.dart';
import 'package:dispute/widget/tweet.dart';
import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

var spams = HashSet<String>();

bool isSpam(Event event) {
  var toHash = utf8.encode(event.content);
  String hash = sha256.convert(toHash).toString();
  if (spams.contains(hash)) {
    logger.i("${event.id} is a filtered spam");
    return true;
  }
  spams.add(hash);
  return false;
}

class TheWallWidget extends StatefulWidget {
  final WebSocketChannel channel;

  const TheWallWidget({
    super.key,
    required this.channel,
  });

  @override
  TheWallState createState() => TheWallState();
}

class TheWallState extends State<TheWallWidget> {
  final List<Event> events = [];

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    spams.clear();
    logger.i('Connected to WebSocket');
    widget.channel.sink.add(
      Request(generate64RandomHexChars(), [
        Filter(
          kinds: [1],
          since: currentUnixTimestampSeconds() - 86400,
        )
      ]).serialize(),
    );
  }

  @override
  @protected
  @mustCallSuper
  void dispose() {
    super.dispose();
    widget.channel.sink.close();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder(
            stream: widget.channel.stream,
            builder: (context, snapshot) {
              logger.i(snapshot.connectionState);
              logger.i(snapshot.data);
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              Message msg = Message.deserialize(snapshot.data);
              if (msg.type == "EVENT") {
                Event event = msg.message;
                if (!isSpam(event)) {
                  events.add(event);
                  events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                }
              }
              logger.i(
                'events loaded: ${events.length} spams filtered: ${spams.length}',
              );

              return ListView.builder(
                shrinkWrap: true,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return TweetWidget(
                    avatar: '',
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
