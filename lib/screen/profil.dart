import 'package:dispute/main.dart';
import 'package:dispute/model/profile.dart';
import 'package:dispute/screen/home.dart';
import 'package:dispute/utils.dart';
import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../constants/constants.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  ProfilScreenState createState() => ProfilScreenState();
}

class ProfilScreenState extends State<ProfilScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController privkeyInput = TextEditingController();
  TextEditingController pubkeyInput = TextEditingController();
  TextEditingController relayInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final profil = context.watch<Profile>();
    relayInput.text = profil.relay;
    privkeyInput.text = profil.keys.private;
    pubkeyInput.text = profil.keys.public;

    int setColor() {
      var pubKeyChars = pubkeyInput.text.substring(0, 6);
      var color = '0xff';
      var result = '$color$pubKeyChars';
      return int.parse(result);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(children: [
              SizedBox(
                width: 200,
                height: 200,
                child: FittedBox(
                  child: ClipOval(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(setColor()),
                      ),
                      child: Image.network(
                          '$avatarUrl${pubkeyInput.text}.png?$imagesize',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                        debugPrint(error.toString());
                        return const SizedBox.shrink();
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 7,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  pubkeyInput.text.substring(0, 8),
                  textScaleFactor: 1.4,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: privkeyInput,
                      decoration: const InputDecoration(
                        labelText: 'Private Key',
                        border: OutlineInputBorder(),
                        hintText:
                            "5ee1c8000ab28edd64d74a7d951ac2dd559814887b1b9e1ac7c5f89e96125c12",
                      ),
                      maxLength: 64,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Fill it with your own private key, hex encoded';
                        }
                        if (value.length != 64) {
                          return 'Hex encoded private key should be 64 chars long';
                        }
                        try {
                          Keychain(value);
                        } catch (e) {
                          String error =
                              "Private key not supported because of a bug in dart-bip340, github issue copied to your clipboard \nPlease try another one";
                          logger.e(error);
                          displaySnackBar(context, error);
                          Clipboard.setData(
                            const ClipboardData(
                              text:
                                  'https://github.com/nbd-wtf/dart-bip340/issues/4',
                            ),
                          );
                        }
                        return null;
                      },
                      onFieldSubmitted: (value) {
                        formKey.currentState!.validate();
                      },
                    ),
                    if (pubkeyInput.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                          bottom: 45,
                        ),
                        child: InkWell(
                          child: TextFormField(
                            controller: pubkeyInput,
                            enabled: false,
                            keyboardType: TextInputType.url,
                            decoration: const InputDecoration(
                              labelText: 'Public Key',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: pubkeyInput.text));
                            displaySnackBar(context,
                                'Copied to clipboard: ${pubkeyInput.text}');
                          },
                        ),
                      ),
                    TextFormField(
                      controller: relayInput,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Relay',
                        border: OutlineInputBorder(),
                        hintText: 'wss://nostr.sandwich.farm',
                      ),
                      validator: (value) {
                        if (!RegExp(r'^(ws|wss)://').hasMatch(value!)) {
                          return 'WebSocket URL invalid';
                        }
                        return null;
                      },
                      onFieldSubmitted: (value) {
                        formKey.currentState!.validate();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonBackgroundColor,
                          minimumSize: const Size(100, 50),
                          maximumSize: const Size(100, 50),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            profil.keys = Keychain(privkeyInput.text);
                            pubkeyInput.text = profil.keys.public; // update UI
                            profil.relay = relayInput.text;
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const HomeScreen()));
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
