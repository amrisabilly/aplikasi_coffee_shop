import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routes/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'order_channel',
      channelName: 'Order Notifications',
      channelDescription: 'Notifikasi pesanan kopi',
      defaultColor: Color(0xFFC67C4E),
      importance: NotificationImportance.High,
      channelShowBadge: true,
    ),
  ], debug: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Aplikasi Coffe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.soraTextTheme()),
      routerConfig: router,
    );
  }
}
