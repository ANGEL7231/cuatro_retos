import 'package:cuatro_retos/datos/config_claves.dart';
import 'package:cuatro_retos/dominio/excepciones.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConfigClaves', () {
    test('toString nunca imprime las claves completas', () {
      const c = ConfigClaves(tmdb: 'abcdef123456', openWeather: 'zyxwvu987654');
      expect(c.toString(), isNot(contains('abcdef123456')));
      expect(c.toString(), isNot(contains('zyxwvu987654')));
      expect(c.toString(), contains('ab***56'));
    });

    test('claves muy cortas se ocultan por completo', () {
      expect(const ConfigClaves(tmdb: 'abc').toString(), contains('****'));
    });

    test('clave vacía o con espacios lanza ClaveFaltanteException con su nombre', () {
      expect(() => const ConfigClaves().tmdbValida,
          throwsA(isA<ClaveFaltanteException>().having((e) => e.nombre, 'nombre', 'TMDB_API_KEY')));
      expect(() => const ConfigClaves(openWeather: '  ').openWeatherValida,
          throwsA(isA<ClaveFaltanteException>().having((e) => e.nombre, 'nombre', 'OPENWEATHER_API_KEY')));
    });

    test('una clave válida se devuelve sin espacios', () {
      expect(const ConfigClaves(tmdb: ' K ').tmdbValida, 'K');
    });
  });

  group('mensajeSeguro', () {
    test('errores de la app muestran su mensaje', () {
      expect(mensajeSeguro(const SinConexionException()), contains('conexión'));
    });

    test('errores inesperados NO filtran detalles internos', () {
      final msg = mensajeSeguro(StateError('clave=SECRETO en /home/usuario/app'));
      expect(msg, isNot(contains('SECRETO')));
      expect(msg, isNot(contains('/home')));
      expect(msg, contains('inesperado'));
    });
  });
}
