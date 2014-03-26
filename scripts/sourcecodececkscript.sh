#!/bin/bash

# Created by Damian Fürbach on 26.03.2014.
# Copyright (c) 2014 Damian Fürbach. All rights reserved.

# path to Temporary Data
tmpPath=/tmp

# Temporary Data
err=$tmpPath/err.tmp
html=$tmpPath/html.tmp
css=$tmpPath/css.tmp
php=$tmpPath/php.tmp
js=$tmpPath/js.tmp
link=$tmpPath/link.tmp
tmp=$tmpPath/tmp.tmp

# Dir variables
project=${PWD##*/}

# Config variables
jsConfig=.ci-test/jshint.conf
testIgnor=.ci-test/testignore

# vHost variables
fqdn=`hostname --fqdn`
cname=`cut -c1-9 .git/ORIG_HEAD`
dir=/var/www/$project/$cname

# Status variables
exitStatus=0

# Ceck if parameter entered
if [ $1 = "" ];then
	"There was no parameter entered {--help|-html|-css|-php|-js|-link}"
	exit 1
fi

# Copy Commit to /var/www/project-XX/commit
if [ -s $dir ];then
	rm -R $dir/*
	mv * $dir
else
	mkdir -p $dir
	mv * $dir
fi

# crate vHost
echo "
			****************************
			***     vHost script     ***
			****************************"

if [ -s /etc/apache2/sites-available/$cname.$fqdn.conf ];then
	echo "vhost für $cname.$fqdn, existiert bereits!"
else
	echo "vhost für $cname.$fqdn, existiert noch nicht."
	mkdir /var/log/$cname.$fqdn/
echo "#### $cname.$fqdn
<VirtualHost *:80>
	ServerName $fqdn
	ServerAlias $cname.$fqdn
	DocumentRoot $dir
	<Directory $dir>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Order allow,deny
		allow from all
	</Directory>
</VirtualHost>" > /etc/apache2/sites-available/$cname.$fqdn.conf
	sudo ln -s /etc/apache2/sites-available/$cname.$fqdn.conf /etc/apache2/sites-enabled/$cname.$fqdn.conf
	echo "Testing configuration"
	service apache2 configtest
	service apache2 restart
fi


# change dir
cd $dir

# Commands
while test $# -gt 0; do
        case "$1" in
        	-h|--help)
			shift
            echo "
			****************************
			***         Hilfe        ***
			****************************"
			echo "Author: Damian Fürbach"
			echo
			echo "Here you get Help..."
			echo		
			exit 0
		;;
        	-html)
			shift
			echo "
			****************************
			***     HTML-Validator   ***
			****************************"
			find -name *.HTML -or -name *.XHTML -or -name *.XML -or -name *.html -or -name *.xhtml -or -name *.xml > $html
			grep -vxf $testIgnor $html > $tmp
			mv $tmp $html

			if [ -s $html ];then
        	                htmlFiles=`wc -l < $html`
	                        htmlError=0

				for i in `cat $html`; do
					echo "---"
					echo "try $i"
					tidy  -eq $i

					if [ "$?" == "2" ];then
						exitStatus="2"
                        htmlError=`expr $htmlError + 1`
					fi
				done
                rm $html
                echo "- HTML	($htmlError from $htmlFiles)" >> $err

			else
				echo "There is no HTML / XHTML / XML file"
			fi
		;;
			-css)
			shift
            echo "
			****************************
			***     CSS-Validator    ***
			****************************"
			find -name *.CSS -or -name *.css > $css
			grep -vxf $testIgnor $css > $tmp
			mv $tmp $css

			if [ -s $css ];then
				cssFiles=`wc -l < $css`
	            cssError=0
		
				for i in `cat $css`; do
                    echo "---"
					echo "$i"
	                tidy  -eq $i
                        	
				        if [ "$?" == "2" ];then                              
							exitStatus="2"
							cssError=`expr $cssError + 1`
				    	fi
	        	done
				rm $css
				echo "- CCS	($cssError von $cssFiles)" >> $err
			else
				echo "There is no CSS file"
			fi
		;;
            -php)
			shift
			echo "
			****************************
			***      PHP-Syntax      ***
			***        checker       ***
			****************************"
			find -name *.PHP -or -name *.php > $php
			grep -vxf $testIgnor $php > $tmp
			mv $tmp $php

			if [ -s "$php" ];then
                phpFiles=`wc -l < $php`
				phpError=0

				for i in `cat $php`; do
					echo "---"
	            	echo "$i"
					php -l $i
                                	
					if [ "$?" == "2" ];then
            	        exitStatus="2"
						phpError=`expr $phpError + 1`
					fi
		        done
				rm $php
		        echo "- PHP	($phpError von $phpFiles)" >> $err
			else
				echo "There is no PHP file"
			fi
		;;
                -js)
			shift
            echo "
			****************************
			***       JS-JSHint      ***
			****************************"
			find -name *.JS -or -name *.js > $js
			grep -vxf $testIgnor $js > $tmp
			mv $tmp $js

			if [ -s $js ];then
				jsFiles=`wc -l < $js`
				jsError=0

                for i in `cat $js`; do
					echo "---"
                    echo "$i"
                    jshint --config $jsConfig $i

					if [ "$?" == "2" ];then
						exitStatus="2"
						jsError=`expr $jsError + 1`
					fi
		         done
				rm $js
				echo "- JS	($jsError von $jsFiles)" >> $err
	        else
				echo "There is no JavaScript file"
	        fi
		;;
			-link)
			shift
            echo "
			****************************
			***      Linkchecker     ***
			****************************"
			sudo -u nobody linkchecker  --complete --no-warnings http://$cname.$fqdn
		;;
		*)
			shift
			echo "Usage: $0 {-help|-html|-css|-php|-js|-link}"
			exit 1
        esac
done

echo ""
if [ -s $err ];then
	echo "In folgenden Prüfvorgängen haben (n) Dateien Fehler"
	cat $err
	rm $err
    rm $url
fi
echo ""
echo "*** end of script ***"
exit $exitStatus