import 'package:flutter/material.dart';
import '../models/dday.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/dday_card.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      /// 배경은 그라데이션 Container로 처리하므로 투명 설정
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Container(
        decoration: AppTheme.bgDecoration,
        child: SafeArea(
          child: StreamBuilder<List<DDay>>(
            stream: service.getDDays(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.white70),
                      const SizedBox(height: 12),
                      Text(
                        '오류가 발생했어요\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                );
              }

              final ddays = snapshot.data ?? [];

              if (ddays.isEmpty) {
                return const _EmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                itemCount: ddays.length,
                itemBuilder: (context, index) {
                  final dday = ddays[index];
                  return DDayCard(
                    dday: dday,
                    onEdit: () => _openEdit(context, dday),
                    onDelete: () => _confirmDelete(context, service, dday),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  /// 투명 배경의 흰색 텍스트 앱바
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'MyDay',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 26,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_outline,
              color: Colors.white, size: 20),
        ),
      ],
    );
  }

  /// 둥근 보라 FAB
  Widget _buildFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _openAdd(context),
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        '디데이 추가',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.primary,
      elevation: 8,
      extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  void _openAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditScreen()),
    );
  }

  void _openEdit(BuildContext context, DDay dday) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditScreen(dday: dday)),
    );
  }

  void _confirmDelete(
      BuildContext context, FirestoreService service, DDay dday) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text('디데이 삭제',
            style: TextStyle(color: AppTheme.textDark)),
        content: Text('"${dday.title}"을(를) 삭제할까요?',
            style: const TextStyle(color: AppTheme.textSub)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소',
                style: TextStyle(color: AppTheme.textSub)),
          ),
          TextButton(
            onPressed: () {
              service.deleteDDay(dday.id);
              Navigator.pop(ctx);
            },
            style:
                TextButton.styleFrom(foregroundColor: Colors.red.shade400),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

/// 디데이가 없을 때 표시하는 빈 상태 위젯
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📅', style: TextStyle(fontSize: 46)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '디데이가 없어요',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '아래 버튼을 눌러 디데이를 추가해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
