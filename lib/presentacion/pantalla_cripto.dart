import 'package:flutter/material.dart';

import '../dominio/modelos.dart';
import 'viewmodels.dart';
import 'widgets_comunes.dart';

class PantallaCripto extends StatefulWidget {
  final CriptoViewModel vm;
  const PantallaCripto({super.key, required this.vm});
  @override
  State<PantallaCripto> createState() => _PantallaCriptoState();
}

class _PantallaCriptoState extends State<PantallaCripto> {
  @override
  void initState() {
    super.initState();
    widget.vm.cargar();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => RefreshIndicator(
        onRefresh: vm.cargar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: vm.cambiarMonto,
              decoration: InputDecoration(
                labelText: 'Monto en USD',
                prefixText: '\$ ',
                border: const OutlineInputBorder(),
                errorText: vm.errorMonto,
              ),
            ),
            const SizedBox(height: 12),
            VistaCarga<PreciosCripto>(
              carga: vm.precios,
              construir: (p) => Column(children: [
                for (final m in Moneda.values)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text(m.simbolo[0])),
                      title: Text('${m.nombre} (${m.simbolo})'),
                      subtitle: Text('\$${p.usd[m]!.toStringAsFixed(2)} USD'),
                      trailing: Text(
                        vm.fraccion(m) == null
                            ? '—'
                            : '${vm.fraccion(m)!.toStringAsFixed(8)} ${m.simbolo}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 8),
            Text('Jala hacia abajo para actualizar. Datos de CoinGecko; '
                'no es asesoría financiera.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
