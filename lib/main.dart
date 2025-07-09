import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app_config.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Wokytoky',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppConfig.backgroundColor,
          fontFamily: 'Roboto',
        ),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _login = TextEditingController();
  final _pass  = TextEditingController();

  bool   _loggedIn = false;
  String _status   = '';

  static const _logoAsset       = 'assets/images/woky.png';
  static const _logoCenterY     = 0.25;
  static const _logoWidthFrac   = 0.67;
  static const _cardWidthFrac   = 0.90;

  Future<void> _logIn() async {
    setState(() { _status = 'Connecting…'; });

    final uri  = Uri.parse('https://woky.to:12345/_matrix/client/v3/login');
    final body = jsonEncode({
      'type': 'm.login.password',
      'identifier': {'type': 'm.id.user', 'user': _login.text.trim()},
      'password': _pass.text,
    });

    try {
      final r = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (r.statusCode == 200) {
        _loggedIn = true;
      } else {
        _status = 'HTTP ${r.statusCode}';
      }
    } catch (e) {
      _status = 'FAIL • $e';
    }

    setState(() {});       // перерисовать
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: const FractionalOffset(0.5, _logoCenterY),
            child: Image.asset(
              _logoAsset,
              width: screen.width * _logoWidthFrac,
              fit: BoxFit.contain,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: _card(
              width: screen.width * _cardWidthFrac,
              child: _loggedIn
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'login successful!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _inputField(controller: _login, hint: 'Login'),
                        const SizedBox(height: 12),
                        _inputField(
                            controller: _pass,
                            hint: 'Password',
                            obscure: true),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _inputButton('Sign Up', () {/* TODO */}),
                            _inputButton('Log In', _logIn),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(_status, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /* ───────── helpers ───────── */

  Widget _card({required double width, required Widget child}) => Material(
        elevation: 2,
        color: AppConfig.cardBackground,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppConfig.borderMain),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(width: width, child: Padding(padding: const EdgeInsets.all(16), child: child)),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) =>
      TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(height: 1.1, color: AppConfig.textMain),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppConfig.bgInput,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

  Widget _inputButton(String label, VoidCallback onTap) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.btnColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  @override
  void dispose() {
    _login.dispose();
    _pass.dispose();
    super.dispose();
  }
}
