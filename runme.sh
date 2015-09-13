#!/usr/bin/env bash
# 
# Generate vhosts configuration
# OS: Linux
# CLI args: none

set -e

LANG=C
PATH="/bin:/usr/sbin:/usr/bin:/sbin:/usr/local/bin:/usr/local/sbin"
DATE=$(date +%F)

WORKDIR="/home/http/nest.pro-manage.net/html/krasnodar/task"
CONFDIR="$WORKDIR/data"
TMPLDIR="$WORKDIR/tmpl"
JINJA_TMPL="$TMPLDIR/nginx.j2"
DOMAINS_LIST="$CONFDIR/domains.list"
DOMAINS_SSL="$CONFDIR/domains_ssl.list"
DOMAINS_DDOS="$CONFDIR/ddos.list"
ACCOUNTS_SUSPENDED="$CONFDIR/suspend.list"
LOG="$WORKDIR/process.log"

#########################

print_error() { echo "$@" >&2; write_log "[ERROR] $@"; exit 1; }
print_info()  { echo "$@"; write_log "[INFO] $@" || exit 1; }
write_log()   { echo "$(date -R -u) $@" >> "$LOG"; }
catf()	      { [[ -f $@ ]] && grep -vE "^(#|$|\s)" "$@" || print_error "File can not be read: $@"; }

#########################

# j2cli required ( https://github.com/kolypto/j2cli )
[[ -f `which j2 2>/dev/null` ]] && JINJA="j2 --format env" || print_error "No j2 binary found in $PATH"

#########################

#print_info "Started generation"

[[ -d $WORKDIR ]] || print_error "No source dir: $WORKDIR"

# read domains
while read accname homedir domainname
do
	export ACCOUNT="$accname" DOCROOT="$homedir/$domainname" DOMAIN="$domainname"
	export SUSPENDED= SSL= SSL_REDIRECT= DDOS=
	export BACKEND=1

	if RES=( $(catf "$DOMAINS_DDOS" | grep -w "$domainname") )
	then
		export DDOS="${RES[0]}" BACKEND=
	fi

	if RES=( $(catf "$ACCOUNTS_SUSPENDED" | grep -w "$accname") )
	then
		export SUSPENDED="${RES[0]}" LOCALE="${RES[1]%_*}" BACKEND=
	fi

	if RES=( $(catf "$DOMAINS_SSL" | grep -w "$domainname") )
	then
		export SSL="${RES[0]}" SSL_REDIRECT="${RES[1]}"
	fi

	$JINJA "$JINJA_TMPL"

done < <( catf "$DOMAINS_LIST" ) > conf/vhosts.conf

#print_info "Finished generation"
