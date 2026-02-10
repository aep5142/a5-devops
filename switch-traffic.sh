#!/bin/bash

# -----------------------------------
# Showing blue deployment running
# -----------------------------------
echo "--------------------------------"
echo "Showing blue deployment running"
kubectl apply -f blue-deployment.yaml
kubectl rollout status deployment/blue
echo "--------------------------------"

# -----------------------------------
# Showing green deployment running
# -----------------------------------
echo "--------------------------------"
echo "Showing green deployment running"
kubectl apply -f green-deployment.yaml
kubectl rollout status deployment/green
echo "--------------------------------"

#Running the service
kubectl apply -f blue-green-service.yaml

# -----------------------------------
# Describe service showing blue selector
# -----------------------------------
echo "--------------------------------"
echo "Describe service showing blue selector"
kubectl describe service blue-green-service
echo "--------------------------------"

# -----------------------------------
# Commands switching service to green
# -----------------------------------
echo "--------------------------------"
echo "Commands switching service to green"
echo "Commands are: kubectl patch svc blue-green-service -p '{\"spec\":{\"selector\":{\"app\":\"app\",\"version\":\"green\"}}}'"
kubectl patch svc blue-green-service -p '{"spec":{"selector":{"app":"app","version":"green"}}}'
echo "--------------------------------"

# -----------------------------------
# Describe service showing green selector
# -----------------------------------
echo "--------------------------------"
echo "Describe service showing green selector"
kubectl describe service blue-green-service
echo "--------------------------------"

# -----------------------------------
# Execution of rollback script and verification
# -----------------------------------
echo "--------------------------------"
echo "Execution of rollback script and verification"
./rollback.sh
echo "Describe service to check it went back to blue"
kubectl describe service blue-green-service
echo "--------------------------------"

