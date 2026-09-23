#!/bin/zsh
notify() { osascript -e "display notification \"$1\" with title \"Docker\""; }
# macOS has no `timeout`, and docker (Go) ignores SIGALRM: background it and SIGKILL on deadline
alive() {
  docker info >/dev/null 2>&1 & local pid=$!
  for _ in {1..$1}; do kill -0 $pid 2>/dev/null || { wait $pid; return; }; sleep 1; done
  kill -9 $pid 2>/dev/null; return 1
}

pgrep -qf 'Docker.app' || { echo "Docker Desktop not running"; exit 0; }

# --check (launchd): notify only, after 3 consecutive failures to avoid busy/booting false positives
if [[ $1 == --check ]]; then
  state=$TMPDIR/docker-unstick.fails
  alive 15 && { rm -f $state; exit 0; }
  fails=$(( $(cat $state 2>/dev/null || echo 0) + 1 ))
  echo $fails > $state
  (( fails == 3 )) && notify "Looks stuck — run docker-unstick"
  exit 0
fi

alive 15 && { echo "Docker OK"; exit 0; }

echo "Docker stuck, killing"
pkill -9 -f 'Docker.app|com.docker'
sleep 3
open -a Docker

for _ in {1..36}; do
  alive 5 && { notify "Restarted, up ✅"; echo up; exit 0; }
  sleep 5
done
notify "Restart FAILED ❌"; echo "restart failed" >&2; exit 1
