import 'package:diamondnib/utils/sharedpre.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/subscription/allpayment.dart';
import 'package:diamondnib/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _hasUsedTrial = false;
  bool _isLoadingTrialStatus = true;

  @override
  void initState() {
    super.initState();
    _checkTrialStatus();
  }

  Future<void> _checkTrialStatus() async {
    try {
      if (Constant.userID == null) {
        if (!mounted) return;
        setState(() {
          _hasUsedTrial = false;
          _isLoadingTrialStatus = false;
        });
        return;
      }

      final profile = await ApiService().profile();
      final trialUsed = profile.result?.isNotEmpty == true ? (profile.result!.first.trialUsed ?? 0) : 0;

      if (!mounted) return;
      setState(() {
        _hasUsedTrial = trialUsed == 1;
        _isLoadingTrialStatus = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasUsedTrial = false;
        _isLoadingTrialStatus = false;
      });
    }
  }

  Future<Map<String, String>> _readPlanConfig() async {
    final sharedPref = SharedPre();
    final rawPrice = await sharedPref.read('subscription_plan_price');
    final rawPeriod = await sharedPref.read('subscription_plan_period');
    final rawTrialPrice = await sharedPref.read('trial_price');
    final rawTrialDays = await sharedPref.read('trial_period_days');

    return {
      'price': (rawPrice ?? '399').toString(),
      'period': (rawPeriod ?? 'week').toString(),
      'trial_price': (rawTrialPrice ?? '1').toString(),
      'trial_days': (rawTrialDays ?? '1').toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        title: const Text('Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoadingTrialStatus
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF9333EA)))
          : FutureBuilder<Map<String, String>>(
              future: _readPlanConfig(),
              builder: (context, snapshot) {
                final price = snapshot.data?['price'] ?? '399';
                final period = snapshot.data?['period'] ?? 'week';

                final periodText = period.toLowerCase() == 'month' ? 'month' : 'week';

                final trialPrice = snapshot.data?['trial_price'] ?? '1';
                final trialDaysRaw = snapshot.data?['trial_days'] ?? '1';
                final trialDays = int.tryParse(trialDaysRaw) ?? 1;
                final trialPeriod = trialDays == 1 ? '1 day' : '$trialDays days';

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _premiumCard(),
                            const SizedBox(height: 14),
                            if (!_hasUsedTrial) ...[
                              _trialCard(trialDays: trialDays, trialPrice: trialPrice),
                              const SizedBox(height: 14),
                            ],
                            _priceCard(
                              _hasUsedTrial ? price : trialPrice,
                              _hasUsedTrial ? periodText : trialPeriod,
                              isTrial: !_hasUsedTrial,
                            ),
                            const SizedBox(height: 14),
                            _infoCard(),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    _payButton(
                      context: context,
                      price: _hasUsedTrial ? price : trialPrice,
                      isTrial: !_hasUsedTrial,
                    ),
                  ],
                );
              },
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
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.8,
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

  Widget _trialCard({required int trialDays, required String trialPrice}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF9333EA).withOpacity(0.35)),
      ),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(color: Colors.white.withOpacity(0.45), width: 1.5),
            ),
            child: const Icon(Icons.local_offer_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          const Text("🎉 Free Trial Offer",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 6),
          Text(
            "Try Premium for ${trialDays == 1 ? '1 day' : '$trialDays days'} absolutely FREE!\nThen just ₹$trialPrice to continue.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: const Text("Limited Time Offer",
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
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

  Widget _priceCard(String price, String periodText, {bool isTrial = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: isTrial ? const Color(0xFF9333EA).withOpacity(0.10) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isTrial ? const Color(0xFF9333EA).withOpacity(0.30) : Colors.white.withOpacity(0.08)),
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (isTrial) ...[
              const Text("FREE", style: TextStyle(color: Color(0xFF9333EA), fontSize: 38, fontWeight: FontWeight.w500)),
            ] else ...[
              const Text("₹", style: TextStyle(color: Colors.white54, fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Text(price, style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w500)),
            ],
            const SizedBox(width: 4),
            Text("/ $periodText", style: TextStyle(color: isTrial ? const Color(0xFFB794F4) : Colors.white38, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          isTrial
              ? "Then just ₹$price after trial ends · Cancel anytime"
              : "Auto-renews every $periodText · Cancel anytime",
          style: const TextStyle(color: Colors.white38, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isTrial) ...[
              _badge("Risk-Free Trial", Colors.blue),
              const SizedBox(width: 8),
              _badge("No Card Required", Colors.green),
            ] else ...[
              _badge("Best value"),
              const SizedBox(width: 8),
              _badge("Most popular"),
            ],
          ],
        ),
      ]),
    );
  }

  Widget _badge(String label, [Color? color]) {
    final badgeColor = color ?? const Color(0xFFC084FC);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.25)),
      ),
      child: Text(label,
          style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w500)),
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
                  "Payment will be charged to your account upon confirmation. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.",
                  style: TextStyle(color: Colors.white60, fontSize: 12.5, height: 1.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _payButton({
    required BuildContext context,
    required String price,
    bool isTrial = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Column(children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isTrial ? Colors.blue : const Color(0xFF9333EA),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              elevation: 0,
              shadowColor: Colors.transparent,
            ).copyWith(
              overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.08)),
            ),
            onPressed: () async {
              // ✅ Check if user is logged in before allowing payment
              if (Constant.userID == null) {
                Utils.openLogin(context: context, isHome: false, isReplace: false);
                return;
              }

              // ✅ NEW: Navigate to payment with subscription parameters
              final config = await _readPlanConfig();
              final paymentPrice = isTrial
                  ? (config['trial_price'] ?? '1')
                  : (config['price'] ?? '399');
              final trialDaysRaw = config['trial_days'] ?? '1';
              final trialDays = int.tryParse(trialDaysRaw) ?? 1;
              final period = config['period'] ?? 'week';

              if (!context.mounted) return;

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllPayment(
                    payType: "Subscription",
                    itemId: "0",
                    price: paymentPrice,
                    itemTitle: isTrial
                        ? "Premium Trial (${trialDays == 1 ? '1 Day' : '$trialDays Days'})"
                        : "Premium Subscription",
                    typeId: "0",
                    coin: "0",
                    videoType: "0",
                    productPackage: isTrial ? 'trial' : period,
                    isTrial: isTrial,
                    currency: "INR",
                  ),
                ),
              );

              // Handle payment result
              if (result == true && context.mounted) {
                if (isTrial) {
                  // Trial is marked as used on backend via add_subscription_transaction.
                  // Refresh trial flag from backend.
                  await _checkTrialStatus();
                  setState(() {
                    _hasUsedTrial = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Trial activated! Enjoy ${trialDays == 1 ? '1 day' : '$trialDays days'} of Premium.",
                      ),
                      backgroundColor: const Color(0xFF7C3AED),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Subscription activated successfully!"),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
                Navigator.pop(context);
              }
            },
            icon: Icon(isTrial ? Icons.play_arrow_rounded : Icons.lock_rounded, size: 18, color: Colors.white),
            label: Text(isTrial ? "Start Free Trial" : "Pay ₹$price",
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, letterSpacing: 0.3)),
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