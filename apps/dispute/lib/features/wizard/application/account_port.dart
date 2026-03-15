import '../domain/account_entity.dart';

abstract class AccountPort {
  Future<void> store(AccountEntity account);
  Future<List<AccountEntity>> fetchAll();
  Future<bool> hasAny();
}
