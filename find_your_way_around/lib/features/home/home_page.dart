import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

const _kHeroPhotos = [
  'https://resources.finalsite.net/images/f_auto,q_auto,t_image_size_4/v1722613952/thepegasusschoolorg/ctwoatnesjkiiqzsfipp/davitt-R5I_7965.jpg',
  'https://resources.finalsite.net/images/f_auto,q_auto,t_image_size_4/v1722613930/thepegasusschoolorg/paekabgwlvdrtsi5wcif/IMG_6646.jpg',
  'https://resources.finalsite.net/images/f_auto,q_auto,t_image_size_4/v1722613909/thepegasusschoolorg/ewgu1itnk3ixdkdiedb9/davitt-R5I_4703.jpg',
];

const _kBeyondItems = [
  _BeyondItem(
    title: 'Social Emotional Learning',
    subtitle: 'Health, wellness, and trusting relationships are at the heart of our classrooms.',
    photoUrl: 'https://resources.finalsite.net/images/f_auto,q_auto/v1688662738/thepegasusschoolorg/nz9v0w6mhyey5qm3ht50/20230228_100410.jpg',
    color: Color(0xFF1565C0),
  ),
  _BeyondItem(
    title: 'Thunder Athletics',
    subtitle: 'Student-athletes are leaders on the field, in the classroom, and in the community.',
    photoUrl: 'https://resources.finalsite.net/images/f_auto,q_auto,t_image_size_6/v1750786861/thepegasusschoolorg/bkwlylkwrxfvvfzvtuq3/Rdavitt-R5II0356.jpg',
    color: Color(0xFF2E7D32),
  ),
  _BeyondItem(
    title: 'Belonging at Pegasus',
    subtitle: 'Celebrating the unique differences of our students and families builds empathy.',
    photoUrl: 'https://resources.finalsite.net/images/f_auto,q_auto/v1688665369/thepegasusschoolorg/mvshg50qaxijobvdca2t/Davitt-4706.jpg',
    color: Color(0xFF6A1B9A),
  ),
  _BeyondItem(
    title: 'Community',
    subtitle: 'Families from nearly 50 zip codes bring unique perspectives to our campus.',
    photoUrl: 'https://resources.finalsite.net/images/f_auto,q_auto/v1687966167/thepegasusschoolorg/vlfc7gjnvczjf7dpk7um/IMG_0880-2.jpg',
    color: Color(0xFFE65100),
  ),
];

const _kFeatures = [
  _Feature(
    gradient: [Color(0xFF1565C0), Color(0xFF0D47A1)],
    icon: Icons.map,
    label: 'Campus Map',
    description: 'Navigate to any classroom,\noffice, or building on campus',
    route: '/map',
  ),
  _Feature(
    gradient: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
    icon: Icons.calendar_month,
    label: 'Academic Calendar',
    description: 'Upcoming events, activities,\nand important school dates',
    route: '/calendar',
  ),
  _Feature(
    gradient: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
    icon: Icons.people,
    label: 'Faculty Directory',
    description: 'Contact info and room\nnumbers for all teachers',
    route: '/teachers',
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _heroIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        _heroIndex = (_heroIndex + 1) % _kHeroPhotos.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RainbowStripe(),
            _HeroSection(photoIndex: _heroIndex),
            _WelcomeSection(),
            _QuickLinksSection(),
            _BeyondSection(),
          ],
        ),
      ),
    );
  }
}

// ─── Rainbow stripe ────────────────────────────────────────────────────────

class _RainbowStripe extends StatelessWidget {
  static const _colors = [
    Color(0xFF1565C0),
    Color(0xFFF9A825),
    Color(0xFFD32F2F),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
    Color(0xFFE65100),
    Color(0xFF00838F),
    Color(0xFF283593),
    Color(0xFFAD1457),
    Color(0xFF00695C),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      child: Row(
        children: _colors.map((c) => Expanded(child: Container(color: c))).toList(),
      ),
    );
  }
}

