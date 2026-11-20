import '../dominio/excepciones.dart';

enum Estado { inicial, cargando, listo, error }

/// Estado de UNA pantalla o tarjeta.
class Carga<T> {
  final Estado estado;
  final T? dato;
  final String? error;
  const Carga._(this.estado, this.dato, this.error);
  const Carga.inicial() : this._(Estado.inicial, null, null);
  const Carga.cargando() : this._(Estado.cargando, null, null);
  const Carga.listo(T dato) : this._(Estado.listo, dato, null);
  const Carga.fallo(String error) : this._(Estado.error, null, error);
}

/// Ejecuta una petición y la convierte en Carga. Atrapa TODO error, pero el
/// usuario solo ve mensajeSeguro(): un bug no tumba la pantalla ni filtra detalles.
Future<Carga<T>> capturar<T>(Future<T> Function() pedir) async {
  try {
    return Carga.listo(await pedir());
  } catch (e) {
    return Carga.fallo(mensajeSeguro(e));
  }
}
