
This deploys the Istio operator. There are instructions here:
https://istio.io/v1.19/docs/setup/install/operator/

The istio-operator chart in the charts/ directory was copied (and modified -- see
details below) from the istio release which is available for download at
https://github.com/istio/istio/releases/ .
The chart is in `manifests/charts/istio-operator`.

# Changes from upstream chart:

In order to support pod priorities the deployment.yaml and values.yaml files
have been modified from upstream to support a priorityClassName.
