import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _redDark = Color(0xFF8B1A0A);
const _orange  = Color(0xFFF5A524);
const _cream   = Color(0xFFF7F0E6);
const _textBlack = Color(0xFF1C1C1C);
const _textMid   = Color(0xFF555555);
const _textGray  = Color(0xFF888888);

class AdminUlasanScreen extends StatelessWidget {
  const AdminUlasanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dist = [
      {'s': 5, 'n': 108},
      {'s': 4, 'n': 15},
      {'s': 3, 'n': 3},
      {'s': 2, 'n': 1},
      {'s': 1, 'n': 1},
    ];
    const maxN = 108;

    final reviews = [
      {
        'initials': 'RD', 'initBg': Color(0xFFE8331A),
        'name': 'Rizky Darmawan', 'date': '28 Feb 2026 · 13:15',
        'menu': 'Pentol Bakar', 'replied': true,
        'text': '"Mantap banget Pak Ndut! Pentolnya empuk, bumbunya meresap sempurna. Sudah jadi langganan rutin nih!"',
        'reply': 'Terima kasih Kak Rizky! Senang bisa jadi pilihan favorit. Datang lagi ya, ada menu baru minggu ini! 🔥',
      },
      {
        'initials': 'SA', 'initBg': Color(0xFF2980B9),
        'name': 'Siti Aisyah', 'date': '27 Feb 2026 · 09:40',
        'menu': 'Es Teh Manis', 'replied': false,
        'text': '"Es tehnya segar banget! Cocok banget buat temani makan siang. Recommended!!"',
        'reply': null,
      },
    ];

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
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Ulasan Pelanggan',
                      style: GoogleFonts.nunito(color: Colors.white,
                          fontWeight: FontWeight.w800, fontSize: 20)),
                  Text('128 Ulasan · 5 belum dibalas',
                      style: GoogleFonts.nunito(color: Colors.white.withValues(alpha: 0.78), fontSize: 12)),
                ])),
              ]),
            )),
          ]),
        ),

        // ── Body
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
          child: Column(children: [
            // Overall rating card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)],
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Big score
                Column(children: [
                  Text('4.8',
                    style: GoogleFonts.nunito(fontSize: 52, fontWeight: FontWeight.w900,
                        color: _textBlack, height: 1)),
                  const SizedBox(height: 6),
                  Row(children: List.generate(5, (_) =>
                    const Text('⭐', style: TextStyle(fontSize: 18)))),
                  const SizedBox(height: 4),
                  Text('dari 128 ulasan',
                    style: GoogleFonts.nunito(fontSize: 11, color: _textGray)),
                ]),
                const SizedBox(width: 18),
                // Bar distribution
                Expanded(child: Column(children: dist.map((d) {
                  final pct = (d['n'] as int) / maxN;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      Text('${d['s']}★',
                        style: GoogleFonts.nunito(fontSize: 11, color: _textGray,
                            fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      Expanded(child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct, minHeight: 7,
                          backgroundColor: const Color(0xFFEEEEEE),
                          valueColor: const AlwaysStoppedAnimation<Color>(_orange),
                        ),
                      )),
                      const SizedBox(width: 6),
                      SizedBox(width: 22,
                        child: Text('${d['n']}',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.nunito(fontSize: 11, color: _textGray))),
                    ]),
                  );
                }).toList())),
              ]),
            ),
            const SizedBox(height: 12),

            // Review cards
            ...reviews.map((r) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 42, height: 42, decoration: BoxDecoration(
                      shape: BoxShape.circle, color: r['initBg'] as Color),
                    child: Center(child: Text(r['initials'] as String,
                      style: GoogleFonts.nunito(color: Colors.white,
                          fontWeight: FontWeight.w800, fontSize: 15))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r['name'] as String,
                      style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: _textBlack)),
                    const SizedBox(height: 1),
                    Text(r['date'] as String,
                      style: GoogleFonts.nunito(fontSize: 11, color: _textGray)),
                    const SizedBox(height: 3),
                    Row(children: List.generate(5, (_) =>
                      const Text('⭐', style: TextStyle(fontSize: 13)))),
                  ])),
                  if (r['replied'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F8EF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(children: [
                        const Text('✓', style: TextStyle(color: Color(0xFF2BB84A), fontSize: 13)),
                        const SizedBox(width: 3),
                        Text('Dibalas',
                          style: GoogleFonts.nunito(color: const Color(0xFF2BB84A),
                              fontSize: 12, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                ]),
                const SizedBox(height: 10),

                // Menu tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('🍢 ${r['menu']}',
                    style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: _textMid)),
                ),
                const SizedBox(height: 8),

                // Review text
                Text(r['text'] as String,
                  style: GoogleFonts.nunito(fontSize: 14, color: _textBlack, height: 1.6)),

                // Admin reply
                if (r['reply'] != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F0),
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(left: BorderSide(color: _orange, width: 3)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Text('👑', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 5),
                        Text('Balasan Admin',
                          style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: _orange)),
                      ]),
                      const SizedBox(height: 5),
                      Text(r['reply'] as String,
                        style: GoogleFonts.nunito(fontSize: 13, color: _textMid, height: 1.55)),
                    ]),
                  ),
                ],

                // Reply button (if not replied yet)
                if (r['replied'] != true) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: _orange, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text('Balas Ulasan',
                        style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: _orange))),
                    ),
                  ),
                ],
              ]),
            )),
          ]),
        )),
      ]),
    );
  }
}
