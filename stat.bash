#!/bin/bash

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
    memory
    echo "$( ls -d /proc/[0-9]* 2>/dev/null | wc -l ) processes"
  } | sed 's!^!  !'
  log_f
}                                                               # }}}1

function packages () {                                          # {{{1
# log_c aptitude safe-upgrade -s                                # TODO

  if [ -f /var/run/reboot-required ]; then
    log_c cat /var/run/reboot-required
  else
    echo -e '(no reboot required)\n'
  fi
}                                                               # }}}1

function filesystems () {                                       # {{{1
  log_c df -h $( mount | grep ^/dev | cut -d' ' -f1 )
}                                                               # }}}1

function network () {                                           # {{{1
  log_c ifconfig
}                                                               # }}}1

# --

# aptitude update                                               # TODO

# --

{                                                               # {{{1
   sed 's!^    !!' <<__END
    From:     felixstegerman@noxqslabs.nl
    To:       felixstegerman@noxqslabs.nl
    Subject:  status of $host @ $date

__END

  system
  packages
  filesystems
  network

} # | sendmail -t                                               # TODO
                                                                # }}}1

# --
