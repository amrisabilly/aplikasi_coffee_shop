import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Pages
import 'package:project_satu/presentation/pages/main/home/anggaran/anggaran_page.dart';
import 'package:project_satu/presentation/pages/main/menu/detail/detail_page.dart';
import 'package:project_satu/presentation/pages/main/profile/developer/developer_page.dart';
import 'package:project_satu/presentation/pages/main/home/explore/explore_page.dart';
import 'package:project_satu/presentation/pages/main/profile/game/game_page.dart';
import 'package:project_satu/presentation/pages/main/home/janjian/janjian_page.dart';
import 'package:project_satu/presentation/pages/main/menu/menu_page.dart';
import 'package:project_satu/presentation/pages/main/profile/riwayat_pesanan/riwayat_page.dart';
import 'package:project_satu/presentation/pages/main/profile/riwayat_pesanan/struk_page.dart';
import '../presentation/auth/login_page.dart';
import '../presentation/auth/register_page.dart';
import '../presentation/pages/main/home/home_page.dart';
import '../presentation/pages/main/order/order_page.dart';
import '../presentation/pages/main/profile/profile_page.dart';
import '../presentation/pages/widgets/navbar_widget.dart';
import '../presentation/splash/landing_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/landing',
  routes: [
    // ShellRoute untuk halaman utama dengan Navbar
    ShellRoute(
      builder: (context, state, child) {
        int index = 0;
        final location = state.uri.toString();
        if (location.startsWith('/menu')) {
          index = 1;
        } else if (location.startsWith('/orders')) {
          index = 2;
        } else if (location.startsWith('/profile')) {
          index = 3;
        }
        return NavbarWidget(currentIndex: index, child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(path: '/menu', builder: (context, state) => const MenuPage()),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrderPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/explore',
          builder: (context, state) => const ExplorePage(),
        ),
        GoRoute(
          path: '/anggaran',
          builder: (context, state) => const AnggaranPage(),
        ),
        GoRoute(
          path: '/janjian',
          builder: (context, state) => const JanjianPage(),
        ),
      ],
    ),

    // Auth & Landing
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(path: '/landing', builder: (context, state) => const LandingPage()),

    // Game & Developer
    GoRoute(path: '/game', builder: (context, state) => const GamiFikasi()),
    GoRoute(path: '/developer', builder: (context, state) => DeveloperPage()),

    // Detail produk (dengan parameter dan query)
    GoRoute(
      path: '/detail/:productId',
      builder: (context, state) {
        final productId = state.pathParameters['productId']!;
        final from = state.uri.queryParameters['from'] ?? 'home';
        return DetailPage(productId: productId, from: from);
      },
    ),

    // Riwayat pesanan & struk
    GoRoute(path: '/riwayat', builder: (context, state) => const RiwayatPage()),
    GoRoute(
      path: '/struk/:orderId',
      builder: (context, state) {
        final orderId = int.parse(state.pathParameters['orderId']!);
        return StrukPage(orderId: orderId);
      },
    ),
  ],
);
