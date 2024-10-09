# cray-istio Upgrade Notes

## Description

Cray-Istio is a customized version of the Istio service mesh tailored for HPE's Cray supercomputers and high-performance computing (HPC) workloads. It optimizes Istio's performance to minimize overhead and maximize speed for demanding HPC tasks. Cray-Istio integrates seamlessly with HPE's HPC ecosystem, allowing coordinated management with schedulers and resource managers. It might also include additional security features relevant to HPC environments. This runs after cray-istio-deploy which creates the Istio CRDs that
are used by this chart (Gateways, VirtualServices, etc.).<br>
Understanding Cray-Istio builds upon the foundation of Istio, an open-source service mesh. Istio provides features like traffic management, security, and observability for microservices, making it valuable for managing complex HPC deployments.

## Pre-requisites

- As part of upgrading to a new version, make sure the latest version images are added to artifactory.
- Helm does not support upgrading CRDs during chart upgrade. They need to be upgraded explicitly which is handled as part of the templates.
- Make sure to update the latest CRDs in following:
  - <a href="https://github.com/Cray-HPE/cray-istio/tree/master/kubernetes/cray-istio-operator">cray-istio-operator</a>
  - <a href="https://github.com/Cray-HPE/cray-istio/tree/master/kubernetes/cray-istio-deploy">cray-istio-deploy</a>
  - <a href="https://github.com/Cray-HPE/cray-istio/tree/master/kubernetes/cray-istio">cray-istio</a>

## Upgrade

Once the changes are done, a tag can be pushed so that the helm charts are added to artifactory in stable directory. These charts can be deployed on a cluster using standard loftsman commands after applying the customizations over them.<br>

## STEPS

### Create sysmgmt.yaml like the following

```yaml
apiVersion: manifests/v1beta1
metadata:
  name: sysmgmt
spec:
  charts:
  - name: cray-istio-operator
    source: csm-algol60
    version: 1.27.0
    namespace: istio-system
    timeout: 10m
  - name: cray-istio-deploy
    source: csm-algol60
    version: 1.30.0
    namespace: istio-system
    timeout: 10m
  - name: cray-istio
    source: csm-algol60
    version: 2.11.1
    namespace: istio-system
    timeout: 20m
```

### Apply the following command to applying the customizations over them

```sh
manifestgen -c customizations.yaml -i sysmgmt.yaml -o sysmgmt-cust.yaml 
```

### Upgrade the charts using loftsman

```sh
loftsman ship --charts-path <tgz-charts-path> --manifest-path sysmgmt-cust.yaml 
```

---

## Troubleshooting: Istio-Proxy failing with too many open files

## Issue Description

After the CSM upgrade, some nodes with `Istio` might not have come up with the new `Istio-proxy` image due to too many open files so they need increased `fs.inotify.max_user_instances` and `fs.inotify.max_user_watches` values.
When pods with `istio-proxy` restart (such as after a power outage or node reboot), they may fail due to insufficient `inotify` resources, as the limits on the system are too low.

### Related Issue

- [Istio Issue #35829](https://github.com/istio/istio/issues/35829)

## Error Identification

When the issue occurs the following errors are emitted in the `istio-proxy` logs.

```sh
2024-07-22T17:00:37.322350Z info Workload SDS socket not found. Starting Istio SDS Server
2024-07-22T17:00:37.322393Z info CA Endpoint istiod.istio-system.svc:15012, provider Citadel
2024-07-22T17:00:37.322395Z info Opening status port 15020
2024-07-22T17:00:37.322436Z info Using CA istiod.istio-system.svc:15012 cert with certs: var/run/secrets/istio/root-cert.pem
2024-07-22T17:00:37.323487Z error failed to start SDS server: failed to start workload secret manager too many open files
Error: failed to start SDS server: failed to start workload secret manager too many open files
```

## Error Conditions

This issue manifests when:

- Pods are unable to create enough `inotify` instances to monitor required files.
- The system hits the maximum number of file watches, causing crashes or failures in services dependent on file system event monitoring.

This problem can be triggered by events like:

- A node dying and rebooting mid-upgrade.
- Power outages where pods restart on nodes with old kernel settings.

## Fix Description

Manually increase the `fs.inotify.max_user_instances` and `fs.inotify.max_user_watches` values to provide sufficient resources for Istio and other Kubernetes components.

```bash
pdsh -w ncn-m00[1-3],ncn-w00[1-5] 'sysctl -w fs.inotify.max_user_instances=1024'
pdsh -w ncn-m00[1-3],ncn-w00[1-5] 'sysctl -w user.max_inotify_instances=1024'
pdsh -w ncn-m00[1-3],ncn-w00[1-5] 'sysctl -w fs.inotify.max_user_watches=1048576'
pdsh -w ncn-m00[1-3],ncn-w00[1-5] 'sysctl -w user.max_inotify_watches=1048576'
```

---

## Contributing

See the <a href="https://github.com/Cray-HPE/cray-istio/blob/master/CONTRIBUTING.md">CONTRIBUTING.md</a> file for how to contribute to this project.

## License

This project is copyrighted by Hewlett Packard Enterprise Development LP and is distributed under the MIT license. See the <a href="https://github.com/Cray-HPE/cray-istio/blob/master/LICENSE">LICENSE</a> file for details.
