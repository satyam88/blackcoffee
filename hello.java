what i wanted to say here is instead of maintaing nginx-igress, istio-ingress, istio-service and many other post  aks deployment stuff sepratelly for each pod, can't we create a common repo like layer-kube which should have  helm configuration file for nginx-igress, istio-ingress, istio-service and should have gitlab.yaml which sould created a helm-release-v1.0.zip (auto-incremented ) and gitlab.yaml should have another terraform  stage which should deploy these helm release as terraform resource to all the ATcodes


 layer-kube/
├── helm-charts/
│   ├── nginx-ingress/
│   │   └── values.yaml
│   ├── istio-ingress/
│   │   └── values.yaml
│   ├── istio-service/
│   │   └── values.yaml
│   └── ...
├── global-values.yaml
├── gitlab-ci.yaml
├── terraform/
│   └── main.tf
└── README.md

We have already Service connection 
What is a Revision in Istio?
A revision in Istio represents a distinct version of the control plane components (such as istiod). Each revision runs independently, allowing you to have multiple versions of Istio running side-by-side within the same cluster. This way, you can gradually migrate workloads to a new version of Istio by labeling namespaces, reducing the risk of outages or failures during upgrades.

How Does the Revision Mechanism Work?
Install Istio with a Revision Tag: When installing Istio, you can specify a revision to differentiate between different control plane versions. For example:

bash
Copy code
# Install Istio with a specific revision (e.g., 1-16-0)
istioctl install --set revision=1-16-0 -y
This command installs Istio under the revision 1-16-0, which can be any string (often reflecting the version, like 1-16-0).

Label Namespaces with the Revision: To use a specific Istio revision for sidecar injection in a namespace, you label the namespace with istio.io/rev=<revision> instead of istio-injection=enabled.

bash
Copy code
# Label the default namespace with a specific Istio revision
kubectl label namespace default istio.io/rev=1-16-0 --overwrite
This label tells Istio to inject the sidecars managed by the specified revision (1-16-0) of the control plane when new pods are created in this namespace.

Key Differences Between istio-injection=enabled and istio.io/rev=<revision>
istio-injection=enabled: This label tells Istio to use the default (non-revisioned) control plane for sidecar injection. It does not specify a particular version of Istio.

istio.io/rev=<revision>: This label specifies that the namespace should use the sidecar injector of the specified control plane revision. It allows you to direct traffic to a particular Istio version.
