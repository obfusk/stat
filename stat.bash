#!/bin/bash

# --

if ! ( [ "$#" -eq 2 ] || [ "$#" -eq 1 -a "$1" == '--test' ] ); then
  echo 'Usage: stat { <from> <to> | --test }' >&2
  exit 1
fi

from="$1"
  to="$2"
test=no

[ "$#" -eq 1 ] && from=FROM to=TO test=yes

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
  log_h "System"
  {
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
    log_c aptitude -s safe-upgrade
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

function send () {                                              # {{{1
  if [ "$test" == yes ]; then less; else sendmail -t; fi
}                                                               # }}}1

# --

[ "$( id -u )" -eq 0 ] && aptitude update

# --

{                                                               # {{{1
   sed 's!^    !!' <<__END
    From: $from
    To: $to
    Subject: status of $host @ $date

__END

  system
  packages
  filesystems
  network

} | send                                                        # }}}1

# --
