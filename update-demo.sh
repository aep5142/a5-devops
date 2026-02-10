#!/bin/bash

# -----------------------------------
# Step 1: Apply Deployment and Service
# -----------------------------------
echo "Applying Deployment and Service..."
kubectl apply -f rolling-update-deployment.yaml
kubectl apply -f rolling-update-service.yaml

# -----------------------------------
# Step 2: Apply Deployment and Service
# -----------------------------------
echo "get deployments/pods showing initial state"
kubectl get deployments
kubectl get pods

# -----------------------------------
# Step 3: Trigger a rolling update
# -----------------------------------
# Update the image of the container named 'nginx' in the Deployment
# This triggers Kubernetes to replace Pods gradually (rolling update)
echo "rollout status during update..."
kubectl set image deployment/roll-update-app nginx=nginx:mainline-alpine-perl

# -----------------------------------
# Step 4: Monitor the rollout
# -----------------------------------
echo "get pods showing successful update..."
kubectl rollout status deployment/roll-update-app

# -----------------------------------
# Step 5: Monitor the rollout
# -----------------------------------
echo "rollout undo command and result"
kubectl rollout undo deployment/roll-update-app

# -----------------------------------
# Step 6: Verify Pods and Service
# -----------------------------------
echo "Listing updated Pods..."
kubectl get pods

echo "Checking Service details..."
kubectl get svc roll-update-service
minikube service roll-update-service