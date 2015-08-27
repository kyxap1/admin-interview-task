#!/usr/bin/env bash
# 
# Generate vhosts configuration
# OS: Linux
# CLI args: none

set -e

LANG=C
PATH="/bin:/usr/sbin:/usr/bin:/sbin:/usr/local/bin:/usr/local/sbin"
DATE=$(date +%F)

WORKDIR="/home/http/nest.pro-manage.net/html/krasnodar"
TMPLDIR="tmpl"
JINJA_TMPL="$TMPLDIR/nginx.j2"
DOMAINS_LIST="$WORKDIR/domains.list"
DOMAINS_SSL="$WORKDIR/domains_ssl.list"
DOMAINS_DDOS="$WORKDIR/ddos.list"
ACCOUNTS_SUSPENDED="$WORKDIR/suspend.list"
LOG="$WORKDIR/process.log"

#########################

print_error() { echo "$@" >&2; write_log "[ERROR] $@"; exit 1; }
print_info()  { echo "$@"; write_log "[INFO] $@" || exit 1; }
write_log()   { echo "$(date -R -u) $@" >> "$LOG"; }

#########################

# j2cli required ( https://github.com/kolypto/j2cli )
[[ -f `which j2 2>/dev/null` ]] && JINJA="j2 --format env" || print_error "No j2 binary found in $PATH"

#########################

#print_info "Started generation"

[[ -d $WORKDIR ]] || print_error "No source dir: $WORKDIR"

# read domains
while read accname homedir domainname
do
	export ACCOUNT="$accname" DOCROOT="$homedir" DOMAIN="$domainname" BACKEND=1

	if DDOS=$(grep -vE "^(#|$|\s)" "$DOMAINS_DDOS" | grep -wo "$domainname")
	then
		export DDOS BACKEND=
	fi

	if SUSPENDED=$(grep -vE "^(#|$|\s)" "$ACCOUNTS_SUSPENDED" | grep -wo "$accname")
	then
		export SUSPENDED BACKEND=
	fi

	if SSL=$(grep -vE "^(#|$|\s)" "$DOMAINS_SSL" | grep -w "$domainname")
	then
		export SSL SSL_REDIRECT=$(echo $SSL | awk '{print $2}')
	fi

	export ACCOUNT DOCROOT DOMAIN BACKEND DDOS SUSPENDED SSL SSL_REDIRECT

	$JINJA "$JINJA_TMPL"

done < <( grep -vE "^(#|$|\s)" "$DOMAINS_LIST" )

#print_info "Finished generation"
