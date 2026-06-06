# Optimized Codex Claude Mission Loop

## 完整闭环

```text
用户需求
  |
  v
dev-pipeline 判断任务规模
  |
  +-- 小任务 -------------------------> 直接执行 -> 验证 -> 交付
  |
  +-- 需求不清/复杂任务
          |
          v
      superpowers
      brainstorming / writing-plans
          |
          v
      docs/superpowers/specs/*.md
          |
          v
      mission-approved-doc
          |
          v
      issues/*.csv
          |
          v
      /goal 或 mission-csv-execute
          |
          v
      每条 issue 四状态闭环
      dev -> initial review -> regression review -> git
          |
          v
      verification-before-completion
          |
          v
      review.md / 交付总结
```

## 触发语

| 你想做什么 | 对 Codex 说 |
| --- | --- |
| 直接进入完整闭环 | `用完整闭环跑这个任务：...` |
| 先把需求想清楚 | `先用 brainstorming 帮我澄清这个需求：...` |
| 生成规格文档 | `把这个需求写成 spec，放到 docs/superpowers/specs：...` |
| spec 转 CSV | `用 mission-approved-doc 把 @docs/superpowers/specs/xxx.md 转成 CSV` |
| 执行 CSV | `/goal @issues/xxx.csv` |
| 恢复中断 | `用 mission-recovery 继续上次任务` |
| 小改动 | `直接改这个小问题：...` |

## CSV 关闭条件

每条 issue 必须同时满足：

- `dev_state=done`
- `review_initial_state=done`
- `review_regression_state=done`
- `git_state=committed` 或明确说明无需提交
