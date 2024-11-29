import 'package:shared_preferences/shared_preferences.dart';

// Para almacenar el token
Future<void> storeToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('auth_token', token);
}

// Para obtener el token
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}


Future<void> removeToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('token'); // Elimina el token almacenado
}