// ─── Hero section ──────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final int photoIndex;
  const _HeroSection({required this.photoIndex});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;
    final heroHeight = isWide ? 580.0 : 520.0;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 900),
            child: CachedNetworkImage(
              key: ValueKey(photoIndex),
              imageUrl: _kHeroPhotos[photoIndex],
              fit: BoxFit.cover,
              width: double.infinity,
              height: heroHeight,
              placeholder: (_, _) => Container(color: const Color(0xFF0F2347)),
              errorWidget: (_, _, _) => Container(color: const Color(0xFF0F2347)),
            ),
          ),
          // Dark gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xBB080F1E),
                  Color(0x55081022),
                  Color(0xDD050D1A),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: isWide ? 140 : 110,
                  height: isWide ? 140 : 110,
                ),
                SizedBox(height: isWide ? 24 : 18),
                Text(
                  'THE PEGASUS SCHOOL',
                  style: GoogleFonts.openSans(
                    color: AppColors.secondary,
                    fontSize: isWide ? 15 : 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: isWide ? 4.5 : 3.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isWide ? 20 : 16),
                Text(
                  'WHERE BRIGHT\nMINDS SOAR',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.merriweather(
                    color: Colors.white,
                    fontSize: isWide ? 64 : 44,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    shadows: [
                      const Shadow(
                        color: Colors.black45,
                        offset: Offset(0, 4),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isWide ? 22 : 16),
                Text(
                  'Huntington Beach, California  ·  Est. 1984',
                  style: GoogleFonts.openSans(
                    color: Colors.white60,
                    fontSize: isWide ? 14 : 12,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Welcome section ────────────────────────────────────────────────────────

class _WelcomeSection extends StatelessWidget {
  static const _bullets = [
    'Where students are challenged to become curious, motivated learners.',
    'Where inclusiveness, kindness, integrity, and empathy are deeply valued.',
    'Where intellectual curiosity and compassion are integral parts of our academically rigorous curriculum.',
    'Where it is safe to be smart, to be an individual, and to share your unique talents and gifts.',
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;

    return Container(
      color: const Color(0xFF0A1628),
      padding: EdgeInsets.fromLTRB(isWide ? 64 : 28, 56, isWide ? 64 : 28, 56),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: _WelcomeText()),
                const SizedBox(width: 48),
                Expanded(flex: 4, child: _WelcomePhoto()),
              ],
            )
          : Column(
              children: [
                _WelcomeText(),
                const SizedBox(height: 32),
                _WelcomePhoto(),
              ],
            ),
    );
  }
}

class _WelcomeText extends StatelessWidget {
  static const _bullets = [
    'Where students are challenged to become curious, motivated learners.',
    'Where inclusiveness, kindness, integrity, and empathy are deeply valued.',
    'Where intellectual curiosity and compassion are integral parts of our academically rigorous curriculum.',
    'Where it is safe to be smart, to be an individual, and to share your unique talents and gifts.',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WELCOME TO',
          style: GoogleFonts.openSans(
            color: AppColors.secondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'The Pegasus School',
          style: GoogleFonts.merriweather(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 28),
        Container(height: 3, width: 50, color: AppColors.secondary),
        const SizedBox(height: 28),
        ..._bullets.map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    b,
                    style: GoogleFonts.openSans(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.65,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomePhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: 'https://resources.finalsite.net/images/f_auto,q_auto,t_image_size_6/v1722613930/thepegasusschoolorg/paekabgwlvdrtsi5wcif/IMG_6646.jpg',
        height: 340,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          height: 340,
          color: const Color(0xFF152E58),
        ),
        errorWidget: (_, _, _) => Container(
          height: 340,
          color: const Color(0xFF152E58),
        ),
      ),
    );
  }
}

// ─── Quick links section ───────────────────────────────────────────────────

class _QuickLinksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, 52, 24, isWide ? 64 : 48),
      child: Column(
        children: [
          Text(
            'Find Your Way Around',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Everything you need, all in one place.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.subtleText),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isWide ? 40 : 28),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _kFeatures
                  .map((f) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _FeatureTile(feature: f, wide: true),
                        ),
                      ))
                  .toList(),
            )
          else
            Column(
              children: _kFeatures
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _FeatureTile(feature: f, wide: false),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final _Feature feature;
  final bool wide;
  const _FeatureTile({required this.feature, required this.wide});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      elevation: 6,
      shadowColor: feature.gradient.first.withAlpha(90),
      child: InkWell(
        onTap: () => context.go(feature.route),
        child: Container(
          height: wide ? 230 : 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: feature.gradient,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: wide
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(feature.icon,
                        color: Colors.white.withAlpha(220), size: 42),
                    const Spacer(),
                    Text(
                      feature.label,
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature.description,
                      style: GoogleFonts.openSans(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Icon(feature.icon,
                        color: Colors.white.withAlpha(220), size: 38),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            feature.label,
                            style: GoogleFonts.merriweather(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            feature.description.replaceAll('\n', ' '),
                            style: GoogleFonts.openSans(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white54),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Beyond the Classroom section ─────────────────────────────────────────

class _BeyondSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;

    return Container(
      color: const Color(0xFFF5F4F2),
      padding: EdgeInsets.fromLTRB(24, 52, 24, isWide ? 64 : 48),
      child: Column(
        children: [
          Text(
            'BEYOND THE',
            style: GoogleFonts.openSans(
              color: AppColors.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Classroom',
            style: GoogleFonts.merriweather(
              color: AppColors.primary,
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 40),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _kBeyondItems
                  .map((item) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _BeyondCard(item: item),
                        ),
                      ))
                  .toList(),
            )
          else
            Column(
              children: _kBeyondItems
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _BeyondCard(item: item),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _BeyondCard extends StatelessWidget {
  final _BeyondItem item;
  const _BeyondCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(
        elevation: 4,
        shadowColor: Colors.black26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: item.photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: item.color.withAlpha(40)),
                    errorWidget: (_, _, _) =>
                        Container(color: item.color.withAlpha(40)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          item.color.withAlpha(200),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.merriweather(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.openSans(
                      color: AppColors.subtleText,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data models ───────────────────────────────────────────────────────────

class _Feature {
  final List<Color> gradient;
  final IconData icon;
  final String label;
  final String description;
  final String route;
  const _Feature({
    required this.gradient,
    required this.icon,
    required this.label,
    required this.description,
    required this.route,
  });
}

class _BeyondItem {
  final String title;
  final String subtitle;
  final String photoUrl;
  final Color color;
  const _BeyondItem({
    required this.title,
    required this.subtitle,
    required this.photoUrl,
    required this.color,
  });
}
