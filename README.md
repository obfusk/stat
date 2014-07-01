[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2014-07-01

    Copyright   : Copyright (C) 2013  Felix C. Stegerman
    Version     : 0.4.2

[]: }}}1

## Description
[]: {{{1

  stat - server status (cron job)

  The stat cron job uses stat.bash to generate a server status report,
  which is then sent per email using mailer [2].

  The report contains information about hostname, date/time, uname,
  lsb release, uptime, processes, memory, swap, updates, filesystems,
  network interfaces, and (selected) services.

  NB: currently, stat is used only on Ubuntu servers; it should also
  work on Debian, although the reboot-required check may not.

[]: }}}1

## Usage
[]: {{{1

  First, install mailer [2].

    $ mkdir -p /opt/src
    $ git clone https://github.com/noxqsgit/stat.git /opt/src/stat
    $ cp -i /opt/src/stat/stat.cron.sample /etc/cron.daily/stat
    $ vim /etc/cron.daily/stat
    $ chmod +x /etc/cron.daily/stat

[]: }}}1

## License
[]: {{{1

  GPLv3+ [1].

[]: }}}1

## References
[]: {{{1

  [1] GNU General Public License, version 3
  --- http://www.gnu.org/licenses/gpl-3.0.html

  [2] mailer
  --- https://github.com/noxqsgit/mailer

[]: }}}1

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
