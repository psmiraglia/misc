#!/bin/bash
#
# The MIT License (MIT)
#
# Copyright (c) 2015 Paolo Smiraglia <paolo.smiraglia@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# COLORS
__RESET="\e[0m"
__CYAN_BFG="\e[1;36m"
__CYAN_NFG="\e[0;36m"
__RED_BFG="\e[1;31m"
__RED_NFG="\e[0;31m"
__GREEN_BFG="\e[1;32m"
__GREEN_NFG="\e[0;32m"
__YELLOW_BFG="\e[1;33m"
__YELLOW_NFG="\e[0;33m"
__PURPLE_BFG="\e[1;35m"
__PURPLE_NFG="\e[0;35m"
__BLUE_BFG="\e[1;34m"
__BLUE_NFG="\e[0;34m"
__WHITE_BFG="\e[1;37m"
__WHITE_NFG="\e[0;37m"
__RED_BG="\e[41m"

# SETTINGS
# This will enable/disbale timestamp printing. Accepted values are 1 (enable)
# 0 (disable). Default value 0.
__LOG_WITH_TS=${LOG_WITH_TS:-0}
# This defines the TIMESPEC for ISO-8601 timestamp. Accepted values are
# 'date', 'hours', 'minutes', 'seconds' or 'ns'. Default value is 'seconds'.
__LOG_TS_FORMAT=${LOG_TS_FORMAT:-"seconds"}
# This will enable/disbale daemon mode. If enabled, messages will be forwarded
# to the system logegr via 'logger'. Accepted values are 1 (enable)
# 0 (disable). Default value 0.
__LOG_AS_DAEMON=${LOG_AS_DAEMON:-0}
# This defnies the daemon's name that will be used ad tag (-t).
# Default value is 'noname'.
__LOG_DAEMON_NAME=${LOG_DAEMON_NAME:-"noname"}
# This defnies messages' threshold. Accepted values are 0 (emerg), 1 (alert),
# 2 (critical), 3 (error), 4 (warning), 5 (notice), 6 (info) and 7 (debug).
# Default value is 6 (info).
__LOG_THRESHOLD=${LOG_THRESHOLD:-6}
# This defines the syslog's facility if in daemon mode. Accepted values are
# those defined in "FACILITIES AND LEVELS" section for 'logger' man page.
# Default value is 'local0'.
__LOG_FACILITY=${LOG_FACILITY:-"local0"}

# Below and example about how to use that library
#
# #!/bin/bash
#
# LOG_WITH_TS=1
# LOG_TS_FORMAT="ns"
# LOG_AS_DAEMON=0
# LOG_THRESHOLD=7
# . ./log.sh
#
# _success "Quisque ac purus scelerisque, egestas nisl ut, euismod risus"
# _failure "Quisque ac purus scelerisque, egestas nisl ut, euismod risus"
# _debug "Quisque ac purus scelerisque, egestas nisl ut, euismod risus"
# _info "Quisque ac purus scelerisque, egestas nisl ut, euismod risus"
# _warn "Quisque ac purus scelerisque, egestas nisl ut, euismod risus"
# _err "Quisque ac purus scelerisque, egestas nisl ut, euismod risus"
# _emerg "Quisque ac purus scelerisque, egestas nisl ut, euismod risus"


# logging helpers
function _log {
    level=$1

    if [ $__LOG_WITH_TS -eq 0 ] || [ $__LOG_AS_DAEMON -eq 1 ]; then
        raw_msg="$2"
    else
        ts=`date --iso-8601=$__LOG_TS_FORMAT`
        raw_msg="$ts - $2"
    fi

    tag=""
    msg="$raw_msg"
    syslog_level="info"
    case $level in
        debug)
            tag="${__CYAN_BFG}*${__RESET}"
            msg="${__CYAN_NFG}${raw_msg}${__RESET}"
            syslog_level="$level"
            threshold=7
            ;;
        info)
            tag="${__WHITE_BFG}*${__RESET}"
            msg="${__WHITE_NFG}${raw_msg}${__RESET}"
            syslog_level="$level"
            threshold=6
            ;;
        warning)
            tag="${__YELLOW_BFG}*${__RESET}"
            msg="${__YELLOW_NFG}${raw_msg}${__RESET}"
            syslog_level="$level"
            threshold=4
            ;;
        err)
            tag="${__RED_BFG}*${__RESET}"
            msg="${__RED_NFG}${raw_msg}${__RESET}"
            syslog_level="$level"
            threshold=3
            ;;
        emerg)
            tag="${__WHITE_BFG}${__RED_BG}*${__RESET}"
            msg="${__WHITE_BFG}${__RED_BG}${raw_msg}${__RESET}"
            syslog_level="err"
            threshold=0
            ;;
        success)
            tag="${__GREEN_BFG}*${__RESET}"
            msg="${__GREEN_NFG}${raw_msg}${__RESET}"
            syslog_level="info"
            threshold=5
            ;;
        failure)
            tag="${__RED_BFG}*${__RESET}"
            msg="${__RED_NFG}${raw_msg}${__RESET}"
            syslog_level="err"
            threshold=5
            ;;
        *)
            ;;
    esac

    if [ $__LOG_THRESHOLD -ge $threshold ]; then
        if [ $__LOG_AS_DAEMON -eq 0 ]; then
            echo -e "(${tag}) $msg"
        else
            logger -i -p ${__LOG_FACILITY}.${syslog_level} \
                -t $__LOG_DAEMON_NAME "$raw_msg"
        fi
    fi
}

# syslog related
function _debug {
    msg=$1
    _log "debug" "$msg"
}

function _info {
    msg=$1
    _log "info" "$msg"
}

function _warn {
    msg=$1
    _log "warning" "$msg"
}

function _err {
    msg=$1
    _log "err" "$msg"
}

function _emerg {
    msg=$1
    _log "emerg" "$msg"
}

# custom (mapped on syslog levels)
function _success {
    msg=$1
    _log "success" "$msg"
}

function _failure {
    msg=$1
    _log "failure" "$msg"
}
