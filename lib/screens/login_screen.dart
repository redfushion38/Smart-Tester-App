import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import 'metrics_screen.dart'; // Importa el archivo de servicios de autenticación
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contraseniaController = TextEditingController();
  String _errorMessage = '';

  Future<String?> loginUser(String correo, String contrasenia) async {
    print('Iniciando solicitud de login...');
    final response = await http.post(
      Uri.parse('http://192.168.1.76:5000/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'Correo': correo,
        'Contrasenia': contrasenia,
      }),
    );
    print('Código de estado: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('Login exitoso. Respuesta: ${response.body}');
      var data = json.decode(response.body);
      return data['token']; // Retorna el token
    } else {
      print('Error: Código ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');
      throw Exception('Error al iniciar sesión');
    }
  }

  void _login() async {
    final correo = _correoController.text;
    final contrasenia = _contraseniaController.text;

    try {
      print('no se no sed');
      final token = await loginUser(correo, contrasenia);
      if (token != null) {
        await storeToken(token);
        // Almacena el token y navega a la siguiente pantalla
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Inicio de sesión exitoso')));
        // Aquí puedes almacenar el token en SharedPreferences o cualquier otro lugar seguro
        // Después, navega a la siguiente pantalla o muestra las métricas
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MetricsScreen()),
        );
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      setState(() {
        _errorMessage = 'Correo o contrasenia incorrectos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _correoController,
              decoration: InputDecoration(labelText: 'Correo'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _contraseniaController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contrasenia'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Iniciar sesión'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
              ),
              SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text('¿No tienes cuenta? Regístrate aquí'),
            ),
          ],
        ),
      ),
    );
  }
}
