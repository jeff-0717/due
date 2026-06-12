# Focus Records Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a bottom-level “记录” area with focus timing, today-only focus stats, and a study records page.

**Architecture:** Add a small persisted `StudySession` domain beside existing countdown and monitor domains. Use Riverpod state notifiers for session storage and timer state, then expose `/record` and `/study-records` through the existing GoRouter setup with a bottom navigation shell for top-level pages.

**Tech Stack:** Flutter, Dart, flutter_riverpod, Hive, go_router, intl, uuid, flutter_test.

---

## File Structure

| File | Responsibility |
| --- | --- |
| `lib/models/study_session.dart` | Study session value object and JSON mapping |
| `lib/repositories/study_session_repository.dart` | Hive-backed CRUD and date-range query helpers |
| `lib/providers/study_session_provider.dart` | Riverpod providers for sessions, today summary, and timer controller |
| `lib/services/hive_service.dart` | Add `study_sessions` Hive box and clear-all support |
| `lib/pages/record_page.dart` | Focus timer main page with today stats and record entry |
| `lib/pages/study_records_page.dart` | Day/week/month/year summary, distribution, and table |
| `lib/router/app_router.dart` | Add bottom navigation shell and new routes |
| `test/study_session_repository_test.dart` | Persistence and today/range aggregation tests |
| `test/record_page_test.dart` | Timer page UI and today stats tests |
| `test/study_records_page_test.dart` | Study records filter/table tests |
| `test/app_router_test.dart` | Bottom navigation regression tests |

## Task 1: Study Session Domain

**Files:**
- Create: `lib/models/study_session.dart`
- Create: `lib/repositories/study_session_repository.dart`
- Modify: `lib/services/hive_service.dart`
- Test: `test/study_session_repository_test.dart`

- [x] Add `StudySession` with `id`, `startedAt`, `endedAt`, `durationSeconds`, `plannedSeconds`, `note`, `category`, `createdAt`.
- [x] Add `toJson`, `fromJson`, and `copyWith` only if needed by tests.
- [x] Add Hive box constant `studySessionBoxName = 'study_sessions'`.
- [x] Open `_studySessionBox` in `HiveService.init`.
- [x] Add `saveStudySession`, `getAllStudySessions`, and `clearAll` integration.
- [x] Add repository methods: `createSession`, `getAll`, `forLocalDay`, `forRange`.
- [x] Test that sessions serialize and deserialize without losing timestamps.
- [x] Test that `forLocalDay` includes only sessions whose `endedAt` is on that local date.
- [x] Run `flutter test test/study_session_repository_test.dart`.

## Task 2: Providers And Timer State

**Files:**
- Create: `lib/providers/study_session_provider.dart`
- Test: `test/study_session_provider_test.dart`

- [x] Add `studySessionRepositoryProvider`.
- [x] Add `studySessionListProvider` with `refresh()` and `addCompletedSession()`.
- [x] Add `todayStudySummaryProvider` returning count and total seconds for local today.
- [x] Add `FocusTimerState` with `plannedSeconds`, `remainingSeconds`, `isRunning`, `startedAt`.
- [x] Add `FocusTimerNotifier` with `start`, `pause`, `resume`, `reset`, and `finish`.
- [x] Ensure `finish` saves a session only when elapsed seconds are greater than zero.
- [x] Add `FocusTimerMode.fixed45` and `FocusTimerMode.unlimited`.
- [x] Ensure pause/resume time is excluded from saved duration.
- [x] Save note/category on finish and infer category from note when needed.
- [x] Test today summary ignores yesterday and tomorrow sessions.
- [x] Test timer finish creates one persisted session and refreshes today summary.
- [x] Run `flutter test test/study_session_provider_test.dart`.

## Task 3: Bottom Navigation And Routes

**Files:**
- Modify: `lib/router/app_router.dart`
- Create: `lib/pages/app_shell_page.dart`
- Create placeholder first if needed: `lib/pages/record_page.dart`
- Create placeholder first if needed: `lib/pages/study_records_page.dart`
- Test: `test/app_router_test.dart`

