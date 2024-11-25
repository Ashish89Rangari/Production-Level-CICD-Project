## Commands for Production Level CICD Pipeline

1) Login into AWS Cloud account
2) Create Linux VM and connect to it using MobaXterm
3) Github account and Personal Access Token
4) Dockerhub account 

## Git clone

```
git clone https://github.com/Ashish89Rangari/Production-Level-CICD-Project.git
```
## AWS VM

```
sudo apt-get update -y 
sudo apt-get upgrade -y

```
## Install Java

```
sudo apt install openjdk-17-jre-headless -y

```

## Install Jenkins Ubunutu

```
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins

```
## File execution shell script

```
sudo chmod +x jenkins.sh
./jenkins.sh

```
## Install Docker

```
sudo apt install docker.io -y

```

## Verify docker installation

```
docker -v
```
## Docker command are only executable for root user only, Now to give permission to ubuntu user we have to add to Docker group. OR we can run below command to give Docker permission to all user

```
sudo chmod 666 /var/run/docker.sock

```
## Nexus docker installation Creating and pulling image to make container Here -d – detachable mode ,-p -port,8081 Host port port on the VM we gone access container (Port can change),Container port were nexus will be running (Port cannot be changed) Search nexus docker image

```
sudo docker run -d -p 8081:8081 sonatype/nexus3
```

## Verify docker container

```
docker ps
docker ps -a
```

## SonarQube docker installation Creating and pulling image to make container Here -d – detachable mode ,-p -port,9000 Host port port on the VM we gone access container (Port can change),Container port were nexus will be running (Port cannot be changed) Search SonarQube docker image

```
sudo docker run -d -p 9000:9000 sonarqube:lts-community
```

## To go inside  docker container ,-it -interactive mode, ca75ea50e33e  Docker container id

```
sudo docker exec -it  ca75ea50e33e  /bin/bash
```

## Install Trivy Ubuntu

```
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy


```
## Install AWS CLI EKS Setup

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

```
## AWS Configure Secret Access Key

```
aws configure

```
## Install Terraform

```
sudo snap install terraform --classic

```
##  Terraform commands

```
terraform init
terraform plan
terraform apply --auto-approve

```
## Install Kubectl

```
sudo snap install kubectl --classic

```

## To connect to eks cluster

```
aws eks --region ap-south-1 update-kubeconfig --name devopsshack-cluster

```

## Kubernetes Command

```
kubectl get nodes
kubectl create ns webapps
kubectl apply -f svc.yml
kubectl apply -f jenkins-secret.yml -n webapps

```
## To Create Kubernetes Secret Token

```
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: mysecretname
  annotations:
    kubernetes.io/service-account.name: myserviceaccount

```

## To Acess private docker registry create secret. Here, regcred - secret name, 

```
kubectl create secret docker-registry regcred \
         --docker-server=https://index.docker.io/v1/ \
         --docker-username=Dockerhub User name \
         --docker-password=Dockerhub Password


```
## Secret not created in namespace webapps. To create secret in namespace  webapps 

```
kubectl create secret docker-registry regcred --docker-server=https://index.docker.io/v1/  --docker-username=Dockerhub User name --docker-password=Dockerhub Password -n webapps

```

## Kubernetes Command

```
kubectl get secrets -n webapps
kubectl describe secret mysecretname -n webapps

```
## Prometheus Install Command

```
wget https://github.com/prometheus/prometheus/releases/download/v3.0.0/prometheus-3.0.0.linux-amd64.tar.gz
tar -xvf  prometheus-3.0.0.linux-amd64.tar.gz
rm  prometheus-3.0.0.linux-amd64.tar.gz
mv prometheus-3.0.0.linux-amd64/ prometheus
```

## Blackbox Exporter Install Command

```
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.25.0/blackbox_exporter-0.25.0.linux-amd64.tar.gz
tar -xvf  blackbox_exporter-0.25.0.linux-amd64.tar.gz
rm  blackbox_exporter-0.25.0.linux-amd64.tar.gz
mv blackbox_exporter-0.25.0.linux-amd64/ blackbox
```

## Grafana Install Command Ubuntu

```
sudo apt-get install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_11.3.1_amd64.deb
sudo dpkg -i grafana-enterprise_11.3.1_amd64.deb
```
## Start Grafana Server

```
sudo /bin/systemctl start grafana-server
```


## To delete cluster Command

```
terraform destroy --auto-approve


kubectl delete --all pods -n prometheus                   //This command will delete all the pods in prometheus namespace
kubectl delete namespace prometheus
kubectl get all                                           //This command will show the all the deployments, pods & services in default namespace
kubectl delete deployment.apps/virtualtechbox-cluster     //delete deployment in your k8s cluster
kubectl delete service/virtualtechbox-service             //delete service for your deployment of k8s cluster
eksctl delete cluster virtualtechbox-cluster --region ap-south-1     OR    eksctl delete cluster --region=ap-south-1 --name=virtualtechbox-cluster      //This command will delete your EKS cluster



kubectl delete --all pods -n webapps
kubectl delete namespace webapps
kubectl delete deployment.apps/devopsshack-cluster
kubectl delete service/jenkins
eksctl delete cluster devopsshack-cluster --region ap-south-1     


```