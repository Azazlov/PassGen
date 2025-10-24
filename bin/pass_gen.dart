import 'test/crypto_template.dart';

void main() async{
  // await getHash();
  dynamic config = EncryptConfig('');
  printFormatString('config: ${config.getConfigMini()}');
  printFormatString('isExpired: ${config.isExpired()}');
  printFormatString('upToDateLUD: ${config.upToDateLUD()}');
  printFormatString('upToDateUUID: ${config.upToDateUUID()}');
  printFormatString('getDateFromUUID: ${config.getDateFromUUID()}');
  printFormatString('getConfigJSON: ${config.getConfigJSON()}');
}

void printFormatString(String text){
  String space = '-'*60;
  String spaceBefore = '$space\n';
  String spaceAfter = '\n$space\n';
  print('$spaceBefore$text$spaceAfter');
}