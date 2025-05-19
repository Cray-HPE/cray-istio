# Cray Istio Ingress Chart

Istio Ingress configuration for the Cray system.

The cray-istio-base chart creates the Istio CRDs that
are used by this chart (Gateways, VirtualServices, etc.).
This chart runs after the cray-istio-pilot chart which deploys istiod.

This chart specifically manages the Istio ingress gateway for the Cray system.
