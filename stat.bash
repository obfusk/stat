#!/bin/bash

# --                                                            ; {{{1
#
# File        : stat.bash
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-05-06
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# Description : Sets MAILER_SUBJECT, pipes output to "$@".
#
# --                                                            ; }}}1

set -e

if [ "$#" -ne 0 ]; then cmd=( "$@" ); else cmd=( cat ); fi

# --

date="$( date +'%F %T' )"
host="$( hostname )"

# --

function log_h () { echo -e "=== $@ ===\n"; }
function log_f () { echo -e '\n'; }
function log_c () { log_h "$@"; "$@" | sed 's!^!  !'; log_f; }

# --

function memory () {                                            # {{{1
  local total free buffers cached
  local sw_total sw_free sw_cached
  local tok val unit n=0 m s

  while read tok val unit; do
    case "$tok" in
     MemTotal:)       total="$val"; (( ++n )) ;;
     MemFree:)         free="$val"; (( ++n )) ;;
     Buffers:)      buffers="$val"; (( ++n )) ;;
     Cached:)        cached="$val"; (( ++n )) ;;
     SwapTotal:)   sw_total="$val"; (( ++n )) ;;
     SwapFree:)     sw_free="$val"; (( ++n )) ;;
     SwapCached:) sw_cached="$val"; (( ++n )) ;;
    esac
    (( n >= 7 )) && break
  done < /proc/meminfo

  m="$(( (100 * (total - free - buffers - cached)) / total ))"
  s="$(( (100 * (sw_total - sw_free - sw_cached)) / sw_total ))"

  printf 'memory: %s%%, swap: %s%%\n' "$m" "$s"                 # ????
}                                                               # }}}1

function system () {                                            # {{{1
  log_h System
  {
    echo "$host @ $date"
    uname -a
    lsb_release -s -d
    echo
    uptime
    echo "$( ls -d /proc/[0-9]* 2>/dev/null | wc -l ) processes"
    memory
  } | sed 's!^!  !'
  log_f
}                                                               # }}}1

function packages () {                                          # {{{1
  if [ "$( id -u )" -eq 0 ]; then
    # aptitude -F%p --disable-columns search \~U
    log_c aptitude -s safe-upgrade < /dev/null
  else
    echo -e '(not root -- skipping package updates check)\n\n'
  fi

  if [ -f /var/run/reboot-required ]; then
    log_c cat /var/run/reboot-required
  else
    echo -e '(no reboot required)\n\n'
  fi
}                                                               # }}}1

function filesystems () {                                       # {{{1
  log_c df -h $( mount | grep ^/dev | cut -d' ' -f1 )
}                                                               # }}}1

function network () {                                           # {{{1
  log_c ifconfig
}                                                               # }}}1

function services () {                                          # {{{1
  local x
  for x in $STAT_SERVICES; do
    log_c service "$x" status
  done
}                                                               # }}}1

# --

[ "$( id -u )" -eq 0 ] && aptitude update

# --

{ system ; packages ; filesystems ; network ; services
} | MAILER_SUBJECT="status of $host @ $date" "${cmd[@]}"

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
