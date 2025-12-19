import 'package:flutter/material.dart';
import 'owner_clinic_search_page.dart';
import 'owner_appointments_page.dart';
import 'owner_pet_list_page.dart';
import 'owner_profile_page.dart';

class OwnerHomePage extends StatefulWidget {
  final int ownerId;
  const OwnerHomePage({required this.ownerId, Key? key}) : super(key: key);

  @override
  State<OwnerHomePage> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF22577A),
        unselectedItemColor: Colors.brown,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Evcil Hayvanlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Randevular',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Klinik Bul',
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
        return PetListPage(ownerId: widget.ownerId);
      case 1:
        return AppointmentPage(ownerId: widget.ownerId);
      case 2:
        return OwnerClinicSearchPage(ownerId: widget.ownerId);
      case 3:
        return OwnerProfilePage(ownerId: widget.ownerId);
      default:
        return const SizedBox();
    }
  }
}