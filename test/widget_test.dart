import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_satu/main.dart';

void main() {
  testWidgets('AppBar and body text appear', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Cek judul AppBar
    expect(find.text('Login'), findsOneWidget);

    // Cek teks di body
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Cek tombol login
    expect(find.text('Login'), findsNWidgets(2)); // AppBar dan tombol
  });
}