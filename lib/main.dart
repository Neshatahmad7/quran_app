import 'package:flutter/material.dart';
import 'services/app_settings.dart';
import 'pages/home_page.dart';
import 'pages/quran_page.dart';
import 'pages/qibla_page.dart';
import 'pages/me_page.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await AppSettings.instance.load();
	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: AppSettings.instance,
			builder: (context, child) {
				return MaterialApp(
					title: 'Hidaya',
					theme: ThemeData(
						colorScheme: ColorScheme.fromSeed(
							seedColor: const Color(0xFF4CAF50),
							primary: const Color(0xFF81C784),
							onPrimary: Colors.white,
							surface: Colors.white,
							onSurface: Colors.black87,
							brightness: Brightness.light,
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
					darkTheme: ThemeData(
						colorScheme: ColorScheme.fromSeed(
							seedColor: const Color(0xFF4CAF50),
							primary: const Color(0xFF81C784),
							brightness: Brightness.dark,
						),
						useMaterial3: true,
						scaffoldBackgroundColor: const Color(0xFF121212),
						appBarTheme: AppBarTheme(
							backgroundColor: Colors.green.shade900,
							titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
							iconTheme: const IconThemeData(color: Colors.white),
						),
						bottomNavigationBarTheme: BottomNavigationBarThemeData(
							backgroundColor: Colors.black,
							selectedItemColor: const Color(0xFFB9F6CA),
							unselectedItemColor: Colors.grey,
							selectedIconTheme: const IconThemeData(color: Color(0xFFB9F6CA)),
							unselectedIconTheme: const IconThemeData(color: Colors.grey),
							showUnselectedLabels: true,
						),
					),
					themeMode: AppSettings.instance.themeMode,
					home: const AppShell(),
				);
			},
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

	@override
	void initState() {
		super.initState();
		WidgetsBinding.instance.addPostFrameCallback((_) {
			if (!AppSettings.instance.hasSelectedTheme) {
				_showThemeSelectionDialog();
			}
			if (!AppSettings.instance.hasSelectedLanguage) {
				_showLanguageSelectionDialog();
			}
		});
	}

	Future<void> _showLanguageSelectionDialog() async {
		String selected = AppSettings.instance.languageLabel;
		await showDialog<void>(
			context: context,
			barrierDismissible: false,
			builder: (context) {
				return StatefulBuilder(
					builder: (context, setState) {
						return AlertDialog(
							title: const Text('Choose app language'),
							content: Column(
								mainAxisSize: MainAxisSize.min,
								children: ['English', 'Dari/Persian', 'Pashto'].map((option) {
									return RadioListTile<String>(
										title: Text(option),
										value: option,
										groupValue: selected,
										onChanged: (value) {
											if (value != null) {
												setState(() => selected = value);
											}
										},
									);
								}).toList(),
							),
							actions: [
								ElevatedButton(
									onPressed: () {
									AppSettings.instance.setLanguage(selected);
									Navigator.pop(context);
								},
									child: const Text('Save'),
								),
							],
						);
					},
				);
			},
		);
	}

	Future<void> _showThemeSelectionDialog() async {
		String selected = AppSettings.instance.themeModeLabel;
		await showDialog<void>(
			context: context,
			barrierDismissible: false,
			builder: (context) {
				return StatefulBuilder(
					builder: (context, setState) {
						return AlertDialog(
							title: const Text('Choose app theme'),
							content: Column(
								mainAxisSize: MainAxisSize.min,
								children: ['System', 'Light', 'Dark'].map((option) {
									return RadioListTile<String>(
										title: Text(option),
										value: option,
										groupValue: selected,
										onChanged: (value) {
											if (value != null) {
												setState(() => selected = value);
											}
										},
									);
								}).toList(),
							),
							actions: [
								ElevatedButton(
									onPressed: () {
									AppSettings.instance.setThemeMode(selected);
									Navigator.pop(context);
								},
									child: const Text('Save'),
								),
							],
						);
					},
				);
			},
		);
	}

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