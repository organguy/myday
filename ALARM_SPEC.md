# MyDay 알람 기능 Plan Spec

> 작성일: 2026-03-01
> 인터뷰 기반 요구사항 정의서

---

## 1. 기능 개요

디데이(D-Day) 항목에 "D-Day X일 전 오전 Y시" 형식의 알람을 여러 개 등록할 수 있는 기능.
앱이 완전히 종료된 상태(killed)에서도 알람이 발화되어야 한다.

---

## 2. 요구사항 정의

### 2-1. 알람 발화 조건
- **앱 killed 상태에서도 발화** 필수
- Android: `flutter_local_notifications` + `SCHEDULE_EXACT_ALARM` 권한 사용
- iOS: `UNUserNotificationCenter` 기반 로컬 알림 (백그라운드 발화 지원)

### 2-2. 알람 시간 지정 방식
- **D-Day 상대 시간** 방식
  - 형식: `N일 전, HH:mm` (예: "7일 전, 오전 09:00")
  - N = 0 이면 D-Day 당일 알람
  - D-Day 날짜가 수정되면 알람 발화 시각 자동 재계산
  - D+ 상태(이미 지난 날짜)의 알람은 로컬 등록 생략 (조용한 비활성화)

### 2-3. 알람 개수
- 하나의 D-Day에 **제한 없이 여러 개** 등록 가능
- UI: 리스트 형태로 알람 추가/삭제

### 2-4. Android 권한 처리
- `SCHEDULE_EXACT_ALARM` 권한 거부 시:
  - 왜 필요한지 설명하는 다이얼로그 표시
  - "설정으로 이동" 버튼으로 시스템 설정 화면 안내
  - 거부 유지 시 알람 등록 불가 상태로 처리 (기능 비활성화)

### 2-5. 당일(D-Day 0) 알람
- "0일 전 HH:mm" 형식으로 다른 알람과 동일하게 처리
- 별도 특별 취급 없음

---

## 3. UI/UX 설계

### 3-1. 알람 설정 진입점
- `AddEditScreen` 내 기존 섹션(제목/날짜/이모지/색상) 하단에 **알람 섹션 추가**
- 섹션 레이블: "알람"

### 3-2. 알람 섹션 UI 구조
```
┌─────────────────────────────────────┐
│ 알람                                 │
│ ┌─────────────────────────────────┐ │
│ │ 🔔  7일 전  ·  오전 09:00   [×] │ │
│ │ 🔔  1일 전  ·  오전 08:00   [×] │ │
│ │ 🔔  당일    ·  오전 07:00   [×] │ │
│ └─────────────────────────────────┘ │
│ [+ 알람 추가]                        │
└─────────────────────────────────────┘
```

### 3-3. 알람 추가 플로우
1. "+ 알람 추가" 탭
2. 바텀시트 또는 인라인 입력 UI 표시
   - **N일 전** 숫자 입력 (0 이상 정수)
   - **시각** 선택 (TimePicker)
3. 확인 시 리스트에 추가

### 3-4. 홈 카드 알람 배지
- 알람이 1개 이상 설정된 D-Day 카드에 **🔔 아이콘** 표시
- 위치: 카드 우측 하단 또는 이모지 박스 우상단 오버레이
- 알람이 없으면 표시 안 함

### 3-5. 알림창(Notification) 내용
- 제목: `{이모지} {D-Day 제목}`
  예: `🎂 생일파티`
- 본문: `D-{N} · {N}일 남았어요`
  예: `D-7 · 7일 남았어요`
- 당일: `D-Day · 오늘이에요!`

### 3-6. 알림 탭 동작
- 알림 탭 시 앱 실행 → **홈 화면** 이동
- 딥링크(특정 화면 이동) 없음

### 3-7. 스누즈
- **미지원** (확인/닫기만)

### 3-8. 알람음/진동
- **시스템 기본 알림음 + 진동** 사용
- 커스터마이징 없음

---

## 4. 데이터 모델

### 4-1. AlarmItem 모델
```dart
class AlarmItem {
  final String id;         // uuid
  final int daysBeforeTarget; // D-Day 기준 N일 전 (0 = 당일)
  final int hour;          // 시 (0~23)
  final int minute;        // 분 (0~59)
  final bool isActive;     // 과거 시점이면 false
}
```

