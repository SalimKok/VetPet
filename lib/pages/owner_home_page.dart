// owner_home.dart
import 'package:flutter/material.dart';
import 'owner_appointments_page.dart';
import 'owner_pet_list_page.dart';
import 'owner_profile_page.dart';

class OwnerHome extends StatefulWidget {
  final int ownerId;
  const OwnerHome({required this.ownerId, Key? key}) : super(key: key);

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE),
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: const Color(0xFF81C784),
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF81C784),
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
        return "Evcil Dostlarım";
      case 1:
        return "Randevularım";
      case 2:
        return "Profil";
      case 3:
        return "Ayarlar";
      default:
        return "";
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return PetListPage(ownerId: widget.ownerId); // kendi Scaffold'u içinde
      case 1:
        return AppointmentPage(ownerId: widget.ownerId);
      case 2:
        return OwnerProfilePage(ownerId: widget.ownerId);
      case 3:
        return const Center(child: Text('Ayarlar'));
      default:
        return const SizedBox();
    }
  }
}
