#!/bin/bash

source /home/tim_dzik/jenkins/config.sh

function hipchat {
	COLOR=$1
	MESSAGE=$2

 curl -H "Content-Type: application/json" \
	     -X POST \
	     -d "{\"color\": \"$COLOR\", \"message_format\": \"text\", \"message\": \"$MESSAGE\" }" \
	     https://api.hipchat.com/v2/room/$HIPCHAT_ROOM_ID/notification?auth_token=$HIPCHAT_AUTH_TOKEN
}

function setupServing {
	#statements
	echo "hey you"
}

function setupProcessing {
	#statements
	echo "hey you"
}

function setupIngestion {
	#statements
	echo "hey you"
}

# printenv  <- to print env variable
# hipchat 'random' 'Starting Jenkins deployment'
echo "Stage 1 - Checkout to Develop + Security Checking"

git checkout develop
git pull origin develop


COMMIT_LAST_5MINS="$(git rev-list --all --since=5.minutes --count --branches=develop)"
echo ${COMMIT_LAST_5MINS}

LAST_COMMIT="$(git log -n 1 --pretty=format:%H)"
echo ${LAST_COMMIT}

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
echo ${CURRENT_BRANCH}



LAST_COMMIT_ANSIBLE="$(git log -n 1 --pretty=format:%H -- src/deployment)"

echo "NUMBER_OF_COMMIT_LAST_5MINS = ${COMMIT_LAST_5MINS}"

if [[ "$NUMBER_OF_COMMIT_LAST_5MINS" -ge 1 ]]; then
	hipchat 'purple' 'We found 2 commits made to Develop the last 5 mins, we force a 300secs sleep'
	sleep 3
else
	hipchat 'purple' 'No other commit were made the last 5 mins. Building ongoing...'
fi


# Step2: supposed to run a bunch of test if test fails we DONT deploy
# and redeploy to the last "stable commit"
echo "Stage 2 - Testing code // Unit testing"
hipchat 'purple' 'Stage 2 - Testing code // Unit testing'
hipchat 'purple' 'Well we dont have unit test yet bro'


# X We triggered Ansible changes and now we will test which building we fire :
# 	- Adding new host to staging Ingestion = Redeploy ansibles
# 			modification in src/deployment/ingestion but NOT host
# 	- Adding new host to Processing = Redeploy ansibles
# 			modification in src/deployment/processing but NOT host
# 	- Adding new host to Serving = Redeploy ansibles
# 			modification in src/deployment/serving but NOT host
# 	- Changing an Ansible config in Ingestion = Redeploy Ansible on all hosts
# 			modification in src/deployment/ingestion/staging
# 	- Changing an Ansible config in Processing = Redeploy Ansible on all hosts
# 			modification in src/deployment/processing/staging
# 	- Changing an Ansible config in Serving = Redeploy Ansible on all hosts
# 			modification in src/deployment/serving/staging
# X Changes in src/ingestion = run an Ansible to ONLY deploy
# X Changes in src/processing = run an Ansible to ONLY deploy
# X Changes in src/serving = run an Ansible to ONLY deploy
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 	Finally we will just test which repo in deployment has been
# 	change and rerun everything
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "Stage 3 - Running Ansible Environment"
hipchat 'purple' 'Stage 3 - Running Ansible Environment'

if [[ "$LAST_COMMIT" == "$LAST_COMMIT_ANSIBLE" ]]; then
	echo "Fireing Ansible changes --  will rerun the whole shit"

	LAST_COMMIT_ANSIBLE_INGESTION="$(git log -n 1 --pretty=format:%H -- src/deployment/ingestion)"
	echo ${LAST_COMMIT_ANSIBLE_INGESTION}

	LAST_COMMIT_ANSIBLE_PROCESSING="$(git log -n 1 --pretty=format:%H -- src/deployment/processing)"
	echo ${LAST_COMMIT_ANSIBLE_PROCESSING}

	LAST_COMMIT_ANSIBLE_SERVING="$(git log -n 1 --pretty=format:%H -- src/deployment/serving)"
	echo ${LAST_COMMIT_ANSIBLE_SERVING}

	if [[ "$LAST_COMMIT" == "$LAST_COMMIT_ANSIBLE_SERVING" ]]; then
		setupServing
	elif [[ "$LAST_COMMIT" == "$LAST_COMMIT_ANSIBLE_PROCESSING" ]]; then
		setupProcessing
	elif [[ "$LAST_COMMIT" == "$LAST_COMMIT_ANSIBLE_INGESTION" ]]; then
		setupIngestion
	else
		hipchat 'purple' 'Commit : doesnt contain any Ansible changes, skipping this stage! *dab*'
	fi

fi

# Stage 4: Deploying the tested code
echo "Stage 4 - Deploy"
hipchat 'purple' 'Stage 4 - Deploy"'

LAST_COMMIT_INGESTION="$(git log -n 1 --pretty=format:%H -- src/ingestion)"
echo ${LAST_COMMIT_INGESTION}

LAST_COMMIT_PROCESSING="$(git log -n 1 --pretty=format:%H -- src/processing)"
echo ${LAST_COMMIT_PROCESSING}

LAST_COMMIT_SERVING="$(git log -n 1 --pretty=format:%H -- src/deployment/serving)"
echo ${LAST_COMMIT_ANSIBLE_SERVING}

if [[ "$LAST_COMMIT" == "$LAST_COMMIT_INGESTION" ]]; then
	deployIngestion
elif [[ "$LAST_COMMIT" == "$LAST_COMMIT_PROCESSING" ]]; then
	deployProcessing
elif [[ "$LAST_COMMIT" == "$LAST_COMMIT_SERVING" ]]; then
	deployServing
elif [[ "$LAST_COMMIT" != "$LAST_COMMIT_INGESTION" && "$LAST_COMMIT" != "$LAST_COMMIT_PROCESSING" && "$LAST_COMMIT" != "$LAST_COMMIT_SERVING" ]]; then
	hipchat 'PURPLE' "No changes so no deployment"
fi

echo "Stage 5 - Running Crossbrowser"
echo "We will run Crossbrowser Celenium test here and if the error is too big rollback bitch"


echo "Stage 6 - Send HipChat report"
