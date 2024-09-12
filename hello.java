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