### 4-2. DDay 모델 확장
```dart
class DDay {
  // 기존 필드 유지
  ...
  final List<AlarmItem> alarms; // 알람 리스트 추가
}
```

### 4-3. Firestore 저장 구조
```
users/default_user/ddays/{ddayId}
  └── alarms: [
        {
          id: "uuid",
          daysBeforeTarget: 7,
          hour: 9,
          minute: 0,
          isActive: true
        },
        ...
      ]
```

---

## 5. 기술 구현 계획

### 5-1. 사용 패키지
| 패키지 | 용도 |
|--------|------|
| `flutter_local_notifications` | 로컬 알람 스케줄링 (iOS/Android) |
| `timezone` | 시간대 처리 (TZDateTime 변환) |
| `permission_handler` | Android SCHEDULE_EXACT_ALARM 권한 요청 |

### 5-2. 알람 스케줄링 로직

```
알람 발화 시각 계산:
  targetDate - daysBeforeTarget일 = 알람 날짜
  알람 날짜 + hour:minute = 최종 발화 DateTime

  if (발화 DateTime <= 현재) → 로컬 등록 생략 (isActive: false)
  else → flutter_local_notifications.zonedSchedule() 등록
```

### 5-3. 앱 시작 시 알람 재등록
- `main()` 또는 홈 화면 `initState()`에서 실행
- Firestore에서 전체 DDay 목록 조회
- 각 DDay의 alarms 순회 → 로컬 알람 전체 재등록
- 기기 재설치/교체 시 자동 복구

### 5-4. D-Day 수정/삭제 시 처리
| 이벤트 | 처리 |
|--------|------|
| D-Day 날짜 수정 | 기존 로컬 알람 전체 취소 → 새 시각으로 재등록 |
| D-Day 삭제 | 연결된 모든 로컬 알람 취소 |
| 알람 개별 삭제 | 해당 알람 ID로 로컬 알람 취소 |

### 5-5. 알람 ID 전략
- 로컬 알람 ID: `ddayId + alarmItemId` 조합으로 고유 int 생성
  - 예: `uuid.hashCode ^ alarmItem.id.hashCode`

---

## 6. 엣지케이스 처리

| 케이스 | 처리 방법 |
|--------|-----------|
| 과거 시점 알람 | Firestore 저장은 하되 로컬 등록 생략 |
| Android SCHEDULE_EXACT_ALARM 권한 거부 | 설정 화면 안내 다이얼로그 → 등록 불가 처리 |
| D-Day 날짜 변경으로 알람이 과거가 됨 | 재계산 시 과거 알람은 자동 비활성화 |
| 앱 재설치 후 로컬 알람 소실 | 앱 시작 시 Firestore 기반 자동 재등록 |
| 알람 시각 중복 | 허용 (사용자가 직접 관리) |

---

## 7. 구현 파일 계획

```
lib/
  models/
    dday.dart              # AlarmItem 모델 추가, DDay.alarms 필드 추가
  services/
    firestore_service.dart # alarms 필드 직렬화/역직렬화 추가
    alarm_service.dart     # 신규: 로컬 알람 등록/취소/재등록 로직
  screens/
    add_edit_screen.dart   # 알람 섹션 UI 추가
  widgets/
    dday_card.dart         # 🔔 배지 표시 추가
    alarm_list_tile.dart   # 신규: 알람 항목 위젯
  main.dart                # 앱 시작 시 알람 재등록 호출
```

---

## 8. 구현 순서 (권장)

1. `AlarmItem` 모델 정의 + `DDay` 모델 확장
2. `FirestoreService` alarms 직렬화/역직렬화
3. `AlarmService` 구현 (등록/취소/재등록)
4. `AddEditScreen` 알람 섹션 UI
5. `AlarmListTile` 위젯
6. `DDayCard` 배지 표시
7. `main.dart` 앱 시작 시 재등록 연결
8. Android 권한 처리
9. 엣지케이스 테스트

---

## 9. 미결 사항 (향후 검토)

- iOS 알람 권한 요청 타이밍 (첫 알람 추가 시 vs 앱 최초 실행 시)
- 알람 개수가 매우 많아질 경우 성능 최적화 방안
- 향후 반복 알람(매년 기념일 등) 지원 여부
