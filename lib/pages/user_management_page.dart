import 'package:flutter/material.dart';
import 'package:petvet/services/admin_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final AdminService _adminService = AdminService();

  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final data = await _adminService.fetchAllUsers();
      setState(() {
        users = data;
        isLoading = false;
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  // Kullanıcı Sil
  Future<void> _handleDeleteUser(int id, int index) async {
    final deletedUser = users[index];
    setState(() {
      users.removeAt(index);
    });

    try {
      await _adminService.deleteUser(id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kullanıcı başarıyla silindi"), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() => users.insert(index, deletedUser));
      _showError("Silinemedi: ${e.toString()}");
    }
  }

  void _showError(String message) {
    setState(() => isLoading = false);
    final cleanMessage = message.replaceAll("Exception: ", "");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(cleanMessage), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
      appBar: AppBar(
        title: const Text("Kullanıcı Yönetimi"),
        backgroundColor: const Color(0xFF4E342E),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text("Sistemde kayıtlı kullanıcı yok."))
          : ListView.builder(
        itemCount: users.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          final user = users[index];
          final isVet = user['role'] == 'vet';

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isVet ? Colors.orange[100] : Colors.green[100],
                child: Icon(
                  isVet ? Icons.medical_services : Icons.person,
                  color: isVet ? Colors.orange : Colors.green,
                ),
              ),
              title: Text(
                user['name'] ?? 'İsimsiz',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(user['email']),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _confirmDelete(user['id'], index),
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(int id, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Emin misiniz?"),
        content: const Text("Bu kullanıcı silinecek."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _handleDeleteUser(id, index);
            },
            child: const Text("Sil", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}