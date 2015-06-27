#!/bin/bash
set -e


declare RUN=0
declare EXIT_CODE=255
declare PID
declare SYSLOG_PID

postfix_check() {
    [ -d /var/lib/postfix/ ] || mkdir -p /var/lib/postfix/
    [ 'postfix:postfix' = `stat -c %U:%G /var/lib/postfix/` ] || chown postfix:postfix /var/lib/postfix/

    [ -d /var/spool/postfix/ ] || mkdir -p /var/spool/postfix/
    [ 'root:root' = `stat -c %U:%G /var/spool/postfix/` ] || chown root:root /var/spool/postfix/

    /usr/sbin/postfix check
}

postfix_start() {
    log "Starting the Postfix mail system"
    /usr/lib/postfix/master "$@" & PID=$!
    RUN=1
}

postfix_stop() {
    log "Stopping the Postfix mail system"
    kill -s TERM ${PID}
    wait ${PID}
    RUN=0
    log "Stopped the Postfix mail system"
}

postfix_reload() {
    log "Reloading the Postfix mail system"
    kill -s HUP ${PID}
}

postfix_abort() {
    log "Aborting the Postfix mail system"
    kill -s ABRT ${PID}
    wait ${PID}
    RUN=0
    log "Aborted the Postfix mail system"
}

syslog_start() {
    /bin/busybox syslogd -nSO /dev/stdout & SYSLOG_PID=$!
}

syslog_stop() {
    kill -s TERM ${SYSLOG_PID}
}

log() {
    local priority="${2:-mail.info}" message="${1}"
    logger -t "entrypoint[$$]" -p "${priority}" "${message}"
}

install_signals() {
    trap 'postfix_reload' HUP
    trap 'postfix_abort' ABRT
    trap 'postfix_stop' INT TERM QUIT
}

process_wait() {
    set +e

    while [ 1 -eq ${RUN} ] && ps ${PID} > /dev/null; do
        wait ${PID}
        EXIT_CODE=$?
    done
}

if [[ $# -lt 1 ]] || [[ "$1" == "-"* ]]; then
    syslog_start
    postfix_check
    postfix_start "$@"

    install_signals
    process_wait
    syslog_stop

    exit ${EXIT_CODE}
elif [ "$1" = 'postfix-check' ]; then
    syslog_start
    postfix_check
    syslog_stop
else
    exec "$@"
fi
