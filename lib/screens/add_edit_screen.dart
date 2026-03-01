import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/dday.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class AddEditScreen extends StatefulWidget {
  final DDay? dday;

  const AddEditScreen({super.key, this.dday});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _service = FirestoreService();
  final _uuid = const Uuid();

  late DateTime _selectedDate;
  late String _selectedEmoji;
  late int _selectedColorValue;
  bool _isSaving = false;

  static const _emojis = [
    '📅', '🎂', '💍', '🎓', '✈️', '🏖️', '💼', '🎯',
    '❤️', '🌸', '🎉', '⭐', '🏃', '🎵', '📚', '🌍',
  ];

  /// 보라 계열 중심의 컬러 팔레트
  static const _colors = [
    0xFF7C3AED, // 메인 보라
    0xFFA855F7, // 연보라
    0xFFEC4899, // 핑크
    0xFFEF4444, // 레드
    0xFF3B82F6, // 블루
    0xFF06B6D4, // 시안
    0xFF10B981, // 그린
    0xFFF59E0B, // 옐로우
  ];

  bool get _isEditing => widget.dday != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final d = widget.dday!;
      _titleController.text = d.title;
      _selectedDate = d.targetDate;
      _selectedEmoji = d.emoji;
      _selectedColorValue = d.colorValue;
    } else {
      _selectedDate = DateTime.now().add(const Duration(days: 30));
      _selectedEmoji = '📅';
      _selectedColorValue = _colors[0];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Container(
        decoration: AppTheme.bgDecoration,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('제목', _buildTitleField()),
                  const SizedBox(height: 16),
                  _buildSection('날짜', _buildDatePicker()),
                  const SizedBox(height: 16),
                  _buildSection('이모지', _buildEmojiPicker()),
                  const SizedBox(height: 16),
                  _buildSection('색상', _buildColorPicker()),
                  const SizedBox(height: 24),
                  _buildPreviewCard(),
                  const SizedBox(height: 24),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 투명 배경 앱바 (뒤로가기 + 제목)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        _isEditing ? '디데이 수정' : '디데이 추가',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// 섹션 레이블 + 콘텐츠
  Widget _buildSection(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  /// 제목 입력 필드
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      style: const TextStyle(color: AppTheme.textDark, fontSize: 15),
      decoration: _inputDecoration('예: 수능 시험일, 여행 출발일'),
      maxLength: 30,
      onChanged: (_) => setState(() {}),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? '제목을 입력해주세요' : null,
    );
  }

  /// 날짜 선택 버튼
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_today_outlined,
                  size: 18, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('yyyy년 MM월 dd일 (E)', 'ko').format(_selectedDate),
              style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppTheme.textSub),
          ],
        ),
      ),
    );
  }

  /// 이모지 선택 그리드
  Widget _buildEmojiPicker() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _emojis.map((e) {
          final selected = e == _selectedEmoji;
          return GestureDetector(
            onTap: () => setState(() => _selectedEmoji = e),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? Color(_selectedColorValue).withValues(alpha: 0.18)
                    : AppTheme.inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? Color(_selectedColorValue)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(e, style: const TextStyle(fontSize: 22)),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 색상 선택 원형 팔레트
  Widget _buildColorPicker() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _colors.map((c) {
          final selected = c == _selectedColorValue;
          return GestureDetector(
            onTap: () => setState(() => _selectedColorValue = c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Color(c),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: Color(c).withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 실시간 미리보기 카드
  Widget _buildPreviewCard() {
    final color = Color(_selectedColorValue);
    final title = _titleController.text.trim().isEmpty
        ? '제목 미리보기'
        : _titleController.text.trim();

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final target =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final diff = target.difference(todayDate).inDays;
    final label = diff == 0
        ? 'D-Day'
        : diff > 0
            ? 'D-$diff'
            : 'D+${diff.abs()}';
    final isToday = diff == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '미리보기',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            children: [
              /// 이모지 박스
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child:
                    Text(_selectedEmoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSub),
                    ),
                  ],
                ),
              ),
              /// D-Day 뱃지
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isToday
                      ? LinearGradient(
                          colors: [color, AppTheme.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isToday ? null : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isToday ? Colors.white : color,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 날짜 피커 실행
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko', 'KR'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: Color(_selectedColorValue),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  /// 저장 버튼
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primary,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: AppTheme.primary),
              )
            : Text(
                _isEditing ? '수정 완료' : '추가하기',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800),
              ),
      ),
    );
  }

  /// Firestore 저장 처리
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final dday = DDay(
        id: _isEditing ? widget.dday!.id : _uuid.v4(),
        title: _titleController.text.trim(),
        targetDate: _selectedDate,
        emoji: _selectedEmoji,
        colorValue: _selectedColorValue,
        createdAt: _isEditing ? widget.dday!.createdAt : DateTime.now(),
      );

      if (_isEditing) {
        await _service.updateDDay(dday);
      } else {
        await _service.addDDay(dday);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(color: AppTheme.textSub.withValues(alpha: 0.6), fontSize: 14),
      filled: true,
      fillColor: AppTheme.cardBg,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            BorderSide(color: Color(_selectedColorValue), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            BorderSide(color: Colors.red.shade300, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
      counterStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
    );
  }
}
