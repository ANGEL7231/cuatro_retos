import 'package:flutter/material.dart';

import 'carga.dart';

/// Muestra spinner, error, pista inicial o contenido según el estado.
class VistaCarga<T> extends StatelessWidget {
  final Carga<T> carga;
  final String pista;
  final Widget Function(T) construir;
  const VistaCarga({
    super.key,
    required this.carga,
    required this.construir,
    this.pista = '',
  });

  @override
  Widget build(BuildContext context) {
    return switch (carga.estado) {
      Estado.inicial => Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text(pista, textAlign: TextAlign.center)),
        ),
      Estado.cargando => const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      Estado.error => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(carga.error ?? 'Error',
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      Estado.listo => construir(carga.dato as T),
    };
  }
}
