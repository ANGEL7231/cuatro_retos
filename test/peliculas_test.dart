import 'package:cuatro_retos/datos/config_claves.dart';
import 'package:cuatro_retos/datos/servicios.dart';
import 'package:cuatro_retos/dominio/excepciones.dart';
import 'package:cuatro_retos/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas.dart';

void main() {
  const claves = ConfigClaves(tmdb: 'MI_CLAVE');

  group('Reto 1 · Películas (TMDB)', () {
    test('un ánimo con género usa discover con with_genres y la clave', () async {
      final s = ServicioPeliculas(
          seguro((req) async {
            expect(req.url.host, 'api.themoviedb.org');
            expect(req.url.path, '/3/discover/movie');
            expect(req.url.queryParameters['with_genres'], '35');
            expect(req.url.queryParameters['api_key'], 'MI_CLAVE');
            expect(req.url.queryParameters['language'], 'es-MX');
            return jsonOk(jsonPeliculas);
          }),
          claves);
      final r = await s.listar(Animo.feliz);
      expect(r.length, 3);
    });

    test('"tendencias" usa el endpoint trending', () async {
      final s = ServicioPeliculas(
          seguro((req) async {
            expect(req.url.path, '/3/trending/movie/week');
            expect(req.url.queryParameters.containsKey('with_genres'), false);
            return jsonOk(jsonPeliculas);
          }),
          claves);
      await s.listar(Animo.tendencias);
    });

    test('convierte póster, año y calificación', () async {
      final s = ServicioPeliculas(seguro((_) async => jsonOk(jsonPeliculas)), claves);
      final r = await s.listar(Animo.feliz);
      expect(r[0].titulo, 'Película Uno');
      expect(r[0].urlPoster, 'https://image.tmdb.org/t/p/w342/uno.jpg');
      expect(r[0].anio, 2024);
      expect(r[0].calificacion, 7.5);
      expect(r[1].urlPoster, isNull); // sin póster
      expect(r[1].anio, isNull); // fecha vacía
    });

    test('una ruta de póster sospechosa se descarta', () async {
      final s = ServicioPeliculas(seguro((_) async => jsonOk(jsonPeliculas)), claves);
      final r = await s.listar(Animo.feliz);
      expect(r[2].urlPoster, isNull);
    });

    test('sin clave ni siquiera hace la petición', () {
      var llamado = false;
      final s = ServicioPeliculas(
          seguro((_) async {
            llamado = true;
            return jsonOk(jsonPeliculas);
          }),
          const ConfigClaves());
      expect(s.listar(Animo.feliz), throwsA(isA<ClaveFaltanteException>()));
      expect(llamado, false);
    });

    test('sorprender elige según el azar inyectado', () async {
      final s = ServicioPeliculas(seguro((_) async => jsonOk(jsonPeliculas)), claves,
          azar: AzarFijo(1));
      expect((await s.sorprender(Animo.feliz)).titulo, 'Película Dos');
    });

    test('lista vacía lanza RespuestaInvalidaException', () {
      final s = ServicioPeliculas(
          seguro((_) async => jsonOk({'results': []})), claves,
          azar: AzarFijo(0));
      expect(s.sorprender(Animo.feliz), throwsA(isA<RespuestaInvalidaException>()));
    });

    test('si falta "results" lanza RespuestaInvalidaException', () {
      final s = ServicioPeliculas(seguro((_) async => jsonOk({'otra': 1})), claves);
      expect(s.listar(Animo.feliz), throwsA(isA<RespuestaInvalidaException>()));
    });

    test('401 explica que la clave no es válida', () {
      final s = ServicioPeliculas(seguro((_) async => jsonOk({}, 401)), claves);
      expect(
          s.listar(Animo.feliz),
          throwsA(isA<ErrorServidorException>().having((e) => e.toString(), 'm', contains('clave'))));
    });
  });
}
