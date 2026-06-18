// lib/screens/level_select_screen.dart
import 'package:flutter/material.dart';
import '../main.dart' show routeObserver;
import '../utils/constants.dart';
import '../utils/preferences.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});
  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          backgroundColor: kBg,
          pinned: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextDim),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('SELECT LEVEL', style: techno(16, letterSpacing: 4)),
          centerTitle: true,
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            _section('EASY', kEasyColor, 0, 49, '5×5'),
            _section('MEDIUM', kMediumColor, 50, 99, '6×6'),
            _section('HARD', kHardColor, 100, 149, '7×7'),
            const SizedBox(height: 32),
          ]),
        ),
      ]),
    );
  }

  Widget _section(String label, Color color, int start, int end, String grid) {
    final count = end - start + 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Text(label, style: techno(14, color: color, letterSpacing: 4)),
          const SizedBox(width: 10),
          Text(grid,
              style: techno(11,
                  color: kTextDim.withOpacity(0.6), letterSpacing: 2)),
        ]),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.9,
          ),
          itemCount: count,
          itemBuilder: (ctx, i) => _LevelButton(
            levelIndex: start + i,
            accentColor: color,
          ),
        ),
      ]),
    );
  }
}

class _LevelButton extends StatelessWidget {
  final int levelIndex;
  final Color accentColor;
  const _LevelButton({required this.levelIndex, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final maxUnlocked = Preferences.instance.getMaxUnlocked();
    final stars = Preferences.instance.getLevelStars(levelIndex);
    final unlocked = levelIndex <= maxUnlocked;
    final completed = stars > 0;

    return GestureDetector(
      onTap: unlocked
          ? () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => GameScreen(levelIndex: levelIndex)))
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: completed
                ? accentColor.withOpacity(0.6)
                : unlocked
                    ? kBorder
                    : kBorder.withOpacity(0.3),
          ),
          boxShadow: completed
              ? [BoxShadow(color: accentColor.withOpacity(0.18), blurRadius: 10)]
              : null,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('${levelIndex + 1}',
              style: techno(15,
                  color: unlocked ? Colors.white : kTextDim.withOpacity(0.3))),
          const SizedBox(height: 5),
          if (!unlocked)
            Icon(Icons.lock_outline,
                color: kTextDim.withOpacity(0.22), size: 14)
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  3,
                  (i) => Icon(
                        i < stars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: i < stars ? kStarOn : kStarOff,
                        size: 11,
                      )),
            ),
        ]),
      ),
    );
  }
}
