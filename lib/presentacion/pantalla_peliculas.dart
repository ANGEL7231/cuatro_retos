import 'package:flutter/material.dart';

import '../dominio/modelos.dart';
import 'carga.dart';
import 'viewmodels.dart';
import 'widgets_comunes.dart';

class PantallaPeliculas extends StatelessWidget {
  final PeliculasViewModel vm;
  const PantallaPeliculas({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('¿Cómo te sientes hoy?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 4, children: [
            for (final a in Animo.values)
              ChoiceChip(
                label: Text('${a.emoji} ${a.etiqueta}'),
                selected: vm.animo == a,
                onSelected: (_) => vm.elegirAnimo(a),
              ),
          ]),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: vm.pelicula.estado == Estado.cargando ? null : () => vm.sorprender(),
            icon: const Icon(Icons.casino),
            label: const Text('Sorpréndeme'),
          ),
          const SizedBox(height: 12),
          VistaCarga<Pelicula>(
            carga: vm.pelicula,
            pista: 'Elige tu estado de ánimo y pulsa "Sorpréndeme".',
            construir: (p) => _TarjetaPelicula(p),
          ),
          const SizedBox(height: 16),
          Text(
            'This product uses the TMDB API but is not endorsed or certified by TMDB.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TarjetaPelicula extends StatelessWidget {
  final Pelicula p;
  const _TarjetaPelicula(this.p);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (p.urlPoster != null)
            Center(
              child: Image.network(
                p.urlPoster!,
                height: 360,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Text('No se pudo cargar el póster'),
              ),
            ),
          const SizedBox(height: 10),
          Text(p.titulo, style: Theme.of(context).textTheme.titleLarge),
          Text('${p.anio ?? 's/f'} · ⭐ ${p.calificacion.toStringAsFixed(1)}'),
          const SizedBox(height: 8),
          Text(p.sinopsis.isEmpty ? 'Sin sinopsis disponible.' : p.sinopsis),
        ]),
      ),
    );
  }
}
