# Claude Planning Rules

Claude 侧主要负责讨论、澄清、写 spec、生成 CSV。Codex 侧主要负责本地执行、验证、修改文件。

## 使用前提

本模板适用于 Claude Code 或支持 skills 的 Claude 环境。如果使用 Claude Desktop 且没有 skills，仍可按本文档手工执行同样流程。

推荐 skills：

- `brainstorming`
- `writing-plans`
- `mission`
- `mission-approved-doc`
- `mission-long-task`

## 项目适配区

- 项目类型：Flutter Android MVP，目标是交付极简考试倒计时、复习天数和 Android 桌面 Widget 的最小闭环。
- 主要技术栈：Flutter 3.x / Dart 3.x、flutter_riverpod、Hive、go_router、home_widget、intl、uuid。
- 规划输入优先级：以 `docs/PROGRESS.md` 作为任务与进度主来源，同时读取 `lib/`、`android/`、`test/` 校准真实代码现状。
- 当前基础已完成范围：`pubspec.yaml` 依赖配置、`lib/models`、`lib/repositories`、`lib/providers`、`lib/router`、`lib/theme`、`lib/utils`，以及首页/添加编辑页/复习开始页/设置页/Widget 预览页、`widget_sync_service.dart` 与 Android Widget 第一版骨架。
- 当前待规划重点：围绕 `PROGRESS.md` 的 Task 11-18，把“待实现”细化为“完善现有页面交互与校验、补齐 Widget 同步链路、补齐 Android Widget 最小可用能力、补测试并跑通 `flutter pub get` / `flutter test` / `flutter build apk`”。
- 关键目录：`docs/PROGRESS.md`、`docs/superpowers/specs/`、`issues/`、`lib/`、`android/app/src/main/`、`test/`。
- 本轮边界：只做讨论、澄清、写 spec、生成 CSV，不执行业务代码改动；允许更新规则文件和规划产物本身。

## 边界

- Claude 负责把需求变清楚。
- Claude 负责产出 spec 和 CSV 草案。
- Codex 负责本地执行、验证、修改文件。
- Claude 输出必须服务于 `dev-pipeline -> mission/CSV -> /goal` 这条路线。

## 适合 Claude 的任务

- 把模糊需求问清楚。
- 做 brainstorming。
- 写 `docs/superpowers/specs/*.md`。
- 把 spec 转成 `issues/*.csv`。
- 帮用户判断任务是否已经足够清晰。

## 触发方式

| 用户触发语 | Claude 应做什么 |
| --- | --- |
| `帮我讨论这个需求：...` | 使用 `brainstorming` 澄清目标、约束和风险 |
| `把这个需求写成 spec` | 使用 `writing-plans` 输出 `docs/superpowers/specs/*.md` |
| `把 spec 转 CSV` | 按 `issues/template.long-task.csv` 生成 CSV 草案 |
| `给 Codex 执行用` | 确保每条 issue 有验收标准、状态字段、refs 和 notes |

Claude 输出给 Codex 的最后一句建议格式：

```text
请在 Codex 中执行：/goal @issues/xxx.csv
```

## Spec 输出格式

每份 spec 至少包含：

- 背景
- 目标
- 非目标
- 任务拆分
- 验收标准
- 风险
- 回滚方案

## CSV 生成要求

生成 CSV 时，必须使用仓库模板 `issues/template.long-task.csv`。

每条 issue 应该是 atomic issue，标准是：

- 可以独立执行。
- 有明确文件范围。
- 有明确验收标准。
- 失败时能单独回滚或重试。
