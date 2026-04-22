    import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const _redDark   = Color(0xFF8B1A0A);
const _orange    = Color(0xFFF5A524);
const _cream     = Color(0xFFF7F0E6);
const _textBlack = Color(0xFF1C1C1C);
const _textGray  = Color(0xFF888888);

// ─────────────────────────────────────────────────────────────────────────────
class AdminCetakStrukScreen extends StatelessWidget {
  const AdminCetakStrukScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Column(children: [
        // ── Header
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD63010), _redDark],
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
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Cetak Struk',
                      style: GoogleFonts.nunito(color: Colors.white,
                          fontWeight: FontWeight.w800, fontSize: 20)),
                  Text('Histori pesanan — tap untuk cetak',
                      style: GoogleFonts.nunito(color: Colors.white.withValues(alpha: 0.78), fontSize: 12)),
                ])),
              ]),
            )),
          ]),
        ),

        // ── Daftar order dari Firestore
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD63010)));
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('🧾', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 12),
                    Text('Belum ada pesanan',
                        style: GoogleFonts.nunito(fontSize: 16, color: _textGray)),
                  ]),
                );
              }

              final docs = snap.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  return _OrderCard(
                    orderId: docs[i].id,
                    data: data,
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kartu order
class _OrderCard extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> data;

  const _OrderCard({required this.orderId, required this.data});

  String _fmt(dynamic v) {
    final amount = (v is num) ? v.toDouble() : 0.0;
    final s = amount.toStringAsFixed(0);
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write('.');
      buf.write(s[i]);
      c++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  String _tanggal(dynamic ts) {
    if (ts == null) return '-';
    try {
      final dt = (ts as Timestamp).toDate();
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return '-';
    }
  }

  String _statusLabel(String? s) {
    if (s == 'selesai' || s == 'Selesai') return 'Selesai';
    if (s == 'dibatalkan' || s == 'Dibatalkan') return 'Dibatalkan';
    return 'Diproses';
  }

  Color _statusBg(String label) {
    switch (label) {
      case 'Selesai':    return const Color(0xFFE8F5E9);
      case 'Dibatalkan': return const Color(0xFFFCE4EC);
      default:           return const Color(0xFFFFF3E0);
    }
  }

  Color _statusFg(String label) {
    switch (label) {
      case 'Selesai':    return const Color(0xFF2E7D32);
      case 'Dibatalkan': return const Color(0xFFC62828);
      default:           return const Color(0xFFE65100);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items    = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final total    = (data['totalPrice'] ?? 0).toDouble();
    final status   = _statusLabel(data['status'] as String?);
    final tanggal  = _tanggal(data['createdAt'] ?? data['timestamp']);
    final userName = data['userName'] ?? data['buyerName'] ?? data['userEmail'] ?? 'Pelanggan';
    final shortId  = orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header baris
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('#$shortId',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16, color: _textBlack)),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusBg(status), borderRadius: BorderRadius.circular(20)),
            child: Text(status,
                style: GoogleFonts.nunito(color: _statusFg(status),
                    fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 4),
        Text(tanggal, style: GoogleFonts.nunito(fontSize: 11, color: _textGray)),
        Text(userName, style: GoogleFonts.nunito(fontSize: 12, color: _textGray)),
        const SizedBox(height: 10),

        // Item list ringkas
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _cream, borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.take(3).map((item) {
              final name  = item['menuName'] ?? item['name'] ?? '-';
              final qty   = item['quantity'] ?? item['qty'] ?? 1;
              final price = (item['menuPrice'] ?? item['price'] ?? 0).toDouble();
              return Text('• $name ×$qty  — ${_fmt(price * qty)}',
                  style: GoogleFonts.nunito(fontSize: 12, color: _textBlack));
            }).toList()
            ..addAll(items.length > 3
                ? [Text('+ ${items.length - 3} item lainnya',
                    style: GoogleFonts.nunito(fontSize: 11, color: _textGray))]
                : []),
          ),
        ),

        const SizedBox(height: 12),
        // Total + tombol cetak
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total Bayar', style: GoogleFonts.nunito(color: _textGray, fontSize: 11)),
            Text(_fmt(total),
                style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900,
                    color: const Color(0xFFD63010))),
          ]),
          ElevatedButton.icon(
            onPressed: () => _showStrukPreview(context, orderId, items, total, tanggal, userName),
            icon: const Icon(Icons.print_outlined, size: 16),
            label: Text('Cetak', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ]),
      ]),
    );
  }

  void _showStrukPreview(BuildContext context, String id,
      List<Map<String, dynamic>> items, double total, String tanggal, String name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StrukSheet(
        orderId: id,
        items: items,
        total: total,
        tanggal: tanggal,
        userName: name,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet preview struk kasir
class _StrukSheet extends StatelessWidget {
  final String orderId;
  final List<Map<String, dynamic>> items;
  final double total;
  final String tanggal;
  final String userName;

  const _StrukSheet({
    required this.orderId,
    required this.items,
    required this.total,
    required this.tanggal,
    required this.userName,
  });

  String _fmt(double v) {
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

  Future<void> _generateAndPrintStruk(BuildContext context) async {
    final pdf = pw.Document();
    final shortId = orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase();

    final subtotal = items.fold(0.0, (acc, item) {
      final qty = (item['quantity'] ?? item['qty'] ?? 1) as int;
      final price = (item['menuPrice'] ?? item['price'] ?? 0).toDouble();
      return acc + (qty * price);
    });
    final tax = subtotal * 0.1;

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(80 * PdfPageFormat.mm, double.infinity, marginAll: 5 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('DAPUR KULINER PAK NDUT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
              pw.Text('Jl. Raya Pakndut No. 123', style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 5),
              pw.Text('================================', style: const pw.TextStyle(fontSize: 8)),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('No. Order:', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text('#$shortId', style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Tanggal:', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(tanggal, style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Pelanggan:', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(userName, style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Text('--------------------------------', style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 5),
              ...items.map((item) {
                final name = item['menuName'] ?? item['name'] ?? '-';
                final qty = (item['quantity'] ?? item['qty'] ?? 1) as int;
                final price = (item['menuPrice'] ?? item['price'] ?? 0).toDouble();
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('  $qty x ${_fmt(price)}', style: const pw.TextStyle(fontSize: 8)),
                        pw.Text(_fmt((qty * price).toDouble()), style: const pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ],
                );
              }),
              pw.SizedBox(height: 5),
              pw.Text('--------------------------------', style: const pw.TextStyle(fontSize: 8)),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(_fmt(subtotal), style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('PPN (10%):', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(_fmt(tax), style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Text('================================', style: const pw.TextStyle(fontSize: 8)),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text(_fmt(total), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text('Terima kasih sudah makan di sini! 😊', style: const pw.TextStyle(fontSize: 7), textAlign: pw.TextAlign.center),
              pw.Text('Selamat menikmati — Dapur Kuliner Pak Ndut', style: const pw.TextStyle(fontSize: 6), textAlign: pw.TextAlign.center),
            ],
          );
        },
      ),
    );

    final bool printed = await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Struk_$shortId.pdf',
    );

    if (printed) {
      try {
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .update({'status': 'Selesai'});
        
        if (context.mounted) {
          Navigator.pop(context); // Tutup popup preview struk
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Struk berhasil dicetak. Pesanan selesai!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengubah status: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shortId = orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase();
    final subtotal = items.fold(0.0, (acc, item) {
      final qty   = (item['quantity'] ?? item['qty'] ?? 1) as int;
      final price = (item['menuPrice'] ?? item['price'] ?? 0).toDouble();
      return acc + (qty * price);
    });
    final tax = subtotal * 0.1;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Header struk
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFD63010),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            const Icon(Icons.receipt_long, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Preview Struk Kasir',
                style: GoogleFonts.nunito(color: Colors.white,
                    fontWeight: FontWeight.w800, fontSize: 16)),
          ]),
        ),

        // Isi struk — format thermal kasir
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(children: [
            // Nama toko
            Text('DAPUR KULINER PAK NDUT',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w900,
                    fontSize: 15, color: const Color(0xFFD63010))),
            Text('================================',
                style: GoogleFonts.sourceCodePro(fontSize: 12, color: _textGray)),
            _row2('No. Order:', '#$shortId'),
            _row2('Tanggal:', tanggal),
            _row2('Pelanggan:', userName),
            Text('--------------------------------',
                style: GoogleFonts.sourceCodePro(fontSize: 12, color: _textGray)),
            const SizedBox(height: 4),

            // Item
            ...items.map((item) {
              final name  = item['menuName'] ?? item['name'] ?? '-';
              final qty   = (item['quantity'] ?? item['qty'] ?? 1) as int;
              final price = (item['menuPrice'] ?? item['price'] ?? 0).toDouble();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name,
                      style: GoogleFonts.sourceCodePro(
                          fontSize: 12, fontWeight: FontWeight.bold, color: _textBlack)),
                  _row2('  $qty × ${_fmt(price)}', _fmt((qty * price).toDouble())),
                ]),
              );
            }),

            Text('--------------------------------',
                style: GoogleFonts.sourceCodePro(fontSize: 12, color: _textGray)),
            _row2('Subtotal:',     _fmt(subtotal), light: true),
            _row2('PPN (10%):',    _fmt(tax),     light: true),
            Text('================================',
                style: GoogleFonts.sourceCodePro(fontSize: 12, color: _textGray)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('TOTAL',
                  style: GoogleFonts.sourceCodePro(
                      fontWeight: FontWeight.bold, fontSize: 14, color: _textBlack)),
              Text(_fmt(total),
                  style: GoogleFonts.sourceCodePro(
                      fontWeight: FontWeight.bold, fontSize: 14,
                      color: const Color(0xFFD63010))),
            ]),
            const SizedBox(height: 8),
            Text('================================',
                style: GoogleFonts.sourceCodePro(fontSize: 12, color: _textGray)),
            const SizedBox(height: 6),
            Text('Terima kasih sudah makan di sini! 😊',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 12, color: _textGray)),
            Text('Selamat menikmati — Dapur Kuliner Pak Ndut',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 11, color: _textGray)),
            const SizedBox(height: 16),

            // Tombol aksi
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Tutup', style: GoogleFonts.nunito(color: _textGray)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _generateAndPrintStruk(context),
                  icon: const Icon(Icons.print, size: 18),
                  label: Text('Cetak', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD63010),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 8),
          ]),
        ),
      ]),
    );
  }

  Widget _row2(String left, String right, {bool light = false}) {
    final style = GoogleFonts.sourceCodePro(
        fontSize: 12, color: light ? _textGray : _textBlack);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(left, style: style),
        Text(right, style: style),
      ]),
    );
  }
}
