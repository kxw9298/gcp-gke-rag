## 1. Create your cluster infrastructure
### Deploy cloud resources under terraform/gke-autopilot
```
terraform init
terraform apply
```
## 2. Deploy the PostgreSQL vector  in the k8s cluster
### Connect to the cluster
```
export PROJECT_ID=PROJECT_ID
export KUBERNETES_CLUSTER_PREFIX=postgres
export REGION=us-central1
export DB_NAMESPACE=pg-ns
gcloud container clusters get-credentials \
    ${KUBERNETES_CLUSTER_PREFIX}-cluster --region ${REGION} --project ${PROJECT_ID}

```
###
```
# Add the CloudNativePG operator Helm Chart repository
helm repo add cnpg https://cloudnative-pg.github.io/charts

# Deploy the CloudNativePG operator using the Helm command-line tool

helm upgrade --install cnpg \
    --namespace cnpg-system \
    --create-namespace \
    cnpg/cloudnative-pg

# Create a namespace pg-ns for the database:
kubectl create ns pg-ns

# Apply the manifest to deploy PostgreSQL cluster. The cluster manifest enables the pgvector extension.

cd kubernetes
kubectl apply -n pg-ns -f manifests/01-basic-cluster/postgreSQL_cluster.yaml

# Check the status of the cluster. Wait for the output to show a status of Cluster in healthy state.
kubectl get cluster -n pg-ns --watch

```
## 3. Deploy k8s services 
### Build Docker images for the embed-docs and chatbot Services
```
export DOCKER_REPO="${REGION}-docker.pkg.dev/${PROJECT_ID}/${KUBERNETES_CLUSTER_PREFIX}-images"
gcloud builds submit docker/chatbot --region=${REGION} \
  --tag ${DOCKER_REPO}/chatbot:1.0 --async
gcloud builds submit docker/embed-docs --region=${REGION} \
  --tag ${DOCKER_REPO}/embed-docs:1.0 --async
```

### Deploy a Kubernetes Service Account with permissions to run Kubernetes Jobs
```
sed "s/<PROJECT_ID>/$PROJECT_ID/;s/<CLUSTER_PREFIX>/$KUBERNETES_CLUSTER_PREFIX/" manifests/03-rag/service-account.yaml | kubectl -n pg-ns apply -f -
```

### Deploy a Kubernetes Deployment for the embed-docs and chatbot Services
```
sed "s|<DOCKER_REPO>|$DOCKER_REPO|" manifests/03-rag/chatbot.yaml | kubectl -n pg-ns apply -f -
sed "s|<DOCKER_REPO>|$DOCKER_REPO|" manifests/03-rag/docs-embedder.yaml | kubectl -n pg-ns apply -f -
```
