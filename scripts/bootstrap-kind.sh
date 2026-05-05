#!/bin/bash

set -e

CLUSTER_NAME="dev"

echo "🚀 Creating Kind cluster..."
kind create cluster --name $CLUSTER_NAME --config kind-config.yaml || true

echo "📦 Updating Helm dependencies..."
helm dependency update helm/charts/ingress-nginx
helm dependency update helm/charts/kube-prometheus-stack
helm dependency update helm/charts/loki

echo "🌐 Installing Ingress (Helm wrapper)..."
helm upgrade --install ingress-nginx helm/charts/ingress-nginx \
  --namespace ingress-nginx --create-namespace

echo "📊 Installing Monitoring (Helm wrapper)..."
helm upgrade --install monitoring helm/charts/kube-prometheus-stack \
  --namespace monitoring --create-namespace

echo "🧾 Installing Loki (Helm wrapper)..."
helm upgrade --install loki helm/charts/loki \
  --namespace monitoring

echo "⏳ Waiting for infra pods..."
kubectl wait --for=condition=ready pod --all -n ingress-nginx --timeout=180s || true
kubectl wait --for=condition=ready pod --all -n monitoring --timeout=180s || true

echo "🚀 Deploying applications (Kustomize)..."
kubectl apply -k k8s/overlays/dev

echo "⏳ Waiting for app pods..."
kubectl wait --for=condition=ready pod --all --timeout=180s || true

echo "✅ Setup Complete!"
kubectl get pods -A
