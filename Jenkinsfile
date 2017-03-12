#!groovy
//  Grab the master Jenkinsfile

import hudson.model.*
import hudson.EnvVars
import groovy.json.JsonSlurperClassic
import groovy.json.JsonBuilder
import groovy.json.JsonOutput
import java.net.URL

node {
	//basically stage 1 plays with git, and set the git environment
	stage '1 - Checkout to Develop + Security Checking'
		//notifying HipChat that we begin the job
		// notifyHipChatBegin()

		//grabbing the right git repository
		git url: "https://github.com/TimDzik/test-jenkins"



		//  Checkouting to develop
		sh "git checkout develop"
		//  Pulling develop branch
		sh "git pull origin develop"

		/******************************************************
			Declaring all my variable from sh command line
			(most of them to grab git infos)
		*******************************************************/


		//  Grab the number of commit for the last 5 mins
		NUMBER_OF_COMMIT_LAST_5MINS = sh (
			script: "git rev-list --all --since=5.minutes --count --branches=develop",
			returnStdout: true
		).toInteger()

		//  Grab the last commit id
		LAST_COMMIT = sh (
			script: "git log -n 1 --pretty=format:%H",
			returnStdout: true
		)

		//  Grab the current branch name
		CURRENT_BRANCH = sh (
			script: "git rev-parse --abbrev-ref HEAD",
			returnStdout: true
		)

		//  Grab the last commit id which modified stuff in src/deployment
		LAST_COMMIT_ANSIBLE = sh (
			script: "git log -n 1 --pretty=format:%H -- src/deployment",
			returnStdout: true
		)

		echo "NUMBER_OF_COMMIT_LAST_5MINS = ${NUMBER_OF_COMMIT_LAST_5MINS}"

		//  If we had more than 1 commit for the last 5 mins we delay the build of 300secs
		if (NUMBER_OF_COMMIT_LAST_5MINS > 1) {
			echo "We found 2 commits made to Develop the last 5 mins, we force a 300secs sleep"
			sh "sleep 300"
		}else {
			echo "No other commit were made the last 5 mins. Building ongoing..."
		}

		echo "your current branch ${CURRENT_BRANCH}"

	//  Step2: supposed to run a bunch of test if test fails we rollback bitch
	//  and redeploy to the last "stable commit"
	stage '2 - Testing code // Unit testing'
		echo "We will test code here"

	//  try to check if there was some changes in the ansibles playbooks,
	//  if yes RERUN it
	//  if not We don't need to rerun Ansible and skip stage 3
	stage '3 - Running Ansible Environment'


		echo "Last commit = ${LAST_COMMIT}"
		echo "Last ANSIBLE commit = ${LAST_COMMIT_ANSIBLE}"

		/*
		  X We triggered Ansible changes and now we will test which building we fire :
				- Adding new host to staging Ingestion = Redeploy ansibles
						modification in src/deployment/ingestion but NOT host
				- Adding new host to Processing = Redeploy ansibles
						modification in src/deployment/processing but NOT host
				- Adding new host to Serving = Redeploy ansibles
						modification in src/deployment/serving but NOT host
				- Changing an Ansible config in Ingestion = Redeploy Ansible on all hosts
						modification in src/deployment/ingestion/staging
				- Changing an Ansible config in Processing = Redeploy Ansible on all hosts
						modification in src/deployment/processing/staging
				- Changing an Ansible config in Serving = Redeploy Ansible on all hosts
						modification in src/deployment/serving/staging
			X Changes in src/ingestion = run an Ansible to ONLY deploy
			X Changes in src/processing = run an Ansible to ONLY deploy
			X Changes in src/serving = run an Ansible to ONLY deploy
		*/
		if (LAST_COMMIT == LAST_COMMIT_ANSIBLE) {
			//  We fired some Ansible changes now we have to know where they come from
			echo "Fireing Ansible changes --  will rerun the whole shit"

			//  Modification in src/deployment/ingestion
			LAST_COMMIT_ANSIBLE_INGESTION = sh (
				script: "git log -n 1 --pretty=format:%H -- src/deployment/ingestion",
				returnStdout: true
			)

			//  Modification in src/deployment/processing
			LAST_COMMIT_ANSIBLE_PROCESSING = sh (
				script: "git log -n 1 --pretty=format:%H -- src/deployment/processing",
				returnStdout: true
			)

			//  Modification in src/deployment/serving
			LAST_COMMIT_ANSIBLE_SERVING = sh (
				script: "git log -n 1 --pretty=format:%H -- src/deployment/serving",
				returnStdout: true
			)

			//  Modification in src/deployment/ingestion/staging
			LAST_COMMIT_ANSIBLE_INGESTION_HOST = sh (
				script: "git log -n 1 --pretty=format:%H -- src/deployment/ingestion/staging",
				returnStdout: true
			)

			//  Modification in src/deployment/processing/staging
			LAST_COMMIT_ANSIBLE_PROCESSING_HOST = sh (
				script: "git log -n 1 --pretty=format:%H -- src/deployment/processing/staging",
				returnStdout: true
			)

			//  Modification in src/deployment/serving/staging
			LAST_COMMIT_ANSIBLE_SERVING_HOST = sh (
				script: "git log -n 1 --pretty=format:%H -- src/deployment/serving/staging",
				returnStdout: true
			)

			switch(LAST_COMMIT) {
				case LAST_COMMIT_ANSIBLE_SERVING:
					if (LAST_COMMIT_ANSIBLE_SERVING_HOST == LAST_COMMIT_ANSIBLE_SERVING) {
						addHostServing()
					}else {
						setupServing()()
					}
				break
				case LAST_COMMIT_ANSIBLE_PROCESSING:
					if (LAST_COMMIT_ANSIBLE_PROCESSING_HOST == LAST_COMMIT_ANSIBLE_PROCESSING) {
						addHostProcessing()
					}else {
						setupProcessing()
					}
				break
				case LAST_COMMIT_ANSIBLE_INGESTION:
					if (LAST_COMMIT_ANSIBLE_INGESTION_HOST == LAST_COMMIT_ANSIBLE_INGESTION) {
						addHostIngestion()
					}else {
						setupIngestion()
					}
				break
				default:
					notifyHipChat("GRAY", "Infos : Last Ansible commit didn't change either - src/deployment/ingestion - src/deployment/processing - src/deployment/serving")
				break
			}

		} else {
			//  We skip Ansible as this commit doesn't concern Ansible Changes
			echo "Skipping Ansible"
		}

	//  Stage 4: Deploying the tested code
	stage '4 - Deploy'

		echo "If everything goes well we will deploy here"

		//  Modification in src/ingestion
		LAST_COMMIT_INGESTION = sh (
			script: "git log -n 1 --pretty=format:%H -- src/ingestion",
			returnStdout: true
		)

		//  Modification in src/processing
		LAST_COMMIT_PROCESSING = sh (
			script: "git log -n 1 --pretty=format:%H -- src/processing",
			returnStdout: true
		)

		//  Modification in src/serving
		LAST_COMMIT_SERVING = sh (
			script: "git log -n 1 --pretty=format:%H -- src/serving",
			returnStdout: true
		)

		switch(LAST_COMMIT) {
			case LAST_COMMIT_INGESTION:
				deployIngestion()
			break
			case LAST_COMMIT_PROCESSING:
				deployProcessing()
			break
			case LAST_COMMIT_SERVING:
				deployServing()
			break
			default:
				notifyHipChat("GRAY", "Not triggering any changes in either - src/ingestion - src/processing - src/serving So we are not deploying anything, we might have run Ansible Playbook")
			break
		}


	stage '5 - Running Crossbrowser'
		//We will see :p
		echo "We will run Crossbrowser Celenium test here and if the error is too big rollback bitch"

	stage '6 - Send HipChat Report'
		//Send an HipChat message
		notifyHipChat("GREEN", "End of the building, will send some infos soon bruh")

}

