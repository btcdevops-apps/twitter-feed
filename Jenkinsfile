pipeline {
    agent any
    
    stages {
        stage('Build') { 
            steps {
                sh "mvn install -DskipTests" 
            }
        }
        stage('Create docker image') { 
            steps {
                script {
                    def scmVars = checkout([
                        $class: 'GitSCM',
                        doGenerateSubmoduleConfigurations: false,
                        userRemoteConfigs: [[
                            url: 'https://github.com/btcdevops-apps/twitter-feed.git'
                          ]],
                        branches: [ [name: '*/master'] ]
                      ])
                sh "docker build -f Dockerfile -t twitterfeed:${scmVars.GIT_COMMIT} ." 
                }
            }
        }
        stage('Push image to OCIR') { 
            steps {
                script {
                    def scmVars = checkout([
                        $class: 'GitSCM',
                        doGenerateSubmoduleConfigurations: false,
                        userRemoteConfigs: [[
                            url: 'https://github.com/btcdevops-apps/twitter-feed.git'
                          ]],
                        branches: [ [name: '*/master'] ]
                      ])
                sh "docker login -u ${params.REGISTRY_USERNAME} -p ${params.REGISTRY_TOKEN} lhr.ocir.io"
                sh "docker tag twitterfeed:${scmVars.GIT_COMMIT} ${params.DOCKER_REPO}:${scmVars.GIT_COMMIT}"
                sh "docker push ${params.DOCKER_REPO}:${scmVars.GIT_COMMIT}" 
                env.GIT_COMMIT = scmVars.GIT_COMMIT
                sh "export GIT_COMMIT=${env.GIT_COMMIT}"
                }
            }
        }
        stage('Deploy to OKE') {
            steps {
                script {
                    def scmVars = checkout([
                        $class: 'GitSCM',
                        doGenerateSubmoduleConfigurations: false,
                        userRemoteConfigs: [[
                            url: 'https://github.com/btcdevops-apps/twitter-feed.git'
                          ]],
                        branches: [ [name: '*/master'] ]
                      ])
                    sh 'export ts=$(date +"%Y%m%d%H%M")'
                    sh 'cp kubernetestwitter.yml manifest$ts.yml'
                    sh 'cat manifest$ts.yml'
                    sh '''
                        replacements=(
                            {{GIT_COMMIT}}:$GIT_COMMIT
                            {{DOCKER_REPO}}:${params.DOCKER_REPO}
                        )
                    ENDSSH'
                    '''
                    sh '''
                        for row in "${replacements}"; do
                            original="$(echo $row | cut -d: f1)"
                            new="$(echo $row | cut -d: -f2)"
                            sed -i -e "s/${original}/${new}/g" "manifest$ts.yml"
                        done
                    ENDSSH'
                    '''
                    sh 'sudo kubectl version --client'
                    sh 'ls -l'
                    sh 'kubectl apply -f manifest$ts.yml --server={params.OKE_SERVER_PORT} --token={params.OKE_TOKEN} --insecure-skip-tls-verify=true'
                }
            }
        }
    }
}
