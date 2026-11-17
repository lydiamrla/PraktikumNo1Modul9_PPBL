import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/sensor_cubit.dart';
import '../helpers/pengaturan_helper.dart';
import '../theme/app_theme.dart';

class HalamanPengaturan extends StatefulWidget {
  const HalamanPengaturan({super.key});

  @override
  State<HalamanPengaturan> createState() => _HalamanPengaturanState();
}

class _HalamanPengaturanState extends State<HalamanPengaturan> {
  final Map<String, TextEditingController> _waspadaCtrl = {};
  final Map<String, TextEditingController> _siagaCtrl = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    for (var jenis in SensorCubit.daftarJenis) {
      final batas = await PengaturanHelper.muatAmbangBatas(jenis);
      _waspadaCtrl[jenis] =
          TextEditingController(text: batas['waspada'].toString());
      _siagaCtrl[jenis] =
          TextEditingController(text: batas['siaga'].toString());
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    for (var c in _waspadaCtrl.values) {
      c.dispose();
    }
    for (var c in _siagaCtrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _simpanSemua() async {
    final cubit = context.read<SensorCubit>();
    for (var jenis in SensorCubit.daftarJenis) {
      final w = double.tryParse(_waspadaCtrl[jenis]!.text) ?? 50.0;
      final s = double.tryParse(_siagaCtrl[jenis]!.text) ?? 100.0;
      await cubit.simpanPengaturanAmbang(jenis, w, s);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ambang batas berhasil disimpan ke SharedPreferences'),
          backgroundColor: AppTheme.bgTop,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Pengaturan Ambang Batas')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ...SensorCubit.daftarJenis.map((jenis) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardGlass,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jenis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _waspadaCtrl[jenis],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Batas Waspada',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _siagaCtrl[jenis],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Batas Siaga',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.bgTop,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _simpanSemua,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'Simpan Ambang Batas',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}