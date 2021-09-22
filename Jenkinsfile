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
                sh "export DOCKER_REPOS=${params.DOCKER_REPO}"
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
                    sh "export DOCKER_REPOS=${params.DOCKER_REPO}"
                    sh "export OKE_SERVERZ=${params.OKE_SERVER_PORT}"
                    
                    //url="$(echo 'http://ws.geonames.org/findNearestAddress?lat='${lat}'&lng='${lon} )"
                    //sh 'URLZ="$(echo ${params.OKE_TOKEN})"'
                    //sh 'export URLZ=$(echo '''http:///\''')'
                    //sh 'export URLZ=$(echo '''http://''')'
                    
                    //URLZ="https://"
                    //echo " $URLZ"
                    //sh 'export O_URLZ=$URLZ$OKE_SERVERZ'
                    sh 'echo ${params.OKE_SERVER_PORT}'
                    
                    //sh 'export O_URLZ=$URLZ'
                    sh 'export OKE_URL=$(echo ${params.OKE_TOKEN})'
                    sh "export OKE_TOKEN=${params.OKE_TOKEN}"                   
                    //echo "repos = $DOCKER_REPOS"
                    //sh 'replacements=({{GIT_COMMIT}}:${GIT_COMMIT} {{DOCKER_REPO}}:${params.DOCKER_REPO})'
                    sh 'echo "done 1"'
                    sh 'sed -i -e "s/[GITCOMMIT]/${GIT_COMMIT}/g" "manifest$ts.yml"'
                    sh 'sed -i -e "s/[DOCKER_REPO]/$DOCKER_REPOS/g" "manifest$ts.yml"'
                    sh 'cat manifest$ts.yml'
                    // sh '''
                       
                    //     for row in "${replacements[@]}"; do
                    //         original="$(echo $row | cut -d: -f1)"
                    //         new="$(echo $row | cut -d: -f2)"
                    //         echo "new = ${new}"
                    //         sed -i -e "s/${original}/${new}/g" "manifest$ts.yml"
                    //     done
                    // ENDSSH'
                    // '''
                    sh 'echo "done 2"'
                    sh 'kubectl version --client'
                    sh 'ls -l'
                    sh 'kubectl apply -f manifest$ts.yml --token=$OKE_TOKEN --server=$O_URLZ --insecure-skip-tls-verify=true'
                    //sh 'bash oke.sh manifest$ts.yml'
                }
            }
        }
    }
}
