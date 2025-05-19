# Cray Istio Base Chart

This chart deploys the Istio base components including CRDs for the Cray system.

The base chart is a prerequisite for both the cray-istio-pilot and cray-istio-ingress charts.
This chart should be installed first in the Istio deployment sequence.

There are instructions for Istio base components here:
https://istio.io/v1.26/docs/setup/install/helm/

The base chart is pulled as a dependency from the Istio release which is available at
https://istio-release.storage.googleapis.com/charts

# Changes from upstream chart:

In order to support pod priorities and Cray-specific settings, the values.yaml file
has been configured with the following customizations:
- Set priorityClassName to csm-high-priority-service
- Configured other Cray-specific global settings
