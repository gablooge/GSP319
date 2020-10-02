#!/bin/bash
gcloud auth revoke --all

while [[ -z "$(gcloud config get-value core/account)" ]]; 
do echo "waiting login" && sleep 2; 
done

while [[ -z "$(gcloud config get-value project)" ]]; 
do echo "waiting project" && sleep 2; 
done


# Copy paste ke terminal


# export PRODIR=$(pwd)

export PROJECT_ID=$(gcloud info --format='value(config.project)')

# git clone https://github.com/googlecodelabs/monolith-to-microservices.git
# cd monolith-to-microservices
# ./setup.sh

gcloud services enable cloudbuild.googleapis.com
cd monolith-to-microservices/monolith
gcloud builds submit --tag gcr.io/${PROJECT_ID}/fancytest:1.0.0 .

gcloud services enable container.googleapis.com
gcloud container clusters create fancy-cluster --num-nodes 3 --zone us-central1-a
 
kubectl create deployment fancytest --image=gcr.io/${PROJECT_ID}/fancytest:1.0.0
kubectl expose deployment fancytest --type=LoadBalancer --port 80 --target-port 8080


cd ../../monolith-to-microservices/microservices/src/orders
gcloud builds submit --tag gcr.io/${PROJECT_ID}/orders:1.0.0 .
kubectl create deployment orders --image=gcr.io/${PROJECT_ID}/orders:1.0.0

kubectl expose deployment orders --type=LoadBalancer --port 80 --target-port 8081



cd ../../../monolith-to-microservices/microservices/src/products
gcloud builds submit --tag gcr.io/${PROJECT_ID}/products:1.0.0 .

kubectl create deployment products --image=gcr.io/${PROJECT_ID}/products:1.0.0
kubectl expose deployment products --type=LoadBalancer --port 80 --target-port 8082

kubectl get service products
kubectl get service orders


cd ../../../monolith-to-microservices/microservices/src/frontend
gcloud builds submit --tag gcr.io/${PROJECT_ID}/frontend:1.0.0 .
kubectl create deployment frontend --image=gcr.io/${PROJECT_ID}/frontend:1.0.0
kubectl expose deployment frontend --type=LoadBalancer --port 80 --target-port 8080


