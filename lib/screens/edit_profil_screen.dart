import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

const _redDark   = Color(0xFF8B1A0A);
const _orange    = Color(0xFFF5A524);
const _textBlack = Color(0xFF1C1C1C);
const _textGray  = Color(0xFF888888);
const _cream     = Color(0xFFF7F0E6);

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});
  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _nameCtrl      = TextEditingController();
  final _panggilanCtrl = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _teleponCtrl   = TextEditingController();

  String _gender   = '';        // 'Laki-laki' | 'Perempuan'
  DateTime? _birthDate;
  bool _loading = true;
  bool _saving  = false;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _panggilanCtrl.dispose();
    _emailCtrl.dispose(); _teleponCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    _emailCtrl.text = user?.email ?? '';
    _nameCtrl.text  = user?.displayName ?? '';
    _panggilanCtrl.text = user?.displayName?.split(' ').first ?? '';

    if (_uid.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
        if (doc.exists) {
          final d = doc.data()!;
          _nameCtrl.text      = d['name']      ?? _nameCtrl.text;
          _panggilanCtrl.text = d['panggilan']  ?? _panggilanCtrl.text;
          _teleponCtrl.text   = d['telepon']    ?? '';
          _gender             = d['gender']     ?? '';
          final ts            = d['birthDate'];
          if (ts != null) _birthDate = (ts as dynamic).toDate();
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _snack('Nama tidak boleh kosong.', isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      // Update Firebase Auth display name
      await FirebaseAuth.instance.currentUser?.updateDisplayName(_nameCtrl.text.trim());

      // Save to Firestore users collection
      await FirebaseFirestore.instance.collection('users').doc(_uid).set({
        'name':      _nameCtrl.text.trim(),
        'panggilan': _panggilanCtrl.text.trim(),
        'email':     _emailCtrl.text.trim(),
        'telepon':   _teleponCtrl.text.trim(),
        'gender':    _gender,
        'birthDate': _birthDate,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _snack('Profil berhasil disimpan! ✅');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _snack('Gagal menyimpan: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
      backgroundColor: isError ? const Color(0xFFE8331A) : const Color(0xFF2BB84A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: now,
      locale: const Locale('id', 'ID'),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: _orange, onPrimary: Colors.white),
          dialogTheme: const DialogThemeData(shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)))),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '';
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agt','Sep','Okt','Nov','Des'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Column(children: [
        // ── Header
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFFD63010), _redDark]),
          ),
          child: Stack(children: [
            Positioned.fill(child: _blobs()),
            SafeArea(bottom: false, child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 20, 14),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Text('Edit Profil',
                    style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
              ]),
            )),
          ]),
        ),

        // ── Body
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: _orange))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(children: [
                    // Avatar card
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)]),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(children: [
                        Stack(children: [
                          Container(width: 76, height: 76,
                              decoration: const BoxDecoration(color: Color(0xFFF5C842), shape: BoxShape.circle),
                              child: const Center(child: Text('👧', style: TextStyle(fontSize: 38)))),
                          Positioned(bottom: 2, right: 2, child: Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(color: _orange, shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2)),
                            child: const Center(child: Text('✏', style: TextStyle(fontSize: 12))),
                          )),
                        ]),
                        const SizedBox(height: 6),
                        Text('Tap untuk ganti foto',
                            style: GoogleFonts.nunito(fontSize: 12, color: _textGray)),
                      ]),
                    ),

                    // ── Text fields
                    _inputField('NAMA LENGKAP', _nameCtrl, hint: 'Masukkan nama lengkap'),
                    _inputField('NAMA PANGGILAN', _panggilanCtrl, hint: 'Nama panggilan'),
                    _inputField('EMAIL', _emailCtrl, hint: 'email@example.com',
                        keyboard: TextInputType.emailAddress, readOnly: true),
                    _inputField('NO. TELEPON', _teleponCtrl, hint: '08xx-xxxx-xxxx',
                        keyboard: TextInputType.phone),

                    // ── Jenis Kelamin
                    _label('JENIS KELAMIN'),
                    Row(children: [
                      _genderChip('Laki-laki', '👦'),
                      const SizedBox(width: 10),
                      _genderChip('Perempuan', '👧'),
                    ]),
                    const SizedBox(height: 14),

                    // ── Tanggal Lahir
                    _label('TANGGAL LAHIR'),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: _birthDate != null ? _orange : const Color(0xFFEAEAEA), width: 1.5),
                        ),
                        child: Row(children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 18, color: _birthDate != null ? _orange : _textGray),
                          const SizedBox(width: 10),
                          Text(
                            _birthDate != null ? _fmtDate(_birthDate) : 'Pilih tanggal lahir...',
                            style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _birthDate != null ? _textBlack : _textGray),
                          ),
                          const Spacer(),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              color: _birthDate != null ? _orange : _textGray),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          elevation: 0,
                        ),
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(width: 22, height: 22,
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

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 2),
    child: Align(alignment: Alignment.centerLeft,
      child: Text(t, style: GoogleFonts.nunito(
          fontSize: 11, fontWeight: FontWeight.w800,
          color: const Color(0xFFAAAAAA), letterSpacing: 1.1))),
  );

  Widget _inputField(String label, TextEditingController ctrl,
      {String hint = '', TextInputType keyboard = TextInputType.text, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label(label),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          readOnly: readOnly,
          style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: _textBlack),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.nunito(fontSize: 14, color: _textGray),
            filled: true,
            fillColor: readOnly ? const Color(0xFFF5F5F5) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFEAEAEA))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFEAEAEA), width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: readOnly ? const Color(0xFFEAEAEA) : _orange, width: 1.5)),
          ),
        ),
      ]),
    );
  }

  Widget _genderChip(String label, String emoji) {
    final selected = _gender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _orange : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: selected ? _orange : const Color(0xFFEAEAEA), width: 1.5),
            boxShadow: selected
                ? [BoxShadow(color: _orange.withValues(alpha: 0.3), blurRadius: 10)]
                : [],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700, fontSize: 14,
                color: selected ? Colors.white : _textBlack)),
          ]),
        ),
      ),
    );
  }
}

Widget _blobs() => Stack(children: [
  Positioned(right: -35, top: -55,
      child: Container(width: 170, height: 170,
          decoration: BoxDecoration(shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.07)))),
  Positioned(right: 75, bottom: 5,
      child: Container(width: 110, height: 110,
          decoration: BoxDecoration(shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05)))),
]);
