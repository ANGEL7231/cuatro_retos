import 'package:cuatro_retos/datos/config_claves.dart';
import 'package:cuatro_retos/datos/servicios.dart';
import 'package:cuatro_retos/dominio/excepciones.dart';
import 'package:cuatro_retos/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas.dart';

void main() {
  const claves = ConfigClaves(openWeather: 'K');

  group('Reto 3 · Clima (OpenWeatherMap)', () {
    test('convierte la respuesta y pide unidades métricas en español', () async {
      final s = ServicioClima(
          seguro((req) async {
            expect(req.url.host, 'api.openweathermap.org');
            expect(req.url.queryParameters['q'], 'Dolores Hidalgo');
            expect(req.url.queryParameters['appid'], 'K');
            expect(req.url.queryParameters['units'], 'metric');
            expect(req.url.queryParameters['lang'], 'es');
            return jsonOk(jsonClimaOwm);
          }),
          claves);
      final c = await s.porCiudad('Dolores Hidalgo');
      expect(c.ciudad, 'Dolores Hidalgo');
      expect(c.pais, 'MX');
      expect(c.temperatura, 24.3);
      expect(c.humedad, 41);
      expect(c.vientoKmh, closeTo(18.0, 0.0001)); // 5 m/s × 3.6
      expect(c.descripcion, 'cielo claro');
    });

    test('rechaza ciudad vacía, muy larga o con caracteres de control', () {
      final s = ServicioClima(seguro((_) async => jsonOk(jsonClimaOwm)), claves);
      expect(s.porCiudad('  '), throwsA(isA<EntradaInvalidaException>()));
      expect(s.porCiudad('a' * 61), throwsA(isA<EntradaInvalidaException>()));
      expect(s.porCiudad('Leon\nGto'), throwsA(isA<EntradaInvalidaException>()));
    });

    test('sin clave ni siquiera hace la petición', () {
      var llamado = false;
      final s = ServicioClima(
          seguro((_) async {
            llamado = true;
            return jsonOk(jsonClimaOwm);
          }),
          const ConfigClaves());
      expect(s.porCiudad('Leon'), throwsA(isA<ClaveFaltanteException>()));
      expect(llamado, false);
    });

    test('ciudad inexistente (404) da un mensaje claro', () {
      final s = ServicioClima(seguro((_) async => jsonOk({'cod': '404'}, 404)), claves);
      expect(s.porCiudad('Xyzzy'), throwsA(isA<ErrorServidorException>().having((e) => e.codigo, 'codigo', 404)));
    });

    test('JSON incompleto lanza RespuestaInvalidaException', () {
      final s = ServicioClima(seguro((_) async => jsonOk({'name': 'X'})), claves);
      expect(s.porCiudad('X'), throwsA(isA<RespuestaInvalidaException>()));
    });

    test('emojiClima traduce códigos', () {
      expect(emojiClima(800), '☀️');
      expect(emojiClima(501), '🌧️');
      expect(emojiClima(211), '⛈️');
      expect(emojiClima(804), '☁️');
    });
  });
}
