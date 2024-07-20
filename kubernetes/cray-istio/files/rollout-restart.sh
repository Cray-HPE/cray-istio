#!/bin/sh
#
# MIT License
#
# (C) Copyright 2024 Hewlett Packard Enterprise Development LP
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# When upgrading from Istio 1.11.8 to 1.19.10 we need to rollout-restart because
# the istio-injection enabled namespaces doesn't get the latest image of istio.

set -x

# Function to check rollout status and handle errors
check_rollout_status() {
  resource_type=$1
  resource_name=$2
  namespace=$3

  kubectl rollout status $resource_type/$resource_name -n $namespace --timeout=1m
  if [ $? -ne 0 ]; then
    echo "Error: Rollout status check failed for $resource_type/$resource_name in namespace $namespace" >> errors.log
  fi
}

echo "**** Performing rollout restart for namespace: nexus ****"

timeout 60 kubectl rollout restart deployment -n nexus
echo "Waiting for 2.5 minutes before nexus rollout is finished..."
sleep 150

# Check rollout status for nexus
echo "**** Checking rollout status for namespace: nexus ****"
deployments=$(kubectl get deployments -n nexus -o jsonpath='{.items[*].metadata.name}')
for deployment in $deployments; do
  check_rollout_status deployment $deployment nexus
done


# If there were any errors in the nexus rollout status checks, exit with status 1
if [ -f errors.log ]; then
  echo "Errors were encountered during the rollout status checks for nexus:"
  cat errors.log
  rm errors.log
  exit 1
fi

# Retrieve namespaces with istio-injection=enabled label except nexus (handled separately) to prevent IPBO issue
namespaces=$(kubectl get ns -l istio-injection=enabled -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep -v '^nexus$' | tr '\n' ' ')

# Perform rollout restart for deployments, statefulsets, and daemonsets in each namespace
for namespace in $namespaces; do
  echo "**** Performing rollout restart for namespace: $namespace ****"
  timeout 60 kubectl rollout restart deployment -n $namespace 
  timeout 60 kubectl rollout restart statefulset -n $namespace 
  timeout 60 kubectl rollout restart daemonset -n $namespace 
done

echo "Rollout restart completed for all istio-injection enabled namespaces."
echo "Waiting for 5 minutes before checking rollout status..."
sleep 300

# Check rollout status for deployments, statefulsets, and daemonsets in each namespace
for namespace in $namespaces; do
  echo "**** Checking rollout status for namespace: $namespace ****"
  # Check rollout status for deployments
  deployments=$(kubectl get deployments -n $namespace -o jsonpath='{.items[*].metadata.name}')
  for deployment in $deployments; do
    check_rollout_status deployment $deployment $namespace
  done

  # Check rollout status for statefulsets
  statefulsets=$(kubectl get statefulsets -n $namespace -o jsonpath='{.items[*].metadata.name}')
  for statefulset in $statefulsets; do
    check_rollout_status statefulset $statefulset $namespace
  done

  # Check rollout status for daemonsets
  daemonsets=$(kubectl get daemonsets -n $namespace -o jsonpath='{.items[*].metadata.name}')
  for daemonset in $daemonsets; do
    check_rollout_status daemonset $daemonset $namespace
  done
done

echo "Rollout restart and status check completed for all istio-injection enabled namespaces."

# Report errors if any
if [ -f errors.log ]; then
  echo "Errors were encountered during the rollout status checks:"
  cat errors.log
  rm errors.log
else
  echo "No errors encountered during the rollout status checks."
fi
