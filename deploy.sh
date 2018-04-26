#!/usr/bin/env bash

function deploy_infra() {

    proj=$1
    oc new-project $proj

    # deploy catalog and inventory
    oc policy add-role-to-user view -n $proj -z default
    oc process -f catalog-template.yaml | oc create -f -

    # deploy web
    oc new-build --name web --image nodejs:8 --strategy source --binary
    oc start-build web --from-dir=web-nodejs --follow
    oc new-app web
    oc expose svc/web
}

# vertx catalog
deploy_infra coolstore-vertx
mvn -f gateway-vertx clean package fabric8:deploy

# spring catalog
deploy_infra coolstore-spring
mvn -f gateway-spring clean package fabric8:deploy

# put load on spring
# ab -n 500000 -c 10 http://gateway-coolstore-spring.apps.127.0.0.1.nip.io/api/products
# then access http://web-coolstore-spring.apps.127.0.0.1.nip.io

# put load on vertx
# ab -n 500000 -c 10 http://gateway-coolstore-vertx.apps.127.0.0.1.nip.io/api/products
# then access http://web-coolstore-vertx.apps.127.0.0.1.nip.io
