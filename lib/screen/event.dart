import 'dart:convert';
import 'dart:io';

import 'package:dispute/main.dart';
import 'package:dispute/model/profile.dart';
import 'package:dispute/utils.dart';
import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:provider/provider.dart';

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
    bool sent = false;
    if (wsEvent.isNotEmpty) {
      var json = jsonDecode(wsEvent);
      if (json[0] == "OK" && json[2] == true) {
        logger.w(json);
        sent = true;
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
                    border: OutlineInputBorder(),
                    hintText: 'Write your message',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (profil.keys.private.length == 64) {
                        Event event = Event.from(
                          kind: 1,
                          tags: [],
                          content: _controller.text,
                          privkey: profil.keys.private,
                        );
                        WebSocket webSocket = await WebSocket.connect(
                          profil.relay,
                        );
                        webSocket.add(event.serialize());
                        await Future.delayed(const Duration(seconds: 1));
                        webSocket.listen((event) {
                          setState(() {
                            wsEvent = event;
                          });
                        });
                        await webSocket.close();
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
                if (sent) const Text('Sent !')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
