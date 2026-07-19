import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mybooks_mobile/screens/login_screen.dart';

// 🎨 Jedina boja koja se koristi kroz cijeli tutorial — drži brend konzistentan.
const Color kTutorialColor = Color(0xFF6D8B74);

class OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class TutorialScreen extends StatefulWidget {
  final Widget nextScreen;

  const TutorialScreen({
    super.key,
    this.nextScreen = const LoginScreen(),
  });

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  late AnimationController _floatingController;

  bool get isLastPage => _currentPage == _slides.length - 1;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      icon: Icons.auto_stories_rounded,
      title: "Tvoje knjige.\nTvoja priča.",
      description:
          "Više nikada nemoj zaboraviti knjigu koja te je promijenila. Sačuvaj trenutke, misli i emocije koje ostaju nakon čitanja.",
    ),
    OnboardingSlide(
      icon: Icons.favorite_rounded,
      title: "Pretvori čitanje\nu uspomene.",
      description:
          "Piši recenzije, čuvaj omiljene citate, zabilježi raspoloženje i napravi svoj privatni čitalački dnevnik.",
    ),
    OnboardingSlide(
      icon: Icons.insights_rounded,
      title: "Upoznaj svoje\nčitalačke navike.",
      description:
          "Prati napredak, statistiku, omiljene žanrove, autore i otključavaj posebne značke.",
    ),
    OnboardingSlide(
      icon: Icons.rocket_launch_rounded,
      title: "Vrijeme je za\nprvu knjigu.",
      description:
          "Započni svoju biblioteku, postavi cilj čitanja i napravi mjesto gdje će tvoje knjige živjeti.",
    ),
  ];

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  void _finish() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => widget.nextScreen),
      (route) => false,
    );
  }

  void _nextPage() {
    if (isLastPage) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffF8FAF8),
              Color(0xffEEF3EE),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 18, top: 8),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isLastPage ? 0 : 1,
                    child: TextButton(
                      onPressed: isLastPage ? null : _finish,
                      child: const Text(
                        "Preskoči",
                        style: TextStyle(
                          color: Color(0xff7B857B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 📖 Expanded + LayoutBuilder osigurava da PageView zna tačnu
              // visinu koju ima na raspolaganju, pa slajd unutra može
              // sigurno da se skroluje ako sadržaj ne stane (fix za overflow).
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _SlideContent(
                      slide: _slides[index],
                      animation: _floatingController,
                    );
                  },
                ),
              ),

              _buildIndicator(),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kTutorialColor,
                      elevation: 5,
                      shadowColor: kTutorialColor.withOpacity(.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Text(
                      isLastPage ? "Započni svoju biblioteku 📚" : "Nastavi",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (index) {
        final active = index == _currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 34 : 10,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: active ? kTutorialColor : Colors.grey.shade300,
          ),
        );
      }),
    );
  }
}

class _SlideContent extends StatelessWidget {
  final OnboardingSlide slide;
  final Animation<double> animation;

  const _SlideContent({
    required this.slide,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    // 🔧 LayoutBuilder + SingleChildScrollView + ConstrainedBox(minHeight):
    // sadržaj je i dalje vertikalno centriran na velikim ekranima, ali se
    // na manjim (ili kod dužeg teksta) skroluje umjesto da baci overflow.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, animation.value * 8),
                      child: child,
                    );
                  },
                  child: _buildHero(),
                ),
                const SizedBox(height: 42),
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff263238),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  slide.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.55,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHero() {
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  kTutorialColor.withOpacity(.20),
                  kTutorialColor.withOpacity(.02),
                ],
              ),
            ),
          ),
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kTutorialColor.withOpacity(.12),
            ),
          ),
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.75),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kTutorialColor.withOpacity(.35),
                      blurRadius: 35,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  slide.icon,
                  size: 65,
                  color: kTutorialColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}