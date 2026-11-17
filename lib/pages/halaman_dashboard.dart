import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../cubit/sensor_cubit.dart';
import '../helpers/hive_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';
import 'halaman_riwayat.dart';
import 'halaman_pengaturan.dart';

class HalamanDashboard extends StatelessWidget {
  const HalamanDashboard({super.key});

  String _satuan(String jenis) {
    if (jenis == 'Ketinggian Air') return 'cm';
    if (jenis == 'Pergeseran Tanah') return 'mm';
    return 'mm/jam';
  }

  void _simulasikanSensor(BuildContext context) {
    final random = Random();
    final jenisList = SensorCubit.daftarJenis;
    final posList = ['Pos Citarum Hulu', 'Pos Tebing Lembang', 'Pos Dayeuhkolot'];

    final jenis = jenisList[random.nextInt(jenisList.length)];
    double nilai;
    if (jenis == 'Ketinggian Air') {
      nilai = 80 + random.nextInt(220).toDouble();
    } else if (jenis == 'Pergeseran Tanah') {
      nilai = double.parse((1 + random.nextDouble() * 18).toStringAsFixed(1));
    } else {
      nilai = 10 + random.nextInt(120).toDouble();
    }

    final data = PembacaanSensor(
      id: 'SNS-${DateTime.now().millisecondsSinceEpoch}',
      jenisSensor: jenis,
      nilai: nilai,
      lokasiPos: posList[random.nextInt(posList.length)],
      waktu: DateTime.now(),
    );

    context.read<SensorCubit>().tambahPembacaan(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Simulasi tersimpan: $jenis (${data.nilai} ${_satuan(jenis)})'),
        backgroundColor: AppTheme.bgTop,
      ),
    );
  }

  void _tampilkanDialogManual(BuildContext context) {
    String jenisTerpilih = SensorCubit.daftarJenis.first;
    final nilaiCtrl = TextEditingController();
    final posCtrl = TextEditingController(text: 'Pos Pantau Utama');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF240B36),
          title: const Text('Input Pembacaan Manual'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: jenisTerpilih,
                dropdownColor: const Color(0xFF311042),
                decoration: const InputDecoration(labelText: 'Jenis Sensor'),
                items: SensorCubit.daftarJenis
                    .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                    .toList(),
                onChanged: (val) => setStateDialog(() => jenisTerpilih = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nilaiCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nilai (${_satuan(jenisTerpilih)})',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: posCtrl,
                decoration: const InputDecoration(labelText: 'Lokasi Pos'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.bgTop),
              onPressed: () {
                final val = double.tryParse(nilaiCtrl.text);
                if (val != null && posCtrl.text.isNotEmpty) {
                  final data = PembacaanSensor(
                    id: 'MAN-${DateTime.now().millisecondsSinceEpoch}',
                    jenisSensor: jenisTerpilih,
                    nilai: val,
                    lokasiPos: posCtrl.text,
                    waktu: DateTime.now(),
                  );
                  context.read<SensorCubit>().tambahPembacaan(data);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Simpan ke Hive'),
            ),
          ],
        ),
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
          title: const Text('BPBD AIoT MONITOR'),
          actions: [
            BlocBuilder<SensorCubit, SensorState>(
              builder: (context, state) => StatusBadge(status: state.statusGlobal),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Emblem Kotak Bergaya Stamp (Adaptasi Gambar Referensi)
              Container(
                width: 140,
                height: 155,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2.5),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A148C), Color(0xFF9C27B0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.waves, color: Colors.white, size: 36),
                    Text(
                      'SIAGA\nBPBD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Halo, Petugas Piket',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Sistem Pemantauan Dini Bencana Lokal',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 20),

              // Kartu Pembacaan Terakhir (Reaktif dari Hive)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ValueListenableBuilder(
                    valueListenable: HiveHelper.instance.box.listenable(),
                    builder: (context, Box<PembacaanSensor> box, _) {
                      if (box.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.cardGlass,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Center(
                            child: Text(
                              'Belum ada data telemetri tersimpan.\nGunakan tombol di bawah untuk simulasi atau input.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        );
                      }

                      final list = box.values.toList()
                        ..sort((a, b) => b.waktu.compareTo(a.waktu));
                      final terkini = list.first;

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.cardGlass,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'PEMBACAAN TERBARU',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.5,
                                color: Colors.white60,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${terkini.nilai} ${_satuan(terkini.jenisSensor)}',
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              terkini.jenisSensor,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFE1BEE7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${terkini.lokasiPos} • ${DateFormat('dd MMM yyyy, HH:mm:ss').format(terkini.waktu)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Total Log Tersimpan: ${box.length} rekaman',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 4 Tombol Aksi Bulat di Bawah (Adaptasi Layout Gambar Referensi)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MenuBulat(
                      icon: Icons.sensors,
                      label: 'Simulasi',
                      onTap: () => _simulasikanSensor(context),
                    ),
                    _MenuBulat(
                      icon: Icons.edit_note,
                      label: 'Input Manual',
                      onTap: () => _tampilkanDialogManual(context),
                    ),
                    _MenuBulat(
                      icon: Icons.history,
                      label: 'Riwayat Audit',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HalamanRiwayat()),
                      ),
                    ),
                    _MenuBulat(
                      icon: Icons.tune,
                      label: 'Ambang Batas',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HalamanPengaturan()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuBulat extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuBulat({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.bgTop,
              border: Border.all(color: Colors.white38, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.bgTop.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}