# Cray Istio Chart

Istio configuration for the Cray system.

The cray-istio-base chart creates the Istio CRDs that
are used by this chart (Gateways, VirtualServices, etc.).
This chart runs after the cray-istio-pilot chart which deploys the pilot.

This chart specifically manages the Istio ingress gateway for the Cray system.
