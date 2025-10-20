pipeline {
  agent any

  environment {
    IMAGE = 'satvikahuja13/hello-world-java'     // your Docker Hub repo
    TAG   = "${env.BUILD_NUMBER}"                // unique tag per build
    KUBECONFIG = '/var/jenkins_home/.kube/config'
  }

  options {
    timestamps()
  }

  stages {
    stage('Checkout') {
      steps {
        // use YOUR fork
        git url: 'https://github.com/satvikahuja/docker-hello-world-spring-boot.git',
            branch: 'master'
      }
    }

    stage('Docker Build') {
      steps {
        // pre-pull bases (helps when registry is flaky) + retry the build once
        sh '''
          set -eux
          docker pull eclipse-temurin:11-jre-jammy || true
          docker pull maven:3.8.5-openjdk-11 || true
        '''
        retry(2) {
          sh '''
            set -eux
            docker build --pull --no-cache -t "$IMAGE:$TAG" .
            docker images | head -n 10
          '''
        }
      }
    }

    stage('Docker Push') {
      steps {
        sh '''
          set -eux
          docker push "$IMAGE:$TAG"
        '''
      }
    }

    stage('Deploy to Kubernetes (minikube)') {
      steps {
        sh '''
          set -eux
          export KUBECONFIG="${KUBECONFIG}"

          # create deployment/service if missing (idempotent), else roll image
          if ! kubectl get deploy hello-spring >/dev/null 2>&1; then
            kubectl create deployment hello-spring --image="$IMAGE:$TAG" --port=8080
            kubectl expose deployment hello-spring --type=NodePort --port=8080 || true
          else
            kubectl set image deploy/hello-spring "*=$IMAGE:$TAG"
          fi

          # wait for rollout
          kubectl rollout status deployment/hello-spring --timeout=180s

          # show current state
          kubectl get deploy hello-spring -o wide
          kubectl get svc hello-spring -o wide

          # print a URL to test
          NODE_PORT=$(kubectl get svc hello-spring -o jsonpath='{.spec.ports[0].nodePort}')
          NODE_IP=$(kubectl get node -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
          echo "App should be reachable at: http://$NODE_IP:$NODE_PORT"
          echo "Try: curl http://$NODE_IP:$NODE_PORT"
        '''
      }
    }
  }

  post {
    always {
      echo "Build URL: ${env.BUILD_URL}"
    }
  }
}
