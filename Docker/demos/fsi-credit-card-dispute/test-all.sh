#!/usr/bin/env bash
export ENTANDO_IMAGE_VERSION=${1:-5.0.3-SNAPSHOT}

function cleanup(){
    docker-compose -f docker-compose-qa.yml down &>/dev/null
    docker volume rm fsi-credit-card-dispute_entando-admin-volume &>/dev/null
    docker volume rm fsi-credit-card-dispute_entando-customer-volume &>/dev/null
    docker network rm fsi-credit-card-dispute_entando-network &>/dev/null
}

cleanup


docker-compose -f docker-compose-qa.yml up -d || { echo "Could not bring down docker containers"; exit 1; }
timeout 180 ./wait-for-engine.sh || { echo "Timed out waiting for Engines"; exit 1; }

docker run --rm --network=fsi-credit-card-dispute_entando-network -e ENTANDO_APPBUILDER_URL=http://admin-appbuilder:5000  \
    entando/entando-smoke-tests:$ENTANDO_IMAGE_VERSION mvn verify -Dtest=org.entando.selenium.smoketests.STAddTestUserTest \
    || {  echo "The 'AddUser' test failed on Admin"; exit 1;  }

sleep 10

docker run --rm --network=fsi-credit-card-dispute_entando-network -e ENTANDO_APPBUILDER_URL=http://customer-appbuilder:5000  \
    entando/entando-smoke-tests:$ENTANDO_IMAGE_VERSION mvn verify -Dtest=org.entando.selenium.smoketests.STAddTestUserTest \
    || {  echo "The 'AddUser' test failed on Customer"; exit 1;  }


docker-compose -f docker-compose-qa.yml down || { echo "Could not bring down docker containers"; exit 1; }
docker-compose -f docker-compose-qa.yml up -d || { echo "Could not spin up docker containers"; exit 1; }

timeout 180 ./wait-for-engine.sh || { echo "Timed out waiting for Engines"; exit 1; }

docker run --rm --network=fsi-credit-card-dispute_entando-network -e ENTANDO_APPBUILDER_URL=http://admin-appbuilder:5000 \
    entando/entando-smoke-tests:$ENTANDO_IMAGE_VERSION mvn verify -Dtest=org.entando.selenium.smoketests.STLoginWithTestUserTest \
    || {  echo "The 'Login' test failed on Admin"; exit 1;  }
sleep 10

docker run --rm --network=fsi-credit-card-dispute_entando-network -e ENTANDO_APPBUILDER_URL=http://customer-appbuilder:5000 \
    entando/entando-smoke-tests:$ENTANDO_IMAGE_VERSION mvn verify -Dtest=org.entando.selenium.smoketests.STLoginWithTestUserTest \
    || {  echo "The 'Login' test failed on Customer"; exit 1;  }

cleanup

echo "Entando FSI Credit Card Dispute tests successful"
exit 0