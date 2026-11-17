import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../cubit/sensor_cubit.dart';
import '../helpers/hive_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';

class HalamanRiwayat extends StatelessWidget {
  const HalamanRiwayat({super.key});

  String _satuan(String jenis) {
    if (jenis == 'Ketinggian Air') return 'cm';
    if (jenis == 'Pergeseran Tanah') return 'mm';
    return 'mm/jam';
  }

  void _dialogKoreksi(BuildContext context, PembacaanSensor item) {
    final ctrl = TextEditingController(text: item.nilai.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF240B36),
        title: const Text('Koreksi Nilai Sensor'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Nilai Baru (${_satuan(item.jenisSensor)})',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.bgTop),
            onPressed: () {
              final nilaiBaru = double.tryParse(ctrl.text);
              if (nilaiBaru != null) {
                context.read<SensorCubit>().updatePembacaan(item, nilaiBaru);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan Koreksi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Riwayat Audit Sensor'),
          actions: [
            BlocBuilder<SensorCubit, SensorState>(
              builder: (context, state) => StatusBadge(status: state.statusGlobal),
            ),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: HiveHelper.instance.box.listenable(),
          builder: (context, Box<PembacaanSensor> box, _) {
            if (box.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada riwayat pembacaan sensor.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            // Urutkan dari yang terbaru
            final daftar = box.values.toList()
              ..sort((a, b) => b.waktu.compareTo(a.waktu));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: daftar.length,
              itemBuilder: (context, index) {
                final item = daftar[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    context.read<SensorCubit>().hapusPembacaan(item);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Baris pembacaan dihapus')),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardGlass,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: ListTile(
                      title: Text(
                        '${item.jenisSensor} — ${item.nilai} ${_satuan(item.jenisSensor)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        '${item.lokasiPos}\n${DateFormat('dd MMM yyyy • HH:mm:ss').format(item.waktu)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.purpleAccent),
                        tooltip: 'Koreksi Nilai',
                        onPressed: () => _dialogKoreksi(context, item),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}