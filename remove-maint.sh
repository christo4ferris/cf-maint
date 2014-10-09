#!/bin/bash

DOMAIN="mybluemix.net"
APP=myapp
if [ ! $# -gt 0 ]; then
  echo "Usage: $0 appname [domain]"
  exit 1
elif [ ! $# -lt 3 ]; then
  echo "Usage: $0 appname [domain]"
  exit 1
elif [ ! $# == 2 ]; then
  APP=$1
else
  APP=$1
  DOMAIN=$2
fi
cf app $APP > /dev/null 2>&1
if [ "$?" == "1" ]; then
    echo "$APP not running... exiting"
    exit 1
fi
echo "removing $APP from maintennce mode ..."
cf app maint > /dev/null 2>&1
if [ "$?" == "1" ]; then 
    echo "starting maintenance mode app ..."
    cf push maint -b https://github.com/cloudfoundry-community/nginx-buildpack.git -m 8M -k 8M
fi
cf app maint
if [ "$?" == "1" ]; then
    echo "failed to start maintenance mode app"
    exit 1
  else
    echo "mapping routes ..."
    cf unmap-route maint $DOMAIN -n $APP
    cf unmap-route $APP $DOMAIN -n m-$APP
    cf map-route $APP $DOMAIN -n $APP
    echo "restarting $APP..."
    cf restart maint
    cf restart $APP
fi
