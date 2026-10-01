import 'dart:ui' show lerpDouble;
import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/daily_slogans.dart';
import '../../core/constants/milestone_tiers.dart';
import '../../core/services/vibration_service.dart';
import '../../core/theme/app_colors.dart';
import '../viewmodels/habit_viewmodel.dart';
import '../widgets/animations/burning_streak_number.dart';
import '../widgets/animations/flying_sparkle_overlay.dart';
import '../widgets/animations/milestone_celebration_overlay.dart';
import '../widgets/animations/perfect_day_overlay.dart';
import '../widgets/arcade_arrow_button.dart';
import '../widgets/concentric_habit_rings.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/overall_habit_heatmap.dart';
import '../widgets/stacked_habit_deck.dart';

class TodayScreen extends StatefulWidget {
  final VoidCallback onNavigateToGoals;

  const TodayScreen({
    super.key,
    required this.onNavigateToGoals,
  });

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final GlobalKey<ConcentricHabitRingsState> _ringsKey = GlobalKey();
  final GlobalKey<BurningStreakNumberState> _headerStreakKey = GlobalKey();
  final GlobalKey<BurningStreakNumberState> _cardStreakKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _headerBoxKey = GlobalKey();
  final Map<String, GlobalKey> _categoryKeys = {};
  final Set<String> _expandedCategories = {};
  List<String> _dockedCategoryNames = [];
  late ConfettiController _confettiController;
  bool _showPerfectDay = false;

  // Segmented horizontal view: 0 = Today, 1 = Overall
  int _selectedSegment = 0;
  late final PageController _pageController;
  final ScrollController _overallScrollController = ScrollController();
  final GlobalKey _overallHeaderStreakKey = GlobalKey();

  int _sloganOffset = 0;

  String get _todaySlogan {
    return DailySlogans.getSloganWithOffset(DateTime.now(), _sloganOffset);
  }

  void _shuffleSlogan() {
    VibrationService.click();
    setState(() {
      _sloganOffset++;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedSegment);
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final vm = Provider.of<HabitViewModel>(context, listen: false);
        vm.syncTodayDate();
        _updateDockedCategories();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _overallScrollController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _updateDockedCategories();
  }

  void _updateDockedCategories() {
    if (!mounted || _selectedSegment != 0) return;
    final vm = Provider.of<HabitViewModel>(context, listen: false);
    final categories = StackedHabitDeck.groupGoals(vm.scheduledGoals);
    if (categories.isEmpty) return;

    if (_scrollController.hasClients && _scrollController.offset <= 6.0) {
      if (_dockedCategoryNames.isNotEmpty) {
        setState(() {
          _dockedCategoryNames = [];
        });
      }
      return;
    }

    final headerBox = _headerBoxKey.currentContext?.findRenderObject() as RenderBox?;
    if (headerBox == null || !headerBox.hasSize) return;

    final headerBottom = headerBox.localToGlobal(Offset.zero).dy + headerBox.size.height;
    final List<String> docked = [];

    // Card 0 ("SỨC KHỎE") docks when its tab scrolls under the header
    final key0 = _categoryKeys[categories[0].name];
    final box0 = key0?.currentContext?.findRenderObject() as RenderBox?;
    if (box0 != null && box0.hasSize) {
      final cardTop = box0.localToGlobal(Offset.zero).dy;
      if (cardTop <= headerBottom - 6) {
        docked.add(categories[0].name);
      }
    } else if (_scrollController.hasClients && _scrollController.offset > 20.0) {
      docked.add(categories[0].name);
    }

    // Cards 1..N:
    for (int i = 1; i < categories.length; i++) {
      final cat = categories[i];
      final key = _categoryKeys[cat.name];
      final box = key?.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final cardTop = box.localToGlobal(Offset.zero).dy;
        if (cardTop <= headerBottom + 10) {
          docked.add(cat.name);
        }
      }
    }

    if (!listEquals(_dockedCategoryNames, docked)) {
      setState(() {
        _dockedCategoryNames = docked;
      });
    }
  }

