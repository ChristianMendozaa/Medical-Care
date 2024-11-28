import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicre/Pages/diagnostics/my_diagnostics.dart';
import 'package:medicre/Pages/diagnostics/new_diagnostic.dart';
import 'package:medicre/Pages/user/userAccountPage.dart';
import 'package:medicre/blocs/diagnostic/diagnostic_bloc.dart';
import 'package:medicre/blocs/diagnostic/diagnostic_event.dart';
import 'package:medicre/widgets/drawer_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  double progressValue = 0.5; // Example progress for diagnostics (50%)

  @override
  void initState() {
    super.initState();
    _pages = [
      BlocProvider(
        create: (_) => DiagnosticBloc(),
        child: const NewDiagnosticPage(),
      ),
      BlocProvider(
        create: (_) => DiagnosticBloc()..add(LoadDiagnosticsEvent()),
        child: const MyDiagnosticsPage(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Care', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserAccountPage(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: DrawerMenu(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                // You can modify the progress based on the selected page
                progressValue = index == 1 ? 0.75 : 0.5; // Example: 75% progress in "Mis Diagnósticos"
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: _currentIndex == 0 ? 1.2 : 1.0,
                  child: Icon(
                    Icons.add_circle,
                    size: 30,
                    color: _currentIndex == 0 ? Colors.white : Colors.green,
                  ),
                ),
                label: 'Nuevo Diagnóstico',
                backgroundColor: _currentIndex == 0 ? Colors.blueAccent : Colors.white,
              ),
              BottomNavigationBarItem(
                icon: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: _currentIndex == 1 ? 1.2 : 1.0,
                  child: Icon(
                    Icons.list,
                    size: 30,
                    color: _currentIndex == 1 ? Colors.white : Colors.orange,
                  ),
                ),
                label: 'Mis Diagnósticos',
                backgroundColor: _currentIndex == 1 ? Colors.blueAccent : Colors.white,
              ),
            ],
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            backgroundColor: _currentIndex == 0 || _currentIndex == 1
                ? Colors.blueAccent
                : Colors.white,
            elevation: 10,
          ),
          // Barra de progreso debajo del BottomNavigationBar
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: Colors.grey[300],
            color: Colors.blueAccent,
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}
