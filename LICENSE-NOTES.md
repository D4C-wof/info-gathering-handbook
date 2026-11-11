# License（双许可说明）

Copyright (c) 2026 info-gathering-handbook contributors（《信息收集实战手册（新手版）》）

本仓库按**内容类型**双重许可。本文只说明适用范围与版权，**法条全文在另外两份标准全文文件里**；
两者如有出入，以官方全文为准。

## 1. 文档 → CC BY-NC-SA 4.0

- 适用范围：`README.md`、`信息收集实战手册（新手版）.md`、`CHANGELOG.md`
- 许可：Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
- 全文：`LICENSE-CC-BY-NC-SA-4.0.txt`（creativecommons.org 官方 `legalcode.txt` 原样落地）
- 官方地址：<https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode>
- 三条要点：署名（BY）、非商业（NC）、相同方式共享（SA）
- **NC 是实质限制**：不得用于商业售卖、付费课程、商业培训。教学与个人学习不受限。

## 2. 脚本 → MIT

- 适用范围：`scripts/check-tools.sh`、`scripts/recon.sh`
- 全文：`LICENSE-MIT`
- 脚本内容与正文对应小节（§1.7、§9.2）为同一来源的两份副本；正文受 CC BY-NC-SA 4.0 约束，
  `scripts/` 下的副本按 MIT 授权。

## 3. 第三方工具

本仓库**不重新分发**任何工具，只在正文给出安装与用法说明。文中提到的 nmap、subfinder、httpx、
naabu、katana、ffuf、tlsx、jsluice、gf、alterx、nuclei 等各自按其上游许可（多为 MIT / Apache-2.0 /
GPL）。商业使用前请自行核对上游条款。

## 4. 为什么不是一个 `LICENSE`

GitHub 只按「标准文件名 + 标准全文」识别许可证。把这份中文说明命名为 `LICENSE`，
侧栏会显示 `NOASSERTION` / Other。因此标准全文分别落在 `LICENSE-MIT` 与
`LICENSE-CC-BY-NC-SA-4.0.txt`，说明放在本文件。

> 侧栏识别为 **MIT 只代表 `scripts/` 部分**；文档仍受 CC BY-NC-SA 4.0（含非商业）约束，
> 转载整本手册请按第 1 节处理。
