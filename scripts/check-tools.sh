#!/bin/bash
# 用途：检查信息收集工具链是否可用
# 摘自《信息收集实战手册（新手版）》§1.7；正文为唯一来源，改脚本请同步正文。
# 许可：MIT（见仓库根目录 LICENSE-MIT）

# 用法：bash check_tools.sh

for t in dig whois curl jq nmap nc subfinder dnsx httpx tlsx naabu \
         cdncheck katana nuclei ffuf anew unfurl gau; do
  if command -v "$t" >/dev/null 2>&1; then
    printf '[ OK ] %-10s %s\n' "$t" "$("$t" -version 2>&1 | head -1)"
  else
    printf '[MISS] %-10s 未安装\n' "$t"
  fi
done

echo "---- 同名冲突检查 ----"
for t in httpx; do
  n=$(which -a "$t" 2>/dev/null | wc -l)
  [ "$n" -gt 1 ] && { echo "[WARN] $t 有 $n 个版本："; which -a "$t"; }
done
