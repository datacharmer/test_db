#!/bin/bash

MYSQL=$1

if [ -z "$MYSQL" ]
then
    echo "Syntax: $0 mysql_connection "
    echo "Where 'mysql_connection is your client invocation"
    echo "Examples:"
    echo "      mysql # (when using \$HOME/.my.cnf)"
    echo "      'mysql -u something -psomepass -P3307'"
    echo "      'mysql --defaults-file=/some/path/my.cnf'"
    echo "      \$HOME/sandboxes/msb_5_7_9/use"
    echo ""
    exit 1
fi

EXPECTED=(
departments:9:3737256214
dept_emp:331603:1015881734
dept_manager:24:2275236704
employees:300024:610052939
salaries:2844047:4273816835
titles:443308:1842528371
)

function get_expected
{
    table=$1
    field=$2
    for E in ${EXPECTED[*]}
    do
        t=$(echo $E | tr ':' ' ' | awk '{print $1}')
        count=$(echo $E | tr ':' ' ' | awk '{print $2}')
        crc=$(echo $E | tr ':' ' ' | awk '{print $3}')
        if [ "$t" == "$table" ]
        then
           if [ "$field" == "count" ]
           then
               echo $count
           else
               echo $crc
           fi 
           return
        fi
    done
}

printf "%-15s %-10s     %-15s \n" table count crc
echo '--------------- ----------     ---------------'
for T in $($MYSQL -BN -e 'show tables from employees') 
do 
    CRC_TEXT=$($MYSQL -BN -e "checksum table $T" employees)
    COUNT=$($MYSQL -BN -e "select count(*) from $T" employees)
    CRC=$(echo $CRC_TEXT | awk '{print $2}')
    expected_crc=$(get_expected $T crc)
    expected_count=$(get_expected $T count)
    if [ "$expected_count" == "$COUNT" ]
    then
        COUNT_RESULT=OK
    else
        COUNT_RESULT=DIFFERS
    fi
    if [ "$expected_crc" == "$CRC" ]
    then
        CRC_RESULT=OK
    else
        CRC_RESULT=DIFFERS
    fi
    printf "%-15s %'10d     %'15d (%-7s %-7s)\n" $T $COUNT $CRC $COUNT_RESULT $CRC_RESULT
done

