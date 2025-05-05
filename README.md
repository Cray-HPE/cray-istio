# cray-istio Upgrade Notes
 
## Description
Cray-Istio is a customized version of the Istio service mesh tailored for HPE's Cray supercomputers and high-performance computing (HPC) workloads. It optimizes Istio's performance to minimize overhead and maximize speed for demanding HPC tasks. Cray-Istio integrates seamlessly with HPE's HPC ecosystem, allowing coordinated management with schedulers and resource managers. It might also include additional security features relevant to HPC environments. This runs after cray-istio-base which creates the Istio CRDs that
are used by this chart (Gateways, VirtualServices, etc.).<br>
Understanding Cray-Istio builds upon the foundation of Istio, an open-source service mesh. Istio provides features like traffic management, security, and observability for microservices, making it valuable for managing complex HPC deployments.
 
## Pre-requisites
- As part of upgrading to a new version, make sure the latest version images are added to artifactory.
- Helm does not support upgrading CRDs during chart upgrade. They need to be upgraded explicitly which is handled as part of the templates.
- Make sure to update the latest CRDs in following:
    - <a href="https://github.com/Cray-HPE/cray-istio/tree/master/kubernetes/cray-istio-base">cray-istio-base</a>
    - <a href="https://github.com/Cray-HPE/cray-istio/tree/master/kubernetes/cray-istio-pilot">cray-istio-pilot</a>
    - <a href="https://github.com/Cray-HPE/cray-istio/tree/master/kubernetes/cray-istio-ingress">cray-istio-ingress</a>

## Upgrade
Once the changes are done, a tag can be pushed so that the helm charts are added to artifactory in stable directory. These charts can be deployed on a cluster using standard loftsman commands after applying the customizations over them.<br>

## STEPS:

### Create sysmgmt.yaml like the following:

```yaml
apiVersion: manifests/v1beta1
metadata:
  name: sysmgmt
spec:
  charts:
  - name: cray-istio-base
    source: csm-algol60
    version: 1.0.0
    namespace: istio-system
    timeout: 10m
  - name: cray-istio-pilot
    source: csm-algol60
    version: 1.0.0
    namespace: istio-system
    timeout: 10m
  - name: cray-istio-ingress
    source: csm-algol60
    version: 4.0.0
    namespace: istio-system
    timeout: 20m
```

### Apply the following command to applying the customizations over them:

```sh
manifestgen -c customizations.yaml -i sysmgmt.yaml -o sysmgmt-cust.yaml 
```

### Upgrade the charts using loftsman:

```sh 
loftsman ship --charts-path <tgz-charts-path> --manifest-path sysmgmt-cust.yaml 
```

## Contributing
See the <a href="https://github.com/Cray-HPE/cray-istio/blob/master/CONTRIBUTING.md">CONTRIBUTING.md</a> file for how to contribute to this project.
 
## License
This project is copyrighted by Hewlett Packard Enterprise Development LP and is distributed under the MIT license. See the <a href="https://github.com/Cray-HPE/cray-istio/blob/master/LICENSE">LICENSE</a> file for details.