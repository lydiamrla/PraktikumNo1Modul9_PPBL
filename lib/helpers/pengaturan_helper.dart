import 'package:shared_preferences/shared_preferences.dart';

class PengaturanHelper {
  PengaturanHelper._();

  static String _keyWaspada(String jenis) => 'waspada_$jenis';
  static String _keySiaga(String jenis) => 'siaga_$jenis';

  static Future<void> simpanAmbangBatas(
      String jenisSensor, double waspada, double siaga) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyWaspada(jenisSensor), waspada);
    await prefs.setDouble(_keySiaga(jenisSensor), siaga);
  }

  static Future muatAmbangBatas(String jenisSensor) async {
    final prefs = await SharedPreferences.getInstance();
    double defaultWaspada = 50.0;
    double defaultSiaga = 80.0;

    if (jenisSensor == 'Ketinggian Air') {
      defaultWaspada = 150.0;
      defaultSiaga = 250.0;
    } else if (jenisSensor == 'Pergeseran Tanah') {
      defaultWaspada = 5.0;
      defaultSiaga = 15.0;
    } else if (jenisSensor == 'Curah Hujan') {
      defaultWaspada = 50.0;
      defaultSiaga = 100.0;
    }

    return {
      'waspada': prefs.getDouble(_keyWaspada(jenisSensor)) ?? defaultWaspada,
      'siaga': prefs.getDouble(_keySiaga(jenisSensor)) ?? defaultSiaga,
    };
  }
}
