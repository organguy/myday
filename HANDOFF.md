# HANDOFF.md — MyDay 프로젝트 인수인계

> 작성일: 2026-03-01
> 다음 에이전트가 이 파일만 읽고 즉시 이어갈 수 있도록 작성

---

## 1. 프로젝트 기본 정보

| 항목 | 내용 |
|------|------|
| 앱 이름 | MyDay |
| 설명 | Flutter + Firestore 기반 D-Day 카운트다운 앱 |
| 경로 | `/Users/organguy/Unidev_Projects/StudyProject/ MyDay/myday/` |
| Flutter 버전 | 3.35.1 / Dart 3.9.0 |
| Firebase 프로젝트 | `myday-study-dev` (서울, asia-northeast3) |
| Bundle ID | `com.myday.myday` |

---

## 2. 완료된 작업 (성공)

### 2-1. 앱 기본 구조 구축
- Flutter 프로젝트 생성 (`myday`)
- Firebase 연동 (firebase_options.dart 수동 작성 — flutterfire CLI 미사용)
- Firestore CRUD 구현 (`users/default_user/ddays/{uuid}` 경로)
- 인증 없는 단일 유저 구조

### 2-2. 구현된 파일 목록
```
lib/
  main.dart                    # Firebase 초기화, 한국어 로케일 고정
  firebase_options.dart        # 수동 작성 (iOS/Android App ID 포함)
  models/dday.dart             # DDay 모델 (ddayLabel, isToday, dayDiff 등 getter)
  services/firestore_service.dart  # getDDays(stream), addDDay, updateDDay, deleteDDay
  screens/home_screen.dart     # 홈(목록) 화면, StreamBuilder 패턴
  screens/add_edit_screen.dart # 추가/수정 화면
  widgets/dday_card.dart       # 디데이 카드 위젯 (_EmojiBox, _DDayBadge)
  theme/app_theme.dart         # 색상 팔레트, bgDecoration, cardShadow
```

### 2-3. UI 디자인
- 보라 그라데이션 배경 (`0xFF4C1D95` → `0xFF7C3AED`)
- 연보라 카드 (`AppTheme.cardBg = 0xFFF5F0FF`)
- 이모지 박스 + D-Day 뱃지 (당일: 그라데이션, 나머지: 연한 포인트색)
- 투명 AppBar + 흰색 텍스트
- FAB: 흰색 배경 + 보라 텍스트

### 2-4. 기술적 수정 이력
- `.withOpacity()` → `.withValues(alpha:)` 전체 교체 (Flutter 3.35+ deprecated)
- `widget_test.dart` placeholder로 교체 (MyApp 클래스 없음)
- `app_theme.dart` 리팩토링: 미사용 필드 제거, `bgDark` → `_bgDark` private화

### 2-5. Firebase 설정
- Firestore 보안 규칙: `users/default_user/ddays/{ddayId}` 공개 read/write
- `firestore.rules`, `firebase.json` 배포 완료
- Android: Kotlin DSL (`build.gradle.kts`), google-services.json 수동 작성
- iOS: GoogleService-Info.plist 수동 작성

### 2-6. 알람 기능 Plan Spec 작성
- 사용자 인터뷰 14문항 완료
- `ALARM_SPEC.md` 파일 생성 완료

---

## 3. 실패 / 문제 이력

| 문제 | 원인 | 해결 |
|------|------|------|
| Firebase 프로젝트 ID 충돌 | `myday-dev` 이미 존재 | `myday-study-dev`로 신규 생성 |
| flutterfire configure 실패 | CLI 캐시 목록에 신규 프로젝트 미포함 | `firebase apps:create`로 수동 등록 후 `firebase_options.dart` 직접 작성 |
| Firestore API 미활성화 | 프로젝트 생성 직후 API 비활성 상태 | `gcloud services enable firestore.googleapis.com` |
| `.withOpacity()` 경고 | Flutter 3.35+ deprecated | `.withValues(alpha:)` 전체 교체 |

---

## 4. 다음 단계 — 알람 기능 구현

> 상세 스펙: `ALARM_SPEC.md` 참고

### 4-1. 구현 순서

**Step 1. 패키지 추가** (`pubspec.yaml`)
```yaml
flutter_local_notifications: ^17.x
timezone: ^0.9.x
permission_handler: ^11.x
```

