import 'dart:convert';
import 'dart:io';
import 'package:dispute/model/profile.dart';
import 'package:dispute/utils.dart';
import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/constants.dart';

void sendEvent(Uri relay, Event event) {
  WebSocketChannel channel = WebSocketChannel.connect(relay);
  channel.sink.add(event.serialize());
  sleep(const Duration(seconds: 1));
  channel.stream.listen((response) {
    if (response.isNotEmpty) {
      var json = jsonDecode(response);
      var msg = Message.deserialize(json);
      if (msg.type == "OK") {
      } else {
        throw Exception(msg);
      }
    } else {
      throw Exception("Empty response");
    }
  });
  channel.sink.close();
}

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  EventScreenState createState() => EventScreenState();
}

class EventScreenState extends State<EventScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<Profile>();

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
                        try {
                          sendEvent(Uri.parse(profil.relay), event);
                          displaySnackBar(context, "Event is sent");
                          Navigator.of(context).pop(false);
                        } catch (e) {
                          displaySnackBar(
                            context,
                            "Event not sent: $e",
                          );
                        }
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
