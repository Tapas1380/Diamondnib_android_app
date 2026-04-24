import 'package:flutter/material.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        title: const Text('Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _premiumCard(),
                  const SizedBox(height: 14),
                  _priceCard(),
                  const SizedBox(height: 14),
                  _infoCard(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          _payButton(),
        ],
      ),
    );
  }

  Widget _premiumCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1500), Color(0xFF2D2000), Color(0xFF3D2800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.amber.withOpacity(0.30)),
      ),
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber.withOpacity(0.15),
              border: Border.all(color: Colors.amber.withOpacity(0.45), width: 1.5),
            ),
            child: const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 30),
          ),
          const SizedBox(height: 14),
          const Text("Premium Plan",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 6),
          const Text(
            "Unlock millions of tracks and enjoy\nan elevated listening experience",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.8,
            children: const [
              FeatureItem(Icons.lock_open_rounded, "Unlocked", "All content"),
              FeatureItem(Icons.download_rounded, "Download", "Listen offline"),
              FeatureItem(Icons.support_agent_rounded, "Support", "24/7 priority"),
              FeatureItem(Icons.new_releases_rounded, "Early Access", "New releases"),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statChip("320", "kbps Audio"),
              const SizedBox(width: 8),
              _statChip("Hi-Fi", "Lossless"),
              const SizedBox(width: 8),
              _statChip("∞", "Skips"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFBBF24).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.25)),
        ),
        child: Column(children: [
          Text(value, style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 17, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ]),
      ),
    );
  }

  Widget _priceCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: const [
            Text("₹", style: TextStyle(color: Colors.white54, fontSize: 18, fontWeight: FontWeight.w500)),
            SizedBox(width: 4),
            Text("399", style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w500)),
            SizedBox(width: 4),
            Text("/ 3 months", style: TextStyle(color: Colors.white38, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          "Auto-renews every 3 months · Cancel anytime",
          style: TextStyle(color: Colors.white38, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _badge("Best value"),
            const SizedBox(width: 8),
            _badge("Most popular"),
          ],
        ),
      ]),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFC084FC).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC084FC).withOpacity(0.25)),
      ),
      child: Text(label,
          style: const TextStyle(color: Color(0xFFC084FC), fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.access_time_rounded, color: Color(0x99C084FC), size: 15),
              SizedBox(width: 8),
              Text(
                "SUBSCRIPTION INFO",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Your plan auto-renews based on the selected plan. You can cancel anytime before renewal — your subscription stays active until it expires.",
            style: TextStyle(color: Colors.white60, fontSize: 12.5, height: 1.7),
          ),
          const Divider(color: Colors.white10, height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("•  ", style: TextStyle(color: Color(0x99C084FC), fontSize: 13)),
              Expanded(
                child: Text(
                  "FHD/HD availability depends on your internet & device. Not all content supports all resolutions or devices.",
                  style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _payButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Column(children: [
        SizedBox(
          width: double.infinity, height: 56,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9333EA), 
              foregroundColor: Colors.white, // vivid purple
              shape: const StadiumBorder(),
              elevation: 0,
              shadowColor: Colors.transparent,
            ).copyWith(
              overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.08)),
            ),
            onPressed: () {},
            icon: const Icon(Icons.lock_rounded, size: 18, color: Colors.white),
            label: const Text("Pay ₹399",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, letterSpacing: 0.3)),
          ),
        ),
        const SizedBox(height: 8),
        const Text("Secured payment · 100% safe checkout",
            style: TextStyle(color: Colors.white24, fontSize: 11)),
      ]),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const FeatureItem(this.icon, this.title, this.subtitle, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFFBBF24).withOpacity(0.15),  // gold tint
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFFBBF24), size: 16),  // gold icons
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ]),
    );
  }
}