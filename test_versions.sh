#!/usr/bin/env bash

# Tests that the employees database can work with all versions of MySQL
# 
# Requires dbdeployer to be installed and configured (https://www.dbdeployer.com)

function found_in_path {
    name=$1
    for dir in $(echo $PATH | tr ':' ' ')
    do
        if [ -x $dir/$name ]
        then
            echo $dir/$name
            return
        fi
    done
}


function check_exit_code {
    exit_code=$?
    if [ "$exit_code" != "0" ]
    then
        echo "Execution error"
        exit $exit_code
    fi
}

dbdeployer=$(found_in_path dbdeployer)

if [ -z "$dbdeployer" ]
then
    echo "dbdeployer not found in \$PATH"
    exit 1
fi

[ -z "$SANDBOX_HOME" ] && SANDBOX_HOME=$HOME/sandboxes

for short_version in 5.0 5.1 5.5 5.6 5.7 8.0
do
    version=$($dbdeployer info version $short_version)
    if [ -z "$version" ]
    then
        continue
    fi
    echo "### -------------------"
    echo "### $version"
    echo "### -------------------"
    ver_name=$(echo $version | tr '.' '_')
    
    $dbdeployer deploy single $version
    check_exit_code

    msb=$SANDBOX_HOME/msb_$ver_name

    if [ ! -d $msb ]
    then
        echo "'$msb' not found or not a directory - Halting test"
        exit 1
    fi

    $msb/use < employees.sql 
    check_exit_code
    echo "Testing MD5"
    $msb/use -t < test_employees_md5.sql >  /tmp/test_md5.txt
    md5_ok=$(grep -iw ok /tmp/test_md5.txt | wc -l | tr -d ' \t')

    if [ "$md5_ok" == "8" ]
    then
        echo "MD5 OK - $md5_ok"
    else
        echo "MD5 FAIL - expected 8 - found $md5_ok"
        cat /tmp/test_md5.txt
        exit 1
    fi

    echo "Testing SHA"
    $msb/use -t < test_employees_sha.sql >  /tmp/test_sha.txt
    sha_ok=$(grep -iw ok /tmp/test_sha.txt | wc -l | tr -d ' \t')
    if [ "$sha_ok" == "8" ]
    then
        echo "SHA OK - $sha_ok"
    else
        echo "SHA FAIL - expected 8 - found $sha_ok"
        cat /tmp/test_sha.txt
        exit 1
    fi

    $dbdeployer delete msb_$ver_name
    check_exit_code

done

