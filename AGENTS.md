# Codex Long-Task Operating Rules

本项目默认使用优化后的长任务闭环：

```text
dev-pipeline -> superpowers -> mission -> CSV -> /goal -> verification -> review.md
```

## 使用前提

本模板假设以下 skills 已安装到当前 agent 环境：

- `dev-pipeline`
- `brainstorming`
- `writing-plans`
- `mission`
- `mission-approved-doc`
- `mission-csv-execute`
- `mission-doc-route`
- `mission-long-task`
- `mission-recovery`
- `verification-before-completion`

如果某个 skill 不可用，保留流程语义，使用最接近的本地能力替代。

## 项目适配区

首次复制到新项目后，必须补全：

| 项 | 当前项目填写 |
| --- | --- |
| 项目类型 | Flutter Android MVP（极简考试倒计时 + 复习天数 + Android 桌面 Widget） |
| 主要技术栈 | Flutter 3.x / Dart 3.x、flutter_riverpod、Hive、go_router、home_widget、intl、uuid |
| 构建命令 | `flutter pub get`；`flutter build apk` |
| 测试命令 | `flutter test` |
| 启动命令 | `flutter run` |
| 关键目录 | `lib/models`、`lib/repositories`、`lib/providers`、`lib/pages`、`lib/widgets`、`lib/services`、`lib/router`、`lib/theme`、`lib/utils`、`android/app/src/main`、`test`、`docs/PROGRESS.md` |
| 不可修改区域 | 非任务相关平台生成文件、用户已有无关改动；规划阶段不改业务代码，仅允许更新 `AGENTS.md`、`CLAUDE.md`、`docs/superpowers/specs/*.md`、`issues/*.csv` |
| 发布/交付方式 | 先产出 spec 和 long-task CSV，再由 Codex 执行 `/goal @issues/*.csv`，完成后通过本地测试与 `flutter build apk` 验证交付 |

补充约束：

- 当前项目的计划基线以 `docs/PROGRESS.md` 为主。
- 如果 `PROGRESS.md` 与实际代码不一致，spec/CSV 需要显式标注“文档进度”和“代码现状”的差异，避免把已存在的页面骨架、Widget 骨架或原生接线重复规划为从零实现。
- 当前已可视为基础完成的范围包括：`models`、`repositories`、`providers`、`router`、`theme`、`utils`，以及首页/表单页/设置页/Widget 预览页/Android Widget 的第一版骨架。

## 触发方式

| 用户触发语 | 应走流程 |
| --- | --- |
| `用完整闭环跑这个任务：...` | `dev-pipeline -> superpowers -> mission -> CSV -> /goal -> verification` |
| `把这个需求先做成 spec：...` | `brainstorming -> writing-plans -> docs/superpowers/specs/*.md` |
| `把这个 spec 转 CSV：@docs/...md` | `mission-approved-doc -> issues/*.csv` |
| `执行这个 CSV：@issues/...csv` | `mission-csv-execute` 或 `/goal @issues/...csv` |
| `继续上次任务` / `恢复 mission` | `mission-recovery` |
| `直接改这个小问题：...` | 不进入 mission，直接执行并验证 |

默认判断：

- 预计少于 1 小时、少于 3 步：直接执行。
- 需求不清、影响面未知：先走 `brainstorming`。
- 超过 1 小时、跨多个文件或需要持续恢复：走完整闭环。

## 默认路线

| 输入 | 路由 |
| --- | --- |
| 模糊需求、复杂需求 | 使用 `brainstorming` / `writing-plans` 生成 `docs/superpowers/specs/*.md` |
| 已有 spec 文档 | 使用 `mission-approved-doc` 转成 `issues/*.csv` |
| 已有 CSV | 使用 `mission-csv-execute` 或 `/goal @issues/xxx.csv` 执行 |
| 自然语言长任务 | 使用 `mission-long-task` 拆解并执行 |
| 中断恢复 | 使用 `mission-recovery` 读取 CSV 状态和 `review.md` 后继续 |

## 执行原则

- 先确认目标，再拆成 5-15 个 atomic issue。
- 每个 issue 必须有可机器验证的 `acceptance_criteria`。
- 不允许只做 smoke test 就标记完成。
- 每个 issue 按四状态闭环推进：开发、自审、回归审查、提交。
- 遇到不确定点，优先记录到 `notes`，不要静默跳过。
- 跑长任务时，必须周期性更新 CSV 状态或 review 日志。
- 保护用户已有改动，禁止回滚无关变更。

## CSV 状态规则

| 字段 | 状态 |
| --- | --- |
| `dev_state` | `not_started` -> `in_progress` -> `done` |
| `review_initial_state` | `not_started` -> `in_progress` -> `done` |
| `review_regression_state` | `not_started` -> `in_progress` -> `done` |
| `git_state` | `uncommitted` -> `committed` |

只有四个状态都到位时，该 issue 才算关闭。

## 验收要求

- 后端/API：优先跑单元测试、契约测试或接口验证。
- 前端/UI：优先跑构建、视觉检查、关键交互验证。
- 跨流程：优先跑端到端路径。
- 无法自动验证时，标记 `test_mcp=MANUAL`，并在 `notes` 写清人工验收步骤。

## 输出要求

最终回复保持简短，必须包含：

- 结果
- 改动文件
- 验证方式
- 剩余风险
