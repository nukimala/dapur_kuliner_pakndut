import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

const _redDark  = Color(0xFF8B1A0A);
const _orange   = Color(0xFFF5A524);
const _textBlack = Color(0xFF1C1C1C);
const _textGray  = Color(0xFF888888);
const _green     = Color(0xFF25D366);
const _blue      = Color(0xFF2980B9);
const _redBtn    = Color(0xFFE8331A);

class HubungiCSScreen extends StatelessWidget {
  const HubungiCSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final channels = [
      {'title': 'Whatsapp',         'sub': 'Online 08:00-22:00',            'btn': 'CHAT',    'color': _green,  'url': 'https://wa.me/6285730803962'},
      {'title': 'Email Support',    'sub': 'cs@dapurkulinerpakndut.com',     'btn': 'KIRIM',   'color': _blue,   'url': 'mailto:cs@dapurkulinerpakndut.com?subject=Bantuan%20-%20Dapur%20Kuliner%20Pak%20Ndut&body=Halo%20Tim%20CS%20Dapur%20Kuliner%20Pak%20Ndut%2C%0A%0ASaya%20ingin%20bertanya%20mengenai%3A%0A'},
      {'title': 'Telepon Langsung', 'sub': '+62 852-3569-6918',              'btn': 'HUBUNGI', 'color': _redBtn, 'url': 'tel:+628523569618'},
    ];

    final schedule = [
      ['Senin – Jumat', '08:00–22:00'],
      ['Sabtu & Minggu', 'Libur'],
      ['Hari Libur', 'Libur'],
    ];

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
                  Text('Hubungi CS', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                child: Column(children: [
                  const Text('🎧', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 10),
                  Text('Tim Kami Siap Membantu!', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 21)),
                  const SizedBox(height: 6),
                  Text('Pilih saluran yang paling nyaman untuk kamu hubungi!',
                      textAlign: TextAlign.center, style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13, height: 1.55)),
                ]),
              ),
            ])),
          ]),
        ),

        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(children: [
            ...channels.map((ch) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)]),
              child: Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text(
                    ch['title'] == 'Whatsapp' ? '💬' : ch['title'] == 'Email Support' ? '📧' : '📞',
                    style: const TextStyle(fontSize: 24),
                  )),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ch['title'] as String, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 15, color: _textBlack)),
                  const SizedBox(height: 2),
                  Text(ch['sub'] as String, style: GoogleFonts.nunito(fontSize: 12, color: _textGray)),
                ])),
                GestureDetector(
                  onTap: () async {
                    final url = Uri.parse(ch['url'] as String);
                    final isExternal = url.scheme == 'mailto' || url.scheme == 'tel';
                    final launched = await launchUrl(
                      url,
                      mode: isExternal
                          ? LaunchMode.externalApplication
                          : LaunchMode.platformDefault,
                    );
                    if (!launched && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tidak dapat membuka ${url.scheme == 'mailto' ? 'aplikasi email' : url.scheme == 'tel' ? 'aplikasi telepon' : 'tautan'}. Pastikan aplikasi terkait sudah terpasang.',
                            style: GoogleFonts.nunito(),
                          ),
                          backgroundColor: _redDark,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(color: ch['color'] as Color, borderRadius: BorderRadius.circular(20)),
                    child: Text(ch['btn'] as String, style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.3)),
                  ),
                ),
              ]),
            )),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)]),
              child: Column(children: [
                Row(children: [
                  const Text('⏰', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text('JAM OPERASIONAL', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14, color: _orange)),
                ]),
                const SizedBox(height: 14),
                ...schedule.map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(row[0], style: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFF555555))),
                    Text(row[1], style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF555555))),
                  ]),
                )),
              ]),
            ),
          ]),
        )),
      ]),
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
