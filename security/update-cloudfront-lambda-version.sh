#!/bin/bash
set -xeuo pipefail

# This script updates the cloudfront headers after you create a new version of the lambda@edge function for some-company-set-security-headers
# Example: ./update-cloudfront-lambda-version.sh -d ABC1IB1LY3KID9 -n some-company-set-security-headers -r us-east-1
# where ABC1IB1LY3KID9 is the id for cloudfront, namely dev in this example,
# some-company-set-security-headers is the lambda function,
# and us-east-1 is the region that the cloudfront and lambda reside in. The region is an optional parameter.

# You may need to run chmod u+x ./update-cloudfront-lambda-version.sh

REGION="us-east-1"

# Get flags passed into script
while getopts :r:d:n: opt; do
  case "$opt" in
    r)
      REGION=$OPTARG
      ;;
    d)
      DISTRIBUTION_ID=$OPTARG
      ;;
    n)
      FUNCTION_NAME=$OPTARG
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

if [[ -z $DISTRIBUTION_ID || -z $FUNCTION_NAME ]]; then
  echo 'ERROR: One or more variables are undefined. 
HINT: Did you forget to add -d and -n dynamically while using yarn update-headers?!'
  exit 1
fi

echo "DISTRIBUTION_ID is set to $DISTRIBUTION_ID"
echo "FUNCTION_NAME is set to $FUNCTION_NAME"
echo "REGION is set to $REGION"

readonly LAMBDA_ARN=$(
  aws lambda list-versions-by-function \
    --function-name "$FUNCTION_NAME" \
    --region "$REGION" \
    --query "max_by(Versions, &to_number(to_number(Version) || '0'))" \
    | jq -r '.FunctionArn'
)

readonly ORIGINAL_FILE=$(mktemp)
readonly MODIFIED_FILE=$(mktemp)

aws cloudfront get-distribution-config \
  --id "$DISTRIBUTION_ID" \
  > "$ORIGINAL_FILE"

readonly ETAG=$(jq -r '.ETag' < "$ORIGINAL_FILE")

cat "$ORIGINAL_FILE" \
  | jq '(.DistributionConfig.DefaultCacheBehavior | .LambdaFunctionAssociations.Items[] | select(.EventType=="origin-response") | .LambdaFunctionARN ) |= "'"$LAMBDA_ARN"'"' \
  | jq '.DistributionConfig' \
    > "$MODIFIED_FILE"

# The Distribution Config requires exact specifications with the formatting, etc. so it's better to store in a temp file.
aws cloudfront update-distribution \
  --id "$DISTRIBUTION_ID" \
  --distribution-config "file://$MODIFIED_FILE" \
  --if-match "$ETAG"

rm -f "$ORIGINAL_FILE" "$MODIFIED_FILE"
