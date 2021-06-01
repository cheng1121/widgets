import 'package:flutter/foundation.dart';

void main() async {
  final String reuslt = await compute<String, String>(_callback, 'hello world');

  print('result: $reuslt');
}

String _callback(String msg) {
  print('msg ====$msg');
  final List<String> m =
      List<String>.generate(msg.length, (int index) => msg[index]);
  return m.map((String e) => e.padLeft(2, ' ')).toList().join();
}
