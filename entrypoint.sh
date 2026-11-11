#!/bin/sh
ssh-keygen -A

# Ctrl-C(SIGINT) や docker stop(SIGTERM) を受け取ったら sshd を終了させる
terminate_sshd() {
    kill -TERM "$sshd_pid" 2>/dev/null
}
trap terminate_sshd INT TERM

/usr/sbin/sshd -D -e "$@" &
sshd_pid=$!

# シグナルで wait が中断されても、sshd が実際に終了するまで待ち続ける
while kill -0 "$sshd_pid" 2>/dev/null; do
    wait "$sshd_pid"
done
