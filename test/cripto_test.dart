import 'package:cuatro_retos/datos/servicios.dart';
import 'package:cuatro_retos/dominio/excepciones.dart';
import 'package:cuatro_retos/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas.dart';

void main() {
  group('Reto 4 · Cripto (CoinGecko)', () {
    test('pide los 3 ids en USD y convierte los precios', () async {
      final s = ServicioCripto(seguro((req) async {
        expect(req.url.host, 'api.coingecko.com');
        expect(req.url.queryParameters['ids'], 'bitcoin,ethereum,solana');
        expect(req.url.queryParameters['vs_currencies'], 'usd');
        return jsonOk(jsonCripto);
      }));
      final p = await s.precios();
      expect(p.usd[Moneda.bitcoin], 50000);
      expect(p.usd[Moneda.solana], 100);
    });

    test('calcula la fracción comprada con un monto en USD', () async {
      final p = await ServicioCripto(seguro((_) async => jsonOk(jsonCripto))).precios();
      expect(p.fraccion(Moneda.bitcoin, 100), closeTo(0.002, 1e-12));
      expect(p.fraccion(Moneda.ethereum, 100), closeTo(0.04, 1e-12));
      expect(p.fraccion(Moneda.solana, 100), closeTo(1.0, 1e-12));
    });

    test('una moneda faltante lanza RespuestaInvalidaException', () {
      final s = ServicioCripto(seguro((_) async => jsonOk({'bitcoin': {'usd': 1}})));
      expect(s.precios(), throwsA(isA<RespuestaInvalidaException>()));
    });

    test('un precio en cero se rechaza (evita dividir entre cero)', () {
      final s = ServicioCripto(seguro((_) async => jsonOk({
            'bitcoin': {'usd': 0},
            'ethereum': {'usd': 1},
            'solana': {'usd': 1},
          })));
      expect(s.precios(), throwsA(isA<RespuestaInvalidaException>()));
    });

    test('429 produce un mensaje de límite de peticiones', () {
      final s = ServicioCripto(seguro((_) async => jsonOk({}, 429)));
      expect(s.precios(),
          throwsA(isA<ErrorServidorException>().having((e) => e.toString(), 'm', contains('Demasiadas'))));
    });
  });

  group('parsearMontoUsd', () {
    test('acepta punto y coma decimal', () {
      expect(parsearMontoUsd('100'), 100);
      expect(parsearMontoUsd(' 12,5 '), 12.5);
      expect(parsearMontoUsd('0.01'), 0.01);
    });

    test('rechaza vacío, texto, NaN, infinito, cero, negativos y absurdos', () {
      for (final malo in ['', '  ', 'abc', 'NaN', 'Infinity', '0', '-5', '1e12']) {
        expect(() => parsearMontoUsd(malo), throwsA(isA<EntradaInvalidaException>()),
            reason: 'debió rechazar "$malo"');
      }
    });
  });
}
