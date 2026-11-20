import 'package:cuatro_retos/datos/config_claves.dart';
import 'package:cuatro_retos/datos/servicios.dart';
import 'package:cuatro_retos/dominio/modelos.dart';
import 'package:cuatro_retos/presentacion/carga.dart';
import 'package:cuatro_retos/presentacion/viewmodels.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas.dart';

void main() {
  const claves = ConfigClaves(tmdb: 'K', openWeather: 'K');

  group('PeliculasViewModel', () {
    test('sorprender pasa por cargando y termina en listo', () async {
      final vm = PeliculasViewModel(
          ServicioPeliculas(seguro(servidorFalso), claves, azar: AzarFijo(0)));
      expect(vm.pelicula.estado, Estado.inicial);
      final vistos = <Estado>[];
      vm.addListener(() => vistos.add(vm.pelicula.estado));
      await vm.sorprender();
      expect(vistos, [Estado.cargando, Estado.listo]);
      expect(vm.pelicula.dato!.titulo, 'Película Uno');
    });

    test('elegirAnimo cambia el ánimo', () {
      final vm = PeliculasViewModel(ServicioPeliculas(seguro(servidorFalso), claves));
      vm.elegirAnimo(Animo.asustado);
      expect(vm.animo, Animo.asustado);
    });

    test('un error muestra mensaje genérico, sin detalles internos', () async {
      final vm = PeliculasViewModel(ServicioPeliculas(
          seguro((_) async => throw Exception('detalle interno')), claves));
      await vm.sorprender();
      expect(vm.pelicula.estado, Estado.error);
      expect(vm.pelicula.error, isNot(contains('detalle interno')));
    });

    test('sin clave muestra qué clave falta', () async {
      final vm = PeliculasViewModel(
          ServicioPeliculas(seguro(servidorFalso), const ConfigClaves()));
      await vm.sorprender();
      expect(vm.pelicula.error, contains('TMDB_API_KEY'));
    });
  });

  group('GatosViewModel', () {
    test('aplicarTexto actualiza la dirección', () {
      final vm = GatosViewModel();
      vm.aplicarTexto('Miau');
      expect(vm.uri.pathSegments, ['cat', 'says', 'Miau']);
      expect(vm.error, isNull);
    });

    test('un texto inválido conserva el gato anterior y muestra el error', () {
      final vm = GatosViewModel();
      vm.aplicarTexto('Miau');
      final antes = vm.uri;
      vm.aplicarTexto('a' * 61);
      expect(vm.uri, antes);
      expect(vm.error, isNotNull);
    });

    test('otroGato cambia la semilla y elegirFiltro agrega el filtro', () {
      final vm = GatosViewModel();
      final t0 = vm.uri.queryParameters['t'];
      vm.otroGato();
      expect(vm.uri.queryParameters['t'], isNot(t0));
      vm.elegirFiltro(FiltroGato.sepia);
      expect(vm.uri.queryParameters['filter'], 'sepia');
    });
  });

  group('ClimaViewModel', () {
    test('buscar carga el clima de la ciudad', () async {
      final vm = ClimaViewModel(ServicioClima(seguro(servidorFalso), claves));
      await vm.buscar();
      expect(vm.clima.estado, Estado.listo);
      expect(vm.clima.dato!.temperatura, 24.3);
    });

    test('ciudad vacía muestra error amable', () async {
      final vm = ClimaViewModel(ServicioClima(seguro(servidorFalso), claves));
      await vm.buscar('  ');
      expect(vm.clima.estado, Estado.error);
      expect(vm.clima.error, contains('ciudad'));
    });
  });

  group('CriptoViewModel', () {
    test('cargar + monto calcula las fracciones', () async {
      final vm = CriptoViewModel(ServicioCripto(seguro(servidorFalso)));
      await vm.cargar();
      expect(vm.precios.estado, Estado.listo);
      expect(vm.fraccion(Moneda.bitcoin), isNull); // aún sin monto
      vm.cambiarMonto('100');
      expect(vm.fraccion(Moneda.bitcoin), closeTo(0.002, 1e-12));
      expect(vm.fraccion(Moneda.solana), closeTo(1.0, 1e-12));
    });

    test('un monto inválido muestra error y borra el resultado', () async {
      final vm = CriptoViewModel(ServicioCripto(seguro(servidorFalso)));
      await vm.cargar();
      vm.cambiarMonto('100');
      vm.cambiarMonto('abc');
      expect(vm.errorMonto, isNotNull);
      expect(vm.fraccion(Moneda.bitcoin), isNull);
      vm.cambiarMonto('');
      expect(vm.errorMonto, isNull);
    });

    test('si CoinGecko falla, el error es claro y la app no se cae', () async {
      final vm = CriptoViewModel(ServicioCripto(seguro((_) async => jsonOk({}, 429))));
      await vm.cargar();
      expect(vm.precios.estado, Estado.error);
      expect(vm.precios.error, contains('429'));
    });
  });
}
