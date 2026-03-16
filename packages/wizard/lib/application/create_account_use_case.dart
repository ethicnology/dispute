import '../domain/account_entity.dart';
import 'account_port.dart';

class CreateAccountUseCase {
  const CreateAccountUseCase({required this.accountPort});

  final AccountPort accountPort;

  Future<AccountEntity> execute({required AccountEntity account}) async {
    await accountPort.store(account);
    return account;
  }
}