def notifyHipChatBegin() {
	hipchatSend (color: 'GREEN', notify: true,
	message: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL} <br> If you want to follow the job : ${env.JENKINS_URL}${env.BUILD_NUMBER}/console (beer))"
	)
}

def notifyHipChat(color, message) {
	hipchatSend (color: color, notify: true, message: message)
}

def deployIngestion() {
	echo "deployIngestion"
	// ansiblePlaybook(
	//     playbook: 'path/to/playbook.yml',
	//     inventory: 'path/to/inventory.ini',
	//     credentialsId: 'my-creds',
	//     extras: 'my-extras'
	// 	)
}

def deployProcessing() {
	echo "deployProcessing"
	// ansiblePlaybook(
	//     playbook: 'path/to/playbook.yml',
	//     inventory: 'path/to/inventory.ini',
	//     credentialsId: 'my-creds',
	//     extras: 'my-extras'
	// 	)
}

def deployServing() {
	echo "deployServing"
	// ansiblePlaybook(
	//     playbook: 'path/to/playbook.yml',
	//     inventory: 'path/to/inventory.ini',
	//     credentialsId: 'my-creds',
	//     extras: 'my-extras'
	// 	)
}
def setupIngestion() {
	echo "setupIngestion"
	// ansiblePlaybook(
	//     playbook: 'path/to/playbook.yml',
	//     inventory: 'path/to/inventory.ini',
	//     credentialsId: 'my-creds',
	//     extras: 'my-extras'
	// 	)
}

def setupProcessing() {
	echo "setupProcessing"
	// ansiblePlaybook(
	//     playbook: 'path/to/playbook.yml',
	//     inventory: 'path/to/inventory.ini',
	//     credentialsId: 'my-creds',
	//     extras: 'my-extras'
	// 	)
}

def setupServing() {
	echo "setupServing"
	// ansiblePlaybook(
	//     playbook: 'path/to/playbook.yml',
	//     inventory: 'path/to/inventory.ini',
	//     credentialsId: 'my-creds',
	//     extras: 'my-extras'
	// 	)
}
def addHostIngestion() {
	echo "addHostIngestion"
	// ansiblePlaybook(
	//     playbook: 'path/to/playbook.yml',
	//     inventory: 'path/to/inventory.ini',
	//     credentialsId: 'my-creds',
	//     extras: 'my-extras'
	// 	)
}

def addHostProcessing() {
	echo "addHostProcessing"
	// ansiblePlaybook(
	//     playbook: 'path/to/playbook.yml',
	//     inventory: 'path/to/inventory.ini',
	//     credentialsId: 'my-creds',
	//     extras: 'my-extras'
	// 	)
}

def addHostServing() {
	echo "addHostServing"
	// ansiblePlaybook(
	//     playbook: 'path/to/playbook.yml',
	//     inventory: 'path/to/inventory.ini',
	//     credentialsId: 'my-creds',
	//     extras: 'my-extras'
	// 	)
}
