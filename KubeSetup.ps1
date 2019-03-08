#Create Resource Group for all resources 
az group create --name myResourceGroup --location eastus

#Create ACR to store your images and push images
az acr create --resource-group myResourceGroup --name acrkubecde --sku Basic
az acr login --name acrkubecde
docker push acrkubecde.azurecr.io/kubeui:v3
docker push acrkubecde.azurecr.io/kubeapi:v5

# get appId and Password for the rbac from line below and use it under the line.
az ad sp create-for-rbac --skip-assignment

#get the acrid from line below
az acr show --resource-group myResourceGroup --name acrkubecde --query "id" --output tsv

# allow pull of images from acr for the application
az role assignment create --assignee 6243a649-2311-4017-ab68-c5675e3ddcc6 --scope "/subscriptions/585c6789-4e5e-48d3-a721-7cd5a6558aaa/resourceGroups/myResourceGroup/providers/Microsoft.ContainerRegistry/registries/acrkubecde" --role acrpull

#Create Aks Cluster
az aks create  --resource-group myResourceGroup  --name myAKSCluster  --node-count 1  --service-principal 6243a649-2311-4017-ab68-c5675e3ddcc6  --client-secret af204e04-5b11-4ce0-aa2a-98b203b82f38  --generate-ssh-keys

# Get Credentials from AKS cluster and store it locally.
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
kubectl get nodes

cd C:\Users\hsingh402\Documents\Harpal\Code\Research\Kubernetes

kubectl apply -f kube-deployment-1.yml

kubectl get all

# View Logs
kubectl logs kubeui-7fc7b767b9-gfp9n

#Static Ip#
    #- Get the Node Resource Group for assigning pulic ip.
az aks show --resource-group myResourceGroup --name myAKSCluster --query nodeResourceGroup -o tsv
az network public-ip create --resource-group MC_myResourceGroup_myAKSCluster_eastus --name myAKSPublicIP --allocation-method static

#get ip address and update yml file in load balancer
az network public-ip show --resource-group MC_myResourceGroup_myAKSCluster_eastus --name myAKSPublicIP --query ipAddress --output tsv
kubectl apply -f kube-deployment.yml

#kubectl dashboard
az aks browse --resource-group myResourceGroup --name myAKSCluster


#add disk for kubecluster - persitence containers
az disk create --resource-group MC_myResourceGroup_myAKSCluster_eastus --name myAKSDisk  --size-gb 20 --query id --output tsv
kubectl apply -f kube-deployment.yml


#storage class and sql server
# For createing persitance containers for db, we need 3 steps in yml file. create storage class, define volume, mount volume to sql container.
kubectl create secret generic mssql --from-literal=SA_PASSWORD="MyC0m9l&xP@ssw0rd" 
kubectl apply -f kube-deployment-sqlserver.yml

#VM Credentials
#username: sa
#password: MyC0m9l&xP@ssw0rd


#update deployment image to new version - update the version of image for a deployment.
#docker-compose
kubectl --record deployment.apps/kubeapi set image deployment.v1.apps/kubeapi kubeapi=acrkubecde.azurecr.io/kubeapi:v5
#kubectl --record deployment.apps/kubeapi[deployment name] set image deployment.v1.apps/kubeapi[deploymentname] kubeapi[containername]=acrkubecde.azurecr.io/kubeapi:v5[image version]



#TLS CERT SSL Kube
# We need helm to install stuffs on kubernetes. With helm we can install stable/nginx-ingress to load balance and make certificate work.  
helm init --upgrade
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl create clusterrolebinding permissive-binding --clusterrole=cluster-admin --user=admin --user=kubelet --group=system:serviceaccounts
helm install stable/nginx-ingress --namespace kube-system --set controller.replicaCount=2 --set rbac.create=false

# this gives you a list of deployed installations. nginx-ingress
helm list
# gets the external ip address of ingress and then use that ip address to update DNS
kubectl get service -l app=nginx-ingress --namespace kube-system

#secret and ingress
# get the private key and crt file. rename then to aks-ingress-tls.key and aks-ingress-tls.crt
kubectl create secret tls aks-ingress-tls --key aks-ingress-tls.key --cert aks-ingress-tls.crt
kubectl apply -f kube-ui-ingress.yml

kubectl get ingress kube-ui-ingress 
kubectl get all


 