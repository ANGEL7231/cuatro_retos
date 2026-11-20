import 'dart:math';

import '../dominio/excepciones.dart';
import '../dominio/modelos.dart';
import 'cliente_seguro.dart';
import 'config_claves.dart';

bool _tieneControl(String s) => s.contains(RegExp(r'[\x00-\x1F]'));

/// Reto 1 · TMDB (con clave). Películas según el estado de ánimo.
class ServicioPeliculas {
  final ClienteSeguro _c;
  final ConfigClaves _claves;
  final Random _azar;
  ServicioPeliculas(this._c, this._claves, {Random? azar}) : _azar = azar ?? Random();

  Future<List<Pelicula>> listar(Animo animo) async {
    final base = {'api_key': _claves.tmdbValida, 'language': 'es-MX'};
    final uri = animo.generoId == null
        ? Uri.https('api.themoviedb.org', '/3/trending/movie/week', base)
        : Uri.https('api.themoviedb.org', '/3/discover/movie', {
            ...base,
            'with_genres': '${animo.generoId}',
            'sort_by': 'popularity.desc',
            'include_adult': 'false',
            'vote_count.gte': '200',
          });
    final json = await _c.obtenerJson(uri);
    return convertir(() => ((json as Map<String, dynamic>)['results'] as List)
        .map((e) => Pelicula.desdeJson(e as Map<String, dynamic>))
        .toList());
  }

  /// Una película al azar de la lista que corresponde al ánimo.
  Future<Pelicula> sorprender(Animo animo) async {
    final lista = await listar(animo);
    if (lista.isEmpty) throw const RespuestaInvalidaException();
    return lista[_azar.nextInt(lista.length)];
  }
}

/// Reto 2 · Cataas. No devuelve JSON sino una IMAGEN, así que aquí solo
/// construimos la dirección de forma segura; Image.network la descarga.
class ConstructorGato {
  static String normalizarTexto(String texto) {
    final t = texto.trim();
    if (t.length > 60) throw const EntradaInvalidaException('frase demasiado larga (máx. 60)');
    if (_tieneControl(t)) throw const EntradaInvalidaException('caracteres no permitidos');
    return t;
  }

  /// [semilla] cambia en cada "otro gato" para que no se reutilice la imagen en caché.
  static Uri construir({
    String texto = '',
    FiltroGato filtro = FiltroGato.ninguno,
    int semilla = 0,
  }) {
    final t = normalizarTexto(texto);
    final params = <String, String>{'t': '$semilla'};
    if (t.isNotEmpty) {
      params['fontSize'] = '48';
      params['fontColor'] = 'white';
    }
    if (filtro.valor != null) params['filter'] = filtro.valor!;
    // pathSegments codifica "/" y "?" dentro del texto: no puede escapar de la ruta.
    return Uri(
      scheme: 'https',
      host: 'cataas.com',
      pathSegments: t.isEmpty ? ['cat'] : ['cat', 'says', t],
      queryParameters: params,
    );
  }
}

/// Reto 3 · OpenWeatherMap (con clave). Clima actual por ciudad.
class ServicioClima {
  final ClienteSeguro _c;
  final ConfigClaves _claves;
  ServicioClima(this._c, this._claves);

  static String normalizarCiudad(String ciudad) {
    final t = ciudad.trim();
    if (t.isEmpty) throw const EntradaInvalidaException('escribe una ciudad');
    if (t.length > 60) throw const EntradaInvalidaException('nombre de ciudad demasiado largo');
    if (_tieneControl(t)) throw const EntradaInvalidaException('caracteres no permitidos');
    return t;
  }

  Future<ClimaCiudad> porCiudad(String ciudad) async {
    final q = normalizarCiudad(ciudad);
    final json = await _c.obtenerJson(Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'q': q,
      'appid': _claves.openWeatherValida,
      'units': 'metric',
      'lang': 'es',
    }));
    return convertir(() => ClimaCiudad.desdeJson(json as Map<String, dynamic>));
  }
}

/// Reto 4 · CoinGecko (sin clave). Precios actuales en USD.
class ServicioCripto {
  final ClienteSeguro _c;
  ServicioCripto(this._c);

  Future<PreciosCripto> precios() async {
    final json = await _c.obtenerJson(Uri.https('api.coingecko.com', '/api/v3/simple/price', {
      'ids': Moneda.values.map((m) => m.id).join(','),
      'vs_currencies': 'usd',
    }));
    return convertir(() => PreciosCripto.desdeJson(json as Map<String, dynamic>));
  }
}
