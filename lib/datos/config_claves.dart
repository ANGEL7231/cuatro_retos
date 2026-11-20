import '../dominio/excepciones.dart';

/// Las claves NUNCA se escriben en el código. Entran al compilar:
///   flutter run --dart-define-from-file=secrets.json
class ConfigClaves {
  final String tmdb;
  final String openWeather;
  const ConfigClaves({this.tmdb = '', this.openWeather = ''});

  factory ConfigClaves.desdeEntorno() => const ConfigClaves(
        tmdb: String.fromEnvironment('TMDB_API_KEY'),
        openWeather: String.fromEnvironment('OPENWEATHER_API_KEY'),
      );

  /// Devuelve la clave o lanza ClaveFaltanteException ANTES de pedir nada.
  String get tmdbValida => _requerir(tmdb, 'TMDB_API_KEY');
  String get openWeatherValida => _requerir(openWeather, 'OPENWEATHER_API_KEY');

  static String _requerir(String valor, String nombre) {
    if (valor.trim().isEmpty) throw ClaveFaltanteException(nombre);
    return valor.trim();
  }

  /// Si alguien imprime esta clase por accidente, las claves no se filtran.
  @override
  String toString() =>
      'ConfigClaves(tmdb: ${_ocultar(tmdb)}, openWeather: ${_ocultar(openWeather)})';

  static String _ocultar(String s) =>
      s.length <= 4 ? '****' : '${s.substring(0, 2)}***${s.substring(s.length - 2)}';
}
