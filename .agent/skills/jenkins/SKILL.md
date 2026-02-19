---
name: Jenkins
description: Skill for Jenkins — open-source CI/CD automation server with pipeline DSL, REST API, plugin ecosystem, and build automation.
---

# Jenkins — CI/CD Automation

## Overview
Jenkins is the most widely used open-source CI/CD automation server with 1,800+ plugins, declarative/scripted Pipeline DSL, and extensible REST API.

## Jenkinsfile (Declarative Pipeline)
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'npm install && npm run build'
            }
        }
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        stage('Deploy') {
            when { branch 'main' }
            steps {
                sh 'npm run deploy'
            }
        }
    }
    post {
        failure {
            slackSend channel: '#devops', message: "Build Failed: ${env.JOB_NAME}"
        }
    }
}
```

## REST API
```bash
# Trigger build
curl -X POST "https://jenkins/job/my-job/build" --user admin:API_TOKEN

# Get build status
curl "https://jenkins/job/my-job/lastBuild/api/json" --user admin:API_TOKEN

# Get console output
curl "https://jenkins/job/my-job/lastBuild/consoleText" --user admin:API_TOKEN
```

## Best Practices
- Use **Declarative Pipeline** over Scripted for readability
- Implement **Shared Libraries** for reusable pipeline code
- Configure **Blue Ocean** for modern UI
