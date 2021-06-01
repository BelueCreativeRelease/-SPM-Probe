#!/bin/bash
#
# spmscan
# ver. 1.0  2021-05-11 OpenSource version.

#
# Copyright (c) 2021 Belue Creative,Inc.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or any later version.This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.You should have received a copy of the GNU General Public License
# along with this program. If not, see http://www.gnu.org/licenses/.
#

#
#   main
#
SPMSCAN_VERSION='1.0'

export LANG=C

# init variables
set -u
SCANLOGDIR=scanlog
OUTPUTFNAME=scanlog

OSTYPE="O"
# DU: Debian/Ubuntu
# C: CentOS
# R: Red Hat
# O: Other
#
#COLUMNS_BAK=$COLUMNS


# RootCheck
#
#if [ `id -u` != 0 ] ; then
#    echo "Error! Run by root "
#    exit 1
#fi

if [ ! -d $SCANLOGDIR ]; then
    mkdir $SCANLOGDIR
fi

#
# OS Platform check
#
ls /etc/debian_version > $SCANLOGDIR/ls_etc_debian_version 2>&1 ; echo $? > $SCANLOGDIR/ls_etc_debian_version.exit
#
if(( `cat $SCANLOGDIR/ls_etc_debian_version.exit` == 0  )) ; then
    #
    # Debian Distro/Ubuntu
    #
    echo Debian/Ubuntu
    #
    # make Debian files
    OSTYPE="DU"
    #
    cat /etc/debian_version > $SCANLOGDIR/cat_etc_debian_version 2>&1 ; echo $? > $SCANLOGDIR/cat_etc_debian_version.exit
    #
    cat /etc/issue > $SCANLOGDIR/cat_etc_issue 2>&1 ; echo $? > $SCANLOGDIR/cat_etc_issue.exit
    #
    lsb_release -ir > $SCANLOGDIR/lsb_release-ir 2>&1 ; echo $? > $SCANLOGDIR/lsb_release-ir.exit
    #
else
    #
    # Red Hat/CentOS & others
    #
    echo Red Hat/CentOS
    #
    # make CentOS files
    OSTYP="C"
    #
    ls /etc/os-release > $SCANLOGDIR/ls_etc_os_release 2>&1 ; echo $? > $SCANLOGDIR/ls_etc_os_release.exit
    if(( `cat $SCANLOGDIR/ls_etc_os_release.exit` == 0  )) ; then
        cat /etc/os-release > $SCANLOGDIR/cat_etc_os_release 2>&1 ; echo $? > $SCANLOGDIR/cat_etc_os_release.exit
    fi
    #
    ls /etc/fedora-release > $SCANLOGDIR/ls_etc_fedora-release 2>&1 ; echo $? > $SCANLOGDIR/ls_etc_fedora-release.exit
    if(( `cat $SCANLOGDIR/ls_etc_fedora-release.exit` == 0  )) ; then
        cat /etc/fedora-release > $SCANLOGDIR/cat_etc_fedora-release 2>&1 ; echo $? > $SCANLOGDIR/cat_etc_fedora-release.exit
    fi
    #
    ls /etc/oracle-release > $SCANLOGDIR/ls_etc_oracle-release 2>&1 ; echo $? > $SCANLOGDIR/ls_etc_oracle-release.exit
    if(( `cat $SCANLOGDIR/ls_etc_oracle-release.exit` == 0  )) ; then
        cat /etc/oracle-release > $SCANLOGDIR/cat_etc_oracle-release 2>&1 ; echo $? > $SCANLOGDIR/cat_etc_oracle-release.exit
    fi
    #
    ls /etc/redhat-release > $SCANLOGDIR/ls_etc_redhat-release 2>&1 ; echo $? > $SCANLOGDIR/ls_etc_redhat-release.exit
    if(( `cat $SCANLOGDIR/ls_etc_redhat-release.exit` == 0  )) ; then
        cat /etc/redhat-release > $SCANLOGDIR/cat_etc_redhat-release 2>&1 ; echo $? > $SCANLOGDIR/cat_etc_redhat-release.exit
    fi
    #
    yum -h 2>&1 | grep assumeno > $SCANLOGDIR/yum-h_grep_assumeno 2>&1 ; echo $? > $SCANLOGDIR/yum-h_grep_assumeno.exit
    #
    rpm -q yum-plugin-changelog > $SCANLOGDIR/rpm-q_yum-plugin-changelog 2>&1 ; echo $? > $SCANLOGDIR/rpm-q_yum-plugin-changelog.exit
    #
