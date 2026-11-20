// Ayudas compartidas por las pruebas (no es una prueba en sí).
import 'dart:convert';
import 'dart:math';

import 'package:cuatro_retos/datos/cliente_seguro.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response jsonOk(Object cuerpo, [int estado = 200]) => http.Response.bytes(
    utf8.encode(jsonEncode(cuerpo)), estado,
    headers: {'content-type': 'application/json; charset=utf-8'});

ClienteSeguro seguro(Future<http.Response> Function(http.Request) manejador,
        {Duration? espera, int? maxBytes}) =>
    ClienteSeguro(MockClient(manejador),
        espera: espera ?? const Duration(seconds: 2),
        maxBytes: maxBytes ?? 1024 * 1024);

/// Azar controlado: siempre elige el índice [valor].
class AzarFijo implements Random {
  final int valor;
  AzarFijo(this.valor);
  @override
  int nextInt(int max) => valor;
  @override
  double nextDouble() => 0;
  @override
  bool nextBool() => false;
}

// Respuestas que imitan el formato documentado de cada API.
final jsonPeliculas = {
  'page': 1,
  'results': [
    {
      'id': 1,
      'title': 'Película Uno',
      'overview': 'Una comedia de prueba.',
      'poster_path': '/uno.jpg',
      'release_date': '2024-05-01',
      'vote_average': 7.5,
    },
    {
      'id': 2,
      'title': 'Película Dos',
      'overview': '',
      'poster_path': null,
      'release_date': '',
      'vote_average': 6,
    },
    {
      'id': 3,
      'title': 'Película Tres',
      'overview': 'Poster malicioso.',
      'poster_path': '/../../x.jpg',
      'release_date': '2020-01-01',
      'vote_average': 5.0,
    },
  ],
};

final jsonClimaOwm = {
  'name': 'Dolores Hidalgo',
  'sys': {'country': 'MX'},
  'weather': [
    {'id': 800, 'description': 'cielo claro', 'icon': '01d'}
  ],
  'main': {'temp': 24.3, 'feels_like': 23.8, 'humidity': 41},
  'wind': {'speed': 5.0},
};

final jsonCripto = {
  'bitcoin': {'usd': 50000},
  'ethereum': {'usd': 2500},
  'solana': {'usd': 100},
};

/// Servidor falso que enruta por dominio.
Future<http.Response> servidorFalso(http.Request r) async {
  switch (r.url.host) {
    case 'api.themoviedb.org':
      return jsonOk(jsonPeliculas);
    case 'api.openweathermap.org':
      return jsonOk(jsonClimaOwm);
    case 'api.coingecko.com':
      return jsonOk(jsonCripto);
  }
  return http.Response('', 404);
}
