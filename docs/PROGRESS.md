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
- 依赖安装：待执行 `flutter pub get`
- 开发者模式：待开启（`start ms-settings:developers`）

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

### ⏳ 待完成（Task 11-18）

| # | 任务 | 状态 | 文件 |
|---|------|------|------|
| 11 | 实现首页（交互完善） | ⏳ | `pages/home_page.dart` |
| 12 | 实现添加/编辑页 | ⏳ | `pages/add_countdown_page.dart`, `pages/edit_countdown_page.dart` |
| 13 | 实现复习开始日期页 | ⏳ | `pages/review_start_page.dart` |
| 14 | 实现设置页 | ⏳ | `pages/settings_page.dart` |
| 15 | 实现 Widget 预览页 | ⏳ | `pages/widget_preview_page.dart` |
| 16 | 实现 widget_sync_service.dart | ⏳ | `services/widget_sync_service.dart` |
| 17 | 实现 Android Widget 最小版本 | ⏳ | `android/` 原生代码 |
| 18 | 跑通本地构建 | ⏳ | `flutter build apk` |

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

## 路由

| 路径 | 页面 |
|------|------|
| `/` | 首页 |
| `/add` | 添加倒计时 |
| `/edit/:id` | 编辑倒计时 |
| `/review-start` | 复习开始日期 |
| `/widget-preview` | Widget 预览 |
| `/settings` | 设置 |

---

## 下一步操作

1. **开启开发者模式**：`start ms-settings:developers`
2. **安装依赖**：`flutter pub get`
3. **继续 Task 11-18**
