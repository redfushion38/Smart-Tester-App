import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'auth_service.dart';
import 'login_screen.dart';

class MetricsScreen extends StatefulWidget {
  @override
  _MetricsScreenState createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen> {
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _edadController = TextEditingController();
  final _bpmrController = TextEditingController();
  final _bpmaController = TextEditingController();
  final _spo2Controller = TextEditingController();
  final _vamController = TextEditingController();
  final _vo2maxController = TextEditingController();
  String _selectedGenero = 'Masculino';

    // Función para cerrar sesión
  Future<void> logout() async {
    // Aquí puedes eliminar el token (si estás usándolo en SharedPreferences o algún almacenamiento seguro)
    await removeToken();

    // Navegar a la pantalla de Login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

    // Aquí almacenamos el ID del usuario, que puede venir del token o de un almacenamiento previo.
  Future<int?> getUserId() async {
    final token = await getToken();
    if (token != null) {
      // Aquí, asumiendo que el token tiene un campo de "userId"
      final decodedToken = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(token.split('.')[1]))));
      return decodedToken['id']; // Asegúrate de que el token tenga el ID del usuario
    }
    return null;
  }

  Future<void> addMetrics() async {
    final token = await getToken();
    if (token == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No se encontró un token de autenticación.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final id = await getUserId(); // Obtén el ID del usuario desde el token
    if (id == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No se pudo obtener el ID del usuario.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://192.168.1.76:5000/api/metrics'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userID': id, // Reemplaza con el ID real del usuario
        'peso': double.tryParse(_pesoController.text) ?? 0.0,
        'altura': double.tryParse(_alturaController.text) ?? 0.0,
        'edad': int.tryParse(_edadController.text) ?? 0,
        'genero': _selectedGenero,
        'bpmr': int.tryParse(_bpmrController.text) ?? 0,
        'bpma': int.tryParse(_bpmaController.text) ?? 0,
        'spo2': int.tryParse(_spo2Controller.text) ?? 0,
        'vam': double.tryParse(_vamController.text) ?? 0.0,
        'vo2max': double.tryParse(_vo2maxController.text) ?? 0.0,
      }),
    );

    // Verificar el estado de la respuesta
  print('Código de estado de la respuesta: ${response.statusCode}');
  print('Cuerpo de la respuesta: ${response.body}');

    if (response.statusCode == 201) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Éxito'),
          content: Text('Las métricas se registraron correctamente.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No se pudieron registrar las métricas. Codigo de estado: ${response.statusCode}'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Métricas'),
        actions: [
          IconButton(onPressed: logout, icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _pesoController,
                decoration: InputDecoration(labelText: 'Peso (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _alturaController,
                decoration: InputDecoration(labelText: 'Altura (cm)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _edadController,
                decoration: InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _selectedGenero,
                decoration: InputDecoration(labelText: 'Género'),
                items: ['Masculino', 'Femenino']
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGenero = newValue!;
                  });
                },
              ),
              TextField(
                controller: _bpmrController,
                decoration: InputDecoration(labelText: 'BPMR'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _bpmaController,
                decoration: InputDecoration(labelText: 'BPMA'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _spo2Controller,
                decoration: InputDecoration(labelText: 'SPO2'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _vamController,
                decoration: InputDecoration(labelText: 'VAM (metros)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _vo2maxController,
                decoration: InputDecoration(labelText: 'VO2MAX (km)'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: addMetrics,
                child: Text('Registrar Métricas'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
