:

cd `dirname "$0"`

. ./server_variables.sh

if [ ! -d '../backups' ]; then
  mkdir ../backups
  if [ $? -ne 0 ]; then 
    echo 'ERROR: problems creating ../backups'
    exit 10
  fi
fi

mysqldump -u "${HCC_DATABASE_USERNAME}" --password="${HCC_DATABASE_PASSWORD}" \
  "${HCC_DATABASE_TABLE}" \
  > ../backups/${HCC_DATABASE_TABLE}.`date '+%Y%m%d%H%M%S'`.sql

