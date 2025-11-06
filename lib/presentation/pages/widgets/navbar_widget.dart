import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavbarWidget extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const NavbarWidget({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  static const tabs = ['/home', '/menu', '/orders', '/profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: Color(0xFFC67C4E),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (index) {
          if (index != currentIndex) {
            context.go(tabs[index]);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.coffee), label: 'Menu'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
