---
name: Jenkins
description: Skill for Jenkins — open-source CI/CD automation server with pipeline DSL, REST API, plugin ecosystem, and build automation.
---

# Jenkins Skill

## Overview
Jenkins is the most widely used open-source CI/CD automation server. It provides pipeline-as-code (Jenkinsfile), extensive plugin ecosystem, distributed builds, and flexible job configuration for building, testing, and deploying applications.

**References**:
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Jenkins Plugin Index](https://plugins.jenkins.io/)

---

## Declarative Pipeline (Jenkinsfile)

```groovy
// Jenkinsfile — Declarative Pipeline
pipeline {
    agent any

    environment {
        NODE_VERSION = '20'
        DOCKER_REGISTRY = 'registry.myapp.com'
        APP_NAME = 'myapp-api'
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.BUILD_TAG = "${env.BRANCH_NAME}-${env.GIT_COMMIT_SHORT}-${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Install') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Lint & Type Check') {
            parallel {
                stage('Lint') {
                    steps { sh 'npm run lint' }
                }
                stage('Type Check') {
                    steps { sh 'npm run type-check' }
                }
            }
        }

        stage('Test') {
            steps {
                sh 'npm run test:ci'
            }
            post {
                always {
                    junit 'test-results/**/*.xml'
                    publishHTML(target: [
                        reportDir: 'coverage/lcov-report',
                        reportFiles: 'index.html',
                        reportName: 'Coverage Report'
                    ])
                }
            }
        }

        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Docker Build & Push') {
            when {
                anyOf {
                    branch 'main'
                    branch 'staging'
                }
            }
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-credentials') {
                        def image = docker.build("${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_TAG}")
                        image.push()
                        image.push('latest')
                    }
                }
            }
        }

        stage('Deploy to Staging') {
            when { branch 'staging' }
            steps {
                withCredentials([
                    string(credentialsId: 'staging-deploy-token', variable: 'DEPLOY_TOKEN')
                ]) {
                    sh """
                        curl -X POST https://staging.myapp.com/deploy \
                            -H 'Authorization: Bearer ${DEPLOY_TOKEN}' \
                            -d '{"image": "${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_TAG}"}'
                    """
                }
            }
        }

        stage('Deploy to Production') {
            when { branch 'main' }
            input {
                message "Deploy to production?"
                ok "Deploy"
                submitter "admin,deployer"
            }
            steps {
                withCredentials([
                    string(credentialsId: 'prod-deploy-token', variable: 'DEPLOY_TOKEN')
                ]) {
                    sh """
                        curl -X POST https://api.myapp.com/deploy \
                            -H 'Authorization: Bearer ${DEPLOY_TOKEN}' \
                            -d '{"image": "${DOCKER_REGISTRY}/${APP_NAME}:${BUILD_TAG}"}'
                    """
                }
            }
        }
    }

    post {
        success {
            slackSend(channel: '#deployments', color: 'good',
                message: "✅ ${APP_NAME} build #${BUILD_NUMBER} succeeded (${BRANCH_NAME})")
        }
        failure {
            slackSend(channel: '#deployments', color: 'danger',
                message: "❌ ${APP_NAME} build #${BUILD_NUMBER} failed (${BRANCH_NAME}): ${BUILD_URL}")
        }
        cleanup {
            cleanWs()
        }
    }
}
```

---

## Multibranch Pipeline

```groovy
// Jenkinsfile — Multi-environment pipeline
pipeline {
    agent any

    stages {
        stage('Build & Test') {
            steps {
                sh 'npm ci && npm run build && npm test'
            }
        }

        stage('Deploy') {
            when { anyOf { branch 'main'; branch 'staging'; branch pattern: 'release/*' } }
            steps {
                script {
                    def env = ''
                    if (BRANCH_NAME == 'main') env = 'production'
                    else if (BRANCH_NAME == 'staging') env = 'staging'
                    else env = 'preview'

                    sh "deploy.sh --env ${env} --tag ${BUILD_TAG}"
                }
            }
        }
    }
}
```

---

## Shared Library

```groovy
// vars/buildAndDeploy.groovy (Shared Library)
def call(Map config) {
    pipeline {
        agent any
        stages {
            stage('Build') {
                steps {
                    sh "${config.buildCommand ?: 'npm run build'}"
                }
            }
            stage('Test') {
                steps {
                    sh "${config.testCommand ?: 'npm test'}"
                }
            }
            stage('Deploy') {
                when { branch 'main' }
                steps {
                    sh "deploy.sh --app ${config.appName} --env production"
                }
            }
        }
    }
}

// Usage in Jenkinsfile:
// @Library('my-shared-library') _
// buildAndDeploy(appName: 'myapp', buildCommand: 'npm run build')
```

---

## Credentials & Secrets

```groovy
// Types of credentials in Jenkins:
// - string: API tokens, passwords
// - usernamePassword: user/pass pairs
// - sshUserPrivateKey: SSH keys
// - file: certificate files, env files

withCredentials([
    string(credentialsId: 'api-token', variable: 'API_TOKEN'),
    usernamePassword(credentialsId: 'db-creds', usernameVariable: 'DB_USER', passwordVariable: 'DB_PASS'),
    file(credentialsId: 'env-file', variable: 'ENV_FILE'),
]) {
    sh '''
        export DATABASE_URL="postgresql://${DB_USER}:${DB_PASS}@db:5432/myapp"
        cp ${ENV_FILE} .env
        npm run migrate
    '''
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Declarative** | Prefer declarative over scripted pipelines |
| **Pipeline-as-code** | Store Jenkinsfile in repo root |
| **Parallel stages** | Run lint, type-check, test in parallel |
| **Shared libraries** | Extract reusable pipeline logic to shared libraries |
| **Credentials** | Use Jenkins credential store, never hardcode secrets |
| **Agents** | Use Docker agents for clean, reproducible builds |
| **Timeout** | Set job timeout to prevent hung builds |
| **Notifications** | Slack/email on failure, optional on success |
| **Artifact retention** | `buildDiscarder` to limit stored builds |
| **Manual approval** | `input` step for production deployments |

---

## Rules Integration
- **Pipeline**: Declarative Jenkinsfile with stages, parallel, when conditions
- **Security**: Credentials store, `withCredentials`, never expose secrets in logs
- **Deployment**: Manual approval for production, automatic for staging
- **Quality**: Parallel lint+test, JUnit reports, coverage publishing
- **Operations**: Slack notifications, build cleanup, timeout limits
