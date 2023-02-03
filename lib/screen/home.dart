import 'package:dispute/model/profile.dart';
import 'package:dispute/screen/event.dart';
import 'package:dispute/screen/profil.dart';
import 'package:dispute/widget/the_wall.dart';
import 'package:dispute/utils.dart';
import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String projectUrl = 'https://github.com/ethicnology/dispute';
    final profil = context.watch<Profile>();
    profil.init();
    profil.channel.sink.add(
      Request(generate64RandomHexChars(), [
        Filter(
          kinds: [1],
          since: currentUnixTimestampSeconds() - 86400,
        )
      ]).serialize(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('nostr dispute'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Divider(),
            const Padding(
              padding:
                  EdgeInsets.only(top: 20, bottom: 25, left: 10, right: 10),
              child: SelectableText(
                'A dispute is a disagreement or argument about something. It can refer to a disagreement between individuals or groups, or it can refer to a disagreement about a specific issue or topic.',
                textAlign: TextAlign.justify,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 0,
                bottom: 25,
                left: 10,
                right: 10,
              ),
              child: InkWell(
                child: Text(projectUrl),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: projectUrl));
                  displaySnackBar(context, 'copied to clipboard: $projectUrl');
                },
              ),
            ),
            TheWallWidget(channel: profil.channel),
          ],
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: 'Send an event',
            heroTag: "send_event",
            child: const Icon(Icons.message),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            tooltip: 'Edit your profil',
            heroTag: "profil",
            child: const Icon(Icons.vpn_key),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
