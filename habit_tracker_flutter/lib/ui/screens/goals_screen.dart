import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/goal.dart';
import '../viewmodels/habit_viewmodel.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  void _showAddEditGoalModal(BuildContext context, {Goal? existingGoal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GoalFormModal(goal: existingGoal),
    );
  }

  void _showBackupDialog(BuildContext context, HabitViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.backup_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Sao Lưu Dữ Liệu Offline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ứng dụng lưu trữ 100% offline trên thiết bị của bạn. Bạn có thể sao lưu dữ liệu dưới dạng chuỗi JSON để chuyển sang máy khác bất cứ lúc nào.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Sao chép dữ liệu sao lưu (JSON)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  final json = await vm.exportBackup();
                  await Clipboard.setData(ClipboardData(text: json));
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã sao chép mã sao lưu vào bộ nhớ tạm!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Khôi phục từ JSON'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showImportDialog(context, vm);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, HabitViewModel vm) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Khôi Phục Dữ Liệu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dán chuỗi JSON đã sao lưu vào ô dưới đây để phục hồi toàn bộ thói quen và lịch sử:',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '{"version": 1, "goals": ...}',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;

              try {
                await vm.importBackup(text);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Khôi phục dữ liệu thành công!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dữ liệu sao lưu không hợp lệ!'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Khôi phục'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, HabitViewModel vm, Goal goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xoá thói quen?'),
        content: Text('Bạn có chắc chắn muốn xoá mục tiêu "${goal.title}" cùng toàn bộ lịch sử thực hiện?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              vm.deleteGoal(goal.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Xoá vĩnh viễn'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HabitViewModel>(context);
    final goals = vm.goals;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Quản Lý Thói Quen',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textMain,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.backup_outlined, color: AppColors.primary),
            tooltip: 'Sao lưu & Khôi phục',
            onPressed: () => _showBackupDialog(context, vm),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: goals.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.track_changes_rounded, size: 64, color: AppColors.textLight),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có thói quen nào',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMain),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tạo thói quen đầu tiên để bắt đầu hành trình xây dựng kỷ luật bản thân.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _showAddEditGoalModal(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm thói quen mới'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final streak = vm.getStreakForGoal(goal.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.getCategoryBg(goal.category),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              goal.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.getCategoryColor(goal.category),
                              ),
                            ),
                          ),
                          if (streak > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '🔥 $streak ngày',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFEA580C),
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textMuted),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () => _showAddEditGoalModal(context, existingGoal: goal),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () => _confirmDelete(context, vm, goal),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                      ),
                      if (goal.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          goal.description,
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.repeat, size: 14, color: AppColors.textLight),
                          const SizedBox(width: 4),
                          Text(
                            goal.targetFrequency == 'all'
                                ? 'Hàng ngày'
                                : 'Tuỳ chọn (${goal.weekdays.length} ngày/tuần)',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          if (goal.targetCount > 1) ...[
                            const SizedBox(width: 14),
                            const Icon(Icons.flag_outlined, size: 14, color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Text(
                              '${goal.targetCount} ${goal.unit}/ngày',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditGoalModal(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm thói quen', style: TextStyle(fontWeight: FontWeight.w700)),
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
  late String _targetFrequency;
  late List<int> _weekdays;

  final List<Map<String, String>> _categories = [
    {'id': 'health', 'name': 'Sức khỏe'},
    {'id': 'study', 'name': 'Học tập'},
    {'id': 'work', 'name': 'Công việc'},
    {'id': 'mind', 'name': 'Tâm trí'},
    {'id': 'finance', 'name': 'Tài chính'},
  ];

  final List<String> _colors = [
    '#2D6A4F',
    '#10B981',
    '#3B82F6',
    '#8B5CF6',
    '#F59E0B',
    '#EF4444',
    '#EC4899',
    '#0D9488',
  ];

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    _titleController = TextEditingController(text: g?.title ?? '');
    _descController = TextEditingController(text: g?.description ?? '');
    _targetCountController = TextEditingController(text: '${g?.targetCount ?? 1}');
    _unitController = TextEditingController(text: g?.unit ?? 'lần');

    _category = g?.category ?? 'health';
    _color = g?.color ?? '#2D6A4F';
    _targetFrequency = g?.targetFrequency ?? 'all';
    _weekdays = g?.weekdays ?? [0, 1, 2, 3, 4, 5, 6];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _targetCountController.dispose();
    _unitController.dispose();
    super.dispose();
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
        targetFrequency: _targetFrequency,
        weekdays: _weekdays,
        targetCount: count,
        unit: _unitController.text.trim().isEmpty ? 'lần' : _unitController.text.trim(),
      );
      vm.updateGoal(updatedGoal);
    }

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

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.goal == null ? 'Thêm Thói Quen Mới' : 'Chỉnh Sửa Thói Quen',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textMain),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 8),
                  // Title Field
                  const Text('Tên thói quen *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleController,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên thói quen' : null,
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: Đọc sách 20 phút, Uống nước...',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Description Field
                  const Text('Mô tả (tuỳ chọn)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Lý do duy trì thói quen hoặc ghi chú...',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Category Selector
                  const Text('Danh mục', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((c) {
                      final isSelected = _category == c['id'];
                      return ChoiceChip(
                        label: Text(c['name']!),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textMain,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        onSelected: (_) => setState(() => _category = c['id']!),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  // Color Swatches
                  const Text('Màu sắc nhận diện', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: _colors.map((hex) {
                      final isSelected = _color == hex;
                      final colorVal = Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
                      return InkWell(
                        onTap: () => setState(() => _color = hex),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colorVal,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: AppColors.textMain, width: 3)
                                : Border.all(color: Colors.white, width: 2),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Target Frequency
                  const Text('Tần suất lặp lại', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'all',
                        label: Text('Mỗi ngày'),
                        icon: Icon(Icons.calendar_today, size: 16),
                      ),
                      ButtonSegment(
                        value: 'custom',
                        label: Text('Tuỳ chọn các ngày'),
                        icon: Icon(Icons.date_range, size: 16),
                      ),
                    ],
                    selected: {_targetFrequency},
                    onSelectionChanged: (newSelection) {
                      setState(() => _targetFrequency = newSelection.first);
                    },
                  ),
                  if (_targetFrequency == 'custom') ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: weekdayLabels.map((w) {
                        final val = w['val'] as int;
                        final isSelected = _weekdays.contains(val);
                        return FilterChip(
                          label: Text(w['label'] as String),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textMain,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _weekdays.add(val);
                              } else {
                                if (_weekdays.length > 1) {
                                  _weekdays.remove(val);
                                }
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Target Count & Unit
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Mục tiêu/ngày', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _targetCountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '1',
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                            const Text('Đơn vị tính', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _unitController,
                              decoration: InputDecoration(
                                hintText: 'lần, phút, ly nước...',
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _save(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  widget.goal == null ? 'Tạo Thói Quen' : 'Lưu Thay Đổi',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
