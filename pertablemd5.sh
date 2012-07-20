#!/bin/sh
SCRIPT_NAME=`basename $0`
AUTH="-uroot -ppasswd"
OPTIONS="--no-data --skip-lock-tables --skip-dump-date --skip-comments" 
[ $# -ne 3 ] && echo "USAGE: ${SCRIPT_NAME} <master> <slave> <schema>" && exit 1 
MASTER=$1
SLAVE=$2
DATABASE=$3

[ -z "${TMPDIR}" ] && TMPDIR="/tmp"
mkdir -p ${TMPDIR}

[ -z `which mysql 2>/dev/null` ] && echo "ERROR: mysql not found in the PATH" && exit 1

HAVE_DIFF="FALSE"
for TABLE in `mysql ${AUTH} -h${MASTER} -e "SELECT table_name FROM information_schema.tables WHERE table_schema = '${DATABASE}'"  |grep -vi "^TABLE_NAME" |uniq`
do
  mysqldump ${AUTH} -h${MASTER} ${OPTIONS} --database ${DATABASE} --table $TABLE --result-file=${TMPDIR}/master.${DATABASE}.${TABLE}.sql
  MASTER_MD5=`cat ${TMPDIR}/master.${DATABASE}.${TABLE}.sql | md5sum`
  mysqldump ${AUTH} -h${SLAVE} ${OPTIONS} --database ${DATABASE} --table $TABLE --result-file=${TMPDIR}/slave.${DATABASE}.${TABLE}.sql
  SLAVE_MD5=`cat ${TMPDIR}/slave.${DATABASE}.${TABLE}.sql | md5sum`
  [ "${MASTER_MD5}" != "${SLAVE_MD5}" ] && echo "${DATABASE}.${TABLE} is different" && HAVE_DIFF="TRUE"
done

[ "${HAVE_DIFF}" = "TRUE" ] && echo "You can view individual differences with $ diff ${TMPDIR}/*.DATABASE.TABLE.sql" 

exit 0
