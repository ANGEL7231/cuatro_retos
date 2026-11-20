import 'package:flutter/material.dart';

import '../dominio/modelos.dart';
import 'viewmodels.dart';

class PantallaGatos extends StatefulWidget {
  final GatosViewModel vm;
  const PantallaGatos({super.key, required this.vm});
  @override
  State<PantallaGatos> createState() => _PantallaGatosState();
}

class _PantallaGatosState extends State<PantallaGatos> {
  final _texto = TextEditingController();

  @override
  void dispose() {
    _texto.dispose();
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
            controller: _texto,
            maxLength: 60,
            textInputAction: TextInputAction.done,
            onSubmitted: vm.aplicarTexto,
            decoration: InputDecoration(
              labelText: 'Frase para el gato',
              border: const OutlineInputBorder(),
              errorText: vm.error,
              suffixIcon: IconButton(
                tooltip: 'Poner frase',
                icon: const Icon(Icons.check),
                onPressed: () => vm.aplicarTexto(_texto.text),
              ),
            ),
          ),
          Wrap(spacing: 8, runSpacing: 4, children: [
            for (final f in FiltroGato.values)
              ChoiceChip(
                label: Text(f.etiqueta),
                selected: vm.filtro == f,
                onSelected: (_) => vm.elegirFiltro(f),
              ),
          ]),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: vm.otroGato,
            icon: const Icon(Icons.pets),
            label: const Text('Otro gato'),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              vm.uri.toString(),
              key: ValueKey(vm.uri),
              height: 340,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progreso) => progreso == null
                  ? child
                  : const SizedBox(
                      height: 340, child: Center(child: CircularProgressIndicator())),
              errorBuilder: (_, __, ___) => const SizedBox(
                  height: 340, child: Center(child: Text('No se pudo cargar el gato 😿'))),
            ),
          ),
          const SizedBox(height: 8),
          Text('Imágenes de cataas.com', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
