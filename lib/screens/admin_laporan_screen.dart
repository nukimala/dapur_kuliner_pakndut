import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ── Warna
const _redGrad1  = Color(0xFFD63010);
const _redDark   = Color(0xFF8B1A0A);
const _redCard   = Color(0xFF7F0000);
const _orange    = Color(0xFFF5A524);
const _cream     = Color(0xFFF7F0E6);
const _textBlack = Color(0xFF1C1C1C);
const _textGray  = Color(0xFF888888);

final _barColorsRed = [
  const Color(0xFFCC2813), const Color(0xFFCC2813), const Color(0xFFCC2813),
  const Color(0xFFCC2813), const Color(0xFFCC2813), const Color(0xFFCC2813),
  const Color(0xFFF5A524), // last bar = orange
];

final _menuColors = [
  const Color(0xFFE8331A),
  const Color(0xFFF5A524),
  const Color(0xFF2BB84A),
  const Color(0xFF2980B9),
  const Color(0xFF9B59B6),
];

// ─────────────────────────────────────────────────────────────────────────────
class AdminLaporanScreen extends StatefulWidget {
  const AdminLaporanScreen({super.key});
  @override
  State<AdminLaporanScreen> createState() => _AdminLaporanScreenState();
}

class _AdminLaporanScreenState extends State<AdminLaporanScreen> {
  String _period = 'Bulan ini';
  final _periods = ['Hari Ini', '7 Hari', 'Bulan ini'];

