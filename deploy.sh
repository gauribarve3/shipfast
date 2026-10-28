#!/usr/bin/env bash
set -e

VERSION=$1
if [[ ! "$VERSION" =~ ^v[0-9]+$ ]]; then
  echo "Usage: ./deploy.sh <version>   e.g. ./deploy.sh v2" >&2
  exit 1
fi

step() { echo -e "\n\033[1;36m[$1/4] $2\033[0m"; }

step 1 "Running tests"
python -m pytest -q

step 2 "Building image shipfast:$VERSION in minikube"
minikube image build -t shipfast:$VERSION .

step 3 "Updating deployment"
if ! kubectl get deployment shipfast >/dev/null 2>&1; then
  kubectl apply -f k8s/
fi
kubectl set image deployment/shipfast shipfast=shipfast:$VERSION
kubectl set env deployment/shipfast APP_VERSION=$VERSION
kubectl annotate deployment/shipfast kubernetes.io/change-cause="deploy $VERSION" --overwrite

step 4 "Waiting for rollout"
kubectl rollout status deployment/shipfast
kubectl get pods -o wide

echo -e "\n\033[1;32mDeployed $VERSION successfully\033[0m"
