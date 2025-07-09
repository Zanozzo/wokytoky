// app_config.dart
// ----------------------------------------------------
// Центральные константы проекта Wokytoky
// (цвета взяты из вашего “другого проекта”).
// ----------------------------------------------------

import 'package:flutter/material.dart';

class AppConfig {
  /* ═══════════════  COLOURS  ═══════════════ */

  /// Базовый фон всего экрана
  static const Color backgroundColor = Color(0xFFFDF8F4); // bgMain

  /// Рамки, линии
  static const Color borderMain = Color.fromARGB(255, 253, 239, 227);

  /// Основной цвет текста
  static const Color textMain = Color(0xFF444444);

  /// Цвет фона карточек (≈ 15 % темнее bgMain)
  static const Color cardBackground = Color.fromARGB(255, 213, 255, 246);

  /// Цвет фона инпут-полей (≈ 10 % темнее карточки)
  static const Color bgInput = Color.fromARGB(255, 203, 243, 234);

  static const Color btnColor = Color.fromARGB(255, 138, 226, 222);
}
