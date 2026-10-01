import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/services/vibration_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/habit_icons.dart';
import '../../data/models/goal.dart';
import '../viewmodels/habit_viewmodel.dart';
import '../widgets/animations/animated_delete_wrapper.dart';
import '../widgets/animations/staggered_list_item.dart';
import '../widgets/habit_card.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  String? _deletingGoalId;

  void _showAddEditGoalModal(BuildContext context, {Goal? existingGoal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GoalFormModal(goal: existingGoal),
    );
  }

  void _confirmDelete(BuildContext context, HabitViewModel vm, Goal goal) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 2.2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(4.5, 4.5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1.8),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Xoá thói quen?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Bạn có chắc chắn muốn xoá "${goal.title}" cùng toàn bộ lịch sử thực hiện không? Thao tác này không thể hoàn tác.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text(
                      'Huỷ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _deletingGoalId = goal.id;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black, width: 2.0),
                      ),
                    ),
                    child: const Text(
                      'Xoá vĩnh viễn',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseGoalColor(String hexString, String category) {
    try {
      final hex = hexString.replaceAll('#', '');
      if (hex.isEmpty) return AppColors.getCategoryColor(category);
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.getCategoryColor(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HabitViewModel>(context);
    final goals = vm.goals;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Habits',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textMain,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: goals.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 2.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(4.0, 4.0),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2.2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black, offset: Offset(3.0, 3.0), blurRadius: 0),
                          ],
                        ),
                        child: const Icon(Icons.star_rounded, size: 40, color: Colors.black),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Chưa có thói quen nào',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tạo thói quen đầu tiên để bắt đầu hành trình xây dựng kỷ luật bản thân.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 22),
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditGoalModal(context),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text(
                          'Thêm thói quen mới',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: Colors.black, width: 2.2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 180),
              physics: const BouncingScrollPhysics(),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final streak = vm.getStreakForGoal(goal.id);
                final goalColor = _parseGoalColor(goal.color, goal.category);
                final parentCat = HabitCard.getParentCategory(goal);
                final habitIcon = HabitIcons.getIcon(goal.icon, title: goal.title, category: goal.category);

                return AnimatedDeleteWrapper(
                  key: ValueKey(goal.id),
                  isDeleting: _deletingGoalId == goal.id,
                  onDeleted: () {
                    vm.deleteGoal(goal.id);
                    if (mounted) {
                      setState(() {
                        _deletingGoalId = null;
                      });
                    }
                  },
                  child: StaggeredListItem(
                    index: index,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.black,
                          width: 2.2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(4.0, 4.0),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            VibrationService.click();
                            _showAddEditGoalModal(context, existingGoal: goal);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Habit Icon Neo-Brutalist Badge
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: goalColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.black, width: 2.0),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(2.5, 2.5),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(habitIcon, color: Colors.black, size: 26),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Habit Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Category Pill
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: goalColor,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.black, width: 1.2),
                                        ),
                                        child: Text(
                                          parentCat,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        goal.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.black,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            if (goal.description.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                goal.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  color: Color(0xFF64748B),
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 10),

                                            // Badges row
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: [
                                                // Frequency Chip
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF1F5F9),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: Colors.black, width: 1.2),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.repeat_rounded, size: 12, color: Colors.black),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        goal.targetFrequency == 'all'
                                                            ? 'Hàng ngày'
                                                            : '${goal.weekdays.length} ngày/tuần',
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w800,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // Target Count Chip
                                                if (goal.targetCount > 1)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFEF3C7),
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(color: Colors.black, width: 1.2),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.flag_rounded, size: 12, color: Colors.black),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${goal.targetCount} ${goal.unit}/ngày',
                                                          style: const TextStyle(
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.w800,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                // Streak Chip
                                                if (streak > 0)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFFEDD5),
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(color: Colors.black, width: 1.2),
                                                    ),
                                                    child: Text(
                                                      '🔥 $streak ngày',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w800,
                                                        color: Color(0xFFEA580C),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // Neo-Brutalist Action Buttons
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              VibrationService.click();
                                              _showAddEditGoalModal(context, existingGoal: goal);
                                            },
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              width: 34,
                                              height: 34,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.black, width: 1.5),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black,
                                                    offset: Offset(2.0, 2.0),
                                                    blurRadius: 0,
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(Icons.edit_outlined, size: 17, color: Colors.black),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          InkWell(
                                            onTap: () {
                                              VibrationService.click();
                                              _confirmDelete(context, vm, goal);
                                            },
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              width: 34,
                                              height: 34,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFEE2E2),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.black, width: 1.5),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black,
                                                    offset: Offset(2.0, 2.0),
                                                    blurRadius: 0,
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 17,
                                                color: Color(0xFFDC2626),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                  },
                ),

      // Circular Floating Action Button comfortably hovering above the Bottom Navigation Bar
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 88, right: 18),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF10B981),
            border: Border.all(color: Colors.black, width: 2.2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(3.5, 3.5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                VibrationService.click();
                _showAddEditGoalModal(context);
              },
              child: const Center(
                child: Icon(Icons.add_rounded, size: 34, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalFormModal extends StatefulWidget {
  final Goal? goal;

  const _GoalFormModal({this.goal});

  @override
  State<_GoalFormModal> createState() => _GoalFormModalState();
}

class _GoalFormModalState extends State<_GoalFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _targetCountController;
  late TextEditingController _unitController;

  late String _category;
  late String _color;
  late String _icon;
  late String _targetFrequency;
  late List<int> _weekdays;

  final List<Map<String, String>> _categories = [
    {'id': 'health', 'name': 'Sức khỏe'},
    {'id': 'sport', 'name': 'Thể thao'},
    {'id': 'study', 'name': 'Học tập'},
    {'id': 'mind', 'name': 'Tâm trí'},
    {'id': 'work', 'name': 'Công việc'},
    {'id': 'finance', 'name': 'Tài chính'},
  ];

  final List<String> _colors = [
    // 1. Đỏ & San hô (Reds & Coral)
    '#EF4444', // Đỏ tươi
    '#DC2626', // Đỏ đậm
    '#B91C1C', // Đỏ mận
    '#F43F5E', // Đỏ hồng
    '#FB7185', // Hồng san hô

    // 2. Cam & Hổ phách (Oranges & Ambers)
    '#EA580C', // Cam sẫm
    '#F97316', // Cam rực rỡ
    '#FB923C', // Cam pastel
    '#F59E0B', // Hổ phách
    '#FBBF24', // Vàng cam ấm

    // 3. Vàng & Chanh (Yellows & Limes)
    '#FACC15', // Vàng tươi
    '#FDE047', // Vàng chanh
    '#FEF08A', // Vàng kem pastel
    '#A3E635', // Xanh chanh tươi
    '#84CC16', // Xanh quả chanh

    // 4. Lục & Ngọc bích (Greens & Emeralds)
    '#4ADE80', // Xanh lá sáng
    '#22C55E', // Xanh cỏ
    '#16A34A', // Xanh lục đậm
    '#10B981', // Xanh ngọc lục bảo
    '#059669', // Xanh ngọc đậm
    '#047857', // Xanh rừng rậm

    // 5. Mòng két & Lục lam (Teals & Cyans)
    '#2DD4BF', // Xanh ngọc biển
    '#14B8A6', // Xanh mòng két
    '#0D9488', // Teal sẫm
    '#06B6D4', // Cyan rực rỡ
    '#0891B2', // Cyan biển sâu

    // 6. Da trời & Xanh dương (Sky & Blues)
    '#38BDF8', // Xanh da trời sáng
    '#0EA5E9', // Xanh da trời
    '#3B82F6', // Xanh dương tươi
    '#2563EB', // Xanh cobalt
    '#1D4ED8', // Xanh navy đậm

    // 7. Chàm, Tím & Hồng cánh sen (Indigos, Violets & Pinks)
    '#6366F1', // Chàm sáng
    '#4F46E5', // Chàm đậm
    '#A78BFA', // Tím oải hương
    '#8B5CF6', // Tím hoa cà
    '#7C3AED', // Tím thạch anh
    '#D946EF', // Hồng cánh sen
    '#EC4899', // Hồng tươi
    '#F472B6', // Hồng phấn

    // 8. Đất, Cà phê & Đen tuyền (Earth & Neutrals)
    '#78350F', // Nâu cà phê
    '#92400E', // Nâu caramel
    '#64748B', // Xám đá phiến
    '#334155', // Xám than chì
    '#18181B', // Đen tuyền Neo-Brutalist
  ];

  List<String> get _allColors {
    if (!_colors.any((c) => c.toLowerCase() == _color.toLowerCase())) {
      return [_color, ..._colors];
    }
    return _colors;
  }

  void _showCustomColorDialog(BuildContext context) {
    final hexController = TextEditingController(text: _color.replaceAll('#', ''));
    Color previewColor = _parseColorHex(_color);

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isLight = previewColor.computeLuminance() > 0.45;
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.black, width: 2.2),
            ),
            title: const Row(
              children: [
                Icon(Icons.palette_rounded, color: Colors.black, size: 22),
                SizedBox(width: 8),
                Text(
                  'Mã màu HEX tuỳ chọn',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: previewColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2.0),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(2.5, 2.5), blurRadius: 0),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '#${hexController.text.toUpperCase()}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: isLight ? Colors.black : Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: hexController,
                  autofocus: true,
                  maxLength: 6,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    prefixText: '# ',
                    prefixStyle: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 16),
                    hintText: 'VD: FF5722',
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black, width: 1.6),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black, width: 2.2),
                    ),
                  ),
                  onChanged: (val) {
                    final clean = val.replaceAll('#', '').trim();
                    if (clean.length == 6) {
                      try {
                        final parsed = Color(int.parse('FF$clean', radix: 16));
                        setDialogState(() {
                          previewColor = parsed;
                        });
                      } catch (_) {}
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Huỷ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  final clean = hexController.text.replaceAll('#', '').trim();
                  if (clean.length == 6) {
                    try {
                      final hex = '#${clean.toUpperCase()}';
                      setState(() {
                        _color = hex;
                      });
                      Navigator.pop(dialogCtx);
                    } catch (_) {}
                  }
                },
                child: const Text('Áp dụng', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    _titleController = TextEditingController(text: g?.title ?? '');
    _descController = TextEditingController(text: g?.description ?? '');
    _targetCountController = TextEditingController(text: '${g?.targetCount ?? 1}');
    _unitController = TextEditingController(text: g?.unit ?? 'lần');

    _category = g?.category ?? 'health';
    _color = g?.color ?? '#10B981';
    _icon = g?.icon ?? HabitIcons.getDefaultIconForCategory(_category);
    _targetFrequency = g?.targetFrequency ?? 'all';
    _weekdays = g?.weekdays != null ? List<int>.from(g!.weekdays) : [0, 1, 2, 3, 4, 5, 6];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _targetCountController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Color _parseColorHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF10B981);
    }
  }

  void _save(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final vm = Provider.of<HabitViewModel>(context, listen: false);
    final count = int.tryParse(_targetCountController.text) ?? 1;

    if (widget.goal == null) {
      final newGoal = Goal(
        id: 'g_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        color: _color,
        icon: _icon,
        targetFrequency: _targetFrequency,
        weekdays: _weekdays,
        targetCount: count,
        unit: _unitController.text.trim().isEmpty ? 'lần' : _unitController.text.trim(),
        createdAt: DateTime.now(),
      );
      vm.addGoal(newGoal);
    } else {
      final updatedGoal = widget.goal!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        color: _color,
        icon: _icon,
        targetFrequency: _targetFrequency,
        weekdays: _weekdays,
        targetCount: count,
        unit: _unitController.text.trim().isEmpty ? 'lần' : _unitController.text.trim(),
      );
      vm.updateGoal(updatedGoal);
    }

    VibrationService.taskComplete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const weekdayLabels = [
      {'val': 1, 'label': 'T2'},
      {'val': 2, 'label': 'T3'},
      {'val': 3, 'label': 'T4'},
      {'val': 4, 'label': 'T5'},
      {'val': 5, 'label': 'T6'},
      {'val': 6, 'label': 'T7'},
      {'val': 0, 'label': 'CN'},
    ];

    final currentColor = _parseColorHex(_color);
    final currentIconData = HabitIcons.getIcon(_icon);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.black, width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, -4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),

            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: currentColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black, width: 2.0),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(2.0, 2.0), blurRadius: 0),
                        ],
                      ),
                      child: Icon(currentIconData, color: Colors.black, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.goal == null ? 'Thêm Thói Quen Mới' : 'Chỉnh Sửa Thói Quen',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.black, thickness: 1.5),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 8),

                  // 1. Title Field
                  const Text('Tên thói quen *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleController,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên thói quen' : null,
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: Đọc sách 20 phút, Uống nước...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black, width: 1.8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black, width: 2.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Description Field
                  const Text('Mô tả (tuỳ chọn)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Lý do duy trì thói quen hoặc ghi chú...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black, width: 1.8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black, width: 2.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Icon Picker (Requirement 5)
                  Row(
                    children: [
                      const Text(
                        'Biểu tượng thói quen',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black, width: 1.2),
                        ),
                        child: Text(
                          HabitIcons.getLabel(_icon),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 118,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: HabitIcons.all.length,
                      itemBuilder: (context, idx) {
                        final item = HabitIcons.all[idx];
                        final isSelected = _icon == item.id;
                        return InkWell(
                          onTap: () {
                            VibrationService.click();
                            setState(() {
                              _icon = item.id;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? currentColor : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.black,
                                width: isSelected ? 2.2 : 1.4,
                              ),
                              boxShadow: isSelected
                                  ? const [
                                      BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 0,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Icon(
                                item.icon,
                                size: 24,
                                color: isSelected ? Colors.black : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Category Selector
                  const Text('Danh mục', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((c) {
                      final isSelected = _category == c['id'];
                      return InkWell(
                        onTap: () {
                          VibrationService.click();
                          setState(() {
                            _category = c['id']!;
                            // Suggest default icon if not customized yet
                            if (_icon.isEmpty || _icon == HabitIcons.getDefaultIconForCategory(_category)) {
                              _icon = HabitIcons.getDefaultIconForCategory(c['id']!);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black, width: 1.5),
                            boxShadow: isSelected
                                ? const [
                                    BoxShadow(color: Colors.black, offset: Offset(2.0, 2.0), blurRadius: 0),
                                  ]
                                : null,
                          ),
                          child: Text(
                            c['name']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 5. Color Swatches
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Màu sắc nhận diện',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: currentColor.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.black, width: 1.2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: currentColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black, width: 1.0),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _color.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Custom Hex picker button
                      InkWell(
                        onTap: () => _showCustomColorDialog(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 1.2),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.colorize_rounded, size: 13, color: Colors.black),
                              SizedBox(width: 4),
                              Text(
                                'Mã HEX',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: _allColors.map((hex) {
                      final isSelected = _color.toLowerCase() == hex.toLowerCase();
                      final colorVal = _parseColorHex(hex);
                      final isLight = colorVal.computeLuminance() > 0.45;
                      return InkWell(
                        onTap: () {
                          VibrationService.click();
                          setState(() => _color = hex);
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colorVal,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black,
                              width: isSelected ? 2.6 : 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isSelected ? 1.0 : 0.25),
                                offset: isSelected ? const Offset(2.5, 2.5) : const Offset(1.0, 1.0),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  color: isLight ? Colors.black : Colors.white,
                                  size: 19,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 6. Target Frequency
                  const Text('Tần suất lặp lại', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            VibrationService.click();
                            setState(() => _targetFrequency = 'all');
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: _targetFrequency == 'all' ? Colors.black : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black, width: 1.8),
                              boxShadow: _targetFrequency == 'all'
                                  ? const [
                                      BoxShadow(color: Colors.black, offset: Offset(2.0, 2.0), blurRadius: 0),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 15,
                                  color: _targetFrequency == 'all' ? Colors.white : Colors.black,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Mỗi ngày',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: _targetFrequency == 'all' ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            VibrationService.click();
                            setState(() => _targetFrequency = 'custom');
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: _targetFrequency == 'custom' ? Colors.black : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black, width: 1.8),
                              boxShadow: _targetFrequency == 'custom'
                                  ? const [
                                      BoxShadow(color: Colors.black, offset: Offset(2.0, 2.0), blurRadius: 0),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.date_range_rounded,
                                  size: 15,
                                  color: _targetFrequency == 'custom' ? Colors.white : Colors.black,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Tuỳ chọn ngày',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: _targetFrequency == 'custom' ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_targetFrequency == 'custom') ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: weekdayLabels.map((w) {
                        final val = w['val'] as int;
                        final isSelected = _weekdays.contains(val);
                        return InkWell(
                          onTap: () {
                            VibrationService.click();
                            setState(() {
                              if (isSelected) {
                                if (_weekdays.length > 1) {
                                  _weekdays.remove(val);
                                }
                              } else {
                                _weekdays.add(val);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 40,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected ? currentColor : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black, width: 1.5),
                              boxShadow: isSelected
                                  ? const [
                                      BoxShadow(color: Colors.black, offset: Offset(1.5, 1.5), blurRadius: 0),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                w['label'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // 7. Target Count & Unit
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Mục tiêu/ngày', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _targetCountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '1',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.black, width: 1.8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.black, width: 2.2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Đơn vị tính', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _unitController,
                              decoration: InputDecoration(
                                hintText: 'lần, phút, ly nước...',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.black, width: 1.8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.black, width: 2.2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _save(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Colors.black, width: 2.2),
                  ),
                ),
                child: Text(
                  widget.goal == null ? 'Tạo Thói Quen' : 'Lưu Thay Đổi',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
