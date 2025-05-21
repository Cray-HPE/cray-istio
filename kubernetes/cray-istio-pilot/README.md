# Cray Istio Pilot Chart

This chart deploys the Istio pilot (istiod) component for the Cray system.

The cray-istio-base chart must be installed first to create the necessary CRDs.
The cray-istio-ingress chart should be installed after this chart to deploy the ingress gateway.

There are instructions for Istio pilot/istiod here:
https://istio.io/v1.26/docs/setup/install/helm/

The istiod chart is pulled as a dependency from the Istio release which is available at
https://istio-release.storage.googleapis.com/charts

# Changes from upstream chart:

In order to support pod priorities and Cray-specific settings, the values.yaml file
has been configured with the following customizations:
- Set priorityClassName to csm-high-priority-service
- Configured meshConfig with accessLogFile and tracing settings
- Disabled CNI feature
- Configured replication (3) and autoscaling parameters (min: 3, max: 8)
- Set rolling update strategy (maxSurge: 100%, maxUnavailable: 1)
- Enabled HTTP probe rewriting with rewriteAppHTTPProbe: true
