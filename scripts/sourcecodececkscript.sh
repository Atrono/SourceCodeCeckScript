#!/bin/bash

# Temporäre Dateien
path=/tmp
err=$path/err.tmp
html=$path/html.tmp
css=$path/css.tmp
php=$path/php.tmp
js=$path/js.tmp
link=$path/link.tmp

fqdn=`hostname --fqdn`
dir=`pwd | cut -c34-`
url=$fqdn$dir

# Variablen
exitStatus=0	#Speichert exit [0|1|2]


if [ $1 = "" ];then
	"Es wurde kein Parameter eingegeben {-help|-html|-css|-php|-js|-link}"
	exit 1
fi

while test $# -gt 0; do
        case "$1" in
                -h|--help)
			shift
                        echo "
			****************************
			***         Hilfe        ***
			****************************"
			echo "Author: Atrono"
			echo "Last change: 21.02.2014"
			echo 
			echo "Das script hat die Aufgabe anhand der Parameter, die datein in dem jeweils befindlichen Ordner zu Prüfen."
			echo "Es ermöglicht die Überprüfung von HTML, XHTML, XML, CSS, PHP, JavaScript und Links(Linkchecker)."
			echo 
			echo "Befehlsübersicht:"
			echo 
			echo "	-h | --help	Hilfe"
			echo 
			echo "	-html		Mithilfe von dem Kommandozeilen-Programm Tidy wird hier die Syntax von HTML/XHTML/XML überprüft."
			echo 
			echo "	-css		Blablabla"
			echo
			echo "	-php		bla"
			echo
			echo "	-js		joooo"
			echo
			echo "	-link		gut!"
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

			if [ -s $html ];then
        	                htmlFiles=`wc -l < $html`
	                        htmlError=0

				for i in `cat $html`; do
					echo "---"
					echo "Teste $i"
					tidy  -eq $i

					if [ "$?" == "2" ];then
                                                exitStatus="2"
                                                htmlError=`expr $htmlError + 1`
                                        fi
                                done
                                rm $html
                                echo "- HTML	($htmlError von $htmlFiles)" >> $err

			else
				echo "Es existiert keine HTML/XHTML/XML-Datei"
			fi
		;;
                -css)
			shift
                        echo "
			****************************
			***     CSS-Validator    ***
			****************************"
			find -name *.CSS -or -name *.css > $css

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
				echo "Es existiert keine HTML-Datei."
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
				echo "Es existiert keine PHP-Datei."
			fi
		;;
                -js)
			shift
                        echo "
			****************************
			***       JS-JSHint      ***
			****************************"
                        find -name *.JS -or -name *.js > $js

                        if [ -s $js ];then
                        	jsFiles=`wc -l < $js`
                        	jsError=0

                                for i in `cat $js`; do
                                        echo "---"
                                        echo "$i"
                                        jshint --config /root/scripts/jshint.conf $i
					#jshint --white $i
                                        if [ "$?" == "2" ];then
                                                exitStatus="2"
                                                jsError=`expr $jsError + 1`
                                        fi
                                done
                                rm $js
                                echo "- JS	($jsError von $jsFiles)" >> $err
                        else
                                echo "Es existiert keine JS-Datei."
                        fi
		;;
                -link)
			shift
                        echo "
			****************************
			***      Linkchecker     ***
			****************************"
                        sudo -u nobody linkchecker  --complete --no-warnings http://$url

			
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