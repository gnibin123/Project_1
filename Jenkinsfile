pipeline {
  agent any
  stages {
    stage('Git_Checkout') {
      steps {
        git(url: 'https://github.com/gnibin123/Project_1.git', branch: 'main', changelog: true, poll: true)
      }
    }

  }
}