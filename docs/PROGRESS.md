# Due 开发进度

## 目标
从零开发一个 Flutter Android MVP：Due。
定位：极简考试倒计时 + 复习天数 + Android 桌面 Widget。

## 技术栈
- Flutter 3.44.0 + Dart 3.12.0
- Riverpod
- Hive
- go_router
- home_widget
- intl
- uuid
- RepaintBoundary 用于后续分享图

## 环境状态
- Flutter SDK：`C:\flutter\bin`（已加入用户 PATH）
- 项目目录：`D:\my github\due`
- Android SDK：已配置，`flutter doctor` Android toolchain OK
- 依赖安装：已完成
- 本地测试：`flutter test` 16/16 通过
- APK 构建：`flutter build apk` 已通过
- APK 输出：`build/app/outputs/flutter-apk/app-release.apk`
- 模拟器验证：BlueStacks `127.0.0.1:5555` 可安装并启动

---

## 开发进度

### ✅ 已完成（Task 1-10）

| # | 任务 | 状态 | 文件 |
|---|------|------|------|
| 1 | 创建 Flutter 工程 | ✅ | `flutter create` 已执行 |
| 2 | 配置 pubspec.yaml | ✅ | `pubspec.yaml` |
| 3 | 建立目录结构 | ✅ | `lib/` 全目录 |
| 4 | 实现 theme | ✅ | `app_tokens.dart`, `app_theme.dart` |
| 5 | 实现 models | ✅ | `countdown.dart`, `review_start.dart`, `widget_config.dart` |
| 6 | 实现 app_date_utils.dart | ✅ | `utils/app_date_utils.dart` |
| 7 | 实现 hive_service.dart | ✅ | `services/hive_service.dart`（使用 jsonEncode/Decode） |
| 8 | 实现 repositories | ✅ | `countdown_repository.dart`, `review_start_repository.dart`, `widget_config_repository.dart` |
| 9 | 实现 providers | ✅ | `countdown_provider.dart`, `review_start_provider.dart`, `widget_config_provider.dart` |
| 10 | 实现 router | ✅ | `router/app_router.dart` |

### ✅ 已完成（用户反馈修正）

| # | 修正 | 状态 | 文件 |
|---|------|------|------|
| 1 | 删除 `_defaultId` 未使用变量 | ✅ | `countdown_repository.dart` |
| 2 | 删除 `uuid` 未使用 import | ✅ | `review_start_repository.dart`, `widget_config_repository.dart` |
| 3 | `createdAt` 保留旧值不重置 | ✅ | `review_start_repository.dart` |
| 4 | UI token 统一（新增 `fontSizeSmall`, `fontSizeHero`, `radiusMedium`, `radiusLarge`） | ✅ | `app_tokens.dart`, `countdown_overview.dart`, `countdown_card.dart` |

### ✅ 已完成（Task 11-18：MVP 收口）

| # | 任务 | 状态 | 文件 |
|---|------|------|------|
| 11 | 首页交互完善 | ✅ | `pages/home_page.dart`, `widgets/countdown_overview.dart`, `widgets/countdown_card.dart` |
| 12 | 添加/编辑页完善 | ✅ | `pages/add_countdown_page.dart`, `pages/edit_countdown_page.dart` |
| 13 | 复习开始日期页完善 | ✅ | `pages/review_start_page.dart` |
| 14 | 设置页完善 | ✅ | `pages/settings_page.dart` |
| 15 | Widget 预览页完善 | ✅ | `pages/widget_preview_page.dart` |
| 16 | Widget 同步服务完善 | ✅ | `services/widget_sync_service.dart`, `providers/widget_sync_provider.dart` |
| 17 | Android Widget 最小链路补齐 | ✅ | `android/app/src/main/` |
| 18 | 本地测试与 APK 构建跑通 | ✅ | `flutter test`, `flutter build apk` |

### ✅ 已完成（启动崩溃热修复）

| # | 修正 | 状态 | 文件 |
|---|------|------|------|
| 1 | 修复安装后启动即崩溃：移除 WorkManager 自动初始化 | ✅ | `android/app/src/main/AndroidManifest.xml` |
| 2 | 记录崩溃根因、日志特征和复验命令 | ✅ | `docs/report/20260606163143562_android_workmanager_startup_crash.md`, `issues/due-mvp-progress-alignment.csv` |

崩溃关键特征：`androidx.startup.InitializationProvider` -> `androidx.work.WorkManagerInitializer` -> `Failed to create WorkDatabase`。

### ✅ 已完成（记录与专注计时）

