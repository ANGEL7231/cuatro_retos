import 'package:flutter/foundation.dart';

import '../datos/servicios.dart';
import '../dominio/excepciones.dart';
import '../dominio/modelos.dart';
import 'carga.dart';

/// Reto 1
class PeliculasViewModel extends ChangeNotifier {
  final ServicioPeliculas _s;
  PeliculasViewModel(this._s);

  Animo animo = Animo.feliz;
  Carga<Pelicula> pelicula = const Carga.inicial();

  void elegirAnimo(Animo a) {
    animo = a;
    notifyListeners();
  }

  Future<void> sorprender() async {
    pelicula = const Carga.cargando();
    notifyListeners();
    pelicula = await capturar(() => _s.sorprender(animo));
    notifyListeners();
  }
}

/// Reto 2
class GatosViewModel extends ChangeNotifier {
  String _texto = '';
  int _semilla = 0;
  FiltroGato filtro = FiltroGato.ninguno;
  String? error;
  Uri uri = ConstructorGato.construir();

  String get texto => _texto;

  /// Valida la frase; si es inválida conserva el gato anterior y muestra el error.
  void aplicarTexto(String t) {
    try {
      uri = ConstructorGato.construir(texto: t, filtro: filtro, semilla: _semilla);
      _texto = t.trim();
      error = null;
    } catch (e) {
      error = mensajeSeguro(e);
    }
    notifyListeners();
  }

  void elegirFiltro(FiltroGato f) {
    filtro = f;
    _reconstruir();
  }

  void otroGato() {
    _semilla++;
    _reconstruir();
  }

  void _reconstruir() {
    uri = ConstructorGato.construir(texto: _texto, filtro: filtro, semilla: _semilla);
    error = null;
    notifyListeners();
  }
}

/// Reto 3
class ClimaViewModel extends ChangeNotifier {
  final ServicioClima _s;
  ClimaViewModel(this._s);

  String ciudad = 'Dolores Hidalgo';
  Carga<ClimaCiudad> clima = const Carga.inicial();

  Future<void> buscar([String? nueva]) async {
    if (nueva != null) ciudad = nueva;
    clima = const Carga.cargando();
    notifyListeners();
    clima = await capturar(() => _s.porCiudad(ciudad));
    notifyListeners();
  }
}

/// Reto 4
class CriptoViewModel extends ChangeNotifier {
  final ServicioCripto _s;
  CriptoViewModel(this._s);

  Carga<PreciosCripto> precios = const Carga.inicial();
  double? _monto;
  String? errorMonto;

  Future<void> cargar() async {
    precios = const Carga.cargando();
    notifyListeners();
    precios = await capturar(() => _s.precios());
    notifyListeners();
  }

  void cambiarMonto(String texto) {
    if (texto.trim().isEmpty) {
      _monto = null;
      errorMonto = null;
    } else {
      try {
        _monto = parsearMontoUsd(texto);
        errorMonto = null;
      } catch (e) {
        _monto = null;
        errorMonto = mensajeSeguro(e);
      }
    }
    notifyListeners();
  }

  /// null si aún no hay precios o el monto no es válido.
  double? fraccion(Moneda m) {
    final p = precios.dato;
    final monto = _monto;
    if (p == null || monto == null) return null;
    return p.fraccion(m, monto);
  }
}
