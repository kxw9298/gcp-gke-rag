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

kubectl apply -n pg-ns -f manifests/01-basic-cluster/postgreSQL_cluster.yaml

```

## k8s manifest