| # | 功能 | 状态 | 文件 |
|---|------|------|------|
| 1 | 专注 session 持久化与本地日期查询 | ✅ | `models/study_session.dart`, `repositories/study_session_repository.dart`, `services/hive_service.dart` |
| 2 | 今日专注统计与计时控制器 | ✅ | `providers/study_session_provider.dart` |
| 3 | 底部导航新增：首页、院校、记录、设置 | ✅ | `pages/app_shell_page.dart`, `router/app_router.dart` |
| 4 | 记录页：45:00、开始/暂停/继续/结束/重置、今日统计 | ✅ | `pages/record_page.dart` |
| 5 | 学习记录页：日/周/月/年、汇总、分布、表格 | ✅ | `pages/study_records_page.dart` |
| 6 | 本轮回归验证 | ✅ | `dart analyze`, `flutter test` 47/47, `flutter build apk` |

本轮未走 Stitch/前端总控闭环：CSV `required_mcp` 为空，且 spec 明确本轮排除 UI 美化，仅实现功能闭环。

---

## 目录结构

```
D:\my github\due\
├── pubspec.yaml
├── analysis_options.yaml
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── models/
│   │   ├── countdown.dart
│   │   ├── review_start.dart
│   │   └── widget_config.dart
│   ├── pages/
│   │   ├── home_page.dart
│   │   ├── add_countdown_page.dart
│   │   ├── edit_countdown_page.dart
│   │   ├── review_start_page.dart
│   │   ├── widget_preview_page.dart
│   │   └── settings_page.dart
│   ├── widgets/
│   │   ├── countdown_card.dart
│   │   ├── countdown_overview.dart
│   │   ├── empty_state.dart
│   │   ├── color_picker_row.dart
│   │   ├── icon_picker_row.dart
│   │   └── widget_preview_card.dart
│   ├── providers/
│   │   ├── countdown_provider.dart
│   │   ├── review_start_provider.dart
│   │   └── widget_config_provider.dart
│   ├── repositories/
│   │   ├── countdown_repository.dart
│   │   ├── review_start_repository.dart
│   │   └── widget_config_repository.dart
│   ├── services/
│   │   ├── hive_service.dart
│   │   └── widget_sync_service.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_tokens.dart
│   └── utils/
│       └── app_date_utils.dart
├── android/
├── ios/
├── web/
├── linux/
├── macos/
├── windows/
└── test/
```

---

## 数据模型

| 模型 | 字段 | 说明 |
|------|------|------|
| `RepeatType` | `once`, `yearly` | 枚举 |
| `Countdown` | id, title, targetDate, repeatType, color, icon, createdAt, updatedAt | 倒计时 |
| `ReviewStart` | id, startDate, title, createdAt, updatedAt | 复习开始日期 |
| `WidgetConfig` | id, countdownId, style, updatedAt | Widget 配置 |

## 设计 Token

| Token | 值 | 用途 |
|-------|-----|------|
| `primary` | #2563EB | 主色 |
| `accent` | #F97316 | 辅色 |
| `background` | #F8FAFC | 背景色 |
| `card` | #FFFFFF | 卡片色 |
| `textPrimary` | #0F172A | 正文色 |
| `textSecondary` | #64748B | 次级文字 |
| `border` | #E2E8F0 | 边框色 |
| `fontSizeBody` | 15 | 正文字号 |
| `fontSizeTitle` | 24 | 标题字号 |
| `fontSizeLargeNumber` | 56 | 大数字字号（卡片） |
| `fontSizeSmall` | 13 | 小字号 |
| `fontSizeHero` | 64 | 大数字字号（概览） |
| `spacing` | 16 | 间距 |
| `radius` | 8 | 圆角 |
| `radiusMedium` | 12 | 中圆角 |
| `radiusLarge` | 16 | 大圆角 |

## 日期逻辑（app_date_utils.dart）

| 函数 | 说明 |
|------|------|
| `daysUntil(target, repeatType)` | 单次：target - today；每年：若今年已过则算明年 |
| `reviewDaysSince(startDate)` | today - startDate + 1 |
| `formatDate(date)` | yyyy/MM/dd |
| `resolveNextTargetDate(target, repeatType)` | 解析下一次目标日期 |

## Hive Box

| Box 名称 | 存储内容 |
|----------|----------|
| `countdowns` | Countdown JSON |
| `review_start` | ReviewStart JSON |
| `widget_config` | WidgetConfig JSON |
| `study_sessions` | StudySession JSON |

## 路由

| 路径 | 页面 |
|------|------|
| `/` | 首页 |
| `/add` | 添加倒计时 |
| `/edit/:id` | 编辑倒计时 |
| `/review-start` | 复习开始日期 |
| `/widget-preview` | Widget 预览 |
| `/monitor` | 院校监控 |
| `/monitor/:id/hits` | 院校命中记录 |
| `/record` | 记录 |
| `/study-records` | 学习记录 |
| `/settings` | 设置 |

---

## 下一步操作

1. **提交当前 MVP 收口与热修复改动**：不提交 `.codex-temp/`。
2. **基于 MVP 规划下一阶段功能**：先让 Claude 输出 spec，再转 CSV。
3. **走完整闭环**：`dev-pipeline -> superpowers -> mission -> CSV -> /goal -> verification -> review.md`。
