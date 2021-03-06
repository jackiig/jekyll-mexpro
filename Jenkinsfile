#! groovy

node {
  stage "Checkout"
  checkout scm
  // Use a staging-specific config to avoid accidental connections to the
  // production database.

  env.APP_NAME = 'Mexpro Website'

  // If BRANCH_NAME includes '/', convert to '-'
  env.BRANCH_NAME = env.BRANCH_NAME.toLowerCase().replaceAll('/', '-')
  env.JOB_NAME = env.JOB_NAME.toLowerCase().replaceAll('/', '-')
  // Sometimes '/' is encoded as '%2f'
  env.BRANCH_NAME = env.BRANCH_NAME.replaceAll('%2f', '-')
  env.JOB_NAME = env.JOB_NAME.replaceAll('%2f', '-')
  // If BRANCH_NAME includes '_', convert to '-'
  env.BRANCH_NAME = env.BRANCH_NAME.replaceAll('_', '-')
  env.JOB_NAME = env.JOB_NAME.replaceAll('_', '-')
  env.EBS_ENV_NAME = env.JOB_NAME
  // EBS won't allow over 40 characters.
  if (env.EBS_ENV_NAME.length() > 40) {
    env.EBS_ENV_NAME = env.EBS_ENV_NAME.substring(0, 40)
  }

  try {
    stage('Building Rails assets') {
      def rails = docker.image('jackiig/mio-rails-mexpro:latest')
      sh "rm -Rf ${env.WORKSPACE}/docs/assets"
      rails.pull()
      rails.withRun("-v ${env.WORKSPACE}/docs/assets:/usr/src/app/public/assets -e RAILS_ENV=production") { c ->
        sh "docker exec ${c.id} rake assets:precompile i18n:js:export"
      }
    }
    stage('Building Nginx image') {
      def nginx = docker.build("jackiig/mexpro-jekyll-rproxy:${BRANCH_NAME}", '-f _nginx/Dockerfile ./')
      nginx.push()
    }
    stage('Deploying to Elastic Beanstalk') {
      dir('_eb') {
        sh "sed -i s/:master/:${BRANCH_NAME}/g Dockerrun.aws.json"
        withCredentials([usernamePassword(credentialsId: 'ebs-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          try {
            sh "eb create ${EBS_ENV_NAME} -r us-west-1 -k jack-2018 -c ${EBS_ENV_NAME} --cfg default-sc"
          } catch(e) {
            sh "eb use ${EBS_ENV_NAME}"
            sh "eb deploy"
          }
          sh "eb status ${EBS_ENV_NAME}"
          env.CNAME = sh(
            script: "eb status ${EBS_ENV_NAME} | grep CNAME | sed \"s/\\s*CNAME:\\s*//\"",
            returnStdout: true
          ).trim()
        }
      }
    }
  } catch(e) {
      // If there was an exception thrown, the build failed
      currentBuild.result = "FAILED"
      throw e
  } finally {
    // Success or failure, always send notifications
    notifyBuild(currentBuild.result)
  }
}

// https://jenkins.io/blog/2016/07/18/pipline-notifications/
def notifyBuild(String buildStatus = 'STARTED') {
  buildStatus = buildStatus ?: 'SUCCESSFUL'

  def colorName = 'RED'
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} (${env.BUILD_URL})"
  if (buildStatus == 'SUCCESSFUL') {
    summary = summary + " URL: http://${env.CNAME}"
  }

  // Override default values based on build status
  if (buildStatus == 'STARTED') {
   color = 'YELLOW'
  } else if (buildStatus == 'SUCCESSFUL') {
   color = 'GREEN'
  } else {
   color = 'RED'
  }

  // send to HipChat
  hipchatSend (color: color, notify: true, message: summary)
}
