import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _redDark = Color(0xFF8B1A0A);
const _orange  = Color(0xFFF5A524);
const _cream   = Color(0xFFF7F0E6);
const _textBlack = Color(0xFF1C1C1C);
const _textMid   = Color(0xFF555555);
const _textGray  = Color(0xFF888888);

class AdminPresentaseScreen extends StatefulWidget {
  const AdminPresentaseScreen({super.key});

  @override
  State<AdminPresentaseScreen> createState() => _AdminPresentaseScreenState();
}

class _AdminPresentaseScreenState extends State<AdminPresentaseScreen> {
  String _period = 'Bulan ini';
  final _periods = ['Hari Ini', '7 Hari', 'Bulan ini'];

  final _cats = [
    {'name': 'Pentol',   'emoji': '🍢', 'color': Color(0xFFE8331A), 'pct': 45, 'val': 578},
    {'name': 'Nasi',     'emoji': '🍱', 'color': Color(0xFFF5A524), 'pct': 22, 'val': 282},
    {'name': 'Gorengan', 'emoji': '🥘', 'color': Color(0xFF2BB84A), 'pct': 18, 'val': 231},
    {'name': 'Minuman',  'emoji': '🥤', 'color': Color(0xFF2980B9), 'pct': 15, 'val': 193},
  ];

  final _tops = [
    {'name': 'Pentol Bakar',     'emoji': '🍢', 'pct': 45, 'color': Color(0xFFE8331A)},
    {'name': 'Nasi Bento Crispy','emoji': '🍱', 'pct': 22, 'color': Color(0xFFF5A524)},
    {'name': 'Tahu Bakar',       'emoji': '🥘', 'pct': 18, 'color': Color(0xFF2BB84A)},
    {'name': 'Rica Balungan',    'emoji': '🍗', 'pct': 10, 'color': Color(0xFF2980B9)},
    {'name': 'Es Teh Manis',     'emoji': '🧋', 'pct': 5,  'color': Color(0xFF9B59B6)},
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
                Text('Presentase Penjualan',
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
                          color: sel ? Colors.white : _textMid))),
                  ),
                ),
              ));
            }).toList()),
            const SizedBox(height: 14),

            // Donut card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Distribusi Per Kategori',
                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: _textBlack)),
                const SizedBox(height: 14),
                Row(children: [
                  // Donut chart (CustomPaint)
                  SizedBox(width: 130, height: 130,
                    child: CustomPaint(
                      painter: _DonutPainter(categories: _cats),
                      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('1.284',
                          style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w900,
                              color: _textBlack, height: 1)),
                        const SizedBox(height: 2),
                        Text('item\nterjual', textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(fontSize: 10, color: _textGray, height: 1.3)),
                      ])),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Legend
                  Expanded(child: Column(children: _cats.map((c) {
                    final col = c['color'] as Color;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(children: [
                        Container(width: 11, height: 11, decoration: BoxDecoration(
                            shape: BoxShape.circle, color: col)),
                        const SizedBox(width: 8),
                        Expanded(child: Text('${c['emoji']} ${c['name']}',
                          style: GoogleFonts.nunito(fontSize: 12, color: _textMid))),
                        Text('${c['val']}',
                          style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700,
                              color: _textBlack)),
                        const SizedBox(width: 4),
                        Text('${c['pct']}%',
                          style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: col)),
                      ]),
                    );
                  }).toList())),
                ]),
              ]),
            ),
            const SizedBox(height: 14),

            // Top menus bar chart card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Presentase Menu Terlaris',
                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: _textBlack)),
                const SizedBox(height: 14),
                ..._tops.map((m) {
                  final col = m['color'] as Color;
                  final pct = m['pct'] as int;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 13),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('${m['emoji']} ${m['name']}',
                          style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: _textBlack)),
                        Text('$pct%',
                          style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: col)),
                      ]),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: pct / 100,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFEEEEEE),
                          valueColor: AlwaysStoppedAnimation<Color>(col),
                        ),
                      ),
                    ]),
                  );
                }),
              ]),
            ),
          ]),
        )),
      ]),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<Map<String, dynamic>> categories;
  const _DonutPainter({required this.categories});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 22.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    double startAngle = -90 * (3.14159 / 180); // start from top
    for (final cat in categories) {
      final pct = (cat['pct'] as int) / 100.0;
      final sweepAngle = pct * 2 * 3.14159;
      final paint = Paint()
        ..color = cat['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
