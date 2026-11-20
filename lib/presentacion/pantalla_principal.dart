import 'package:flutter/material.dart';

import 'pantalla_clima.dart';
import 'pantalla_cripto.dart';
import 'pantalla_gatos.dart';
import 'pantalla_peliculas.dart';
import 'viewmodels.dart';

class PantallaPrincipal extends StatefulWidget {
  final PeliculasViewModel peliculas;
  final GatosViewModel gatos;
  final ClimaViewModel clima;
  final CriptoViewModel cripto;
  const PantallaPrincipal({
    super.key,
    required this.peliculas,
    required this.gatos,
    required this.clima,
    required this.cripto,
  });
  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indice = 0;
  static const _titulos = ['Películas', 'Gatos', 'Clima', 'Cripto'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titulos[_indice])),
      body: IndexedStack(index: _indice, children: [
        PantallaPeliculas(vm: widget.peliculas),
        PantallaGatos(vm: widget.gatos),
        PantallaClima(vm: widget.clima),
        PantallaCripto(vm: widget.cripto),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.movie), label: 'Películas'),
          NavigationDestination(icon: Icon(Icons.pets), label: 'Gatos'),
          NavigationDestination(icon: Icon(Icons.wb_sunny), label: 'Clima'),
          NavigationDestination(icon: Icon(Icons.currency_bitcoin), label: 'Cripto'),
        ],
      ),
    );
  }
}
