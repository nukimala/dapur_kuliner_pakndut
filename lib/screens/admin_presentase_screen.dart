
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Design tokens (match buyer home)
const _redGrad1  = Color(0xFFD63010);
const _redDark   = Color(0xFF8B1A0A);
const _redCard   = Color(0xFF9B1A0B);
const _orange    = Color(0xFFF5A524);
const _cream     = Color(0xFFF7F0E6);
const _textBlack = Color(0xFF1C1C1C);
const _textGray  = Color(0xFF888888);

// Palet warna untuk bar / progress
final _barColors = [
  const Color(0xFFE8331A),
  const Color(0xFFCC2A12),
  const Color(0xFFE8331A),
  const Color(0xFFD02E15),
  const Color(0xFFE8331A),
  const Color(0xFFCC2A12),
  const Color(0xFFF5A524), // last bar = orange (like prototype)
];

final _menuColors = [
  const Color(0xFFE8331A),
  const Color(0xFFF5A524),
  const Color(0xFF2BB84A),
  const Color(0xFF2980B9),
  const Color(0xFF9B59B6),
];

const _menuEmojis = ['🍢', '�', '🥘', '�', '🧋'];

// ─────────────────────────────────────────────────────────────
class AdminPresentaseScreen extends StatefulWidget {
  const AdminPresentaseScreen({super.key});
  @override
  State<AdminPresentaseScreen> createState() => _AdminPresentaseScreenState();
}

class _AdminPresentaseScreenState extends State<AdminPresentaseScreen> {
  String _period = 'Bulan ini';
  final _periods = ['Hari Ini', '7 Hari', 'Bulan ini'];



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
      .where('timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate()))
      .snapshots();



  Future<_SalesData> _process(List<QueryDocumentSnapshot> docs) async {
    double totalRevenue = 0;
    final Map<String, double> menuRevenue = {};
    final Map<String, int>    menuQty     = {};
    // Daily revenue: key = "dd"
    final Map<String, double> dailyRevenue = {};

    for (final doc in docs) {
      final d     = doc.data() as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(d['items'] ?? []);
      final ts    = (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
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

    // Sort menu by revenue desc, top 5
    final sortedMenus = menuRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topMenus = sortedMenus.take(5).toList();

    // Build daily bars (last 7 or 28 days labels)
    final now = DateTime.now();
    List<_DayBar> bars = [];
    int dayCount = _period == '7 Hari' ? 7 : _period == 'Hari Ini' ? 1 : 7;
    for (int i = dayCount - 1; i >= 0; i--) {
      final d   = now.subtract(Duration(days: i));
      final key = '${d.day}';
      bars.add(_DayBar(label: key, value: dailyRevenue[key] ?? 0));
    }
    if (bars.isEmpty) bars = [_DayBar(label: '${now.day}', value: 0)];

    return _SalesData(
      totalRevenue: totalRevenue,
      orderCount: docs.length,
      topMenus: topMenus,
      totalMenuRevenue: totalRevenue,
      bars: bars,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Column(children: [
        // ── Header
        _header(),

        // ── Scrollable body
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _stream(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: _orange));
              }
              final docs = snap.data?.docs ?? [];
              return FutureBuilder<_SalesData>(
                future: _process(docs),
                builder: (ctx2, fs) {
                  if (fs.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: _orange));
                  }
                  final data = fs.data ??
                      _SalesData(
                        totalRevenue: 0, orderCount: 0,
                        topMenus: [], totalMenuRevenue: 0,
                        bars: [_DayBar(label: '${DateTime.now().day}', value: 0)],
                      );
                  return _body(data);
                },
              );
            },
          ),
        ),

