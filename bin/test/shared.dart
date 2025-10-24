import 'dart:convert';

String encodeBase64(String text) {
  return base64Encode(utf8.encode(text));
} 

String decodeBase64(String encoded) {
  return utf8.decode(base64Decode(encoded));
}