# Due 下一阶段规划交接摘要

## 当前目标

基于 Due 项目的真实实现状态，规划一次产品定位升级和新功能开发。

新定位：

- 从“极简考试倒计时 + 复习天数 + Android Widget”升级为
- “面向考试备考的倒计时 + 信息监控 + 关键节点提醒工具”

本轮新增功能主题：`院校考情本地监控`

## 已完成的工作

本轮已经完成的是“规划前置校准”，不是代码实现。

已读取并交叉核对：

- `docs/PROGRESS.md`
- `AGENTS.md`
- `docs/report/20260606163143562_android_workmanager_startup_crash.md`
- `issues/due-mvp-progress-alignment.csv`
- `pubspec.yaml`
- `lib/` 关键代码
- `test/` 现有测试
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/com/example/due/DueWidgetProvider.kt`
- 最近 `git log`

## 已确认的真实基线

以下内容已经完成，不应被下一阶段 spec/CSV 重复规划为 MVP 待办：

- MVP 主线功能已收口完成。
- `flutter test` 已通过，当前记录为 16/16。
- `flutter build apk` 已通过。
- APK 已可安装到 BlueStacks `127.0.0.1:5555` 并启动。
- Android Widget 最小链路已完成并做过验证记录。
- `home_widget` / WorkManager 启动崩溃热修复已落地。

关键热修复约束：

- `AndroidManifest.xml` 中已经移除了 `androidx.work.WorkManagerInitializer` 的自动初始化 metadata。
- 后续若引入 WorkManager，必须“显式初始化/配置”，不能恢复旧的自动启动路径。

## 已确认的规划原则

1. 不要只按 `docs/PROGRESS.md` 规划。
2. 如果 `PROGRESS.md` 与代码、CSV、git 历史不一致，以代码和 CSV 为准。
3. 本轮只做规划，不改业务代码。
4. 必须分阶段：
   - 第一阶段：手动检查 + 命中记录
   - 第二阶段：WorkManager 低频后台检查 + 本地通知
5. spec/CSV 必须写清非回归边界，尤其是：
   - Android Widget
   - Hive 现有数据
   - 当前 go_router 路由
   - WorkManager 启动崩溃热修复

## 已形成的下一阶段功能结论

下一阶段不是继续补 MVP，而是进入“产品定位升级后的第一批新能力”。

建议拆成两阶段：

### 阶段 A：院校考情本地监控 MVP

目标：先做“手动可用”的本地监控闭环，不引入后台调度。

应覆盖：

- 用户手动添加监控对象：院校名称、官网/公告页 URL、关键词
- 支持用户手动触发检查网页/RSS
- 根据关键词筛选命中内容
- 保存命中记录：标题、链接、摘要、命中关键词、发现时间
- 抓取失败时提示用户手动打开官网
- 明确不承诺实时性，不做无头浏览器，不依赖服务器/VPS

### 阶段 B：低频后台检查 + 本地通知

目标：在阶段 A 数据模型稳定后，再加 Android 端低频自动检查。

应覆盖：

- 使用 WorkManager 做 6-12 小时低频后台检查
- 发现新命中时触发本地通知
- 避免重复提醒同一条命中
- 保持启动稳定，不破坏既有 WorkManager 热修复

## 对当前代码结构的判断

现有代码结构偏简单清晰，适合继续沿用：

- `models/`
- `repositories/`
- `providers/`
- `services/`
- `pages/`
- `router/`
- `test/`

因此新功能建议继续沿用同样分层，而不是引入新架构。

大概率需要新增的内容方向包括：

- 新模型：监控源、命中记录、监控配置/检查状态
- 新仓储：基于 Hive 的监控源与命中记录持久化
- 新 Provider：列表状态、手动检查状态、筛选状态
- 新 Service：页面抓取/RSS 解析/关键词命中/去重策略
- 新页面：监控列表页、添加编辑监控页、命中记录页
- 路由扩展：在不破坏现有路由的前提下新增监控相关页面入口
- 第二阶段 Android 侧：WorkManager 调度、通知桥接、Manifest/权限/初始化策略

## 已知风险点

1. 当前项目还没有网络抓取相关依赖，后续 spec 需要先定义抓取策略和依赖范围。
2. 由于“不做无头浏览器”，只能覆盖静态网页或 RSS，可用性要在 spec 中明确降级说明。
3. WorkManager 未来重新接入时，必须把“启动不崩”列为强验收项。
4. Hive 目前只有 countdown/review_start/widget_config 三类数据，新增 Box 时要避免影响既有 clear-all 和迁移逻辑。
5. 现有首页与设置页入口很少，监控功能入口应该放在哪里，需要在 spec 中明确。

## 本轮还没完成的部分

下面这些还没真正落盘：

- 新的 `docs/superpowers/specs/*.md` 还没写出。
- 新的 `issues/*.csv` 还没生成。
- 还没给出最终的 `/goal @issues/xxx.csv`。

也就是说，分析和方向已经完成，但“正式规划产物”还没有创建。

## 新窗口建议直接继续做的事

在新窗口中，直接继续以下任务：

1. 生成 spec：
   - 文件放到 `docs/superpowers/specs/`
   - 主题是“Due 产品定位升级 + 院校考情本地监控”
   - 明确标注：以代码和 `issues/due-mvp-progress-alignment.csv` 为真实基线，不重复规划已完成 MVP
   - 明确两阶段：手动检查 MVP；WorkManager + 通知二阶段

2. 生成 CSV：
   - 文件放到 `issues/`
   - 每条 issue 必须包含：
     - 可验证 acceptance criteria
     - 测试方式
     - 涉及文件
     - 风险备注
   - 按 atomic issue 拆分

3. 最终给出 Codex 命令：
   - `/goal @issues/xxx.csv`

## 可直接在新窗口使用的续做提示词

```text
请继续完成 Due 下一阶段规划，不要重复读取无关内容。
已确认真实基线：MVP 主线、Widget 最小链路、flutter test 16/16、flutter build apk、BlueStacks 启动、WorkManager 启动崩溃热修复都已完成；下一阶段不要重复规划这些内容。

请基于以下既有结论直接落盘：
1. 新定位：Due 升级为“面向考试备考的倒计时 + 信息监控 + 关键节点提醒工具”
2. 新功能：院校考情本地监控
3. 分阶段：
   - 第一阶段：手动检查网页/RSS + 命中记录
   - 第二阶段：WorkManager 6-12 小时低频后台检查 + 本地通知
4. 不使用服务器/VPS，不做无头浏览器，不承诺实时监控，抓取失败时提示用户手动打开官网
5. 如果 PROGRESS.md 与代码/CSV 不一致，以代码和 CSV 为准，并在 spec 中标注差异
6. 必须保护 Android Widget、Hive 数据、现有路由和 WorkManager 热修复

现在请：
- 生成 spec 到 docs/superpowers/specs/*.md
- 再拆成 issues/*.csv
- 最后给出 /goal @issues/xxx.csv
```
