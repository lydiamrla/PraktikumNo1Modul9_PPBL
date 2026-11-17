import 'package:hive_flutter/hive_flutter.dart';
import '../models/pembacaan_sensor.dart';

class HiveHelper {
  HiveHelper._();
  static final HiveHelper instance = HiveHelper._();

  static const String namaBoxSensor = 'pembacaanSensorBox';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PembacaanSensorAdapter());
    await Hive.openBox<PembacaanSensor>(namaBoxSensor);
  }

  Box<PembacaanSensor> get box => Hive.box<PembacaanSensor>(namaBoxSensor);
}