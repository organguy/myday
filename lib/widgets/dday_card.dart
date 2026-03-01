import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/dday.dart';
import '../theme/app_theme.dart';

/// 디데이 목록에서 각 항목을 표시하는 카드 위젯
class DDayCard extends StatelessWidget {
  final DDay dday;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DDayCard({
    super.key,
    required this.dday,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    /// 카드 포인트 색상 (사용자 지정)
    final color = Color(dday.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            /// 이모지 아이콘 컨테이너 (둥근 보라 박스)
            _EmojiBox(emoji: dday.emoji, color: color),
            const SizedBox(width: 14),

            /// 제목 + 날짜
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dday.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('yyyy년 MM월 dd일').format(dday.targetDate),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSub,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            /// D-Day 뱃지
            _DDayBadge(dday: dday, color: color),
            const SizedBox(width: 4),

            /// 수정/삭제 팝업 메뉴
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert,
                  color: AppTheme.textSub.withValues(alpha: 0.6), size: 20),
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 18, color: AppTheme.textDark),
                      SizedBox(width: 8),
                      Text('수정',
                          style: TextStyle(color: AppTheme.textDark)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('삭제', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 이모지를 담는 보라 배경 둥근 박스
class _EmojiBox extends StatelessWidget {
  final String emoji;
  final Color color;

  const _EmojiBox({required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 26)),
    );
  }
}

/// D-Day / D+ / D- 텍스트 뱃지
class _DDayBadge extends StatelessWidget {
  final DDay dday;
  final Color color;

  const _DDayBadge({required this.dday, required this.color});

  @override
  Widget build(BuildContext context) {
    /// 오늘: 흰 텍스트 + 보라 채움 / 나머지: 보라 텍스트 + 연보라 채움
    final isToday = dday.isToday;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
        dday.ddayLabel,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: isToday ? Colors.white : color,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
