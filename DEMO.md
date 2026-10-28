# ShipFast – Live Demo Script

Run everything from the `shipfast/` folder in **Git Bash** unless stated otherwise.

## 1. Docker (Unit 1)
```bash
docker build -t shipfast:v1 .                                  # "We package the app and its dependencies into one image."
docker run -d -p 5000:5000 --name shipfast-test shipfast:v1    # "Run it as an isolated container, mapped to port 5000."
docker ps                                                      # "STATUS shows (healthy) – our HEALTHCHECK works."
docker logs shipfast-test                                      # "Flask logs, straight from the container."
curl localhost:5000/health                                     # "Health endpoint answers {status: ok}."
docker rm -f shipfast-test                                     # "Cleanup."
```

## 2. GitHub Actions CI (Unit 4)
```bash
git add . && git commit -m "demo: trigger CI" && git push      # "Every push triggers the pipeline."
```
"Open the repo's Actions tab: `test` then `build` get green ticks – tests passed and the image smoke test passed."
```bash
sed -i 's/"status": "ok"/"status": "broken"/;s/status="ok"/status="broken"/' app/app.py
git commit -am "break test" && git push                        # "I deliberately break /health."
```
"Actions shows a red cross – `build` never ran because `test` failed, so bad code can't ship."
```bash
git revert --no-edit HEAD && git push                          # "Revert the change."
```
"Green ticks again."

## 3. Kubernetes deploy (Unit 6 + 7)
```bash
minikube start --driver=docker       # "Start a local one-node Kubernetes cluster."
./deploy.sh v1                       # "One script: test, build image inside minikube, deploy, wait for rollout."
kubectl get all                      # "Deployment, ReplicaSet, 3 pods and the NodePort service."
minikube service shipfast-service --url   # "Gives the URL to open in the browser."
```
**Keep this terminal open on Windows** (docker driver tunnels the port). Note the URL, e.g. `http://127.0.0.1:54321`.
"Refresh the page: the pod name changes – the Service load-balances across pods."

## 4. Scaling
```bash
kubectl scale deployment shipfast --replicas=5   # "Scale to 5 replicas with one command."
kubectl get pods -w                              # "Watch new pods appear and become Ready." (Ctrl+C to stop)
```

## 5. Self-healing
```bash
kubectl get pods
kubectl delete pod <pod-name>        # "I kill a pod on purpose."
kubectl get pods                     # "Kubernetes immediately creates a replacement to keep the desired count."
```

## 6. Zero-downtime update
Terminal 2 (Git Bash): `./demo-loop.sh http://127.0.0.1:<port>`  
or PowerShell: `.\demo-loop.ps1 http://127.0.0.1:<port>`
"This hits /version twice a second."

Terminal 3:
```bash
./deploy.sh v2        # "Rolling update: a new pod starts, becomes Ready, then an old one is removed."
```
"Watch terminal 2: version flips v1 -> v2 with no red FAILED lines – zero downtime (maxUnavailable: 0)."

## 7. Rollback
```bash
kubectl rollout history deployment/shipfast   # "Every revision with its change-cause."
kubectl rollout undo deployment/shipfast      # "Bad release? One command returns to the previous version."
kubectl rollout status deployment/shipfast
```
"The loop in terminal 2 shows the version going back, again with no failures."

## 8. Cleanup
```bash
kubectl delete -f k8s/     # "Remove the deployment and service."
minikube stop              # "Stop the cluster."
```
