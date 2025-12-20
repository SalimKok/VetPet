import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petvet/pages/settings_page.dart';
import '../../services/user_service.dart';
import '../../services/api_service.dart';
import '../login_page.dart';

class OwnerProfilePage extends StatefulWidget {
  final int ownerId;
  const OwnerProfilePage({required this.ownerId, Key? key}) : super(key: key);

  @override
  State<OwnerProfilePage> createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await UserService.getUserProfile(widget.ownerId);
    if (data != null) {
      setState(() {
        profileData = data;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil bilgileri alınamadı")),
      );
    }
  }

  ImageProvider? _getProfileImage() {
    if (profileData != null && profileData!["photo_url"] != null && profileData!["photo_url"].toString().isNotEmpty) {
      String url = profileData!["photo_url"].toString();
      if (!url.startsWith('http')) url = ApiService.baseUrl + url;
      url = url.replaceAll("localhost", "10.0.2.2");
      return NetworkImage(url);
    }
    return null;
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _openEditModal() {
    if (profileData == null) return;

    final TextEditingController nameController = TextEditingController(text: profileData!["name"]);
    final TextEditingController emailController = TextEditingController(text: profileData!["email"]);
    final TextEditingController phoneController = TextEditingController(text: profileData!["phone"]);
    File? selectedImage;
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      backgroundColor: const Color(0xFFECE8D9),
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Profili Düzenle", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown)),
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF22577A).withOpacity(0.4),
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!)
                            : _getProfileImage(),
                        child: (selectedImage == null && _getProfileImage() == null)
                            ? const Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () async {
                            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                            if (image != null) setModalState(() => selectedImage = File(image.path));
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF22577A),
                            child: const Icon(Icons.edit, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(label: "Ad Soyad", controller: nameController),
                  _buildTextField(label: "E-posta", controller: emailController, keyboardType: TextInputType.emailAddress),
                  _buildTextField(label: "Telefon", controller: phoneController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final String name = nameController.text.trim();
                          final String email = emailController.text.trim();
                          final String phone = phoneController.text.trim();

                          // Boş alan var mı?
                          if (name.isEmpty || email.isEmpty || phone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Lütfen tüm alanları doldurun!"),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom + 450,
                                  right: 20,
                                  left: 20,
                                ),
                              ),
                            );
                            return;
                          }

                          bool isValidEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
                          if (!isValidEmail) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Geçerli bir e-posta adresi giriniz!"),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom + 450,
                                  right: 20,
                                  left: 20,
                                ),
                              ),
                            );
                            return;
                          }

                          // Telefon numarası çok mu kısa?
                          if (phone.length < 10) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Telefon numarası en az 10 haneli olmalıdır!"),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom + 450,
                                  right: 20,
                                  left: 20,
                                ),
                              ),
                            );
                            return;
                          }
                          final updatedData = {
                            "name": nameController.text,
                            "email": emailController.text,
                            "phone": phoneController.text,
                            "photo": selectedImage
                          };
                          final success = await UserService.updateUserProfile(widget.ownerId, updatedData);
                          if (success) {
                            setState(() {
                              profileData!.addAll({
                                "name": updatedData["name"],
                                "email": updatedData["email"],
                                "phone": updatedData["phone"],
                                "photo_url": selectedImage != null ? selectedImage?.path : profileData!["photo_url"]
                              });
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Profil güncellendi!")),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Güncelleme başarısız!")),
                            );
                          }
                        },
                        icon: const Icon(Icons.save,color: const Color(0xFFFFFFFF),),
                        label: const Text("Kaydet",style: TextStyle(color:  const Color(0xFFFFFFFF))),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close,color: const Color(0xFFFFFFFF),),
                        label: const Text("İptal",style: TextStyle(color:  const Color(0xFFFFFFFF))),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (profileData == null) return const Scaffold(body: Center(child: Text("Profil verisi bulunamadı")));

    final profile = profileData!;
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
      appBar: AppBar(
        title: const Text("Profilim",style: TextStyle(color:  const Color(0xFFFFFFFF))),
        backgroundColor: const Color(0xFF22577A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: "Ayarlar",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage(userRole: "owner")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF22577A).withOpacity(0.4),
                backgroundImage: _getProfileImage(),
                child: _getProfileImage() == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(profile["name"] ?? "Bilinmiyor", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown)),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.phone, "Telefon", profile["phone"] ?? "—"),
                    const Divider(),
                    _buildInfoRow(Icons.email, "E-posta", profile["email"] ?? "—"),
                    const Divider(),
                    _buildInfoRow(Icons.calendar_today, "Kayıt Tarihi", profile["joined"] ?? "—"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openEditModal,
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text("Profili Düzenle",style: TextStyle(color:  const Color(0xFFFFFFFF))),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22577A),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.brown),
              label: const Text("Çıkış Yap",style: TextStyle(color: Colors.brown, fontWeight: FontWeight.w600, fontSize: 16),),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF22577A)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown))),
        Text(value, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }
}
