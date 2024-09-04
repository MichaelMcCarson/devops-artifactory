#!/usr/bin/env bash
set -eu
set +o history

#########################
######### NOTES #########
#########################

# This is a trivial load test to test auto-scaling and see how much of a load the servers can handle.

# Make sure to pass in the -e flag for the environment.
# -e Options: Local | Development | Staging | Production

# run from package.json like "yarn local:env Development"

#########################
######### SETUP #########
#########################

ENVIRONMENT=''
CONCURRENCY=''
RPS=''
URL_TO_TEST=''

# Get flags passed into script
while getopts :e:c:r: opt; do
  case "$opt" in
    e)
      ENVIRONMENT=$OPTARG
      ;;
    c)
      CONCURRENCY=$OPTARG
      ;;
    r)
      RPS=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

case $ENVIRONMENT in

  "Local")
    URL_TO_TEST="http://localhost:3000/auth/institutions?text=SOMETEXT"
    ;;

  "Development")
    URL_TO_TEST="https://development.some.app/auth/institutions?text=SOMETEXT"
    ;;

  "Staging")
    URL_TO_TEST="https://staging.some.app/auth/institutions?text=SOMETEXT"
    ;;

  "Production")
    URL_TO_TEST="https://production.some.app/auth/institutions?text=SOMETEXT"
    ;;

  *)
    echo "Th -e flag (environment) with a provided value is required"
    exit 1
    ;;
esac

echo "Testing endpoint $URL_TO_TEST"

yarn loadtest -c $CONCURRENCY --rps $RPS $URL_TO_TEST
