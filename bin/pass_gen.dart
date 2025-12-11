import 'test/configure_password.dart';
import 'test/encrypt_password.dart';

void main() async{
  // Для теста crypto_template.dart раскомментировать
  // testCryptoTemplate();

  // Для теста encrypt_template.dart раскомментировать
  await testCryptoTemplate();
}

void printFormatString(String text){
  String space = '-'*60;
  String spaceBefore = '$space\n';
  String spaceAfter = '\n$space\n';
  print('$spaceBefore$text$spaceAfter');
}

Future<void> testCryptoTemplate() async{
  EncryptedConfig config = EncryptedConfig();
  // printFormatString('$config');
  printFormatString('config: ${config.getConfigMini()}');
  printFormatString('isExpired: ${config.isExpired()}');
  printFormatString('upToDateLUD: ${config.lastUsageDate}');
  printFormatString('upToDateUUID: ${config.uuid}');
  printFormatString('getDateFromUUID: ${config.getDateFromUUID()}');
  printFormatString('getConfigJSON: ${config.getConfigJSON()}');
  // printFormatString('${EncryptedConfig().getConfigFromMini(config.getConfigMini())}');
  final psswd = EncryptedPassword();
  final encr = await psswd.getEncr(message: [1, 2, 1, 2, 1, 2, 1, 2], passwd: [1, 2]);
  final mssg = await psswd.getDeEncr(passwd: [1, 2]);
  // final trymssg = await psswd.getDeEncr(passwd: [3, 2]); // попытка расшифровки неверным паролем
  final json = psswd.getEncrJSON();
  print(json);

  print('$encr, $mssg');
}

// void testEncryptTemplate() async{
//   HashGenerator generator = HashGenerator(strength: HashStrength.high);
//   List<int> hash = await generator.getHash(cipherText: []);
//   print('$hash');
// }