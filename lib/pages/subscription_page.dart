import 'package:diamondnib/utils/sharedpre.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/subscription/allpayment.dart';
import 'package:diamondnib/webservice/apiservices.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with SingleTickerProviderStateMixin {
  bool _hasUsedTrial = false;
  bool _isLoadingTrialStatus = true;

  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _isVideoPlaying = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const String _videoUrl =
      'https://firebasestorage.googleapis.com/v0/b/diamondnib.firebasestorage.app/o/Diamond%20Nib%20FM.mp4?alt=media&token=c112f5e4-c095-4a10-91f5-52fdd2863426';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _checkTrialStatus();
  }

  Future<void> _initVideo() async {
    if (_videoController != null) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(_videoUrl));
    _videoController = controller;

    try {
      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(1.0); // ✅ UNMUTED — full audio
      await controller.play();
      if (mounted) {
        setState(() {
          _videoInitialized = true;
          _isVideoPlaying = true;
        });
      }
    } catch (_) {
      // graceful degradation — page still works without video
    }
  }

  void _togglePlayPause() {
    if (_videoController == null) return;
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _isVideoPlaying = false;
      } else {
        _videoController!.play();
        _isVideoPlaying = true;
      }
    });
  }

  Future<void> _pausePreviewVideo() async {
    final controller = _videoController;
    if (controller == null) return;

    try {
      if (controller.value.isPlaying) {
        await controller.pause();
      }
    } catch (_) {
      // Ignore pause failures; navigation should not be blocked.
    }

    if (!mounted) return;
    setState(() => _isVideoPlaying = false);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkTrialStatus() async {
    try {
      if (Constant.userID == null) {
        if (!mounted) return;
        setState(() {
          _hasUsedTrial = false;
          _isLoadingTrialStatus = false;
        });
        _initVideo();
        _animController.forward();
        return;
      }

      final profile = await ApiService().profile();
      final trialUsed = profile.result?.isNotEmpty == true
          ? (profile.result!.first.trialUsed ?? 0)
          : 0;

      if (!mounted) return;
      setState(() {
        _hasUsedTrial = trialUsed == 1;
        _isLoadingTrialStatus = false;
      });

      if (!_hasUsedTrial) _initVideo();
      _animController.forward();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasUsedTrial = false;
        _isLoadingTrialStatus = false;
      });
      _initVideo();
      _animController.forward();
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
      backgroundColor: const Color(0xFF080810),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xCC080810), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: _isLoadingTrialStatus
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD166)))
          : FutureBuilder<Map<String, String>>(
              future: _readPlanConfig(),
              builder: (context, snapshot) {
                final price = snapshot.data?['price'] ?? '399';
                final period = snapshot.data?['period'] ?? 'week';
                final periodText =
                    period.toLowerCase() == 'month' ? 'month' : 'week';
                final trialPrice = snapshot.data?['trial_price'] ?? '1';
                final trialDaysRaw = snapshot.data?['trial_days'] ?? '1';
                final trialDays = int.tryParse(trialDaysRaw) ?? 1;
                final trialPeriod =
                    trialDays == 1 ? '1 day' : '$trialDays days';

                return FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              // ── TRIAL USER LAYOUT ─────────────────────
                              if (!_hasUsedTrial) ...[
                                // 1. Hero offer banner (TOP — full bleed)
                                _trialHeroCard(
                                  trialDays: trialDays,
                                  trialPrice: trialPrice,
                                ),

                                // 2. Video preview
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 20, 16, 0),
                                  child: _videoCard(),
                                ),

                                // 3. Price card
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                  child: _priceCard(
                                    trialPrice,
                                    trialPeriod,
                                    isTrial: true,
                                  ),
                                ),

                                // 4. Features grid
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                  child: _featuresGrid(),
                                ),

                                // 5. Info card
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                  child: _trialInfoCard(),
                                ),

                                const SizedBox(height: 100),
                              ],

                              // ── POST-TRIAL / PREMIUM LAYOUT ───────────
                              if (_hasUsedTrial) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 100, 16, 0),
                                  child: Column(
                                    children: [
                                      _premiumCard(),
                                      const SizedBox(height: 16),
                                      _priceCard(price, periodText,
                                          isTrial: false),
                                      const SizedBox(height: 16),
                                      _infoCard(),
                                      const SizedBox(height: 100),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      _payButton(
                        context: context,
                        price: _hasUsedTrial ? price : trialPrice,
                        isTrial: !_hasUsedTrial,
                        trialDays:
                            int.tryParse(snapshot.data?['trial_days'] ?? '1') ??
                                1,
                        period: snapshot.data?['period'] ?? 'week',
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TRIAL HERO CARD  (full-bleed top section — no side padding)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _trialHeroCard({required int trialDays, required String trialPrice}) {
    final period = trialDays == 1 ? '1 Day' : '$trialDays Days';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 86, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0x3322D3EE),
            Color(0x1AFFD166),
            Color(0xFF10131A),
            Color(0xFF121416),
          ],
          stops: [0.0, 0.28, 0.68, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.workspace_premium_rounded,
                    color: Color(0xFFFFD166), size: 14),
                SizedBox(width: 6),
                Text(
                  "TRIAL ACCESS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD166), width: 1.3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.26),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$trialDays",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 0.95,
                  ),
                ),
                Text(
                  trialDays == 1 ? "day free" : "days free",
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "Try Premium Free\nfor $period",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Then just ₹$trialPrice to continue. Cancel anytime.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.62),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          // Benefit pills
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: const [
              _PillChip(
                icon: Icons.music_note_rounded,
                iconColor: Color(0xFF7DD3FC),
                label: "All Tracks",
              ),
              _PillChip(
                icon: Icons.download_rounded,
                iconColor: Color(0xFF6EE7B7),
                label: "Offline Mode",
              ),
              _PillChip(
                icon: Icons.hd_rounded,
                iconColor: Color(0xFFFFD166),
                label: "Hi-Fi Audio",
              ),
              _PillChip(
                icon: Icons.all_inclusive_rounded,
                iconColor: Color(0xFFFDA4AF),
                label: "Unlimited Skips",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VIDEO CARD  (with audio, play/pause toggle, "LIVE PREVIEW" badge)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _videoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF7DD3FC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "WATCH WHAT'S WAITING",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Video container
        GestureDetector(
          onTap: _togglePlayPause,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.width * 9 / 16,
              decoration: BoxDecoration(
                color: const Color(0xFF101217),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.42),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Video or loader
                  if (_videoInitialized && _videoController != null)
                    Positioned.fill(
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                    )
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFFFFD166),
                          strokeWidth: 2.5,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Loading preview...",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                  // Pause overlay icon
                  if (_videoInitialized)
                    AnimatedOpacity(
                      opacity: _isVideoPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.55),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 1.5),
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 30),
                      ),
                    ),

                  // Volume / live badge (top right)
                  if (_videoInitialized)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.volume_up_rounded,
                                color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              "LIVE PREVIEW",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            "Tap video to pause / play",
            style:
                TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 11),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FEATURES GRID  (compact, for trial layout)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _featuresGrid() {
    const features = <_FeatureData>[
      _FeatureData(Icons.lock_open_rounded, "All Unlocked",
          "Every track & album", Color(0xFF7DD3FC)),
      _FeatureData(Icons.download_rounded, "Offline Mode", "Listen anywhere",
          Color(0xFF6EE7B7)),
      _FeatureData(Icons.graphic_eq_rounded, "320kbps Audio",
          "Crystal clear sound", Color(0xFFFFD166)),
      _FeatureData(Icons.support_agent_rounded, "24/7 Support",
          "Priority access", Color(0xFFFDA4AF)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFFBBF24),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "WHAT YOU GET",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemCount: features.length,
          itemBuilder: (context, i) {
            final feature = features[i];
            final icon = feature.icon;
            final title = feature.title;
            final sub = feature.subtitle;
            final accent = feature.accent;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.045),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.14),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: accent, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      Text(sub,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ]),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PREMIUM CARD  (golden — post-trial users only)
  // ─────────────────────────────────────────────────────────────────────────
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
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber.withOpacity(0.15),
              border:
                  Border.all(color: Colors.amber.withOpacity(0.45), width: 1.5),
            ),
            child: const Icon(Icons.star_rounded,
                color: Color(0xFFFBBF24), size: 30),
          ),
          const SizedBox(height: 14),
          const Text("Premium Plan",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
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
              FeatureItem(
                  Icons.support_agent_rounded, "Support", "24/7 priority"),
              FeatureItem(
                  Icons.new_releases_rounded, "Early Access", "New releases"),
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
          Text(value,
              style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 17,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PRICE CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _priceCard(String price, String periodText, {bool isTrial = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        color: isTrial
            ? Colors.white.withOpacity(0.055)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isTrial
              ? const Color(0xFFFFD166).withOpacity(0.34)
              : Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: isTrial
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (isTrial) ...[
              const Text("FREE",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w800)),
            ] else ...[
              const Text("₹",
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 20,
                      fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Text(price,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1)),
            ],
            const SizedBox(width: 6),
            Text(
              "/ $periodText",
              style: TextStyle(
                color: isTrial ? const Color(0xFFFFD166) : Colors.white38,
                fontSize: 15,
              ),
            ),
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
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: isTrial
              ? [
                  _badge("✓  Risk-Free Trial", const Color(0xFF7DD3FC)),
                  _badge("✓  No Card Required", const Color(0xFF6EE7B7)),
                ]
              : [
                  _badge("★  Best Value", const Color(0xFFFBBF24)),
                  _badge("◆  Most Popular", const Color(0xFFC084FC)),
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
        color: badgeColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.25)),
      ),
      child: Text(label,
          style: TextStyle(
              color: badgeColor, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _trialInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline_rounded,
                  color: Color(0xFFFFD166), size: 14),
              SizedBox(width: 8),
              Text(
                "SUBSCRIPTION INFO",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Your plan auto-renews based on the selected plan. You can cancel anytime before renewal — your subscription stays active until it expires.",
            style:
                TextStyle(color: Colors.white54, fontSize: 12.5, height: 1.7),
          ),
          const Divider(color: Colors.white10, height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("•  ",
                  style: TextStyle(color: Color(0xFFFFD166), fontSize: 13)),
              Expanded(
                child: Text(
                  "Payment will be charged to your account upon confirmation. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.",
                  style: TextStyle(
                      color: Colors.white54, fontSize: 12.5, height: 1.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INFO CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline_rounded,
                  color: Color(0x99C084FC), size: 14),
              SizedBox(width: 8),
              Text(
                "SUBSCRIPTION INFO",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Your plan auto-renews based on the selected plan. You can cancel anytime before renewal — your subscription stays active until it expires.",
            style:
                TextStyle(color: Colors.white54, fontSize: 12.5, height: 1.7),
          ),
          const Divider(color: Colors.white10, height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("•  ",
                  style: TextStyle(color: Color(0x99C084FC), fontSize: 13)),
              Expanded(
                child: Text(
                  "Payment will be charged to your account upon confirmation. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.",
                  style: TextStyle(
                      color: Colors.white54, fontSize: 12.5, height: 1.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PAY BUTTON
  // ─────────────────────────────────────────────────────────────────────────
  Widget _payButton({
    required BuildContext context,
    required String price,
    bool isTrial = false,
    int trialDays = 1,
    String period = 'week',
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF080810),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(children: [
        // Trust row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_rounded,
                size: 12, color: Colors.white.withOpacity(0.28)),
            const SizedBox(width: 5),
            Text(
              "Secured payment · 100% safe checkout",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.28), fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Gradient CTA button
        SizedBox(
          width: double.infinity,
          height: 58,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: isTrial
                  ? const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              boxShadow: [
                BoxShadow(
                  color: (isTrial
                          ? const Color(0xFF7C3AED)
                          : const Color(0xFF7C3AED))
                      .withOpacity(0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              onPressed: () async {
                await _pausePreviewVideo();
                if (!context.mounted) return;

                if (Constant.userID == null) {
                  Utils.openLogin(
                      context: context, isHome: false, isReplace: false);
                  return;
                }

                final config = await _readPlanConfig();
                final paymentPrice = isTrial
                    ? (config['trial_price'] ?? '1')
                    : (config['price'] ?? '399');
                final td = int.tryParse(config['trial_days'] ?? '1') ?? 1;
                final pd = config['period'] ?? 'week';

                if (!context.mounted) return;

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllPayment(
                      payType: "Subscription",
                      itemId: "0",
                      price: paymentPrice,
                      itemTitle: isTrial
                          ? "Premium Trial (${td == 1 ? '1 Day' : '$td Days'})"
                          : "Premium Subscription",
                      typeId: "0",
                      coin: "0",
                      videoType: "0",
                      productPackage: isTrial ? 'trial' : pd,
                      isTrial: isTrial,
                      currency: "INR",
                    ),
                  ),
                );

                if (result == true && context.mounted) {
                  if (isTrial) {
                    await _checkTrialStatus();
                    if (!context.mounted) return;

                    setState(() => _hasUsedTrial = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Trial activated! Enjoy ${td == 1 ? '1 day' : '$td days'} of Premium.",
                        ),
                        backgroundColor: const Color(0xFF10B981),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Subscription activated successfully!"),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              icon: Icon(
                  isTrial ? Icons.play_arrow_rounded : Icons.lock_open_rounded,
                  size: 20,
                  color: Colors.white),
              label: Text(
                isTrial ? "Start Free Trial" : "Pay ₹$price",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PILL CHIP  (used in trial hero banner)
// ─────────────────────────────────────────────────────────────────────────────
class _FeatureData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  const _FeatureData(this.icon, this.title, this.subtitle, this.accent);
}

class _PillChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  const _PillChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FEATURE ITEM  (used in premium / golden card)
// ─────────────────────────────────────────────────────────────────────────────
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
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFFBBF24).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFFBBF24), size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
            Text(subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ]),
    );
  }
}
