import 'dart:convert';

import 'package:dispute/main.dart';
import 'package:dispute/model/profile.dart';
import 'package:dispute/utils.dart';
import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/constants.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  EventScreenState createState() => EventScreenState();
}

class EventScreenState extends State<EventScreen> {
  final TextEditingController _controller = TextEditingController();
  String wsEvent = '';

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<Profile>();
    if (wsEvent.isNotEmpty) {
      var json = jsonDecode(wsEvent);
      if (json[0] == "OK" && json[2] == true) {
        logger.w(json);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Argue'),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(100.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _controller,
                  maxLines: null,
                  decoration: const InputDecoration(
                      labelText: "Message",
                      hintText: "Write your message",
                      filled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBackgroundColor,
                      minimumSize: const Size(100, 50),
                      maximumSize: const Size(100, 50),
                    ),
                    onPressed: () async {
                      if (profil.keys.private.length == 64) {
                        Event event = Event.from(
                          kind: 1,
                          tags: [],
                          content: _controller.text,
                          privkey: profil.keys.private,
                        );
                        final channel = WebSocketChannel.connect(
                          Uri.parse(profil.relay),
                        );
                        channel.sink.add(event.serialize());
                        await Future.delayed(const Duration(seconds: 1));
                        channel.sink.close();
                        displaySnackBar(
                          context,
                          "The event is sent, go back to the wall",
                        );
                      } else {
                        displaySnackBar(
                          context,
                          'Please fill a private key in your profile',
                        );
                      }
                    },
                    child: const Text('Send'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