fi

#
# AWS instance check
#
#
type curl > $SCANLOGDIR/type_curl 2>&1 ; echo $? > $SCANLOGDIR/type_curl.exit
#
if (( `cat $SCANLOGDIR/type_curl.exit` == 0 )) ; then
    curl --max-time 1 --retry 3 --noproxy 169.254.169.254 http://169.254.169.254/latest/meta-data/instance-id > $SCANLOGDIR/curl_aws_instamce 2>&1 ; echo $? > $SCANLOGDIR/curl_aws_instamce.exit
#
else
#
    type wget > $SCANLOGDIR/type_wget 2>&1 ; echo $? > $SCANLOGDIR/type_wget.exit
    wget --tries=3 --timeout=1 --no-proxy -q -O - http://169.254.169.254/latest/meta-data/instance-id > $SCANLOGDIR/wget_aws_instamce 2>&1 ; echo $? > $SCANLOGDIR/wget_aws_instamce.exit
fi
#

#
# OS Packages check
#
if [ $OSTYPE == "DU" ] ; then
    #
    # Debian/Ubuntu
    #

    #
    cat /etc/lsb-release > $SCANLOGDIR/cat_etc_lsb-release 2>&1 ; echo $? > $SCANLOGDIR/cat_etc_lsb-release.exit
    #
    test -f /usr/bin/aptitude > $SCANLOGDIR/test-f_usr_bin_aptitude 2>&1 ; echo $? > $SCANLOGDIR/test-f_usr_bin_aptitude.exit
    #

    #
    dpkg-query -W > $SCANLOGDIR/dpkg-query-W 2>&1 ; echo $? > $SCANLOGDIR/dpkg-query-W.exit
    #
    echo dpkg-query
    #

    #
    sudo -S apt-get update > $SCANLOGDIR/sudo-S_apt-get_update 2>&1 ; echo $? > $SCANLOGDIR/sudo-S_apt-get_update.exit
    #
    echo sudo -S apt-get update
    #

    #
    LANGUAGE=en_US.UTF-8 apt-get upgrade --dry-run > $SCANLOGDIR/apt-get-upgrade--dry-run ; echo $? > $SCANLOGDIR/apt-get-upgrade--dry-run.exit
echo apt-get upgrade --dry-run
    #

    #
    # make package list
    cat $SCANLOGDIR/apt-get-upgrade--dry-run | sed -ne '1,/^The following packages will be upgraded\:/d ; p' | sed -e '/^[0-9].*upgraded\./,$d' > $SCANLOGDIR/apt-get-upgrade--dry-run_packagelist 2>&1 ; echo $? > $SCANLOGDIR/apt-get-upgrade--dry-run_packagelist.exit
    #
    echo apt-get-upgrade--dry-run_packagelist
    #

    LANGUAGE=en_US.UTF-8 apt-cache policy `cat $SCANLOGDIR/apt-get-upgrade--dry-run_packagelist` > $SCANLOGDIR/apt-cache_policy_packagelist 2>&1 ; echo $? > $SCANLOGDIR/apt-cache_policy_packagelist.exit
    #

    for pname in `cat $SCANLOGDIR/apt-get-upgrade--dry-run_packagelist` ; do
        PAGER=cat apt-get -q=2 changelog $pname > $SCANLOGDIR/apt-get-q_2_changelog.$pname 2>&1 ; echo $? > $SCANLOGDIR/apt-get-q_2_changelog.$pname.exit
    done;
