#!/bin/bash
# recon.sh — 分阶段信息收集骨架
# 摘自《信息收集实战手册（新手版）》§9.2；正文为唯一来源，改脚本请同步正文。
# 仅对已获得书面授权的目标运行；S3 之后必须人工产出 targets.txt（归属判定不自动化）。
# 许可：MIT（见仓库根目录 LICENSE-MIT）

# 用法: ./recon.sh <domain> [outdir]
# 注意: 只对已授权目标使用；主动探测阶段需要人工确认 targets.txt
set -uo pipefail

D="${1:?用法: ./recon.sh <domain> [outdir]}"
OUT="${2:-$HOME/recon/$D}"
RL="${RL:-20}"           # 每秒请求数：常规 20，敏感项目改 5，靶场可 50

mkdir -p "$OUT"/{00-scope,01-passive,02-subs,03-resolved,04-live,05-ports,06-content,07-evidence/{raw,screens,logs}}
LOG="$OUT/07-evidence/logs/run.log"
log(){ echo "[$(date '+%F %T')] $*" | tee -a "$LOG"; }
has(){ [ -s "$1" ]; }     # 文件存在且非空

# ========== S2-1 被动子域 ==========
has "$OUT/02-subs/passive.txt" || {
  log "subfinder"
  subfinder -d "$D" -all -silent -o "$OUT/02-subs/passive.txt"
}

# ========== S2-2 证书透明度 ==========
has "$OUT/02-subs/cert.txt" || {
  log "crt.sh"
  curl -s "https://crt.sh/?q=%25.$D&output=json" \
    | jq -r '.[].name_value' 2>/dev/null \
    | tr ',' '\n' | sed 's/\*\.//' | sort -u > "$OUT/02-subs/cert.txt"
}

# ========== S2-3 合并 + 只保留本域 ==========
log "merge"
{ cat "$OUT/02-subs/passive.txt" "$OUT/02-subs/cert.txt" 2>/dev/null; echo "$D"; } \
  | awk -v d="$D" 'index($0,d)==length($0)-length(d)+1' | sort -u > "$OUT/02-subs/all.txt"
log "subs: $(wc -l < "$OUT/02-subs/all.txt")"

# ========== S2-4 泛解析判定 ==========
has "$OUT/02-subs/wildcard_ips.txt" || {
  log "wildcard"
  for _ in 1 2 3; do dig +short "$(openssl rand -hex 6).$D"; done | sort -u > "$OUT/02-subs/wildcard_ips.txt"
}
log "wildcard IPs: $(wc -l < "$OUT/02-subs/wildcard_ips.txt")"

# ========== S2-5 解析 + 剔除泛解析 ==========
has "$OUT/03-resolved/clean.txt" || {
  log "dnsx"
  dnsx -l "$OUT/02-subs/all.txt" -a -resp -silent -o "$OUT/03-resolved/resolved.txt"
  if has "$OUT/02-subs/wildcard_ips.txt"; then
    grep -vFf "$OUT/02-subs/wildcard_ips.txt" "$OUT/03-resolved/resolved.txt" > "$OUT/03-resolved/clean.txt" || :
  else
    cp "$OUT/03-resolved/resolved.txt" "$OUT/03-resolved/clean.txt"
  fi
}
awk '{print $1}' "$OUT/03-resolved/clean.txt" | tr -d '[]' > "$OUT/03-resolved/hosts.txt"

# ========== S2-6 探活 + 指纹（限速） ==========
has "$OUT/04-live/live.txt" || {
  log "httpx"
  httpx -l "$OUT/03-resolved/hosts.txt" -silent -td -title -status-code -favicon \
        -rl "$RL" -o "$OUT/04-live/live.txt"
}
log "live: $(wc -l < "$OUT/04-live/live.txt")"

# ========== S3 归属判定：必须人工 ==========
# 把 live.txt 里明显不属于目标的（CDN 节点、第三方 SaaS、云共享 IP）手工剔除，
# 结果写到 04-live/targets.txt。脚本不会替你判归属。
if ! has "$OUT/04-live/targets.txt"; then
  log "!! 请人工审阅 live.txt，产出 targets.txt 后再继续"
  exit 0
fi

# ========== S4-1 端口（只对已确认目标，top1000） ==========
has "$OUT/05-ports/naabu.txt" || {
  log "naabu"
  awk '{print $1}' "$OUT/04-live/targets.txt" | sed -E 's#https?://##; s#[:/].*##' | sort -u \
    | naabu -silent -top-ports 1000 -rate 500 -o "$OUT/05-ports/naabu.txt"
}

# ========== S4-2 内容面（只对少量高价值目标） ==========
if has "$OUT/06-content/targets_content.txt"; then
  while read -r u; do
    tag=$(echo "$u" | sed -E 's#https?://##; s#[/:]#_#g')
    log "content: $u"
    katana -u "$u" -jc -jsl -d 3 -silent -rl "$RL" -o "$OUT/06-content/${tag}_urls.txt"
    grep -Ei '\.js(\?|$)' "$OUT/06-content/${tag}_urls.txt" | sort -u > "$OUT/06-content/${tag}_js.txt"
    while read -r f; do jsluice urls "$f"; done < "$OUT/06-content/${tag}_js.txt" \
      | jq -r '.url' 2>/dev/null | sort -u >> "$OUT/06-content/endpoints.txt"
  done < "$OUT/06-content/targets_content.txt"
fi

log "done. 输出在 $OUT"
