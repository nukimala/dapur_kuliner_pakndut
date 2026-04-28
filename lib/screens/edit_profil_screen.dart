import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

const _red       = Color(0xFFC0321A);
const _redDark   = Color(0xFF8B1A0A);
const _orange    = Color(0xFFF5A524);
const _cream     = Color(0xFFF7F0E6);
const _textBlack = Color(0xFF1C1C1C);
const _textGray  = Color(0xFF888888);

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});
  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String  _avatar         = '👤';
  String? _photoBase64;   // disimpan langsung di Firestore
  File?   _pickedImage;
  bool    _loading        = true;
  bool    _saving         = false;
  bool    _uploadingPhoto = false;

  final List<String> _avatarOptions = [
    '👤','👦','👧','👨','👩','👴','👵',
    '🧑‍🍳','😎','🤠','🥷','🦸','🧑‍💻','🧑‍🎨',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Load profil dari Firestore ──
  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _nameCtrl.text  = user.displayName ?? user.email?.split('@').first ?? '';
    _phoneCtrl.text = user.phoneNumber ?? '';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _avatar      = (data['avatar']      as String?) ?? '👤';
          _photoBase64 = (data['photoBase64'] as String?);
          final storedName  = data['name']  as String?;
          final storedPhone = data['phone'] as String?;
          if (_nameCtrl.text.isEmpty  && (storedName  ?? '').isNotEmpty) _nameCtrl.text  = storedName!;
          if (_phoneCtrl.text.isEmpty && (storedPhone ?? '').isNotEmpty) _phoneCtrl.text = storedPhone!;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  // ── Pilih foto dari galeri & simpan sebagai base64 ──
  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 75,
    );
    if (picked == null) return;

    setState(() {
      _pickedImage    = File(picked.path);
      _uploadingPhoto = true;
    });

    try {
      final uid   = FirebaseAuth.instance.currentUser!.uid;
      final bytes = await _pickedImage!.readAsBytes();
      final b64   = base64Encode(bytes);

      // Simpan base64 langsung ke Firestore (tidak perlu Firebase Storage)
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'photoBase64': b64, 'avatar': _avatar},
        SetOptions(merge: true),
      );

      if (mounted) {
        setState(() {
          _photoBase64    = b64;
          _uploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto profil berhasil diperbarui!',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan foto: $e',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
            backgroundColor: _red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // ── Hapus foto & kembali ke emoji ──
  Future<void> _removePhoto() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'photoBase64': FieldValue.delete(),
      });
      if (mounted) setState(() { _photoBase64 = null; _pickedImage = null; });
    } catch (_) {}
  }

  // ── Bottom sheet pilih sumber avatar ──
  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AvatarPickerSheet(
        currentAvatar: _avatar,
        hasPhoto: _photoBase64 != null,
        onPickGallery: () { Navigator.pop(context); _pickFromGallery(); },
        onPickEmoji: (e)  { Navigator.pop(context); setState(() => _avatar = e); },
        onRemovePhoto: ()  { Navigator.pop(context); _removePhoto(); },
        avatarOptions: _avatarOptions,
      ),
    );
  }

  // ── Simpan profil ──
  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      final name = _nameCtrl.text.trim();
      if (name.isNotEmpty) {
        await FirebaseAuth.instance.currentUser!.updateDisplayName(name);
      }
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'avatar': _avatar,
        'name':   name,
        'phone':  _phoneCtrl.text.trim(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profil berhasil disimpan!',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menyimpan: $e',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Widget avatar ──
  Widget _buildAvatar() {
    Widget inner;
    if (_uploadingPhoto) {
      inner = const Center(child: CircularProgressIndicator(color: _orange, strokeWidth: 3));
    } else if (_pickedImage != null && _photoBase64 != null) {
      inner = ClipOval(child: Image.file(_pickedImage!, width: 90, height: 90, fit: BoxFit.cover));
    } else if (_photoBase64 != null) {
      try {
        final bytes = base64Decode(_photoBase64!);
        inner = ClipOval(child: Image.memory(bytes, width: 90, height: 90, fit: BoxFit.cover));
      } catch (_) {
        inner = Center(child: Text(_avatar, style: const TextStyle(fontSize: 48)));
      }
    } else {
      inner = Center(child: Text(_avatar, style: const TextStyle(fontSize: 48)));
    }

    return GestureDetector(
      onTap: _showAvatarPicker,
      child: Stack(children: [
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F0E0), shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 10)],
          ),
          child: inner,
        ),
        Positioned(
          bottom: 2, right: 2,
          child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: _orange, shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Center(child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14)),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _cream,
        body: Center(child: CircularProgressIndicator(color: _orange)),
      );
    }

    return Scaffold(
      backgroundColor: _cream,
      body: Column(children: [
        // ── Header ──
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFFD63010), _redDark],
            ),
          ),
          child: Stack(children: [
            Positioned.fill(child: _blobsBg()),
            SafeArea(
              bottom: false,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 6, 20, 0),
                  child: Row(children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('Edit Profil',
                        style: GoogleFonts.nunito(
                            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                  child: Column(children: [
                    _buildAvatar(),
                    const SizedBox(height: 8),
                    Text('Ketuk untuk ubah foto',
                        style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12)),
                  ]),
                ),
              ]),
            ),
          ]),
        ),

        // ── Form ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
            child: Column(children: [
              _fieldCard(
                icon: Icons.person_outline_rounded,
                label: 'Nama Lengkap',
                child: TextField(
                  controller: _nameCtrl,
                  style: GoogleFonts.nunito(
                      fontSize: 15, color: _textBlack, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama kamu',
                    hintStyle: GoogleFonts.nunito(color: _textGray, fontSize: 14),
                    border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _fieldCard(
                icon: Icons.phone_outlined,
                label: 'Nomor Telepon',
                child: TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.nunito(
                      fontSize: 15, color: _textBlack, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Contoh: 08123456789',
                    hintStyle: GoogleFonts.nunito(color: _textGray, fontSize: 14),
                    border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _fieldCard(
                icon: Icons.email_outlined,
                label: 'Email',
                child: Text(
                  FirebaseAuth.instance.currentUser?.email ?? '-',
                  style: GoogleFonts.nunito(
                      fontSize: 15, color: _textGray, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                  child: _saving
                      ? const SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text('Simpan Perubahan',
                          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _fieldCard({required IconData icon, required String label, required Widget child}) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: const Color(0xFFFFF0DC), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: _orange, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: GoogleFonts.nunito(fontSize: 11, color: _textGray, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              child,
            ]),
          ),
        ]),
      );
}

// ── Bottom Sheet pilih avatar ──
class _AvatarPickerSheet extends StatelessWidget {
  final String currentAvatar;
  final bool hasPhoto;
  final VoidCallback onPickGallery;
  final ValueChanged<String> onPickEmoji;
  final VoidCallback onRemovePhoto;
  final List<String> avatarOptions;

  const _AvatarPickerSheet({
    required this.currentAvatar, required this.hasPhoto,
    required this.onPickGallery, required this.onPickEmoji,
    required this.onRemovePhoto, required this.avatarOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 18),
        Text('Ubah Foto Profil',
            style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: _textBlack)),
        const SizedBox(height: 20),

        _optionTile(
          icon: Icons.photo_library_rounded,
          iconBg: const Color(0xFFE8F5E9), iconColor: Colors.green.shade700,
          title: 'Pilih dari Galeri', sub: 'Gunakan foto dari album kamu',
          onTap: onPickGallery,
        ),

        if (hasPhoto) ...[
          const SizedBox(height: 10),
          _optionTile(
            icon: Icons.delete_outline_rounded,
            iconBg: const Color(0xFFFFE8E5), iconColor: _red,
            title: 'Hapus Foto Profil', sub: 'Kembali ke avatar emoji',
            onTap: onRemovePhoto,
          ),
        ],

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(children: [
            Expanded(child: Divider(color: Colors.grey[200])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('atau pilih avatar',
                  style: GoogleFonts.nunito(fontSize: 12, color: _textGray, fontWeight: FontWeight.w600)),
            ),
            Expanded(child: Divider(color: Colors.grey[200])),
          ]),
        ),

        Wrap(
          spacing: 10, runSpacing: 10,
          children: avatarOptions.map((emoji) {
            final selected = emoji == currentAvatar;
            return GestureDetector(
              onTap: () => onPickEmoji(emoji),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFFFF0DC) : const Color(0xFFF7F0E6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? _orange : Colors.transparent, width: 2.5),
                  boxShadow: selected
                      ? [BoxShadow(color: _orange.withValues(alpha: 0.25), blurRadius: 8)]
                      : [],
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }

  Widget _optionTile({required IconData icon, required Color iconBg,
      required Color iconColor, required String title, required String sub,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(width: 46, height: 46,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: iconColor, size: 24)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 15, color: _textBlack)),
            const SizedBox(height: 2),
            Text(sub, style: GoogleFonts.nunito(fontSize: 12, color: _textGray)),
          ])),
          const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
        ]),
      ),
    );
  }
}

Widget _blobsBg() => Stack(children: [
  Positioned(right: -35, top: -55,
      child: Container(width: 170, height: 170,
          decoration: BoxDecoration(shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.07)))),
  Positioned(right: 75, bottom: 5,
      child: Container(width: 110, height: 110,
          decoration: BoxDecoration(shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05)))),
]);
