# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# 실행
flutter run                              # 디바이스 선택 후 실행
flutter run -d ce08171863b5cd1b057e     # SM N950N (Android)
flutter run -d 00008110-001A5D9826D0201E # 최인태의 iPhone (iOS)

# 정적 분석 (빌드 전 반드시 확인)
flutter analyze

# 의존성
flutter pub get
flutter pub upgrade --major-versions

# Firebase 보안 규칙 배포
firebase --project myday-study-dev deploy --only firestore:rules
```

## 아키텍처

### 데이터 흐름
`FirestoreService` → `StreamBuilder` (HomeScreen) → `DDayCard` 위젯

상태 관리는 별도 라이브러리 없이 `StreamBuilder`로 Firestore 실시간 스트림을 직접 구독한다. `AddEditScreen`은 `StatefulWidget`으로 폼 상태를 로컬 관리하고, 저장 시 `FirestoreService`를 직접 호출한다.

### Firestore 구조
```
users/
  default_user/          ← 인증 없는 단일 유저 고정 ID
    ddays/
      {uuid}/            ← uuid v4 사용
```
`FirestoreService._userId`가 `'default_user'`로 하드코딩되어 있다. 인증을 추가할 경우 이 부분을 변경해야 한다.

### DDay 모델 핵심 로직
`DDay.dayDiff`는 시간을 제거한 순수 날짜 기준으로 차이를 계산한다 (시간대 오차 방지). `ddayLabel`이 표시 문자열을 반환한다.

### Firebase 설정
- 프로젝트 ID: `myday-study-dev`
- `lib/firebase_options.dart`는 `flutterfire configure`가 아닌 수동으로 작성됨 — FlutterFire CLI로 재생성하면 덮어씌워짐
- `ios/Runner/GoogleService-Info.plist`, `android/app/google-services.json` 동일하게 수동 생성

## 주의사항

- **Color API**: Flutter 3.35+에서 `.withOpacity()` 사용 금지. 반드시 `.withValues(alpha: x)` 사용
- **Android 빌드**: Kotlin DSL (`build.gradle.kts`) 사용. `com.google.gms.google-services` 플러그인은 `settings.gradle.kts`와 `app/build.gradle.kts` 양쪽에 선언됨
- **로케일**: 앱 전체가 `ko_KR`로 고정되어 있음. 날짜 포맷은 `intl` 패키지의 `DateFormat`으로 처리

## 코딩 지침

- 모든 코드 주석과 dartdoc(`///`)은 한글로 작성한다
- 변수명·함수명·클래스명은 영어(카멜케이스)를 유지하되, 설명이 필요한 경우 한글 주석을 바로 위에 붙인다
