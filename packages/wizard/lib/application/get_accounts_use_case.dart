import '../domain/account_entity.dart';
import 'account_port.dart';

class GetAccountsUseCase {
  const GetAccountsUseCase({required this.accountPort});

  final AccountPort accountPort;

  Future<List<AccountEntity>> execute() => accountPort.fetchAll();
}
