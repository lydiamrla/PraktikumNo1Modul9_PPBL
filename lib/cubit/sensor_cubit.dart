import 'package:flutter_bloc/flutter_bloc.dart';
import '../helpers/hive_helper.dart';
import '../helpers/pengaturan_helper.dart';
import '../models/pembacaan_sensor.dart';

class SensorState {
  final String statusGlobal; // 'AMAN', 'WASPADA', 'SIAGA'
  final Map<String, Map<String, double>> ambangBatas;

  SensorState({
    required this.statusGlobal,
    required this.ambangBatas,
  });
}

class SensorCubit extends Cubit<SensorState> {
  SensorCubit()
      : super(SensorState(statusGlobal: 'AMAN', ambangBatas: {})) {
    muatUlangStatus();
  }

  static const List<String> daftarJenis = [
    'Ketinggian Air',
    'Pergeseran Tanah',
    'Curah Hujan',
  ];

  Future<void> muatUlangStatus() async {
    final Map<String, Map<String, double>> batas = {};
    for (var jenis in daftarJenis) {
      batas[jenis] = await PengaturanHelper.muatAmbangBatas(jenis);
    }

    final box = HiveHelper.instance.box;
    String statusTertinggi = 'AMAN';

    if (box.isNotEmpty) {
      // Urutkan dari yang terbaru berdasarkan waktu
      final list = box.values.toList()
        ..sort((a, b) => b.waktu.compareTo(a.waktu));
      final terbaru = list.first;

      final batasJenis = batas[terbaru.jenisSensor]!;
      if (terbaru.nilai >= batasJenis['siaga']!) {
        statusTertinggi = 'SIAGA';
      } else if (terbaru.nilai >= batasJenis['waspada']!) {
        statusTertinggi = 'WASPADA';
      }
    }

    emit(SensorState(statusGlobal: statusTertinggi, ambangBatas: batas));
  }

  Future<void> tambahPembacaan(PembacaanSensor data) async {
    await HiveHelper.instance.box.put(data.id, data);
    await muatUlangStatus();
  }

  Future<void> updatePembacaan(PembacaanSensor data, double nilaiBaru) async {
    data.nilai = nilaiBaru;
    await data.save();
    await muatUlangStatus();
  }

  Future<void> hapusPembacaan(PembacaanSensor data) async {
    await data.delete();
    await muatUlangStatus();
  }

  Future<void> simpanPengaturanAmbang(
      String jenis, double waspada, double siaga) async {
    await PengaturanHelper.simpanAmbangBatas(jenis, waspada, siaga);
    await muatUlangStatus();
  }
}