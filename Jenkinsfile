#!groovy
//  Grab the master Jenkinsfile
//  Grab the master Jenkinsfile
//  Grab the master Jenkinsfile
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



		//checkouting to develop
		sh "git checkout develop"
		sh "git pull origin develop"

		/******************************************************
			Declaring all my variable from sh command line
			(most of them to grab git infos)
		*******************************************************/

		//  Grab the number of commit for the last 5 mins
		// NUMBER_OF_COMMIT_LAST_5MINS = sh (
		// 	script: "git log -v develop --since=5.minutes --pretty=format:%H | wc -l | tr -d '[:space:]'",
		// 	returnStdout: true
		// )


		sh "git log -v develop --since=5.minutes --pretty=format:%H > test.txt.tmp"
		sh "wc -l test.txt.tmp | grep -o '[0-9]\+'"

		NUMBER_OF_COMMIT_LAST_5MINS = sh (
			script: "wc -l test.txt.tmp",
			returnStdout: true
		).toInteger()

		echo NUMBER_OF_COMMIT_LAST_5MINS

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

		int NUMBER_OF_COMMIT_LAST_5MINS = NUMBER_OF_COMMIT_LAST_5MINS.toInteger()

		echo "NUMBER_OF_COMMIT_LAST_5MINS = ${NUMBER_OF_COMMIT_LAST_5MINS}"
		//  If we had more than 1 commit for the last 5 mins we delay the build of 300secs
		if (NUMBER_OF_COMMIT_LAST_5MINS > 1) {
			echo "We found 2 commits made to Develop the last 5 mins, we force a 300secs sleep"
			sh "delay 300"
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

		if (LAST_COMMIT == LAST_COMMIT_ANSIBLE) {
			echo "Fireing Ansible changes --  will rerun the whole shit"
			// ansiblePlaybook(
	    //     playbook: 'path/to/playbook.yml',
	    //     inventory: 'path/to/inventory.ini',
	    //     credentialsId: 'my-creds',
	    //     extras: 'my-extras'
			// 	)
		} else {
			//  We skip Ansible as this commit doesn't concern Ansible Changes
			echo "Skipping Ansible"
		}

	//  Stage 4: Deploying the tested code
	stage '4 - Deploy'
		//Remplace code
		//binary build + push to the binary repository
		echo "If everything goes well we will deploy here"
		// ansiblePlaybook(
		//     playbook: 'path/to/playbook.yml',
		//     inventory: 'path/to/inventory.ini',
		//     credentialsId: 'my-creds',
		//     extras: 'my-extras'
		// 	)

	stage '5 - Running Crossbrowser'
		//We will see :p

		echo "We will run Crossbrowser Celenium test here and if the error is too big rollback bitch"

	stage '6 - Send HipChat Report'
		//Send an HipChat message
		// notifyHipChat("GREEN", "End of the building, will send some infos soon bruh")

}

def notifyHipChatBegin() {
	hipchatSend (color: 'GREEN', notify: true,
	message: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL} <br> If you want to follow the job : ${env.JENKINS_URL}${env.BUILD_NUMBER}/console (beer))"
	)
}

def notifyHipChat(color, message) {
	hipchatSend (color: color, notify: true, message: message)
}
