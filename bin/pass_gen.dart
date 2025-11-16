import 'test/crypto_template.dart';
import 'test/encrypt_password.dart';

void main() async{
  // Для теста crypto_template.dart раскомментировать
  // testCryptoTemplate();

  // Для теста encrypt_template.dart раскомментировать
  // testEncryptTemplate();

  final psswd = EncryptedPassword();
  final encr = await psswd.getEncr(message: [1, 2, 1, 2, 1, 2, 1, 2], passwd: [1, 2]);
  final mssg = await psswd.getDeEncr(passwd: [1, 2]);

  print('$encr, $mssg');
}

void printFormatString(String text){
  String space = '-'*60;
  String spaceBefore = '$space\n';
  String spaceAfter = '\n$space\n';
  print('$spaceBefore$text$spaceAfter');
}

void testCryptoTemplate(){
  EncryptedConfig config = EncryptedConfig();
  printFormatString('$config');
  printFormatString('config: ${config.getConfigMini()}');
  printFormatString('isExpired: ${config.isExpired()}');
  printFormatString('upToDateLUD: ${config.lastUsageDate}');
  printFormatString('upToDateUUID: ${config.uuid}');
  printFormatString('getDateFromUUID: ${config.getDateFromUUID()}');
  printFormatString('getConfigJSON: ${config.getConfigJSON()}');
  printFormatString('${EncryptedConfig().getConfigFromMini(config.getConfigMini())}');
}

// void testEncryptTemplate() async{
//   HashGenerator generator = HashGenerator(strength: HashStrength.high);
//   List<int> hash = await generator.getHash(cipherText: []);
//   print('$hash');
// }