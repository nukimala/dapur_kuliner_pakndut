import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _redDark = Color(0xFF8B1A0A);
const _orange  = Color(0xFFF5A524);
const _orangeL = Color(0xFFFFCA57);
const _cream   = Color(0xFFF7F0E6);
const _textBlack = Color(0xFF1C1C1C);
const _textGray  = Color(0xFF888888);

class AdminLaporanScreen extends StatefulWidget {
  const AdminLaporanScreen({super.key});

  @override
  State<AdminLaporanScreen> createState() => _AdminLaporanScreenState();
}

class _AdminLaporanScreenState extends State<AdminLaporanScreen> {
  String _period = 'Bulan ini';
  final _periods = ['Hari Ini', '7 Hari', 'Bulan ini'];

  final _bars = [
    {'day': '22', 'h': 55.0},
    {'day': '23', 'h': 42.0},
    {'day': '24', 'h': 50.0},
    {'day': '25', 'h': 70.0},
    {'day': '26', 'h': 60.0},
    {'day': '27', 'h': 82.0},
    {'day': '28', 'h': 100.0},
  ];

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
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Text('Laporan Penjualan',
                    style: GoogleFonts.nunito(color: Colors.white,
                        fontWeight: FontWeight.w800, fontSize: 20)),
              ]),
            )),
          ]),
        ),

        // ── Body
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
          child: Column(children: [
            // Period tabs
            Row(children: _periods.map((p) {
              final sel = _period == p;
              return Expanded(child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _period = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? _orange : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(
                        color: sel ? _orange.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.08),
                        blurRadius: sel ? 12 : 4,
                      )],
                    ),
                    child: Center(child: Text(p,
                      style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : const Color(0xFF555555)))),
                  ),
                ),
              ));
            }).toList()),
            const SizedBox(height: 14),

            // Big stat card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFFD63010), _redDark]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(children: [
                Positioned(right: -20, top: -20, child: Container(width: 100, height: 100,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.07)))),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Total Pendapatan',
                    style: GoogleFonts.nunito(color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Rp 8.420.000',
                    style: GoogleFonts.nunito(color: Colors.white,
                        fontWeight: FontWeight.w900, fontSize: 30)),
                  const SizedBox(height: 16),
                  Row(children: [
                    _miniStat('386', 'Pesanan'),
                    const SizedBox(width: 10),
                    _miniStat('1.284', 'Item Terjual'),
                  ]),
                ]),
              ]),
            ),
            const SizedBox(height: 14),

            // Bar chart card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)],
              ),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Pendapatan Harian',
                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: _textBlack)),
                  Text('Feb 22-28',
                    style: GoogleFonts.nunito(fontSize: 12, color: _textGray)),
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(_bars.length, (i) {
                      final b = _bars[i];
                      final isLast = i == _bars.length - 1;
                      final barH = (b['h'] as double) * 1.35;
                      return Expanded(child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                          Container(
                            height: barH,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                colors: isLast
                                    ? [_orange, _orangeL]
                                    : [const Color(0xFFD63010), _redDark],
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(b['day'] as String,
                            style: GoogleFonts.nunito(fontSize: 11, color: _textGray, fontWeight: FontWeight.w600)),
                        ]),
                      ));
                    }),
                  ),
                ),
              ]),
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _miniStat(String val, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(val, style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
      Text(label, style: GoogleFonts.nunito(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
    ]),
  );
}
