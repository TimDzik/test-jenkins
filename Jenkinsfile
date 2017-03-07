#!groovy

import hudson.model.*
import hudson.EnvVars
import groovy.json.JsonSlurperClassic
import groovy.json.JsonBuilder
import groovy.json.JsonOutput
import java.net.URL

node {
	stage '1 - Checkout Bitch'

		git url: "https://github.com/TimDzik/test-jenkins"
		def current_branch = sh "git branch -l"
		echo current_branch

	stage '2 - Testing code // Unit testing'


	stage '3 - Running Ansible Environment'

    ansiblePlaybook(
        playbook: 'path/to/playbook.yml',
        inventory: 'path/to/inventory.ini',
        credentialsId: 'my-creds',
        extras: 'my-extras'
			)

	stage '4 - Deploy'
		//Remplace code

	stage '5 - Running Crossbrowser'
		//We will see :p

	stage '6 - Send HipChat Report'
		//Send an HipChat message
		notifyHipChat("bitch")

}

def notifyHipChat(message) {
  hipchatSend (color: 'YELLOW', message: message, notify: true, room: 'jenkins', sendAs: 'Jenkins', server: 'api.hipchat.com', textFormat: true, v2enabled: true)
}
