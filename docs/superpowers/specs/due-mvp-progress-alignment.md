# Due MVP 剩余任务与进度承接 Spec

## 背景

`Due` 是一个 Flutter Android MVP，目标是交付极简考试倒计时、复习天数与 Android 桌面 Widget 的最小闭环。当前项目的任务与进度主来源是 `docs/PROGRESS.md`，但实际代码现状已经领先于文档中的部分待办描述。

本次规划遵循以下澄清结论：

- 范围采用“全部任务脉络”，即基于 `PROGRESS.md` 的完整阶段性进度来承接后续执行。
- issue 粒度采用偏细的 atomic issue，确保每条都可独立执行、验证、回滚。
- 排序原则以 `PROGRESS.md` 当前顺序和状态为主，必要时仅插入前置校验任务。

## 目标

把当前项目从“基础层已完成、功能与验证层待收口”的状态，整理成一份可直接交给 Codex 执行的 spec 与 CSV，使后续工作可以沿着固定闭环推进：页面完善、Widget 链路打通、测试补齐、本地构建验证完成。

## 非目标

- 不重做 `Task 1-10` 已完成的模型、仓储、Provider、路由、主题和日期工具。
- 不在本轮规划中引入新的产品范围，例如 iOS Widget、分享图、云同步、多主题系统。
- 不把已有页面骨架、`widget_sync_service.dart` 或 Android Widget 资源误判为“从零实现”。
- 不在本轮直接修改业务代码；本轮仅产出规划文档和执行 CSV。

## 当前状态总结

### 已完成基线

根据 `docs/PROGRESS.md` 与代码现状，以下基础能力已基本具备：

- `pubspec.yaml` 已声明 Flutter、Riverpod、Hive、go_router、home_widget、intl、uuid 等依赖。
- `lib/models`、`lib/repositories`、`lib/providers`、`lib/router`、`lib/theme`、`lib/utils` 已形成可运行的基础数据与路由骨架。
- `test/app_date_utils_test.dart` 已存在最小日期逻辑测试。
- `android/app/src/main/` 下已经存在 `DueWidgetProvider.kt`、`due_widget.xml`、`due_widget_info.xml` 与 manifest 接线。

### 文档与代码的差异

`PROGRESS.md` 把 `Task 11-17` 标记为“待实现”，但代码显示这些部分大多已经有第一版骨架：

- `lib/pages/home_page.dart` 已有列表、概览、空态和跳转入口。
- `lib/pages/add_countdown_page.dart` 与 `lib/pages/edit_countdown_page.dart` 已有基础表单、日期选择、颜色图标选择和保存逻辑。
- `lib/pages/review_start_page.dart`、`lib/pages/settings_page.dart`、`lib/pages/widget_preview_page.dart` 已有最小页面结构。
- `lib/services/widget_sync_service.dart` 已有向 `home_widget` 写入数据并触发更新的基础能力。
- Android Widget 原生文件已存在，但是否构成“最小可用链路”仍需联调与验证。

因此，后续执行口径应统一为：

- `Task 11-17` 不是从零开发，而是完善现有页面交互、状态处理、同步链路和原生 Widget 可用性。
- `Task 18` 负责把依赖安装、测试与 APK 构建跑通，并吸收前面任务暴露的问题。

## 任务拆分

### Phase 0：环境与基线校准

1. 安装依赖并校验基础工程可运行性。
2. 记录 `flutter pub get`、`flutter test`、`flutter build apk` 的初始阻塞项，作为后续执行入口。

### Phase 1：页面层完善

3. 完善首页交互闭环，确保空态、有数据态、最近倒计时概览和设置入口行为一致。
4. 完善添加页表单校验、默认值、提交反馈和返回逻辑。
5. 完善编辑页的加载态、找不到目标对象时的兜底、更新与删除确认链路。
6. 完善复习开始日期页，确保设置、修改和显示逻辑闭环。
7. 完善设置页与复习日期、Widget 预览、清空数据等入口的联动和反馈。

### Phase 2：Widget 链路完善

8. 完善 Widget 预览页的空态、选中态、同步按钮反馈与配置持久化体验。
9. 完善 `widget_sync_service.dart` 的数据契约、异常路径和与配置数据的协作边界。
10. 校验并修正 Android Widget Provider、布局、Manifest 与 widget info，使其满足最小可用要求。

### Phase 3：质量与交付验证

11. 为剩余核心逻辑补齐测试，优先覆盖日期逻辑边界、Provider/Repository 基本行为和关键数据流。
12. 跑通 `flutter test` 与 `flutter build apk`，补充必要的人工 Widget 验收步骤，并输出剩余风险。

## 执行约束

- 保持 `PROGRESS.md` 的任务顺序语义，新增 issue 只用于补充前置校验或把过大的任务拆细。
- 每条 issue 必须有明确文件范围、接受标准和可执行验证方式。
- 优先在现有文件上增量完善，不随意新增结构层。
- 涉及 Android Widget 的验证，允许使用 `MANUAL` 标记并在 notes 中写清设备/模拟器验收步骤。
- 不回滚用户已有无关改动。

## 验收标准

### 计划层验收

- `AGENTS.md` 与 `CLAUDE.md` 的项目适配区已反映当前 Flutter 项目真实技术栈、目录和执行边界。
- spec 清楚标注 `PROGRESS.md` 与代码现状差异，并据此重写剩余任务口径。
- `issues/*.csv` 基于 `issues/template.long-task.csv` 生成，且每条 issue 为 atomic issue。

### 执行层验收目标

- 剩余任务覆盖 `PROGRESS.md` 的后续主线，且没有把已完成基础能力重复纳入执行范围。
- 页面、Widget、测试、构建验证四类任务均在 CSV 中有对应 issue。
- 最终可由 Codex 直接执行 `/goal @issues/xxx.csv` 进入闭环。

## 风险

- `PROGRESS.md` 与代码现状存在漂移，执行中可能继续发现“文档说未完成、代码已有部分实现”的情况。
- `home_widget` 的 Android 侧行为可能依赖设备、Launcher 或开发者模式，自动化验证能力有限。
- 目前测试覆盖面较小，首次跑通 `flutter test` 或 `flutter build apk` 时可能暴露历史遗留问题。
- 页面骨架已在多个文件中铺开，若缺少统一验收标准，容易出现“能打开但体验不闭环”的伪完成状态。

## 回滚方案

- 规划层回滚：若本次 spec/CSV 拆分不合理，直接回退 `docs/superpowers/specs/due-mvp-progress-alignment.md` 与对应 CSV 文件即可，不影响业务代码。
- 执行层回滚：要求 Codex 按 atomic issue 独立提交与验证，单条 issue 失败时只回滚该 issue 触及文件，不影响其余任务推进。
- 文档与代码再次漂移时，以代码现状为事实基础更新 `PROGRESS.md` 或在后续 review 文档中显式记录差异。
