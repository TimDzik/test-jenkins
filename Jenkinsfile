#!groovy

import hudson.model.*
import hudson.EnvVars
import groovy.json.JsonSlurperClassic
import groovy.json.JsonBuilder
import groovy.json.JsonOutput
import java.net.URL

node {
	stage '1 - Checkout to Develop'

		git url: "https://github.com/TimDzik/test-jenkins"
		sh "git checkout develop"
		CURRENT_BRANCH = sh (
			script: "git rev-parse --abbrev-ref HEAD",
			returnStdout: true
		)
		echo "your current branch ${CURRENT_BRANCH}"

	stage '2 - Testing code // Unit testing'
		echo "We will test code here"

	stage '3 - Running Ansible Environment'
		//  try to check if there was some changes in the ansibles playbooks,
		//  if yes RERUN it
		//  if not We don't need to rerun Ansible and skip stage 2

		LAST_COMMIT = sh (
			script: "git log -n 1 --pretty=format:%H",
			returnStdout: true
		)

		echo "Last commit = ${LAST_COMMIT}"

		LAST_COMMIT_ANSIBLE = sh (
			script: "git log -n 1 --pretty=format:%H -- src/deployment",
			returnStdout: true
		)

		echo "Last commit = ${LAST_COMMIT_ANSIBLE}"

		if (LAST_COMMIT == LAST_COMMIT_ANSIBLE) {
			echo "Fireing Ansible changes --  will rerun the whole shit"
			// ansiblePlaybook(
	    //     playbook: 'path/to/playbook.yml',
	    //     inventory: 'path/to/inventory.ini',
	    //     credentialsId: 'my-creds',
	    //     extras: 'my-extras'
			// 	)
		} else {
			echo "Skipping Ansible"
		}

	stage '4 - Deploy'
		//Remplace code
		//binary build + push to the binary repository
		echo "If everything goes well we will deploy here"

	stage '5 - Running Crossbrowser'
		//We will see :p

		echo "We will run Crossbrowser Celenium test here and if the error is too big rollback bitch"

	stage '6 - Send HipChat Report'
		//Send an HipChat message
		notifyHipChat()

}
def notifyHipChat() {
	hipchatSend (color: 'YELLOW', notify: true, token: '156b34148800e126b7af319e4b81cb', 
		room: 'jenkins', sendAs: 'jenkins', message: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
		)
}
