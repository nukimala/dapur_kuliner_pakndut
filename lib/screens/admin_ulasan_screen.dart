import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

const _redDark   = Color(0xFF8B1A0A);
const _orange    = Color(0xFFF5A524);
const _cream     = Color(0xFFF7F0E6);
const _textBlack = Color(0xFF1C1C1C);
const _textMid   = Color(0xFF555555);
const _textGray  = Color(0xFF888888);

class AdminUlasanScreen extends StatelessWidget {
  const AdminUlasanScreen({super.key});

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
                  Text('Ulasan Pelanggan',
                      style: GoogleFonts.nunito(color: Colors.white,
                          fontWeight: FontWeight.w800, fontSize: 20)),
                  Text('Real-time dari Firestore',
                      style: GoogleFonts.nunito(color: Colors.white.withValues(alpha: 0.78), fontSize: 12)),
                ])),
              ]),
            )),
          ]),
        ),

        // ── Body: stream dari Firestore ulasan
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('ulasan')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD63010)));
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('⭐', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 12),
                    Text('Belum ada ulasan pelanggan',
                        style: GoogleFonts.nunito(fontSize: 16, color: _textGray)),
                  ]),
                );
              }

              final docs = snap.data!.docs;
              final avg  = docs.fold(0.0, (acc, d) {
                final r = (d.data() as Map<String, dynamic>)['rating'];
                return acc + (r is num ? r.toDouble() : 0);
              }) / docs.length;

              // Distribusi bintang
              final Map<int, int> dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
              for (final d in docs) {
                final r = (d.data() as Map<String, dynamic>)['rating'];
                if (r is int && dist.containsKey(r)) {
                  dist[r] = dist[r]! + 1;
                }
              }
              final maxDist = dist.values.fold(0, (a, b) => a > b ? a : b);

              return ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                children: [
                  // Rating summary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)],
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Column(children: [
                        Text(avg.toStringAsFixed(1),
                          style: GoogleFonts.nunito(fontSize: 50, fontWeight: FontWeight.w900,
                              color: _textBlack, height: 1)),
                        const SizedBox(height: 6),
                        Row(children: List.generate(5, (i) =>
                            Text(i < avg.floor() ? '⭐' : '☆',
                                style: const TextStyle(fontSize: 16)))),
                        const SizedBox(height: 4),
                        Text('dari ${docs.length} ulasan',
                            style: GoogleFonts.nunito(fontSize: 11, color: _textGray)),
                      ]),
                      const SizedBox(width: 18),
                      Expanded(child: Column(
                        children: [5, 4, 3, 2, 1].map((star) {
                          final count = dist[star] ?? 0;
                          final pct = maxDist > 0 ? count / maxDist : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(children: [
                              Text('$star★',
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
                                child: Text('$count',
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.nunito(fontSize: 11, color: _textGray))),
                            ]),
                          );
                        }).toList(),
                      )),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  // Daftar ulasan
                  ...docs.map((doc) {
                    final d = doc.data() as Map<String, dynamic>;
                    return _UlasanCard(docId: doc.id, data: d);
                  }),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _UlasanCard extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;
  const _UlasanCard({required this.docId, required this.data});

  @override
  State<_UlasanCard> createState() => _UlasanCardState();
}

class _UlasanCardState extends State<_UlasanCard> {
  bool _showReply = false;
  final _replyCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() { _replyCtrl.dispose(); super.dispose(); }

  String _tanggal(dynamic ts) {
    if (ts == null) return '-';
    try {
      final dt = (ts as Timestamp).toDate();
      return DateFormat('dd MMM yyyy · HH:mm', 'id_ID').format(dt);
    } catch (_) { return '-'; }
  }

  String _inisial(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Future<void> _kirimBalasan() async {
    if (_replyCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('ulasan')
          .doc(widget.docId)
          .update({'adminReply': _replyCtrl.text.trim()});
      if (mounted) setState(() { _showReply = false; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal mengirim balasan: $e'), 
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d       = widget.data;
    final name    = d['userName'] ?? d['userEmail'] ?? 'Anonim';
    final rating  = (d['rating'] as int?) ?? 5;
    final comment = d['komentar'] ?? d['comment'] ?? '';
    final reply   = d['adminReply'] as String?;
    final tanggal = _tanggal(d['createdAt']);
    final tags    = List<String>.from(d['tags'] ?? []);

    final initColors = [
      const Color(0xFFE8331A), const Color(0xFF2980B9),
      const Color(0xFF27AE60), const Color(0xFF8E44AD),
    ];
    final colorIdx  = name.codeUnitAt(0) % initColors.length;
    final initBg    = initColors[colorIdx];

    return Container(
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
            width: 42, height: 42,
            decoration: BoxDecoration(shape: BoxShape.circle, color: initBg),
            child: Center(child: Text(_inisial(name),
                style: GoogleFonts.nunito(color: Colors.white,
                    fontWeight: FontWeight.w800, fontSize: 15))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: GoogleFonts.nunito(
                fontSize: 14, fontWeight: FontWeight.w700, color: _textBlack)),
            Text(tanggal, style: GoogleFonts.nunito(fontSize: 11, color: _textGray)),
            const SizedBox(height: 3),
            Row(children: List.generate(5, (i) =>
                Text(i < rating ? '⭐' : '☆', style: const TextStyle(fontSize: 14)))),
          ])),
          if (reply != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8EF), borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                const Text('✓', style: TextStyle(color: Color(0xFF2BB84A), fontSize: 13)),
                const SizedBox(width: 3),
                Text('Dibalas', style: GoogleFonts.nunito(
                    color: const Color(0xFF2BB84A), fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
        ]),
        const SizedBox(height: 10),

        // Tags
        if (tags.isNotEmpty) ...[
          Wrap(spacing: 6, children: tags.map((t) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(20)),
            child: Text(t, style: GoogleFonts.nunito(fontSize: 11, color: _textMid)),
          )).toList()),
          const SizedBox(height: 8),
        ],

        // Review text
        Text(comment, style: GoogleFonts.nunito(fontSize: 14, color: _textBlack, height: 1.6)),

        // Admin reply (jika sudah dibalas)
        if (reply != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F0), borderRadius: BorderRadius.circular(12),
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
              Text(reply, style: GoogleFonts.nunito(fontSize: 13, color: _textMid, height: 1.55)),
            ]),
          ),
        ],

        // Form balas (jika belum dibalas)
        if (reply == null) ...[
          const SizedBox(height: 10),
          if (!_showReply)
            GestureDetector(
              onTap: () => setState(() { _showReply = true; }),
              child: Row(children: [
                const Icon(Icons.reply, size: 16, color: Color(0xFFD63010)),
                const SizedBox(width: 4),
                Text('Balas ulasan',
                    style: GoogleFonts.nunito(color: const Color(0xFFD63010),
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            ),
          if (_showReply) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _replyCtrl,
              maxLines: 2,
              style: GoogleFonts.nunito(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Tulis balasan admin...',
                hintStyle: GoogleFonts.nunito(fontSize: 13, color: _textGray),
                filled: true, fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                  onPressed: () => setState(() { _showReply = false; _replyCtrl.clear(); }),
                  child: Text('Batal', style: GoogleFonts.nunito(color: _textGray))),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saving ? null : _kirimBalasan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD63010),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(90, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Kirim', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
              ),
            ]),
          ],
        ],
      ]),
    );
  }
}
