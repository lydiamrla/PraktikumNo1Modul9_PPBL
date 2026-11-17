import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/sensor_cubit.dart';
import 'helpers/hive_helper.dart';
import 'pages/halaman_dashboard.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.instance.init();
  runApp(const AiotPeringatanDiniApp());
}

class AiotPeringatanDiniApp extends StatelessWidget {
  const AiotPeringatanDiniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SensorCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AIoT Peringatan Dini BPBD',
        theme: AppTheme.darkTheme,
        home: const HalamanDashboard(),
      ),
    );
  }
}