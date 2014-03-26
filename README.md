#SourceCodeCeckScript

This script was created for continuous integration in use with [GitLab-ci](https://github.com/gitlabhq/gitlab-ci) and [GitLab-ci-runner](https://github.com/gitlabhq/gitlab-ci-runner).

###What does the Script:
* Copy the branch to the /var/www/project-xx/commitID
* Create automaticaly vHost with subdomain(d37f83hsf.example.com)
* Check the syntax from the sourcecode
* Check the link's with a linkchecker from the subdomain
* exclude files
* JSHint config file

###The following source code is supported:
* HTML(XHTML, XML) 
* CSS
* PHP
* JavaScript

###How to Install the Script?
First you install on GitLab-ci-runner the following programs which requires the script:
* tidy (for html and css)
* php5
* JSHint
* Linkchecker
* apache2 
After you have install the programms you need to download the script. After you have download it, give it executable rights.

###How you use the Script?
You go into GitLab-ci, to the project you whant to check, go on Settings and insert on Build steps the path to the script with the options.

#####Example
    /root/scripts/SourceCodeCheckScript.sh -js -link

#####Script parameters:
    SourceCodeCheckScript.sh {--help | -html | -css | -php | -js | link}

#####Exclude files
    ./ci-test/testignore
Each line on this file is exclude from the test

#####JSHint Setting file
    ./ci-test/jshint.conf
In this file are the settings for the JSHint program which is used for the Tests.

#####Informations:
Actual the script only work with Ubuntu perfectly.

---
Copyright 2014 Atrono

Licensed under the GPLv3: http://www.gnu.org/licenses/gpl-3.0.html
