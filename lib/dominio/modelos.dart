import 'excepciones.dart';

// ───────────── Reto 1 · Películas (TMDB) ─────────────

/// Estado de ánimo → género de TMDB (null = tendencias de la semana).
enum Animo {
  feliz('😄', 'Feliz', 35),
  triste('😢', 'Triste', 18),
  emocionado('🤩', 'Emocionado', 28),
  asustado('😱', 'Con ganas de miedo', 27),
  romantico('😍', 'Romántico', 10749),
  tendencias('🔥', 'Lo más popular', null);

  final String emoji;
  final String etiqueta;
  final int? generoId;
  const Animo(this.emoji, this.etiqueta, this.generoId);
}

/// Solo aceptamos rutas de póster con forma "/abc123.jpg": así el dato que
/// viene de la API nunca puede alterar la dirección final de la imagen.
String? _urlPoster(Object? ruta) =>
    ruta is String && RegExp(r'^/[A-Za-z0-9_\-]+\.(jpg|png)$').hasMatch(ruta)
        ? 'https://image.tmdb.org/t/p/w342$ruta'
        : null;

class Pelicula {
  final int id;
  final String titulo;
  final String sinopsis;
  final String? urlPoster;
  final int? anio;
  final double calificacion;
  const Pelicula(this.id, this.titulo, this.sinopsis, this.urlPoster, this.anio, this.calificacion);

  factory Pelicula.desdeJson(Map<String, dynamic> json) {
    final fecha = json['release_date'];
    return Pelicula(
      (json['id'] as num).toInt(),
      json['title'] as String,
      (json['overview'] as String?) ?? '',
      _urlPoster(json['poster_path']),
      fecha is String && fecha.length >= 4 ? int.tryParse(fecha.substring(0, 4)) : null,
      ((json['vote_average'] as num?) ?? 0).toDouble(),
    );
  }
}

// ───────────── Reto 2 · Gatos (Cataas) ─────────────

/// Filtros que acepta Cataas en el parámetro "filter".
enum FiltroGato {
  ninguno('Sin filtro', null),
  mono('Blanco y negro', 'mono'),
  sepia('Sepia', 'sepia'),
  negativo('Negativo', 'negate'),
  pixel('Pixelado', 'pixel');

  final String etiqueta;
  final String? valor;
  const FiltroGato(this.etiqueta, this.valor);
}

// ───────────── Reto 3 · Clima (OpenWeatherMap) ─────────────

class ClimaCiudad {
  final String ciudad;
  final String pais;
  final double temperatura;
  final double sensacion;
  final int humedad;
  final double vientoKmh;
  final String descripcion;
  final int codigo;
  const ClimaCiudad(this.ciudad, this.pais, this.temperatura, this.sensacion, this.humedad,
      this.vientoKmh, this.descripcion, this.codigo);

  factory ClimaCiudad.desdeJson(Map<String, dynamic> json) {
    final clima = (json['weather'] as List).first as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;
    final viento = json['wind'] as Map<String, dynamic>?;
    final sys = json['sys'] as Map<String, dynamic>?;
    return ClimaCiudad(
      json['name'] as String,
      (sys?['country'] as String?) ?? '',
      (main['temp'] as num).toDouble(),
      (main['feels_like'] as num).toDouble(),
      (main['humidity'] as num).round(),
      ((viento?['speed'] as num?) ?? 0).toDouble() * 3.6, // m/s → km/h
      clima['description'] as String,
      (clima['id'] as num).toInt(),
    );
  }
}

/// Convierte el código de condición de OpenWeatherMap en un emoji.
String emojiClima(int codigo) {
  if (codigo >= 200 && codigo < 300) return '⛈️';
  if (codigo >= 300 && codigo < 400) return '🌦️';
  if (codigo >= 500 && codigo < 600) return '🌧️';
  if (codigo >= 600 && codigo < 700) return '❄️';
  if (codigo >= 700 && codigo < 800) return '🌫️';
  if (codigo == 800) return '☀️';
  if (codigo == 801 || codigo == 802) return '⛅';
  if (codigo > 802 && codigo < 900) return '☁️';
  return '🌡️';
}

// ───────────── Reto 4 · Cripto (CoinGecko) ─────────────

enum Moneda {
  bitcoin('bitcoin', 'BTC', 'Bitcoin'),
  ethereum('ethereum', 'ETH', 'Ethereum'),
  solana('solana', 'SOL', 'Solana');

  final String id;
  final String simbolo;
  final String nombre;
  const Moneda(this.id, this.simbolo, this.nombre);
}

class PreciosCripto {
  final Map<Moneda, double> usd;
  const PreciosCripto(this.usd);

  factory PreciosCripto.desdeJson(Map<String, dynamic> json) {
    final r = <Moneda, double>{};
    for (final m in Moneda.values) {
      final precio = ((json[m.id] as Map<String, dynamic>)['usd'] as num).toDouble();
      // Un precio cero, negativo o infinito rompería la división: se rechaza.
      if (!precio.isFinite || precio <= 0) throw const FormatException('precio inválido');
      r[m] = precio;
    }
    return PreciosCripto(r);
  }

  /// Cuántas unidades de [m] se compran con [montoUsd] dólares.
  double fraccion(Moneda m, double montoUsd) => montoUsd / usd[m]!;
}

/// Convierte el texto que escribe el usuario en un monto válido.
/// Acepta coma o punto decimal. Rechaza vacío, texto, NaN, infinito,
/// cero, negativos y cantidades absurdas.
double parsearMontoUsd(String texto) {
  final t = texto.trim().replaceAll(',', '.');
  if (t.isEmpty) throw const EntradaInvalidaException('escribe un monto en USD');
  final v = double.tryParse(t);
  if (v == null || !v.isFinite) {
    throw const EntradaInvalidaException('el monto debe ser un número');
  }
  if (v <= 0) throw const EntradaInvalidaException('el monto debe ser mayor que cero');
  if (v > 1000000000) throw const EntradaInvalidaException('monto demasiado grande');
  return v;
}
