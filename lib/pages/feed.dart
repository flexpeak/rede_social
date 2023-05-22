import 'package:flutter/material.dart';
import 'package:rede_social/pages/adicionar.dart';
import 'package:rede_social/pages/configuracoes.dart';
import 'package:rede_social/pages/home.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> with TickerProviderStateMixin {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: TabBarView(
          controller: TabController(
            length: 3,
            vsync: this,
            initialIndex: _currentIndex
          ),
          children: const [
            Home(),
            Adicionar(),
            Configuracoes(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Adicionar'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configurações'),
          ],
        ),
      ),
    );
  }
}
