#!/usr/bin/env bash
set -eu
set +o history

#########################
######### NOTES #########
#########################

###### BACKGROUND #######
# This script requires the aws cli to be installed.
# This script registers an AWS Elastic Compute service (ECS) as a scalable target with AWS's Application Auto Scaling system and uploads a scaling policy to AWS for that service with the specified dimension and scaling policy configuration; meaning that ECS resources need to scale to handle an increased number of requests and an increased workload then a scaling policy is needed.
# This script should only need to be run once on a resource.
# Example command "./create-auto-scaling-policy.sh -r us-east-1 -c staging -s some-integration-service -o 60 -t 75 -l 1 -u 4"
# If you have issues executing the file, remember to run "chmod +x create-auto-scaling-policy.sh" from the cloud directory.
# Example script from package.json "yarn cloud:create:scaling-policy -c staging -s some-integration-service"
# The cluster and service are abstracted from the yarn script because they change the most frequently.

###### DOCS ######
# https://docs.aws.amazon.com/autoscaling/application/userguide/create-step-scaling-policy-cli.html
# https://aws.amazon.com/premiumsupport/knowledge-center/ecs-fargate-service-auto-scaling/

###### POST RUNNING ######
# After running, make sure to tag the resources created. (This can be stored in a variable then grepped to automate the belowm but is left for a future revision.)
# Example:
# aws cloudwatch tag-resource \
# --resource-arn arn:aws:cloudwatch:us-east-1:1234567890:alarm:TargetTracking-service/staging/some-integration-service-google-AlarmHigh-852d1f50-5a62-4bb1-9b6c-a075e55f5b8f \
# --tags Key=Name,Value=some-integration-service-google-tracking-scaling-policy-staging-high-alarm \
# Key=name,Value=some-integration-service-google-tracking-scaling-policy-high-alarm \
# Key=environment,Value=staging \
# Key=createdDate,Value=2022-05-05	 \
# Key=application,Value=some-integration-service-google \
# Key=applicationRole,Value=monitoring	 \
# Key=version,Value=1 \
# Key=region,Value=us-east-1

###### FLAGS EXPLAINED ######
# -r = region (ex. us-east-1)               |  -s = service name
# -t = target value (ex. 75.0)              |  -l = min capacity (lower bound ex. 1)
# -c = cluster (ex. staging)                |  -u = max capacity (upper bound ex. 10)
# -o = scale cooldown (optimized ex. 60)

#########################
######### SETUP #########
#########################

REGION=''
TARGET_VALUE=''
CLUSTER_NAME=''
SERVICE_NAME=''
MIN_CAPACITY=''
MAX_CAPACITY=''
SCALE_COOLDOWN=''

# Get flags passed into script
while getopts :r:t:c:s:l:u:o: opt; do
  case "$opt" in
    r)
      REGION=$OPTARG
      ;;
    t)
      TARGET_VALUE=$OPTARG
      ;;
    c)
      CLUSTER_NAME=$OPTARG
      ;;
    s)
      SERVICE_NAME=$OPTARG
      ;;
    l)
      MIN_CAPACITY=$OPTARG
      ;;
    u)
      MAX_CAPACITY=$OPTARG
      ;;
    o)
      SCALE_COOLDOWN=$OPTARG
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

if [[ -z $REGION || -z $SERVICE_NAME || -z $CLUSTER_NAME ||
  -z $TARGET_VALUE || -z $MIN_CAPACITY || -z $MAX_CAPACITY ||
  -z $SCALE_COOLDOWN ]]; then
  echo 'ERROR: One or more variables are undefined. 
HINT: Did you forget to add -c and -s dynamically while using yarn cloud:create:scaling-policy?!'
  exit 1
fi

echo "Region is set to $REGION"
echo "Service Name is set to $SERVICE_NAME"
echo "Cluster Name is set to $CLUSTER_NAME"
echo "Target Value is set to $TARGET_VALUE"
echo "Minimum Capacity is set to $MIN_CAPACITY"
echo "Maximum Capacity is set to $MAX_CAPACITY"
echo "Scale Cooldown is set to $SCALE_COOLDOWN"

#########################
## INTERNAL  VARIABLES ##
#########################

SERVICE_NAMESPACE="ecs"
SCALABLE_DIMENSION="ecs:service:DesiredCount"
RESOURCE_ID="service/$CLUSTER_NAME/$SERVICE_NAME"
POLICY_NAME="$SERVICE_NAME-$CLUSTER_NAME-tracking-scaling-policy"
POLICY_TYPE="TargetTrackingScaling"
TARGET_TRACKING_SCALING_POLICY_CONFIG="{ \"TargetValue\": $TARGET_VALUE, \"PredefinedMetricSpecification\": { \"PredefinedMetricType\": \"ECSServiceAverageCPUUtilization\" }, \"ScaleOutCooldown\": $SCALE_COOLDOWN, \"ScaleInCooldown\": $SCALE_COOLDOWN }"

#########################
########## RUN ##########
#########################

aws application-autoscaling register-scalable-target \
  --service-namespace $SERVICE_NAMESPACE --scalable-dimension $SCALABLE_DIMENSION \
  --resource-id $RESOURCE_ID \
  --min-capacity $MIN_CAPACITY --max-capacity $MAX_CAPACITY --region $REGION

echo "Registered Scalable Targets for cluster: $CLUSTER_NAME, service: $SERVICE_NAME"

aws application-autoscaling put-scaling-policy \
  --service-namespace $SERVICE_NAMESPACE --scalable-dimension $SCALABLE_DIMENSION \
  --resource-id $RESOURCE_ID \
  --policy-name $POLICY_NAME --policy-type $POLICY_TYPE \
  --target-tracking-scaling-policy-configuration "$TARGET_TRACKING_SCALING_POLICY_CONFIG"
