#!/bin/bash
# 자동 배포 워처: 이 폴더가 바뀌면 감지해서 자동으로 commit+push
REPO_DIR="$HOME/Sites/dongyunique-ops.github.io"
LOG="$REPO_DIR/.deploy/watch.log"
cd "$REPO_DIR" || exit 1

echo "[$(date '+%F %T')] 워처 시작됨" >> "$LOG"

while true; do
  if [ -n "$(git status --porcelain)" ]; then
    SUSPECT=$(git status --porcelain | awk '{print $2}' | while read -r f; do
      [ -f "$f" ] && grep -lEi 'api[_-]?key|apikey|secret|password|ghp_[A-Za-z0-9]|github_pat_[A-Za-z0-9]|sk-[A-Za-z0-9]{10,}|AKIA[0-9A-Z]{16}|BEGIN (RSA |EC )?PRIVATE KEY' "$f" 2>/dev/null
    done)

    if [ -n "$SUSPECT" ]; then
      echo "[$(date '+%F %T')] 경고: 민감정보 의심 패턴 발견 - 자동 push 건너뜀:" >> "$LOG"
      echo "$SUSPECT" >> "$LOG"
    else
      git add -A
      git commit -m "auto: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG" 2>&1
      if git push >> "$LOG" 2>&1; then
        echo "[$(date '+%F %T')] push 완료" >> "$LOG"
      else
        echo "[$(date '+%F %T')] push 실패 - 네트워크 등 확인 필요" >> "$LOG"
      fi
    fi
  fi
  sleep 15
done
