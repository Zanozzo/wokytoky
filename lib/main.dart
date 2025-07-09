// main.dart
// ----------------------------------------------------
// Логотип + карточка авторизации (адаптивная).
// При нажатии “Log In” выполняется авторизация на Matrix-сервере
// woky.to:12345 через SDK *matrix 1.0.x*.
// Сохранение на диске и Sembast убраны — берём простое
// in-memory-хранилище MemoryStore, которого для демо вполне достаточно.
// ----------------------------------------------------

import 'package:flutter/material.dart';
import 'app_config.dart';

// Matrix SDK
import 'package:matrix/matrix.dart' as mx;

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
  /* ────────── UI ────────── */

  static const _logo       = 'assets/images/woky.png';
  static const _logoY      = 0.25;   // центр логотипа – 25 % высоты
  static const _logoWFrac  = 0.67;   // 67 % ширины
  static const _cardWFrac  = 0.90;   // карточка – 90 % ширины

  final _login = TextEditingController();
  final _pass  = TextEditingController();

  /* ────────── Matrix ────────── */

  late final mx.Client _client;

  @override
  void initState() {
    super.initState();

    // самый простой in-memory store — никаких зависимостей на path_provider
    _client = mx.Client(
      Uri.parse('https://woky.to:12345'),
      store: mx.MemoryStore(),     // обязательный параметр в 1.0.x
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          /* логотип */
          Align(
            alignment: const FractionalOffset(0.5, _logoY),
            child: Image.asset(
              _logo,
              width: size.width * _logoWFrac,
              fit: BoxFit.contain,
            ),
          ),

          /* карточка */
          Align(
            alignment: Alignment.center,
            child: Material(
              elevation: 2,
              color: AppConfig.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(width: 1, color: AppConfig.borderMain),
              ),
              child: SizedBox(
                width: size.width * _cardWFrac,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,          // адаптивная высота
                    children: [
                      _inputField(_login, 'Login'),
                      const SizedBox(height: 12),
                      _inputField(_pass, 'Password', obscure: true),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _button('Sign Up', () {/* TODO */}),
                          _button('Log In', _loginMatrix),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ────────── Matrix login ────────── */
  Future<void> _loginMatrix() async {
    final user = _login.text.trim();
    final pwd  = _pass.text;
    if (user.isEmpty || pwd.isEmpty) return;

    try {
      // 1) проверяем homeserver (обязательное требование SDK)
      await _client.checkHomeserver(_client.homeserver);

      // 2) логинимся паролем
      await _client.login(
        mx.LoginType.mLoginPassword,
        password: pwd,
        identifier: mx.AuthenticationUserIdentifier(user: user),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in ✅')),
      );
      // TODO: переход к списку комнат
    } on mx.MatrixException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Matrix error: ${e.error}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    }
  }

  /* ────────── helpers ────────── */

  Widget _inputField(TextEditingController c, String hint,
          {bool obscure = false}) =>
      TextField(
        controller: c,
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

  Widget _button(String label, VoidCallback onTap) => ElevatedButton(
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
    _client.dispose();      // корректное закрытие MemoryStore
    super.dispose();
  }
}