  // Format tanggal tanpa locale (tidak perlu initializeDateFormatting)
  static const _bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                              'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  String _tanggalStr(DateTime dt) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(dt.day)} ${_bulan[dt.month]} ${dt.year}  ${pad(dt.hour)}:${pad(dt.minute)}';
  }

  String _tanggalShort(DateTime dt) => '${dt.day} ${_bulan[dt.month]}';

  DateTime _startDate() {
    final now = DateTime.now();
    switch (_period) {
      case 'Hari Ini':
        return DateTime(now.year, now.month, now.day);
      case '7 Hari':
        return now.subtract(const Duration(days: 7));
      default:
        return DateTime(now.year, now.month, 1);
    }
  }

  Stream<QuerySnapshot> _stream() => FirebaseFirestore.instance
      .collection('orders')
      .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate()))
      .snapshots();

  Future<_SalesData> _process(List<QueryDocumentSnapshot> docs) async {
    double totalRevenue = 0;
    final Map<String, double> menuRevenue = {};
    final Map<String, int>    menuQty     = {};
    final Map<String, double> dailyRevenue = {};

    for (final doc in docs) {
      final d     = doc.data() as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(d['items'] ?? []);
      final ts    = (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      final dayKey = '${ts.day}';

      for (final item in items) {
        final qty   = (item['quantity']  as num?)?.toInt()    ?? 1;
        final price = (item['menuPrice'] as num?)?.toDouble() ?? 0;
        final name  = (item['menuName'] ?? 'Unknown') as String;
        final rev   = price * qty;

        totalRevenue            += rev;
        menuRevenue[name]        = (menuRevenue[name] ?? 0) + rev;
        menuQty[name]            = (menuQty[name]     ?? 0) + qty;
        dailyRevenue[dayKey]     = (dailyRevenue[dayKey] ?? 0) + rev;
      }
    }

    // Top 5 menu by revenue
    final sortedMenus = menuRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topMenus = sortedMenus.take(5).toList();

    // Build daily bars
    final now = DateTime.now();
    final dayCount = _period == 'Hari Ini' ? 1 : 7;
    final List<_DayBar> bars = [];
    for (int i = dayCount - 1; i >= 0; i--) {
      final d   = now.subtract(Duration(days: i));
      final key = '${d.day}';
      bars.add(_DayBar(label: key, value: dailyRevenue[key] ?? 0));
    }

    return _SalesData(
      totalRevenue: totalRevenue,
      orderCount: docs.length,
      topMenus: topMenus,
      bars: bars,
    );
  }

  // ─── Format angka Rp
  String _fmtRp(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write('.');
      buf.write(s[i]);
      c++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  // ─── Generate PDF
  Future<void> _cetakPDF(_SalesData data) async {
    final pdf  = pw.Document();
    final now  = _tanggalStr(DateTime.now());

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        // Header
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('DAPUR KULINER PAK NDUT',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18,
                    color: PdfColors.red800)),
            pw.Text('Laporan Penjualan — $_period',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
          ]),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text('Dicetak: $now', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
          ]),
        ]),
        pw.Divider(color: PdfColors.red800, thickness: 2),
        pw.SizedBox(height: 12),

        // Ringkasan
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.red800,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfStat('Total Pendapatan', _fmtRp(data.totalRevenue)),
              _pdfStat('Total Pesanan',    '${data.orderCount}'),
              _pdfStat('Menu Terjual',     '${data.topMenus.length}'),
            ],
          ),
        ),
        pw.SizedBox(height: 20),

        // Bar chart teks
        pw.Text('Pendapatan Harian', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.SizedBox(height: 8),
        ...data.bars.map((b) {
          final pct = data.bars.isEmpty ? 0.0 :
              data.bars.fold(0.0, (acc, x) => acc > x.value ? acc : x.value) > 0
                  ? b.value / data.bars.fold(0.0, (acc, x) => acc > x.value ? acc : x.value)
                  : 0.0;
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(children: [
              pw.SizedBox(width: 30, child: pw.Text(b.label,
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600))),
              pw.SizedBox(width: 8),
              pw.Expanded(child: pw.Stack(children: [
                pw.Container(height: 14, decoration: pw.BoxDecoration(
                    color: PdfColors.grey200, borderRadius: pw.BorderRadius.circular(4))),
                pw.Container(height: 14, width: pct * 400,
                    decoration: pw.BoxDecoration(
                        color: PdfColors.red700, borderRadius: pw.BorderRadius.circular(4))),
              ])),
              pw.SizedBox(width: 8),
              pw.Text(_fmtRp(b.value), style: pw.TextStyle(fontSize: 10)),
            ]),
          );
        }),
        pw.SizedBox(height: 20),

        // Top Menu Terlaris
        pw.Text('Menu Terlaris', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.SizedBox(height: 8),
        pw.Table(
          columnWidths: {
            0: const pw.FlexColumnWidth(0.5),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(1.5),
          },
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.red800),
              children: ['No', 'Nama Menu', 'Pendapatan', '%'].map((h) =>
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: pw.Text(h, style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 11)),
                )).toList(),
            ),
            ...data.topMenus.asMap().entries.map((e) {
              final pct = data.totalRevenue > 0
                  ? (e.value.value / data.totalRevenue * 100).toStringAsFixed(1)
                  : '0.0';
              return pw.TableRow(
                decoration: pw.BoxDecoration(
                    color: e.key.isEven ? PdfColors.white : PdfColors.grey50),
                children: [
                  '${e.key + 1}', e.value.key, _fmtRp(e.value.value), '$pct%',
                ].map((t) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: pw.Text(t, style: const pw.TextStyle(fontSize: 10)),
                )).toList(),
              );
            }),
          ],
        ),
        pw.SizedBox(height: 24),
        pw.Divider(color: PdfColors.grey300),
        pw.Text('Laporan ini dibuat otomatis oleh Sistem Dapur Kuliner Pak Ndut',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
            textAlign: pw.TextAlign.center),
      ],
    ));

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'Laporan_Penjualan_$_period.pdf',
    );
  }

  pw.Widget _pdfStat(String label, String value) => pw.Column(
    children: [
      pw.Text(value, style: pw.TextStyle(color: PdfColors.white,
          fontWeight: pw.FontWeight.bold, fontSize: 16)),
      pw.SizedBox(height: 4),
      pw.Text(label, style: pw.TextStyle(color: PdfColors.grey300, fontSize: 10)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Column(children: [
        // ── Header
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [_redGrad1, _redDark],
            ),
          ),
          child: Stack(children: [
            Positioned(right: -30, top: -50,
              child: Container(width: 160, height: 160,
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

        // ── Body: StreamBuilder
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _stream(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: _redGrad1));
              }
              final docs = snap.data?.docs ?? [];
              return FutureBuilder<_SalesData>(
                future: _process(docs),
                builder: (ctx2, snapData) {
                  final data = snapData.data ?? _SalesData.empty();
                  return Stack(children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // ── Period tabs
                        Row(children: _periods.map((p) {
                          final sel = _period == p;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _period = p),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                                decoration: BoxDecoration(
                                  color: sel ? _orange : Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [BoxShadow(
                                    color: sel ? _orange.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.08),
                                    blurRadius: sel ? 10 : 4,
                                  )],
                                ),
                                child: Text(p,
                                  style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700,
                                      color: sel ? Colors.white : const Color(0xFF555555))),
                              ),
                            ),
                          );
                        }).toList()),
                        const SizedBox(height: 14),

                        // ── Total revenue card (merah tua)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: _redCard, borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Distribusi Per Kategori',
                              style: GoogleFonts.nunito(color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text(_fmtRp(data.totalRevenue),
                              style: GoogleFonts.nunito(color: Colors.white,
                                  fontWeight: FontWeight.w900, fontSize: 30)),
                          ]),
                        ),
                        const SizedBox(height: 14),

                        // ── Bar chart card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)],
                          ),
                          child: Column(children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('Pendapatan harian',
                                style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: _textBlack)),
                              Text(_dateRangeLabel(),
                                style: GoogleFonts.nunito(fontSize: 12, color: _textGray)),
                            ]),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 160,
                              child: _BarChart(bars: data.bars, barColors: _barColorsRed),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 14),

                        // ── Top menu terlaris
                        if (data.topMenus.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white, borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)],
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Presentase Menu Terlaris',
                                style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: _textBlack)),
                              const SizedBox(height: 14),
                              ...data.topMenus.asMap().entries.map((e) {
                                final pct = data.totalRevenue > 0
                                    ? e.value.value / data.totalRevenue
                                    : 0.0;
                                final color = _menuColors[e.key % _menuColors.length];
                                final pctLabel = (pct * 100).toStringAsFixed(0);
                                final emojis  = ['🍢', '🍱', '🥘', '🧋', '🥤'];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Row(children: [
                                        Text(emojis[e.key % emojis.length],
                                            style: const TextStyle(fontSize: 18)),
                                        const SizedBox(width: 8),
                                        Text(e.value.key,
                                          style: GoogleFonts.nunito(fontSize: 14,
                                              fontWeight: FontWeight.w600, color: _textBlack)),
                                      ]),
                                      Text('$pctLabel%',
                                        style: GoogleFonts.nunito(fontSize: 14,
                                            fontWeight: FontWeight.w800, color: color)),
                                    ]),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: pct,
                                        minHeight: 8,
                                        backgroundColor: const Color(0xFFEEEEEE),
                                        valueColor: AlwaysStoppedAnimation<Color>(color),
                                      ),
                                    ),
                                  ]),
                                );
                              }),
                            ]),
                          ),
                        ] else
                          Center(child: Padding(
                            padding: const EdgeInsets.only(top: 24.0),
                            child: Text('Belum ada data penjualan',
                                style: GoogleFonts.nunito(color: _textGray, fontSize: 15)),
                          )),
                      ]),
                    ),

                    // ── Footer: Cetak Laporan
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        color: _redDark,
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                        child: SafeArea(top: false, child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: snapData.hasData ? () => _cetakPDF(data) : null,
                            icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                            label: Text('Cetak Laporan',
                              style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _redDark,
                              disabledBackgroundColor: Colors.white70,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                          ),
                        )),
                      ),
                    ),
                  ]);
                },
              );
            },
          ),
        ),
      ]),
    );
  }

  String _dateRangeLabel() {
    final now = DateTime.now();
    if (_period == 'Hari Ini') return _tanggalShort(now);
    final start = _startDate();
    return '${_tanggalShort(start)} – ${_tanggalShort(now)}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data model
class _DayBar  { final String label; final double value; _DayBar({required this.label, required this.value}); }

class _SalesData {
  final double totalRevenue;
  final int    orderCount;
  final List<MapEntry<String, double>> topMenus;
  final List<_DayBar> bars;

  const _SalesData({
    required this.totalRevenue,
    required this.orderCount,
    required this.topMenus,
    required this.bars,
  });

  factory _SalesData.empty() => const _SalesData(
      totalRevenue: 0, orderCount: 0, topMenus: [], bars: []);
}

// ─────────────────────────────────────────────────────────────────────────────
// Bar chart widget
class _BarChart extends StatelessWidget {
  final List<_DayBar> bars;
  final List<Color> barColors;
  const _BarChart({required this.bars, required this.barColors});

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) {
      return Center(child: Text('Tidak ada data',
          style: GoogleFonts.nunito(color: _textGray)));
    }
    final maxVal = bars.fold(0.0, (acc, b) => acc > b.value ? acc : b.value);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: bars.asMap().entries.map((e) {
        final isLast    = e.key == bars.length - 1;
        final ratio     = maxVal > 0 ? e.value.value / maxVal : 0.0;
        final barColor  = isLast ? const Color(0xFFF5A524)
            : (e.key < barColors.length ? barColors[e.key] : const Color(0xFFCC2813));
        return Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Flexible(child: FractionallySizedBox(
              heightFactor: ratio.clamp(0.05, 1.0),
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  color: barColor,
                ),
              ),
            )),
            const SizedBox(height: 5),
            Text(e.value.label,
              style: GoogleFonts.nunito(fontSize: 11, color: _textGray, fontWeight: FontWeight.w600)),
          ]),
        ));
      }).toList(),
    );
  }
}