- [x] Add an app shell with `NavigationBar` destinations: 首页, 院校, 记录, 设置.
- [x] Map top-level tabs to `/`, `/monitor`, `/record`, `/settings`.
- [x] Keep detail routes outside or above the shell as appropriate: `/add`, `/edit/:id`, `/monitor/edit`, `/monitor/:id/hits`, `/review-start`, `/widget-preview`, `/study-records`.
- [x] Confirm “命中记录” remains reachable from `/monitor/:id/hits`, not the bottom bar.
- [x] Test tapping bottom “记录” shows the record page.
- [x] Test tapping bottom “院校” shows the monitor page.
- [x] Run `flutter test test/app_router_test.dart`.

## Task 4: Record Main Page

**Files:**
- Modify: `lib/pages/record_page.dart`
- Test: `test/record_page_test.dart`

- [x] Build a minimal page based on the reference layout: right-top study record icon, large circular timer, start/pause/resume/finish/reset controls, bottom stats row.
- [x] Keep duration choices limited to `45分钟` and `无限计时`.
- [x] Default planned duration is 2700 seconds and displayed as `45:00`.
- [x] Unlimited mode counts upward from `00:00`.
- [x] Add note input and category selector.
- [x] Add Android lockscreen notification actions for pause/resume/finish.
- [x] Bottom stat labels must be exactly “今日专注次数” and “今日累计时长”.
- [x] Today stats read from `todayStudySummaryProvider`.
- [x] Right-top action pushes `/study-records`.
- [x] Test default page shows `45:00`.
- [x] Test duration choices exclude old 90/120 minute options.
- [x] Test the study record action navigates to learning records page.
- [x] Run `flutter test test/record_page_test.dart`.

## Task 5: Study Records Page

**Files:**
- Modify: `lib/pages/study_records_page.dart`
- Test: `test/study_records_page_test.dart`

- [x] Add segmented control for 日 / 周 / 月 / 年.
- [x] Add summary card showing current range total duration and focus count.
- [x] Add built-in bar distribution without adding chart dependencies.
- [x] Add category duration chart without adding chart dependencies.
- [x] Add data table with columns: 日期, 专注次数, 累计时长.
- [x] Use persisted sessions as the only data source.
- [x] Test weekly mode groups sessions by date.
- [x] Test category duration chart is present.
- [x] Test table includes dates with recorded sessions and excludes out-of-range sessions.
- [x] Test empty state appears when no sessions exist.
- [x] Run `flutter test test/study_records_page_test.dart`.

## Task 6: Clear Data And Regression

**Files:**
- Modify: `lib/services/hive_service.dart`
- Modify: `test/settings_page_test.dart`
- Optional docs sync: `docs/PROGRESS.md`

- [x] Ensure settings “clear all data” clears `study_sessions`.
- [x] Add or extend test fake service so clear-all includes study sessions.
- [x] Run `dart analyze`.
- [x] Run `flutter test`.
- [x] Run `flutter build apk`.
- [x] Update progress docs only after tests pass.

## Completion Sync

| Check | Evidence |
| --- | --- |
| Duration choices | Production code only exposes `focus_duration_45` and `focus_duration_unlimited`; old 90/120/180 choices are absent. |
| Lockscreen controls | Android notification has pause/resume/finish actions and routes native actions back to Flutter through `due/focus_notifications`. |
| Note/category records | `StudySession` persists `note` and `category`; record page saves both on finish. |
| Category chart | Study records page includes `study_category_chart`. |
| Verification | `dart analyze` passed; `flutter test` passed 52/52; `flutter build apk` passed. |

## Self-Review

| Check | Result |
| --- | --- |
| Spec coverage | Tasks cover navigation, timer, today-only stats, learning records, persistence, tests |
| Scope | UI beautification and illustration are excluded |
| Risk control | Timer persistence and date filtering are isolated in provider/repository tests |
| Regression | Existing monitor hit route remains under院校 |
