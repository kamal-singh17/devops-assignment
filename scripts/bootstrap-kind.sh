#!/bin/bash

set -e

CLUSTER_NAME="dev"

echo "🚀 Creating Kind cluster..."
kind create cluster --name $CLUSTER_NAME --config kind-config.yaml || true

echo "📦 Adding Helm repos..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "🌐 Installing Ingress Controller..."
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace

echo "📊 Installing Prometheus Stack..."
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace

echo "🧾 Installing Loki..."
helm upgrade --install loki grafana/loki-stack \
  --namespace monitoring

echo "⏳ Waiting for pods..."
kubectl wait --for=condition=ready pod --all -n ingress-nginx --timeout=120s || true
kubectl wait --for=condition=ready pod --all -n monitoring --timeout=120s || true

echo "🚀 Deploying applications (Kustomize)..."
kubectl apply -k k8s/overlays/dev

echo "✅ Setup Complete!"
echo "Check pods:"
kubectl get pods -A
