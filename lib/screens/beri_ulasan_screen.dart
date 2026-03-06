import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _redDark  = Color(0xFF8B1A0A);
const _orange   = Color(0xFFF5A524);
const _orangeL  = Color(0xFFFFCA57);
const _redBtn   = Color(0xFFE8331A);
const _textBlack = Color(0xFF1C1C1C);
const _textGray  = Color(0xFF888888);
const _textMid   = Color(0xFF555555);

class BeriUlasanScreen extends StatefulWidget {
  const BeriUlasanScreen({super.key});
  @override
  State<BeriUlasanScreen> createState() => _BeriUlasanScreenState();
}

class _BeriUlasanScreenState extends State<BeriUlasanScreen> {
  int _rating = 4;
  List<String> _selected = ['Mudah digunakan', 'Harga Terjangkau'];
  final _textCtrl = TextEditingController(text: 'Aplikasinya sangat mudah digunakan\ndan, sangat memuaskan');

  final _tags = ['Mudah digunakan', 'Harga Terjangkau', 'Tampilan Menarik', 'CS responsif'];
  final _labels = ['Sangat Buruk', 'Buruk', 'Cukup', 'Sangat Bagus', 'Sempurna'];

  void _toggleTag(String t) => setState(
    () => _selected.contains(t) ? _selected.remove(t) : _selected.add(t));

  @override
  void dispose() { _textCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F0E6),
      body: Column(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFFD63010), _redDark]),
          ),
          child: Stack(children: [
            Positioned.fill(child: _blobs()),
            SafeArea(bottom: false, child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 20, 0),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text('Beri Ulasan', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(children: [
                  const Text('⭐👍', style: TextStyle(fontSize: 50)),
                  const SizedBox(height: 10),
                  Text('Bagaimana Pengalamanmu?', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                  const SizedBox(height: 6),
                  Text('Ulasanmu sangat berarti untuk kami terus berkembang menjadi lebih baik!',
                      textAlign: TextAlign.center, style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13, height: 1.55)),
                ]),
              ),
            ])),
          ]),
        ),

        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Rating card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
              child: Column(children: [
                Text('BERI PENILAIAN', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFFAAAAAA), letterSpacing: 1.2)),
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('⭐', style: TextStyle(fontSize: 42, color: i < _rating ? null : Colors.grey.withValues(alpha: 0.3))),
                  ),
                ))),
                const SizedBox(height: 10),
                Text(_labels[_rating - 1], style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: _orange, fontSize: 17)),
              ]),
            ),
            const SizedBox(height: 14),

            // Tags
            Text('APA YANG KAMU SUKA?', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFFAAAAAA), letterSpacing: 1.1)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: _tags.map((t) {
              final on = _selected.contains(t);
              return GestureDetector(
                onTap: () => _toggleTag(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: on ? _redBtn : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: on ? _redBtn : const Color(0xFFDDDDDD), width: 1.5),
                  ),
                  child: Text(t, style: GoogleFonts.nunito(color: on ? Colors.white : _textMid, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              );
            }).toList()),
            const SizedBox(height: 14),

            // Text review
            Text('CERITAKAN PENGALAMANMU', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFFAAAAAA), letterSpacing: 1.1)),
            const SizedBox(height: 8),
            TextField(
              controller: _textCtrl,
              maxLines: 4,
              style: GoogleFonts.nunito(fontSize: 14, color: _textBlack, height: 1.6),
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFEAEAEA))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFEAEAEA), width: 1.5)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _orange, width: 1.5)),
              ),
            ),
            const SizedBox(height: 18),
            _orangeBtn('Kirim Ulasan', () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Terima kasih atas ulasanmu! ⭐'),
                backgroundColor: Color(0xFF2BB84A),
              ));
              Navigator.pop(context);
            }),
          ]),
        )),
      ]),
    );
  }
}

Widget _orangeBtn(String label, VoidCallback onTap) => SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      backgroundColor: _orange,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 0,
    ),
    onPressed: onTap,
    child: Text(label, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16)),
  ),
);

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
