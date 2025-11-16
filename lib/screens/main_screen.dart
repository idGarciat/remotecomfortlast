import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.of(context).pushNamed('/dashboard-screen');
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1173D4);
    const backgroundDark = Color(0xFF101922);

    final titles = ['Inicio', 'Dashboard'];

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(titles[_selectedIndex], style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: const SizedBox(width: 12),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
            color: Colors.grey,
          )
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
            children: [
              _buildHome(context),
              _buildDashboardTab(context),
            ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: backgroundDark,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey[400],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    const primary = Color(0xFF1173D4);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Administración', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),

          // Cards
          _buildCard(primary, Icons.person, 'Usuarios', 'Administrar usuarios', onTap: () {
            Navigator.of(context).pushNamed('/users');
          }),
          const SizedBox(height: 8),
          _buildCard(primary, Icons.face, 'Reconocimiento facial', 'Configurar reconocimiento facial', onTap: () {
            Navigator.of(context).pushNamed('/face-config');
          }),
          const SizedBox(height: 16),
          const Text('Dispositivos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          _buildCard(primary, Icons.dashboard, 'Dashboard', 'Ver panel', onTap: () {
            Navigator.of(context).pushNamed('/dashboard-screen');
          }),
        ],
      ),
    );
  }

  // devices tab removed — only Home and Dashboard remain

  Widget _buildDashboardTab(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Dashboard (placeholder)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Contenido del dashboard se implementará más adelante', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Color primary, IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.03 * 255).round()),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
                  decoration: BoxDecoration(color: primary.withAlpha((0.18 * 255).round()), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[400])),
              ],
            )
          ],
        ),
      ),
    );
  }

}
