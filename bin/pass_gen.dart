import 'test/crypto_template.dart';
import 'test/encrypt_template.dart';

void main() {
  // // Для теста crypto_template.dart раскомментировать
  // testCryptoTemplate();

  // Для теста encrypt_template.dart раскомментировать
  testEncryptTemplate();
}

void printFormatString(String text){
  String space = '-'*60;
  String spaceBefore = '$space\n';
  String spaceAfter = '\n$space\n';
  print('$spaceBefore$text$spaceAfter');
}

void testCryptoTemplate(){
  dynamic config = EncryptedConfig();
  printFormatString('config: ${config.getConfigMini()}');
  printFormatString('isExpired: ${config.isExpired()}');
  printFormatString('upToDateLUD: ${config.upToDateLUD()}');
  printFormatString('upToDateUUID: ${config.upToDateUUID()}');
  printFormatString('getDateFromUUID: ${config.getDateFromUUID()}');
  printFormatString('getConfigJSON: ${config.getConfigJSON()}');
  printFormatString('${EncryptedConfig().getConfigFromMini(config.getConfigMini()).getConfigJSON()}');
}

void testEncryptTemplate() async{
  HashGenerator generator = HashGenerator(strength: HashStrength.high);
  String hash = await generator.getHash(hashedPassword: 'hashedPassword', salt: 'salt');
  print(hash);
}