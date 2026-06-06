# Long Task Loop Template

这是给新项目复制用的基础模板。

## 复制到新项目

在 PowerShell 中执行：

```powershell
Copy-Item -Recurse -Force "D:\my github\.codex-templates\long-task-loop\*" "D:\path\to\your-project\"
```

然后在新项目里对 Codex 说：

```text
按当前项目技术栈，适配 AGENTS.md / CLAUDE.md 和 CSV 模板。先读取项目结构、README、依赖文件和测试配置，只做规则文件适配，不改业务代码。
```

## 日常触发

```text
用完整闭环跑这个任务：……
```

或分阶段：

```text
先用 brainstorming 帮我澄清这个需求：……
把这个需求写成 spec，放到 docs/superpowers/specs
用 mission-approved-doc 把 @docs/superpowers/specs/xxx.md 转成 CSV
/goal @issues/xxx.csv
用 mission-recovery 继续上次任务
```
