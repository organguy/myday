import 'package:flutter/material.dart';

/// 앱 전체 색상 팔레트 및 공통 스타일 정의
class AppTheme {
  AppTheme._();

  // ── 내부 전용 ──────────────────────────────────────
  /// 그라데이션 시작색 / 카드 그림자색으로 사용
  static const Color _bgDark = Color(0xFF4C1D95);

  // ── 배경 ──────────────────────────────────────────
  /// 화면 배경 그라데이션 BoxDecoration
  static const BoxDecoration bgDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_bgDark, primary],
    ),
  );

  // ── 포인트 ────────────────────────────────────────
  /// 메인 보라색
  static const Color primary = Color(0xFF7C3AED);

  /// 강조용 연보라·핑크
  static const Color accent = Color(0xFFC084FC);

  // ── 카드 ──────────────────────────────────────────
  /// 카드 배경 (연보라)
  static const Color cardBg = Color(0xFFF5F0FF);

  /// 카드 위 입력 필드 배경 (cardBg보다 약간 진함)
  static const Color inputBg = Color(0xFFEDE9FE);

  // ── 텍스트 ────────────────────────────────────────
  /// 카드 위 메인 텍스트
  static const Color textDark = Color(0xFF2D1B69);

  /// 카드 위 보조 텍스트 (날짜, 힌트 등)
  static const Color textSub = Color(0xFF8B5CF6);

  // ── 카드 그림자 ───────────────────────────────────
  /// 공통 카드 그림자 (호출마다 새 리스트 생성 — withValues가 const 불가)
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: _bgDark.withValues(alpha: 0.25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}
