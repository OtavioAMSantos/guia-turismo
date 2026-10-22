import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  bool modoEscuro = false;

  // o MaterialApp lê esse valor pra saber qual tema usar
  ThemeMode get temaAtual => modoEscuro ? ThemeMode.dark : ThemeMode.light;

  // inverte o valor (true vira false e false vira true) e avisa a tela
  void alternarTema() {
    modoEscuro = !modoEscuro;
    notifyListeners();
  }
}
