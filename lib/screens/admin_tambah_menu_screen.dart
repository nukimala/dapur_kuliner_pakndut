import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

const _red     = Color(0xFFC0321A);
const _redDark = Color(0xFF8B1A0A);
const _orange  = Color(0xFFF5A524);
const _cream   = Color(0xFFF7F0E6);
const _textBlack = Color(0xFF1C1C1C);
const _textMid   = Color(0xFF555555);
const _textGray  = Color(0xFF888888);

class AdminTambahMenuScreen extends StatefulWidget {
  const AdminTambahMenuScreen({super.key});

  @override
  State<AdminTambahMenuScreen> createState() => _AdminTambahMenuScreenState();
}

class _AdminTambahMenuScreenState extends State<AdminTambahMenuScreen> {
  final _namaCtrl  = TextEditingController();
  final _hargaCtrl = TextEditingController(text: '1000');
  final _imgCtrl   = TextEditingController();
  String _kategori = '';
  bool _saving = false;

  @override
  void dispose() {
    _namaCtrl.dispose(); _hargaCtrl.dispose(); _imgCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_namaCtrl.text.trim().isEmpty) {
      _snack('Nama menu tidak boleh kosong.', isError: true);
      return;
    }
    if (_kategori.isEmpty) {
      _snack('Pilih kategori terlebih dahulu.', isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('menus').add({
        'name':        _namaCtrl.text.trim(),
        'description': '',
        'price':       double.tryParse(_hargaCtrl.text) ?? 0,
        'imageUrl':    _imgCtrl.text.trim(),
        'category':    _kategori,
        'createdAt':   FieldValue.serverTimestamp(),
      });
      _snack('Menu berhasil ditambahkan! ✅');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _snack('Gagal menyimpan: $e', isError: true);
      setState(() => _saving = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
      backgroundColor: isError ? _red : const Color(0xFF2BB84A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 1),
    child: Text(t, style: GoogleFonts.nunito(
        fontSize: 11, fontWeight: FontWeight.w800,
        color: const Color(0xFFAAAAAA), letterSpacing: 1.1)),
  );

  InputDecoration _deco({String hint = ''}) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.nunito(fontSize: 14, color: _textGray),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 1.5)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _orange, width: 1.5)),
  );

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
            Positioned(right: -30, top: -50, child: Container(width: 160, height: 160,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07)))),
            SafeArea(bottom: false, child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 20, 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Tambah Menu Baru',
                        style: GoogleFonts.nunito(color: Colors.white,
                            fontWeight: FontWeight.w800, fontSize: 20)),
                    Text('Lengkapi info Menu',
                        style: GoogleFonts.nunito(color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 12)),
                  ]),
                ]),
              ]),
            )),
          ]),
        ),

        // ── Body
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // fake upload area
            _label('FOTO MENU'),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFAF6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCCCCCC), width: 2,
                      style: BorderStyle.solid),
                ),
                child: Column(children: [
                  const Text('📷', style: TextStyle(fontSize: 38, color: Color(0xFFBBBBBB))),
                  const SizedBox(height: 8),
                  Text('Tap upload foto menu',
                    style: GoogleFonts.nunito(fontSize: 14, color: const Color(0xFFAAAAAA), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('JPG, PNG. Maks 10MB',
                    style: GoogleFonts.nunito(fontSize: 12, color: const Color(0xFFBBBBBB))),
                ]),
              ),
            ),
            const SizedBox(height: 14),

            // URL gambar (alternatif)
            _label('URL GAMBAR (OPSIONAL)'),
            TextField(
              controller: _imgCtrl,
              style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: _textBlack),
              decoration: _deco(hint: 'https://...'),
            ),
            const SizedBox(height: 12),

            // Nama
            _label('NAMA MENU'),
            TextField(
              controller: _namaCtrl,
              style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: _textBlack),
              decoration: _deco(hint: 'Pentol Bakar'),
            ),
            const SizedBox(height: 12),

            // Kategori
            _label('KATEGORI'),
            DropdownButtonFormField<String>(
              initialValue: _kategori.isEmpty ? null : _kategori,
              hint: Text('-----Pilih Kategori-----',
                style: GoogleFonts.nunito(fontSize: 14, color: _textGray)),
              items: ['Makanan', 'Minuman'].map((c) =>
                DropdownMenuItem(value: c,
                  child: Text(c, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: _textBlack)))).toList(),
              onChanged: (v) => setState(() => _kategori = v ?? ''),
              decoration: _deco(),
              style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: _textBlack),
              dropdownColor: Colors.white,
            ),
            const SizedBox(height: 12),

            // Harga
            _label('HARGA (RP)'),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDE8),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                  border: const Border(
                    top: BorderSide(color: Color(0xFFE8E8E8), width: 1.5),
                    bottom: BorderSide(color: Color(0xFFE8E8E8), width: 1.5),
                    left: BorderSide(color: Color(0xFFE8E8E8), width: 1.5),
                  ),
                ),
                child: Text('RP', style: GoogleFonts.nunito(
                    fontSize: 13, fontWeight: FontWeight.w700, color: _textMid)),
              ),
              Expanded(child: TextField(
                controller: _hargaCtrl, keyboardType: TextInputType.number,
                style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: _textBlack),
                decoration: InputDecoration(
                  filled: true, fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(14)),
                    borderSide: BorderSide(color: Color(0xFFE8E8E8))),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(14)),
                    borderSide: BorderSide(color: Color(0xFFE8E8E8), width: 1.5)),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(14)),
                    borderSide: BorderSide(color: _orange, width: 1.5)),
                ),
              )),
            ]),
            const SizedBox(height: 22),

            // Save btn
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _red, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ).copyWith(backgroundColor: WidgetStateProperty.all(_red)),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text('Simpan Menu',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('Batal',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16, color: _textGray)),
              ),
            ),
          ]),
        )),
      ]),
    );
  }
}
