import 'relay_view.dart';

class AccountView {
  const AccountView({
    required this.npub,
    required this.name,
    required this.relays,
  });

  final String npub;
  final String name;
  final List<RelayView> relays;
}
