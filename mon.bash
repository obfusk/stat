#!/bin/bash

d="$( date +'%F %T' )"
h="$( hostname )"

# --

function log_h () { echo "=== $1 ==="; echo; }
function log_f () { echo; echo; }
function log_c () { log_h "$@"; "$@" | sed 's!^!  !'; log_f; }

# --

function upgrade_req () {
  if [ -f /var/run/reboot-required ]; then
    log_c cat /var/run/reboot-required
  else
    echo "(no reboot required)"
  fi
}

function memory () {
while read tok val unit; do
		case "$tok" in
			MemTotal:) total=${val};;
			MemFree:) free=${val};;
			Buffers:) buffers=${val};;
			Cached:) cached=${val};;
		esac
		[ -n "${free}" -a -n "${total}" -a -n "${buffers}" -a -n "${cached}" ] && break;
	done < /proc/meminfo}

# --

# aptitude update

# --

{
  cat <<__END | sed 's!^    !!'
    From:     felixstegerman@noxqslabs.nl
    To:       felixstegerman@noxqslabs.nl
    Subject:  status of $h @ $d

__END

  devs="$( mount | grep ^/dev | cut -d' ' -f1 )"

  log_h "System"
  {
    uname -a
    lsb_release -s -d
    uptime
  } | sed 's!^!  !'
  log_f

  log_c df -h $devs

# log_c aptitude safe-upgrade -s

} # | sendmail -t
