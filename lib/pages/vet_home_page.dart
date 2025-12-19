import 'package:flutter/material.dart';
import 'package:petvet/pages/vet/vet_my_patients_page.dart';
import 'vet_clinics_page.dart';
import 'vet_appointments_page.dart';
import 'vet_profile_page.dart';

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
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE),

      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF22577A),
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
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return VetClinicsPage(vetId: widget.vetId);
      case 1:
        return VetMyPatientsPage(vetId: widget.vetId);
      case 2:
        return VetAppointmentsPage(vetId: widget.vetId);
      case 3:
        return VetProfilePage(vetId: widget.vetId);
      default:
        return const SizedBox();
    }
  }
}