else
#
# Red Hat/CentOS
#
    LANG=C rpm -qa --queryformat '%{NAME}   %{EPOCH}  %{VERSION}  %{RELEASE}\n' > $SCANLOGDIR/rpm-qa 2>&1 ; echo $? > $SCANLOGDIR/rpm-qa.exit

    LANG=C yum list installed --color=never --quiet > $SCANLOGDIR/yum_list_installed 2>&1 ; echo $? > $SCANLOGDIR/yum_list_installed.exit

    #
    #
    #cd $SCANLOGDIR
    #script -c 'LANGUAGE=en_US.UTF-8 yum --color=never  check-update ; echo $? > yum_check-update.exit' yum_check-update_
    #cat yum_check-update_ | sed -ne '2,$p' | sed -e '$d' > yum_check-update
    #
    #cd - > /dev/null 2>&1
    #
fi

# Get OS version
uname -r > $SCANLOGDIR/uname-r 2>&1 ; echo $? > $SCANLOGDIR/uname-r.exit
uname -m > $SCANLOGDIR/uname-m 2>&1 ; echo $? > $SCANLOGDIR/uname-m.exit
uname -p > $SCANLOGDIR/uname-p 2>&1 ; echo $? > $SCANLOGDIR/uname-p.exit
cat /proc/version  > $SCANLOGDIR/cat-proc-version 2>&1 ; echo $? > $SCANLOGDIR/cat-proc-version.exit

# Output SPMScan Version
echo "$SPMSCAN_VERSION" > $SCANLOGDIR/spmscan_version

#
# SSL Reports
#

# OpenSSL
which openssl >$SCANLOGDIR/which-openssl 2>&1 
echo $? > $SCANLOGDIR/openssl.exit

if [ `cat $SCANLOGDIR/openssl.exit` = '1' ] ; then
    echo "Not exist openssl on this system." > $SCANLOGDIR/openssl.txt
else
    #
    openssl version > $SCANLOGDIR/openssl-version.txt
    openssl ciphers > $SCANLOGDIR/openssl-ciphers.txt
    
    #
    sslscan_p443='false'
    which netstat > $SCANLOGDIR/which-netstat 2> $SCANLOGDIR/which-netstat.err
    errcode=$?
    if [[ $errcode = 0 ]] ; then 
        netstat -tln | grep 'tcp .* 0.0.0.0:443 .* LISTEN' > $SCANLOGDIR/netstat-tl-443.log
        echo $? > $SCANLOGDIR/netstat-tl-443.exit
        if [ `cat $SCANLOGDIR/netstat-tl-443.exit` = '0' ] ; then
            sslscan_p443='true'
        fi
    fi
    #
    which ss > $SCANLOGDIR/which-ss 2> $SCANLOGDIR/which-ss.err
    errcode=$?
    if [[ $errcode = 0 ]] ; then 
        ss -tln | grep --color=no 'LISTEN .* \*:443' > $SCANLOGDIR/ss-tl-443.log
        echo $? > $SCANLOGDIR/ss-tl-443.exit
        if [ `cat $SCANLOGDIR/ss-tl-443.exit` = '0' ] ; then
            sslscan_p443='true'
        fi
    fi
    #
    if $sslscan_p443 = 'true' ; then
        # check tcp:443 127.0.0.1:443 
        (echo HEAD HTTP/1.0 ; echo )| openssl s_client -ssl3 -state -host 127.0.0.1 -port 443 > $SCANLOGDIR/openssl-connect-localhost443.log 2>$SCANLOGDIR/openssl-connect-localhost443.err
    fi

fi
#
OUTPUT_ARCHIVE=$OUTPUTFNAME.`date +%Y%m%d_%H%M%S`.tar.gz
tar czf $OUTPUT_ARCHIVE $SCANLOGDIR

if [ $? -ne 2 ]; then
    echo "Generated $OUTPUT_ARCHIVE"
#    rm -r $SCANLOGDIR
else
    echo 'Sorry, maybe generation failed.'
fi

# EOF
