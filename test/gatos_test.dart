import 'package:cuatro_retos/datos/servicios.dart';
import 'package:cuatro_retos/dominio/excepciones.dart';
import 'package:cuatro_retos/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Reto 2 · Gatos (Cataas)', () {
    test('sin texto pide un gato simple por https', () {
      final u = ConstructorGato.construir();
      expect(u.scheme, 'https');
      expect(u.host, 'cataas.com');
      expect(u.pathSegments, ['cat']);
    });

    test('con texto usa /cat/says/<texto>', () {
      final u = ConstructorGato.construir(texto: 'Hola gato');
      expect(u.pathSegments, ['cat', 'says', 'Hola gato']);
      expect(u.queryParameters['fontColor'], 'white');
    });

    test('un texto con "/" y "?" NO puede escapar de la ruta (path injection)', () {
      final u = ConstructorGato.construir(texto: '../../admin?x=1');
      expect(u.pathSegments.length, 3);
      expect(u.pathSegments.last, '../../admin?x=1');
      expect(u.toString(), contains('%2F'));
      expect(u.queryParameters.containsKey('x'), false);
    });

    test('el filtro se manda como parámetro', () {
      expect(ConstructorGato.construir(filtro: FiltroGato.mono).queryParameters['filter'], 'mono');
      expect(ConstructorGato.construir(filtro: FiltroGato.negativo).queryParameters['filter'], 'negate');
      expect(ConstructorGato.construir().queryParameters.containsKey('filter'), false);
    });

    test('la semilla cambia la dirección (evita la caché)', () {
      expect(ConstructorGato.construir(semilla: 1).toString(),
          isNot(ConstructorGato.construir(semilla: 2).toString()));
    });

    test('rechaza texto demasiado largo y caracteres de control', () {
      expect(() => ConstructorGato.construir(texto: 'a' * 61),
          throwsA(isA<EntradaInvalidaException>()));
      expect(() => ConstructorGato.construir(texto: 'hola\nmundo'),
          throwsA(isA<EntradaInvalidaException>()));
    });
  });
}
