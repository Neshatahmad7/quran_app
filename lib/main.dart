import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/quran_page.dart';
import 'pages/qibla_page.dart';
import 'pages/me_page.dart';

void main() {
	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Hidaya',
			theme: ThemeData(
				colorScheme: ColorScheme.fromSeed(
					seedColor: const Color(0xFF4CAF50),
					primary: const Color(0xFF81C784),
					onPrimary: Colors.white,
					surface: Colors.white,
					onSurface: Colors.black87,
				),
				useMaterial3: true,
				appBarTheme: const AppBarTheme(
					backgroundColor: Color(0xFF2E7D32),
					titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
					iconTheme: IconThemeData(color: Colors.white),
				),
				bottomNavigationBarTheme: const BottomNavigationBarThemeData(
					backgroundColor: Color(0xFF1B5E20),
					selectedItemColor: Color(0xFFB9F6CA),
					unselectedItemColor: Color(0xFFB2DFDB),
					selectedIconTheme: IconThemeData(color: Color(0xFFB9F6CA)),
					unselectedIconTheme: IconThemeData(color: Color(0xFFB2DFDB)),
					showUnselectedLabels: true,
				),
			),
			home: const AppShell(),
		);
	}
}

class AppShell extends StatefulWidget {
	const AppShell({super.key});

	@override
	State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
	int _selectedIndex = 0;

	static const List<String> _titles = ['Home', 'Quran', 'Qibla', 'Me'];

	final List<Widget> _pages = const [
		HomePage(),
		QuranPage(),
		QiblaPage(),
		MePage(),
	];

	void _onItemTapped(int index) {
		setState(() {
			_selectedIndex = index;
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text(_titles[_selectedIndex])),
			body: _pages[_selectedIndex],
			bottomNavigationBar: BottomNavigationBar(
				type: BottomNavigationBarType.fixed,
				currentIndex: _selectedIndex,
				onTap: _onItemTapped,
				items: const [
					BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
					BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Quran'),
					BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Qibla'),
					BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
				],
			),
		);
	}
}