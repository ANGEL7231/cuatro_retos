import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'datos/cliente_seguro.dart';
import 'datos/config_claves.dart';
import 'datos/servicios.dart';
import 'presentacion/pantalla_principal.dart';
import 'presentacion/viewmodels.dart';

void main() {
  // Composition root: el único lugar donde se arma todo.
  final cliente = ClienteSeguro(http.Client());
  final claves = ConfigClaves.desdeEntorno();
  runApp(MaterialApp(
    title: 'Cuatro Retos',
    theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
    home: PantallaPrincipal(
      peliculas: PeliculasViewModel(ServicioPeliculas(cliente, claves)),
      gatos: GatosViewModel(),
      clima: ClimaViewModel(ServicioClima(cliente, claves)),
      cripto: CriptoViewModel(ServicioCripto(cliente)),
    ),
  ));
}
