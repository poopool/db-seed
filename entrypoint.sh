#!/bin/bash

BB_BRANCH=${BB_BRANCH:-master}

apt-get update
apt-get install -y openssl libc-dev gcc git netcat jq

while true
do
  rethinkdb_svc_status=$(nc -z rethinkdb 29015; echo $?)
  rabbitmq_svc_status=$(nc -z rabbitmq 5672; echo $?)
  if [ $rethinkdb_svc_status -ne 0 ] || [ $rabbitmq_svc_status -ne 0 ]
  then
    echo "waiting for rethinkdb and rabbitmq services to become available..."
    echo "sleeping for 5s..."
    sleep 5
  else
    break
  fi
done

mkdir -p /app/apl_common

pip install https://applariat:$BB_API_KEY@bitbucket.org/applariat/apl-common/get/$BB_BRANCH.zip
pip install https://applariat:$BB_API_KEY@bitbucket.org/applariat/apl-db-utils/get/$BB_BRANCH.zip

git clone -b $BB_BRANCH https://applariat:$BB_API_KEY@bitbucket.org/applariat/apl-common.git /app/apl_common

export PYTHONPATH=/app

cd /app/apl_common

echo 'Seeding DB now...'
python - <<-EOF
PROJECT_ROOT='/app'
from db_utils import db_utils
db_utils.main()
EOF
echo 'Done Seeding DB...'

if [ $RUN_TEST = true ]
then
  echo "RUN_TEST flag is set, going to run tester.sh script..."
  git clone https://applariat:$BB_API_KEY@bitbucket.org/applariat/automated-testing
  cd automated-testing/
  bash -x tester.sh
fi