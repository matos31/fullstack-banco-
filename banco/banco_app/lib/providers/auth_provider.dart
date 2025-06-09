import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  double _balance = 500.0;
  
  
  String? _username;                         // ADICIONADO
  String? get username => _username;        // ADICIONADO

  bool get isAuthenticated => _accessToken != null;
  String? get accessToken => _accessToken;
  double get balance => _balance;

  Future<void> saveToken(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', access);
    await prefs.setString('refreshToken', refresh);

    notifyListeners();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
    notifyListeners();
  }

  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  
    notifyListeners();
  }
  void setUsername(String nome) {
  _username = nome;
  notifyListeners();
}
  Future<bool> login(String cpf, String senha) async {
    final url = Uri.parse('http://192.168.1.103:8000/api/login/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cpf': cpf, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['access'], data['refresh']);
      _username = data['nome']; // <- aqui armazenamos o nome
      return true;
    }
    return false;
  }

  Future<bool> registerFull(String nome, String cpf, String email, String nascimento, String senha) async {
  final url = Uri.parse('http://192.168.1.103:8000/api/registro/');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'nome': nome,
      'cpf': cpf,
      'email': email,
      'nascimento': nascimento,
      'senha': senha,
    }),
  );

  return response.statusCode == 201;
}


  bool withdraw(double amount) {
    if (_balance >= amount) {
      _balance -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }

  void deposit(double amount) {
    _balance += amount;
    notifyListeners();
  }
 Future<Map<String, dynamic>?> fetchValoresAReceber() async {
  if (_accessToken == null) return null;

  final url = Uri.parse('http://192.168.1.103:8000/api/valores-a-receber/');
  debugPrint("📡 Chamando backend: $url");

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $_accessToken',
    },
  );

  if (response.statusCode == 200) {
    debugPrint("✅ Sucesso: ${response.body}");
    return json.decode(response.body);
  } else {
    debugPrint("❌ Erro ${response.statusCode}: ${response.body}");
    return null;
  }
}



}