**Step 2. 모델 수정** (`lib/models/dday.dart`)
- `AlarmItem` 클래스 신규 추가
  ```dart
  class AlarmItem {
    final String id;              // uuid
    final int daysBeforeTarget;   // D-Day 기준 N일 전 (0 = 당일)
    final int hour;               // 0~23
    final int minute;             // 0~59
    final bool isActive;          // 과거 시점이면 false
  }
  ```
- `DDay` 클래스에 `final List<AlarmItem> alarms` 필드 추가
- `toMap()` / `fromMap()` 직렬화 수정

**Step 3. Firestore 수정** (`lib/services/firestore_service.dart`)
- `alarms` 필드 직렬화/역직렬화 추가

**Step 4. AlarmService 신규 생성** (`lib/services/alarm_service.dart`)
- `flutter_local_notifications` 초기화
- `scheduleAlarm(DDay, AlarmItem)` — 로컬 알람 등록
- `cancelAlarm(alarmId)` — 개별 알람 취소
- `cancelAllAlarmsForDDay(ddayId)` — D-Day 삭제 시 전체 취소
- `rescheduleAllAlarms(List<DDay>)` — 앱 시작 시 전체 재등록
- 알람 ID 전략: `ddayId.hashCode ^ alarmItem.id.hashCode`

**Step 5. AddEditScreen 수정** (`lib/screens/add_edit_screen.dart`)
- 알람 섹션 UI 추가 (섹션 레이블: "알람")
- 알람 리스트 표시 (N일 전 · HH:mm · 삭제 버튼)
- "+ 알람 추가" 버튼 → 바텀시트 (일수 입력 + TimePicker)
- D-Day 저장 시 알람 스케줄링 연동

**Step 6. DDayCard 수정** (`lib/widgets/dday_card.dart`)
- `dday.alarms.isNotEmpty`이면 🔔 아이콘 배지 표시

**Step 7. 신규 위젯** (`lib/widgets/alarm_list_tile.dart`)
- 알람 항목 1개를 표시하는 위젯
- `🔔 N일 전 · 오전 HH:mm [×]` 형태

**Step 8. main.dart 수정**
- 앱 시작 시 `AlarmService.rescheduleAllAlarms()` 호출
- 타임존 초기화: `tz.initializeTimeZones()`

**Step 9. Android 권한 처리**
- `AndroidManifest.xml`에 `SCHEDULE_EXACT_ALARM` 권한 추가
- 알람 추가 시 권한 체크 → 거부 시 설정 안내 다이얼로그

---

## 5. 핵심 결정 사항 (인터뷰 결과)

| 항목 | 결정 |
|------|------|
| 발화 조건 | Killed 상태에서도 발화 필수 |
| 시간 지정 | D-Day 기준 상대 시간 (N일 전 HH:mm) |
| 알람 개수 | 제한 없이 여러 개 |
| Android 권한 거부 | 설정 화면 안내 다이얼로그 |
| 당일 알람 | "0일 전"으로 동일 처리 |
| UI 위치 | AddEditScreen 내 섹션 추가 |
| 알림 내용 | 이모지 + 제목 + 남은 일수 |
| 스누즈 | 미지원 |
| 카드 배지 | 🔔 아이콘 표시 |
| 데이터 저장 | Firestore + 앱 시작 시 로컬 재등록 |
| 수정/삭제 연동 | 자동 처리 |
| 과거 알람 | 조용히 비활성화 (로컬 등록 생략) |
| 알람음 | 시스템 기본값 |
| 알림 탭 동작 | 홈 화면 이동 |

---

## 6. 주의사항

- **`.withOpacity()` 사용 금지** — 반드시 `.withValues(alpha:)` 사용
- **모든 주석/dartdoc은 한국어**로 작성 (CLAUDE.md 지침)
- `firebase_options.dart`는 수동 작성됨 — `flutterfire configure` 재실행 주의
- Firestore 경로: `users/default_user/ddays/{uuid}` (인증 없는 단일 유저)
- Android는 Kotlin DSL (`build.gradle.kts`) 사용
- 한국어 로케일 고정: `Locale('ko', 'KR')`

---

## 7. 참고 파일

| 파일 | 내용 |
|------|------|
| `ALARM_SPEC.md` | 알람 기능 상세 스펙 (데이터 모델, UI 구조, 엣지케이스) |
| `CLAUDE.md` | 프로젝트 개요, 자주 쓰는 명령어, 코딩 지침 |
| `firestore.rules` | Firestore 보안 규칙 |