  void _toggleCategory(String name) {
    VibrationService.click();
    setState(() {
      if (_expandedCategories.contains(name)) {
        _expandedCategories.remove(name);
      } else {
        _expandedCategories.add(name);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateDockedCategories());
  }

  void _toggleExpandAll() {
    VibrationService.click();
    final vm = Provider.of<HabitViewModel>(context, listen: false);
    final categories = StackedHabitDeck.groupGoals(vm.scheduledGoals);
    final allNames = categories.map((c) => c.name).toSet();

    setState(() {
      if (_expandedCategories.length >= allNames.length) {
        _expandedCategories.clear();
      } else {
        _expandedCategories.addAll(allNames);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateDockedCategories());
  }

  void _scrollToCategory(String categoryName) {
    VibrationService.click();
    final vm = Provider.of<HabitViewModel>(context, listen: false);
    final categories = StackedHabitDeck.groupGoals(vm.scheduledGoals);
    if (categories.isEmpty) return;

    if (categoryName == categories[0].name) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
        );
      }
      return;
    }

    final key = _categoryKeys[categoryName];
    final box = key?.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize && _scrollController.hasClients) {
      final cardGlobalY = box.localToGlobal(Offset.zero).dy;
      final headerBox = _headerBoxKey.currentContext?.findRenderObject() as RenderBox?;
      final headerBottom = headerBox != null && headerBox.hasSize
          ? (headerBox.localToGlobal(Offset.zero).dy + headerBox.size.height)
          : 148.0;

      final diff = cardGlobalY - headerBottom;
      final targetOffset = (_scrollController.offset + diff).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Widget _buildDockedIconsRow(List<CategoryInfo> categories) {
    return Align(
      key: const ValueKey('docked_icons_row'),
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _dockedCategoryNames.map((name) {
            final cat = categories.firstWhere(
              (c) => c.name == name,
              orElse: () => categories.first,
            );
            return Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: GestureDetector(
                onTap: () => _scrollToCategory(cat.name),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.5, end: 1.0),
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: cat.color,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1.8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(1.5, 1.5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        cat.icon,
                        size: 17,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildExpandCollapseAllButton(bool isAllExpanded, List<CategoryInfo> categories) {
    return ArcadeArrowButton(
      isExpanded: isAllExpanded,
      onTap: _toggleExpandAll,
      size: 34.0,
      tooltip: isAllExpanded ? 'Thu gọn tất cả' : 'Mở rộng tất cả',
    );
  }

  void _showMilestoneSheet(BuildContext context, int streakDays) {
    final currentTier = MilestoneConstants.getTier(streakDays);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) => MilestoneCelebrationOverlay(
        streakDays: streakDays,
        tier: currentTier,
        onDismiss: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HabitViewModel>(context);

    // Trigger celebration if reached 100%
    if (vm.justReachedPerfect) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.resetConfetti();
        _confettiController.play();
        Future.delayed(const Duration(milliseconds: 1400), () {
          if (mounted) {
            setState(() {
              _showPerfectDay = true;
            });
          }
        });
      });
    }

    final scheduledGoals = vm.scheduledGoals;
    final allGoals = vm.goals;
    final streakDays = vm.overallStreak;
    final categories = StackedHabitDeck.groupGoals(scheduledGoals);
    for (final cat in categories) {
      _categoryKeys.putIfAbsent(cat.name, () => GlobalKey());
    }
    final isAllExpanded = categories.isNotEmpty &&
        _expandedCategories.length >= categories.length;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: PageView(
              controller: _pageController,
              physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
              onPageChanged: (index) {
                if (_selectedSegment != index) {
                  _selectedSegment = index;
                  if (index == 0) {
                    _updateDockedCategories();
                  }
                }
              },
              children: [
                // Page 0: Today
                _KeepAlivePage(
                  child: ScrollConfiguration(
                    behavior: const ScrollBehavior().copyWith(overscroll: false),
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const ClampingScrollPhysics(),
                      slivers: [
                        // 1. COLLAPSIBLE Top Header: Slogan (left) + BurningStreakNumber (right)
                        SliverToBoxAdapter(
                          child: AnimatedBuilder(
                            animation: _scrollController,
                            builder: (context, child) {
                              final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                              final progress = (offset / 105.0).clamp(0.0, 1.0);
                              final sloganOpacity = (1.0 - progress * 1.5).clamp(0.0, 1.0);

                              return Padding(
                                padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _shuffleSlogan,
                                        behavior: HitTestBehavior.opaque,
                                        child: Opacity(
                                          opacity: sloganOpacity,
                                          child: AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 250),
                                            transitionBuilder: (child, animation) => FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            ),
                                            child: Text(
                                              _todaySlogan,
                                              key: ValueKey<String>(_todaySlogan),
                                              style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textMain,
                                                height: 1.35,
                                                letterSpacing: 0.1,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Transform.translate(
                                      offset: Offset(-14.0 * progress, 12.0 * progress),
                                      child: Opacity(
                                        opacity: sloganOpacity,
                                        child: BurningStreakNumber(
                                          key: _headerStreakKey,
                                          streakDays: streakDays,
                                          onTap: () => _showMilestoneSheet(context, streakDays),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // 2. COLLAPSIBLE Horizontal Segmented Switcher (Today | Overall)
                        SliverToBoxAdapter(
                          child: AnimatedBuilder(
                            animation: _scrollController,
                            builder: (context, child) {
                              final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                              final progress = (offset / 85.0).clamp(0.0, 1.0);
                              final opacity = (1.0 - progress * 1.5).clamp(0.0, 1.0);

                              return Opacity(
                                opacity: opacity,
                                child: IgnorePointer(
                                  ignoring: opacity < 0.2,
                                  child: _buildSegmentedSwitcher(),
                                ),
                              );
                            },
                          ),
                        ),

                        // 3. Pinned Sticky Concentric Habit Rings Card with Category Dock Bar & Expand/Collapse All
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _ConcentricCardHeaderDelegate(
                            boxKey: _headerBoxKey,
                            minHeight: 134.0,
                            maxHeight: 134.0,
                            scrollController: _scrollController,
                            builder: (context, shrinkOffset, progress) {
                              final completedCategories = categories
                                  .where((cat) => cat.isCompleted(vm))
                                  .length;
                              final isScrolled =
                                  _dockedCategoryNames.isNotEmpty && progress > 0.05;

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      20,
                                      2,
                                      20,
                                      lerpDouble(4.0, 2.0, progress)!,
                                    ),
                                    child: ConcentricHabitRings(
                                      key: _ringsKey,
                                      categories: categories,
                                      viewModel: vm,
                                      completedGoals: completedCategories,
                                      totalGoals: categories.length,
                                      streakDays: streakDays,
                                      streakKey: _cardStreakKey,
                                      collapseProgress: progress,
                                      onStreakTap: () => _showMilestoneSheet(context, streakDays),
                                      onTap: () {
                                        if (_scrollController.hasClients && _scrollController.offset > 10) {
                                          _scrollController.animateTo(
                                            0.0,
                                            duration: const Duration(milliseconds: 350),
                                            curve: Curves.easeOutCubic,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  if (isScrolled)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: SizedBox(
                                        height: 34.0,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: _buildDockedIconsRow(categories),
                                            ),
                                            const SizedBox(width: 8),
                                            _buildExpandCollapseAllButton(isAllExpanded, categories),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),

                        // 4. Main Body: StackedHabitDeck
                        SliverToBoxAdapter(
                          child: StackedHabitDeck(
                            goals: scheduledGoals,
                            viewModel: vm,
                            onAddHabit: widget.onNavigateToGoals,
                            onCategoryCompleted: _onCategoryCompleted,
                            expandedCategories: _expandedCategories,
                            onToggleCategory: _toggleCategory,
                            categoryKeys: _categoryKeys,
                            hideFirstCardTab: false,
                            firstCardHeaderTrailing: AnimatedBuilder(
                              animation: _scrollController,
                              builder: (context, _) {
                                final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                                final progress = (scrollOffset / 85.0).clamp(0.0, 1.0);
                                final isScrolled = _dockedCategoryNames.isNotEmpty && progress > 0.05;
                                if (isScrolled) {
                                  return const SizedBox.shrink();
                                }
                                return _buildExpandCollapseAllButton(isAllExpanded, categories);
                              },
                            ),
                          ),
                        ),

                        // 5. Bottom clearance for navigation bar
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 180),
                        ),
                      ],
                    ),
                  ),
                ),

                // Page 1: Overall
                _KeepAlivePage(
                  child: ScrollConfiguration(
                    behavior: const ScrollBehavior().copyWith(overscroll: false),
                    child: CustomScrollView(
                      controller: _overallScrollController,
                      physics: const ClampingScrollPhysics(),
                      slivers: [
                        // 1. Slogan + BurningStreak for Overall
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _shuffleSlogan,
                                    behavior: HitTestBehavior.opaque,
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      transitionBuilder: (child, animation) => FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                      child: Text(
                                        _todaySlogan,
                                        key: ValueKey<String>(_todaySlogan),
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textMain,
                                          height: 1.35,
                                          letterSpacing: 0.1,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                BurningStreakNumber(
                                  key: _overallHeaderStreakKey,
                                  streakDays: streakDays,
                                  onTap: () => _showMilestoneSheet(context, streakDays),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 2. Segmented Switcher for Overall
                        SliverToBoxAdapter(
                          child: _buildSegmentedSwitcher(),
                        ),

                        // 3. OverallHabitHeatmap
                        SliverToBoxAdapter(
                          child: OverallHabitHeatmap(
                            categories: StackedHabitDeck.groupGoals(allGoals),
                            goals: allGoals,
                            viewModel: vm,
                            onAddHabit: widget.onNavigateToGoals,
                          ),
                        ),

                        // 4. Bottom clearance for navigation bar
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 180),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Perfect Day Victory Celebration
        if (_showPerfectDay)
          PerfectDayOverlay(
            onDismiss: () {
              setState(() => _showPerfectDay = false);
              vm.resetConfetti();
            },
          ),

        // Confetti Celebration
        ConfettiOverlay(controller: _confettiController),
      ],
    );
  }

  void _onCategoryCompleted(CategoryInfo category, Offset fromPos) {
    final chartBox = _ringsKey.currentContext?.findRenderObject() as RenderBox?;
    if (chartBox == null || !chartBox.hasSize) return;

    // Inside ConcentricHabitRings:
    // Container horizontal padding: 14, chart size: 108 -> center X = 14 + 54 = 68.0
    final localTarget = Offset(68.0, chartBox.size.height * 0.5);
    final chartPos = chartBox.localToGlobal(localTarget);

    FlyingSparkleOverlay.show(
      context,
      from: fromPos,
      to: chartPos,
      color: category.color,
      particleCount: 22,
      targetSpreadX: 20.0,
      targetSpreadY: 20.0,
      onTargetHit: () {
        if (!mounted) return;
        _ringsKey.currentState?.pulse(highlightColor: category.color);
        VibrationService.taskComplete();

        // Check if all scheduled goals for today are completed
        final vm = Provider.of<HabitViewModel>(context, listen: false);
        final scheduled = vm.scheduledGoals;
        final allDone = scheduled.isNotEmpty &&
            scheduled.every((g) => vm.isGoalCompleted(g));

        if (allDone) {
          // Launch magical stars from Circular Chart to Burning Streak Badge!
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            _launchStarsToStreakBadge(chartPos);
          });
        }
      },
    );
  }

  void _launchStarsToStreakBadge(Offset chartPos) {
    final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    final isScrolled = offset > 40.0;

    final targetKey = isScrolled ? _cardStreakKey : _headerStreakKey;
    final streakBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (streakBox == null || !streakBox.hasSize) return;

    final streakPos = streakBox.localToGlobal(
      Offset(streakBox.size.width * 0.5, streakBox.size.height * 0.5),
    );

    FlyingSparkleOverlay.show(
      context,
      from: chartPos,
      to: streakPos,
      color: const Color(0xFFEA580C),
      particleCount: 26,
      targetSpreadX: 18.0,
      targetSpreadY: 8.0,
      duration: const Duration(milliseconds: 1400),
      onTargetHit: () {
        if (!mounted) return;
        _cardStreakKey.currentState?.ignite();
        _headerStreakKey.currentState?.ignite();
        VibrationService.taskComplete();
      },
    );
  }

  void _onSelectSegment(int index) {
    if (_selectedSegment != index) {
      _selectedSegment = index;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  Widget _buildSegmentedSwitcher() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(4.5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black,
            width: 2.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(3.5, 3.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            final trackHeight = constraints.maxHeight;
            final tabWidth = (trackWidth - 4.0) / 2.0;

            return AnimatedBuilder(
              animation: _pageController,
              builder: (context, _) {
                double page = _selectedSegment.toDouble();
                if (_pageController.hasClients &&
                    _pageController.position.hasContentDimensions) {
                  page = (_pageController.page ?? _selectedSegment.toDouble()).clamp(0.0, 1.0);
                }
                final pillLeft = (page * (tabWidth + 4.0)).clamp(0.0, tabWidth + 4.0);
                final isTodayActive = page < 0.5;

                return Stack(
                  children: [
                    // 1. Physical Smooth Animated Sliding Pill following finger in real-time
                    Positioned(
                      left: pillLeft,
                      top: 0.0,
                      width: tabWidth,
                      height: trackHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: Colors.black,
                            width: 1.8,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(2.0, 2.0),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. Interactive Clickable Tab Labels on Top
                    Row(
                      children: [
                        // Tab 0: Today
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _onSelectSegment(0),
                            child: SizedBox(
                              height: trackHeight,
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 15.5,
                                      color: isTodayActive
                                          ? Colors.black
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      'Today',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: isTodayActive
                                            ? FontWeight.w900
                                            : FontWeight.w700,
                                        color: isTodayActive
                                            ? Colors.black
                                            : const Color(0xFF64748B),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 4.0),

                        // Tab 1: Overall
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _onSelectSegment(1),
                            child: SizedBox(
                              height: trackHeight,
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.grid_view_rounded,
                                      size: 15.5,
                                      color: !isTodayActive
                                          ? Colors.black
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      'Overall',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: !isTodayActive
                                            ? FontWeight.w900
                                            : FontWeight.w700,
                                        color: !isTodayActive
                                            ? Colors.black
                                            : const Color(0xFF64748B),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Sliver persistent header delegate for the pinned ConcentricHabitRings card
class _ConcentricCardHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final GlobalKey? boxKey;
  final ScrollController? scrollController;
  final Widget Function(BuildContext context, double shrinkOffset, double progress) builder;

  _ConcentricCardHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    this.boxKey,
    this.scrollController,
    required this.builder,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    if (scrollController != null) {
      return AnimatedBuilder(
        animation: scrollController!,
        builder: (context, _) {
          final scrollOffset = scrollController!.hasClients
              ? scrollController!.offset
              : 0.0;
          final progress = (scrollOffset / 85.0).clamp(0.0, 1.0);
          final currentHeight =
              (maxHeight - shrinkOffset).clamp(minHeight, maxHeight);

          return SizedBox(
            height: currentHeight,
            child: Container(
              key: boxKey,
              color: AppColors.background,
              child: builder(context, shrinkOffset, progress),
            ),
          );
        },
      );
    }

    final scrollOffset = (scrollController?.hasClients ?? false)
        ? scrollController!.offset
        : 0.0;
    final progress = (scrollOffset / 85.0).clamp(0.0, 1.0);
    final currentHeight = (maxHeight - shrinkOffset).clamp(minHeight, maxHeight);

    return SizedBox(
      height: currentHeight,
      child: Container(
        key: boxKey,
        color: AppColors.background,
        child: builder(context, shrinkOffset, progress),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ConcentricCardHeaderDelegate oldDelegate) {
    return true;
  }
}

/// Keep-alive wrapper for PageView children to ensure no rebuild / lag during page transitions
class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}


