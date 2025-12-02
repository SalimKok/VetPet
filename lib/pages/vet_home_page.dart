import 'package:flutter/material.dart';
import 'package:petvet/pages/vet_my_patients_page.dart';
import 'vet_clinics_page.dart';
import 'vet_appointments_page.dart';
import 'vet_profile_page.dart';
import 'vet_settings_page.dart';

class VetHomePage extends StatefulWidget {
  final int vetId;
  const VetHomePage({required this.vetId, Key? key}) : super(key: key);

  @override
  State<VetHomePage> createState() => _VetHomePageState();
}

class _VetHomePageState extends State<VetHomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      VetClinicsPage(vetId: widget.vetId),
      VetMyPatientsPage(vetId: widget.vetId),
      VetAppointmentsPage(vetId: widget.vetId),
      VetProfilePage(vetId:widget.vetId),
      VetSettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE),
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: const Color(0xFF81C784),
        elevation: 0,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF81C784),
        unselectedItemColor: Colors.brown,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Klinikler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sick),
            label: 'Hastalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Randevular',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return "Kliniklerim";
      case 1:
        return "Hastalarım";
      case 2:
        return "Randevularım";
      case 3:
        return "Profil";
      case 4:
        return "Ayarlar";
      default:
        return "";
    }
  }
}