        // ── Footer – Cetak Laporan
        _footer(),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────
  Widget _header() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_redGrad1, _redDark],
      ),
    ),
    child: Stack(children: [
      Positioned(right: -30, top: -50, child: Container(
        width: 160, height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.07),
        ),
      )),
      SafeArea(bottom: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 6, 20, 16),
        child: Row(children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Text('Presentase Penjualan',
            style: GoogleFonts.nunito(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20,
            ),
          ),
        ]),
      )),
    ]),
  );

  Widget _footer() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [_redGrad1, _redDark],
      ),
    ),
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _redGrad1,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            elevation: 0,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cetak laporan belum tersedia.',
                  style: GoogleFonts.nunito(),
                ),
                backgroundColor: _redGrad1,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
          child: Text('Cetak Laporan',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800, fontSize: 16, color: _redGrad1,
            ),
          ),
        ),
      ),
    ),
  );

  // ─────────────────────────────────────────────────────────────
  Widget _body(_SalesData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      child: Column(children: [

        // ── Period tabs
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
                    color: sel
                        ? _orange.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: sel ? 12 : 4,
                  )],
                ),
                child: Center(child: Text(p,
                  style: GoogleFonts.nunito(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : _textGray,
                  ),
                )),
              ),
            ),
          ));
        }).toList()),
        const SizedBox(height: 14),

        // ── Revenue card (dark red)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFFA31E0C), _redCard],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
              color: _redDark.withValues(alpha: 0.45),
              blurRadius: 16, offset: const Offset(0, 6),
            )],
          ),
          child: Column(children: [
            Text('Distribusi Per Kategori',
              style: GoogleFonts.nunito(
                color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(_fmtRp(data.totalRevenue),
              style: GoogleFonts.nunito(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        // ── Bar chart card: Pendapatan harian
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Pendapatan harian',
              style: GoogleFonts.nunito(
                fontSize: 16, fontWeight: FontWeight.w800, color: _textBlack,
              ),
            ),
            Text(_periodLabel(),
              style: GoogleFonts.nunito(fontSize: 12, color: _textGray),
            ),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: _BarChartWidget(bars: data.bars),
          ),
        ])),
        const SizedBox(height: 14),

        // ── Top menu list
        _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Presentase Menu Terlaris',
            style: GoogleFonts.nunito(
              fontSize: 16, fontWeight: FontWeight.w800, color: _textBlack,
            ),
          ),
          const SizedBox(height: 14),
          if (data.topMenus.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('Belum ada data.',
                style: GoogleFonts.nunito(fontSize: 13, color: _textGray),
              ),
            ))
          else
            ...data.topMenus.asMap().entries.map((e) {
              final col    = _menuColors[e.key % _menuColors.length];
              final emoji  = _menuEmojis[e.key % _menuEmojis.length];
              final rev    = e.value.value;
              final maxRev = data.topMenus.first.value;
              final ratio  = maxRev > 0 ? rev / maxRev : 0.0;
              final pct    = data.totalMenuRevenue > 0
                  ? (rev / data.totalMenuRevenue * 100).round()
                  : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(children: [
                  Row(children: [
                    Text(emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.value.key,
                      style: GoogleFonts.nunito(
                        fontSize: 14, fontWeight: FontWeight.w600, color: _textBlack,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )),
                    Text('$pct%',
                      style: GoogleFonts.nunito(
                        fontSize: 14, fontWeight: FontWeight.w800, color: col,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 9,
                      backgroundColor: const Color(0xFFEEEEEE),
                      valueColor: AlwaysStoppedAnimation<Color>(col),
                    ),
                  ),
                ]),
              );
            }),
        ])),
      ]),
    );
  }

  Widget _card(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(
        color: Colors.black.withValues(alpha: 0.07), blurRadius: 10,
      )],
    ),
    child: child,
  );

  String _periodLabel() {
    final now = DateTime.now();
    if (_period == 'Hari Ini') return '${_monthAbbr(now.month)} ${now.day}';
    if (_period == '7 Hari') {
      final from = now.subtract(const Duration(days: 6));
      return '${_monthAbbr(from.month)} ${from.day}-${now.day}';
    }
    return '${_monthAbbr(now.month)} 1-${now.day}';
  }

  String _monthAbbr(int m) {
    const names = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return names[m - 1];
  }

  String _fmtRp(double n) {
    final s = n.toStringAsFixed(0);
    final result = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.write('.');
      result.write(s[i]);
      count++;
    }
    return 'Rp ${result.toString().split('').reversed.join('')}';
  }
}

// ─────────────────────────────────────────────────────────────
// Data model
class _DayBar { final String label; final double value; _DayBar({required this.label, required this.value}); }

class _SalesData {
  final double totalRevenue;
  final int    orderCount;
  final List<MapEntry<String, double>> topMenus;
  final double totalMenuRevenue;
  final List<_DayBar> bars;
  const _SalesData({
    required this.totalRevenue,
    required this.orderCount,
    required this.topMenus,
    required this.totalMenuRevenue,
    required this.bars,
  });
}

// ─────────────────────────────────────────────────────────────
// Bar chart widget
class _BarChartWidget extends StatelessWidget {
  final List<_DayBar> bars;
  const _BarChartWidget({required this.bars});

  @override
  Widget build(BuildContext context) {
    final maxVal = bars.fold<double>(0, (m, b) => b.value > m ? b.value : m);
    final lastIdx = bars.length - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: bars.asMap().entries.map((e) {
        final i      = e.key;
        final bar    = e.value;
        final ratio  = maxVal > 0 ? bar.value / maxVal : 0.0;
        final isLast = i == lastIdx;
        final col    = isLast ? _orange : _barColors[i % _barColors.length];
        const minH   = 6.0;
        const maxH   = 100.0;
        final barH   = minH + ratio * (maxH - minH);

        return Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  height: barH,
                  decoration: BoxDecoration(
                    color: col,
                    borderRadius: const BorderRadius.only(
                      topLeft:  Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isLast
                          ? [_orange, const Color(0xFFFFCA57)]
                          : [const Color(0xFFEF4923), const Color(0xFFCC2A12)],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(bar.label,
                style: GoogleFonts.nunito(fontSize: 10, color: _textGray),
              ),
            ],
          ),
        ));
      }).toList(),
    );
  }
}
