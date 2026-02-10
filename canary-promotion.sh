#!/bin/bash

# Target URL used for testing. Default points at local port-forward for ingress.
TARGET=${TARGET:-http://127.0.0.1:8080}

# -----------------------------------
# Showing stable deployment running
# -----------------------------------
echo "--------------------------------"
echo "Showing stable deployment running"
kubectl apply -f stable-deployment.yaml
kubectl rollout status deployment/stable-deployment
echo "--------------------------------"

# -----------------------------------
# Showing canary deployment running
# -----------------------------------
echo "--------------------------------"
echo "Showing canary deployment running"
kubectl apply -f canary-deployment.yaml
kubectl rollout status deployment/canary-deployment
echo "--------------------------------"

#Running the service
kubectl apply -f stable-service.yaml
kubectl apply -f canary-service.yaml
kubectl apply -f canary-ingress.yaml

# -----------------------------------
# Describe showing initial traffic split
# -----------------------------------
echo "--------------------------------"
echo "Describe showing initial traffic split"
kubectl describe ingress canary-ingress
echo "--------------------------------"

# -----------------------------------
# Multiple curl requests showing ~20% going to canary
# -----------------------------------
echo "--------------------------------"
echo "Multiple curl requests showing ~20% going to canary"
# Make 100 requests and count responses
stable_count=0
canary_count=0

# Make 100 requests
for i in {1..1000}; do
  response=$(curl -s -D - -o /dev/null -H "Host: myapp.local" "$TARGET" | awk -F": " 'tolower($1)=="x-deployment"{print tolower($2); exit}' | tr -d '\r')
  if [[ "$response" == "stable" ]]; then
    stable_count=$((stable_count + 1))
  elif [[ "$response" == "canary" ]]; then
    canary_count=$((canary_count + 1))
  fi
done

echo "Traffic distribution:"
echo "Stable: $stable_count"
echo "Canary: $canary_count"

echo "--------------------------------"

# -----------------------------------
# After promotion showing 50/50 traffic split
# -----------------------------------
echo "--------------------------------"
echo "After promotion showing 50/50 traffic split"
echo "Promoting canary to 50% traffic..."
kubectl patch ingress canary-ingress -p '{"metadata":{"annotations":{"nginx.ingress.kubernetes.io/canary-weight":"50"}}}'
kubectl describe ingress canary-ingress

echo "Testing traffic after 50/50 promotion..."
stable_count=0
canary_count=0

# Make 100 requests
for i in {1..1000}; do
  response=$(curl -s -D - -o /dev/null -H "Host: myapp.local" "$TARGET" | awk -F": " 'tolower($1)=="x-deployment"{print tolower($2); exit}' | tr -d '\r')
  if [[ "$response" == "stable" ]]; then
    stable_count=$((stable_count + 1))
  elif [[ "$response" == "canary" ]]; then
    canary_count=$((canary_count + 1))
  fi
done

echo "Traffic distribution:"
echo "Stable: $stable_count"
echo "Canary: $canary_count"

echo "--------------------------------"

# -----------------------------------
# Final state with 100% traffic to canary
# -----------------------------------
echo "--------------------------------"
echo "Promoting canary to 100% traffic..."
kubectl patch ingress canary-ingress -p '{"metadata":{"annotations":{"nginx.ingress.kubernetes.io/canary-weight":"100"}}}'
echo "Testing traffic after 100% promotion..."
stable_count=0
canary_count=0

# Make 100 requests
for i in {1..1000}; do
  response=$(curl -s -D - -o /dev/null -H "Host: myapp.local" "$TARGET" | awk -F": " 'tolower($1)=="x-deployment"{print tolower($2); exit}' | tr -d '\r')
  if [[ "$response" == "stable" ]]; then
    stable_count=$((stable_count + 1))
  elif [[ "$response" == "canary" ]]; then
    canary_count=$((canary_count + 1))
  fi
done

echo "Traffic distribution:"
echo "Stable: $stable_count"
echo "Canary: $canary_count"
echo "--------------------------------"