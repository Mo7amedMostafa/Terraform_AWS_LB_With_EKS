
# Terrafom 
# Aws Eks Cluster & Load Balancer 



## Build EKS Cluster

```bash
terraform init

terraform plan

terraform apply
```

## Installation

Download IAM Policy 

```bash
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json
```

Apply IAM Policy
```bash
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```

Install eksctl
```bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
```

Create IAM Service Account
```bash
Replace XXXX with your ID

eksctl create iamserviceaccount \
  --cluster=eks-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::XXXXXXXX:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
```
Instal Helm
```bash
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh

helm repo add eks https://aws.github.io/eks-charts
helm repo update
```
Instal Aws-Load-Balancer-Controller
```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eks-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller 
```
Deploy Simple App
```bash
kubectl apply -f sample-deployment.yaml
```
Deploy Service
```bash
kubectl apply -f sample-service.yaml
```
Get External Address
```bash
kubectl get svc nlb-sample-service -n nlb-sample-app
```
