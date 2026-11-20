import 'package:flutter/material.dart';

import '../dominio/modelos.dart';
import 'viewmodels.dart';
import 'widgets_comunes.dart';

class PantallaClima extends StatefulWidget {
  final ClimaViewModel vm;
  const PantallaClima({super.key, required this.vm});
  @override
  State<PantallaClima> createState() => _PantallaClimaState();
}

class _PantallaClimaState extends State<PantallaClima> {
  late final TextEditingController _ciudad;

  @override
  void initState() {
    super.initState();
    _ciudad = TextEditingController(text: widget.vm.ciudad);
    widget.vm.buscar();
  }

  @override
  void dispose() {
    _ciudad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _ciudad,
            textInputAction: TextInputAction.search,
            onSubmitted: vm.buscar,
            decoration: InputDecoration(
              labelText: 'Ciudad',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: 'Buscar',
                icon: const Icon(Icons.search),
                onPressed: () => vm.buscar(_ciudad.text),
              ),
            ),
          ),
          const SizedBox(height: 12),
          VistaCarga<ClimaCiudad>(
            carga: vm.clima,
            construir: (c) => Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Text('${c.ciudad}${c.pais.isEmpty ? '' : ', ${c.pais}'}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(emojiClima(c.codigo), style: const TextStyle(fontSize: 64)),
                  Text('${c.temperatura.toStringAsFixed(1)} °C',
                      style: Theme.of(context).textTheme.displaySmall),
                  Text(c.descripcion.isEmpty
                      ? ''
                      : c.descripcion[0].toUpperCase() + c.descripcion.substring(1)),
                  const SizedBox(height: 12),
                  Text('Sensación ${c.sensacion.toStringAsFixed(1)} °C · '
                      'Humedad ${c.humedad}% · '
                      'Viento ${c.vientoKmh.toStringAsFixed(0)} km/h'),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
