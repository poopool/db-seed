#!/bin/bash

BB_BRANCH=${BB_BRANCH:-master}

apt-get update
apt-get install -y openssl libc-dev gcc git netcat

while ! nc -z rethinkdb 29015
do
  echo "rethinkdb svc is not up yet, going to sleep for 5s..."
  sleep 5
done

while ! nc -z rabbitmq 5672
do
  echo "rabbitmq svc is not up yet, going to sleep for 5s..."
  sleep 5
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