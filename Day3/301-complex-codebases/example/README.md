# xxxx Core

Welcome to the new home for the xxxx Platform codebase. This repository contains all the code to setup an inital xxxx platform cloud environment. Primary deployment items are:

- Base Infrastructure
- Compute Runtime (AKS)
- Supporting Services (Certificate signing, Ingress controllers, etc.)
- Application Specific Infrastructure

Each of these will be explained in more detailed sections that will be stored closer to the appropriate codebase folders in the repository.

# Contributing

We welcome all contributions to this repository! When submitting PRs please adhere to the default template that is added to all PRs. Review the requested bullet points and confirm they have been applied. 

We recognize that this pipeline is foundational to the xxxx platform and needs to run fully to production before any dependencies can be consumed downstream by other applications. To this end we request that all PRs include an expected deploy timeline to production along with the severity. To ensure the changes can be deployed inline with the application needs - this primarily will only be important if something needs to be deployed sooner than the end of sprint cadence (which will be the default)

## Branching strategy

This repository uses trunk based merging. Meaning each feature branch should be branched off of master and merged back into master for a PR. Please include a prefix indicating the type of change (feature, bug, tag), and a valid PBI. This would be something along the line of "feature/4321-Add-my-feature". A PBI will be required for the PR so we expect hose to be included in the feature branch itself. A merge into master will create a new release automatically, but the Autobots will be responsible for the deployment gates.

## Changelog

Given the size and amount of contributions to this repo in an effort to mitigate changelog conflicts all changes to this repo should have a corresponding file added in the changelog-unreleased folder in the root. This file should include the workitem associated and be a .md file based on the _template.md in that folder. As an example a file named 12345-Some-Meaningful-Description.md. This file should be updated with the appropriate level of detail. When a tag is ready to be cut all unreleased features will be consolidated into a single release note update with the new version of the tag. This will be a manual process for now, but efforts to automate this will be underway soon.

## Auto Pipelines 

Given that this pipeline is the foundation for other apps and consists of heavy infrastructure, an auto environment exists for a deployment validation before deploying to dev which can destabilize other application teams. To this end each stage of the pipeline has an auto pipeline with a targeted apply to vet changes. As a result it is expected that an auto pipeline execution should have been run for the applicable stage of the pipeline. This will be required for approvals to be granted. 

# Application Infrastructure

As a part of security hardening, the deployment of application specific infrastructure now lives in the xxxx_core repo and pipelines. Each application has its own folder containing the resources and infrastructure required by the application. 

The following application infrastructure is now deployed by xxxx_core:

- Identity Service
- Facilities Service
- Device Info Service
- Price Integration
- Edge

Application Infrastructure Folder Structure:

> ```
> services
> └── apps
>     ├── someApp
>     │   ├── tf
>     │   |   ├── someInfrastructure.tf
>     │   |   └── moreInfrastructure.tf
> ```

## Changes to APIs and Swagger Definitions


Applications that utilize APIM require one of the following, or both:

1. A swagger JSON file to import when standing up the API. To inject this dependancy into terraform, an updated copy of the swagger JSON must be committed to xxxx_core. To update this definition, open a PR to this repo and overwrite the existing JSON file found in the following directory:

> ```
> services
> └── apps
>     ├── someApp
>     │   ├── tf
>     │   |   ├── yourSwagger.json
> ```

2. Defined APIM using terraform.  The Azure RM Terraform Provider for Terraform has components for the API, API policies, the API operations, and everything else you need. https://www.terraform.io/docs/providers/azurerm/r/api_management.html

If you are using a swagger JSON import, you can still add individual operations, policies, etc. using terraform. An example can be seen under the identity_service apim.tf file.  There are two operations defined that are added to APIM after the swagger import, and these operations use a policy that overrides the one at the top of the API.  (/api/users/registration and /api/registration/checkCode/{code})

## Requesting Changes or New Infrastructure

To request new application infrastructure, or changes to existing infrastructure, please message Autobots on Teams or contact the product owner Sam (sam@xxxx.com).

# Compute Runtime (AKS)
The platform uses AKS as it's compute runtime for deploying and managing containers. There are many considerations that impact the logical and physical configuration of these clusters which is currently in flux, and will change over time. The goal is to keep this documentation in line with reality.

Currently for HA, there are 2 clusters for each environment to a paired region (eastus2 and centralus). These clusters are deployed to the platform base infrastructre - namely VNETs for isolation. The clusters Have an MSI enabled for interacting with other cloud resources.

## Cluster sizing
Until Isitio is fully enabled cross cluster load sharing is not possible. Which means we plan capcity based on only having 1 cluster (this will be revisited). Each environment may have different needs and can be configured with different node counts or SKUs.

Without known workloads on the clusters, starting off with default pod limits per node (110), with a reasonably sized sku, with the initial workloads of EDGE\LEAP deployed the nodes do not have around 40-50% usage. The current pod count in the production cluster is 87 pods:

```
kubectl get pods --all-namespaces --output json | jq -j '.items | length'
```
This does not account for additoinal Istio needs, but leaves plenty of head room. We did not wanted underpowered nodes with fragmented pods across 10 nodes to overburden the K8s scheduler. The other goal is to be able to sustain a node failure, with the current count we should have enough head room to run easily on 2 nodes (if the 3rd fails). This will be an evolving calculation we should revisit, particularly when isito is enabled as we will be able to leverage resoucres across regions.


|Environment | SKU | Node Count | Pods Per Node  | Maximum Pods |
|---|---|---|---|---|
|Auto | Standard_DS4_v2 | 2  | 110  | 220  |
|Dev  | Standard_DS4_v2  | 4  | 110  | 440   |
|Test | Standard_DS4_v2  | 3  | 110  | 330  |
|Stage| Standard_DS4_v2  | 3  | 110  | 330  |
|Pen  | Standard_DS4_v2  |  3 | 110  | 330  |
|Prod | Standard_DS4_v2  |  3 | 110  | 330  |

Current production node numbers (5/7/20)

```
NAME                            CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
aks-pool1-17439591-vmss000000   491m         6%     7867Mi          32%
aks-pool1-17439591-vmss000001   503m         6%     7453Mi          31%
aks-pool1-17439591-vmss000002   555m         7%     7858Mi          32%
```

# Ingress 

Ingress is a broad topic that at a high level covers how traffic is routed into the K8s cluster. Generally speaking as a platform this is done through ingress definitions. There should be NO services exposed directly on a load balancer. The preferred method to expose traffic to the internet is through the defined platform ingress controllers with annotations.

https://kubernetes.io/docs/concepts/services-networking/ingress/#the-ingress-resource

Outside of the AKS there is a DNS Zone and traffic manager that needs to be managed to allow all inbound traffic for the web UIs. 

## Traffic Manager

Traffic manager is deployed as part of the core services pipeline, where the known or expected endpoints are registered for each cluster location (eastus2/centralus) and environment (dev/test/etc.) This entry will create the main entry point for the application (portal-stage.xxxxtechnology.com, leap-stage.xxxxtechnology.com, etc) this will then point to a traffic manager endpoint with the expected cluster DNS entries registered (portal-stage-eastus2.xxxxtechnology.com, portal-stage-centralus.xxxxtechnology.com, etc.). The location specific endpoints will automatically be registered

## DNS Zone 

The DNS Zone is updated both by terraform and autmatically be ExternalDNS which is a pod running locally on the clusters. It will scan for Ingress rules to create DNS entries with the corresponding IP of the loadbalancer for the cluster). There is an annotation filter on some ingress because we do not want them updated by the cluster (for example portal-dev.xxxxtech.dev) this is a location agnostic address so it will be registered through the DNS terraform deploy to point to TM. However the NGINX ingress controller (read below) requires the ingress of that hostname to support connections from the browser to portal-dev.xxxxtech.dev. The work around for this is that rather than having a single rule with 2 hostnames. They are split into 2 Ingress objects each with it's own hostname:

For example:
```
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: "ui-location"
  namespace: "ingress"
  labels: 
    app.kubernetes.io/managed-by: "kustomize-deploy"
  annotations: 
    xxxx.dns/exposed: "true"
    kubernetes.io/ingress.class: ext01
    nginx.ingress.kubernetes.io/ssl-redirect: "false"

spec:
  rules:
    - host: "portal-dev-eastus2.xxxxtech.dev"
      http:
        paths:
          - backend:
              serviceName: "ui-proxy"
              servicePort: 80
  tls:
    - hosts:
      - "*.xxxxtech.dev"
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: "ui"
  namespace: "ingress"
  labels: 
    app.kubernetes.io/managed-by: "kustomize-deploy"
  annotations: 
    xxxx.dns/exposed: "false"
    kubernetes.io/ingress.class: ext01
    nginx.ingress.kubernetes.io/ssl-redirect: "false"

spec:
  rules:
    - host: "portal-dev.xxxxtech.dev"
      http:
        paths:
          - backend:
              serviceName: "ui-proxy"
              servicePort: 80
  tls:
    - hosts:
      - "*.xxxxtech.dev"
---
```
Noe that both point to the same backend, but the Ingress without location has the custom attribute xxxx.dns/exposed: "false", which will be ignored by ExternalDNS, but NGINX will still consume it as a valid hostname for routing traffic

## Ingress Controller

Currently the xxxx platform deploys an NGINX ingress controller for Internal (int1) and External (ext1) traffic. The internal traffic exposes the endpoint on an IP in the same subnet as the APIM instance. This will allow for traffic to be fronted by APIM - This should be leveraged for all API endpoints. Web front end traffic can be exposed through the external ingress controller. 

## Ingress Definitions

Ingress will be controller by ingress definitions. Traditionally these were deployed by application teams - in an effort to manage HA and DR this will begin consolidation into this pipeline. As a result - under the services\ingress\apps folder the ingress definitions can be found. These leverage Kustomize to manage overlays of different environments for the appropriate DNS name. This may change in the future to be totally dynamic - but give how important ingress is this is manually managed through Kustomize templates. The resulting output is a YAML that has the correct values - directly deployed to the clusters in the devops pipeline.

### How kustomize applies

Kustomize allows for templating of raw YAML without the overhead of helm for end deployments to the cluster. As such we have adopted this approach for deploying the raw YAML ingress definitions. Read more about customize here 
https://github.com/kubernetes-sigs/kustomize

This overview of the folder structure is as follows:

> ```
> ~/someApp
> ├── base
> │   ├── external.yaml
> │   ├── internal.yaml
> │   └── kustomization.yaml
> └── overlays
>     ├── auto
>     │   ├── centralus
>     │   |   ├── kustomization.yaml
>     │   |   └── portal_ui_patch.json
>     |   |── eastus2
>     │   |   ├── kustomization.yaml
>     │   |   └── portal_ui_patch.json
>     |   └── internal
>     │       ├── kustomization.yaml
>     │       └── internal.json
>     ├── dev
>     │   ├── centralus
>     │   |   ├── kustomization.yaml
>     │   |   └── portal_ui_patch.json
>     |   |── eastus2
>     │   |   ├── kustomization.yaml
>     │   |   └── portal_ui_patch.json
>     |   └── internal
>     │       ├── kustomization.yaml
>     │       └── internal.json
>     ├── test
>     │   ├── centralus
>     │   |   ├── kustomization.yaml
>     │   |   └── portal_ui_patch.json
>     |   |── eastus2
>     │   |   ├── kustomization.yaml
>     │   |   └── portal_ui_patch.json
>     |   └── internal
>     │       ├── kustomization.yaml
>     │       └── internal.json
>     ├── stage
>     │   ├── centralus
>     │   |   ├── kustomization.yaml
>     │   |   └── portal_ui_patch.json
>     |   |── eastus2
>     │   |   ├── kustomization.yaml
>     │   |   └── portal_ui_patch.json
>     |   └── internal
>     │       ├── kustomization.yaml
>     │       └── internal.json
>     ├── pen
>     │   ├── centralus
>     │   |   ├── kustomization.yaml
>     │   |   └── portal_ui_patch.json
>     |   |── eastus2
>     │   |   ├── kustomization.yaml
>     │   |   └── portal_ui_patch.json
>     |   └── internal
>     │       ├── kustomization.yaml
>     │       └── internal.json
>     └── prod
>         ├── centralus
>         |   ├── kustomization.yaml
>         |   └── portal_ui_patch.json
>         |── eastus2
>         |   ├── kustomization.yaml
>         |   └── portal_ui_patch.json
>         └── internal
>             ├── kustomization.yaml
>             └── internal.json
> ```

In the \services\ingress\apps folder all the kustomize configuration is located. There is a base folder that serves as the starting point. This folder contains the base definitions for internal and external ingress rules. From there an environment will have a folder, and regions will have a folder. At the lowest level each environment and region will have its own override applied. Currently internal does not have multi region support until APIM is enabled for it.

###Proxy place holders

All ingress is being consolidated under the ingress namespace for the sake of centrally managing it - particularly for failover and HA scenarios that need to be managed at a cluster level. The ingress controller will be scoped to the ingress namespace. Ingress definitiations can only target services in the same namespace. Meaning the centralized ingress namespace ingress definitions can not directly link to services in other namespaces like LEAP, EDGE, etc. As a stop gap. a service proxy is being created in the ingress namespace. This will be denoted with the -proxy postfix, and should match the service name otherwise. This proxy service should be of type "ExternalName" with an externalName value of the local DNS entry in the cluster (which can cross namespaces). This approach will likely need to be revisted with service discovery on the horizon and istio, but for now this work around should suffice. This can also be setup on port 80 as the SSL termination will have occured at the ingress controller. 

Example:

```
apiVersion: v1
kind: Service
metadata:
  name: edge-enterprise-operations-ui-proxy
  namespace: ingress
spec:
  type: ExternalName
  externalName: edge-enterprise-operations-ui.edge.svc.cluster.local
  ports:
  - port: 80
```

in the Ingress namespace corresponds to the following service in the EDGE namespace

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
   annotations:  
     kubernetes.io/ingress.class: ext01
     nginx.ingress.kubernetes.io/rewrite-target: /edge-enterprise-operations-ui/
   name: edge-enterprise-operations-ui
spec:
   rules:
   - host: edge-dev.xxxxtech.dev
     http:
      paths:
      - path: /edge-enterprise-operations-ui/
        backend:
          serviceName: edge-enterprise-operations-ui
          servicePort: 40400
   tls:
   - hosts:
     - *.xxxxtech.dev
```



## External DNS

External DNS is configured to monitor ingress resources in ALL namespaces. This will detect when a new ingress has been deployed and handle updating the DNS Tied to the appropirate domain based on the environment (xxxxtech.dev vs xxxxtechnology.com). Currently this only monitors those domains and ingress resources.


https://github.com/kubernetes-sigs/external-dns

## SQL Server / SQL Databases
Wiki: https://rd.visualstudio.com/Platform/_wiki/wikis/Platform.wiki/1131/SQL-Database-Creation-Access-Management

A single SQL Server instance is being created and maintained for all application services.  It was created initially for use by the Taxonomy Service but will eventually be expanded to be used by all application services.  Existing services will need to migrate their data after infrastructure for their databases is set up.  An example of the database-specific logic can be found in the `services/apps/taxonomy_service`.

All applications that require privileged SQL logins that will be scoped to their database will need to pass in a database name & pipeline name as a parameter found in `pipeline/templates/services/deploy.yaml`.

Note to add additional databases an additional block needs to be added to the pipeline:

```
trigger: 
  branches:
    include:
    - feature/*
  paths:
    include:
    - pipeline/templates/services/apps/sql_access_management.yaml

jobs:
- template: ../../templates/services/apps/sql_access_management.yaml
  parameters:
    clusterId: auto
    environment: auto-platform
    subscriptionName: AzurexxxxNonProd
    dependsOn: []
    databases: 
      - database: taxonomy-service
        pipelinename: taxonomy
      - database: task-management
        pipelinename: taskamanagement
```

Note the structure, the pipeline name can ONLY container letters and _ (no dashes)

## APIM Authentication

xxxx endpoints exposed through APIM (publically) should be secured by Okta tokens. At a high level this should be turns on for the API definition through a policy for example:

```xml
<policies>
    <inbound> 
        <validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized" require-expiration-time="true" require-scheme="Bearer" require-signed-tokens="true">
            <openid-config url="https://dev.oktapreview.com/oauth2/default/.well-known/openid-configuration" />
        </validate-jwt>
        <cors>
            <allowed-origins>
                <origin>http://127.0.0.1:8000</origin>
                <origin>http://127.0.0.1:8080</origin>
                <origin>http://localhost:8000</origin>
                <origin>http://localhost:8080</origin>
                <origin>${portal_url}</origin>
            </allowed-origins>
            <allowed-methods>
                <method>GET</method>
                <method>POST</method>
                <method>PUT</method>
                <method>DELETE</method>
                <method>PATCH</method>
            </allowed-methods>
            <allowed-headers>
                <header>Origin</header>
                <header>X-Resuested-With</header>
                <header>Accept</header>
                <header>Authorization</header>
                <header>Content-Type</header>
                <header>If-None-Match</header>
            </allowed-headers>
        </cors>
    </inbound>
</policies>
```

This is a bare bones configuration but claims within the token can also be validated. The openid-config url is critical for validating the token. With xxxx a custom endpoint is implemented per environment to support custom claims. As a result this URL should be managed per environment with the following format:

```
  <validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized" require-expiration-time="true" require-scheme="Bearer" require-signed-tokens="true">
            <openid-config url="https://<env>.oktapreview.com/oauth2/<custom_env_tenant>/.well-known/openid-configuration" />
        </validate-jwt>
```

## Product consumption

This repository is moving towards more of a configuration based approach for how it stands up infrastucture. The product configuration will be driven from the "product" repository. The outputs of this repo will be ingested by xxxx_core to iterate on for infrastrucutre needs. This is a process that will take a while to cut over to, but will be the long term path forward for maintaining infrastrcuture needs for n products.

Products will be given their own namespace to deploy and run in, as defined here: https://xxxx-rd.visualstudio.com/Platform/_wiki/wikis/xxxx%20xxxx%20Security/1383/Security-Model

As described in the above document the security model is moving to an AAD service principal based model, where products need to connect as their respective identity to consume azure resources. Each namespace will contain a config map that can be consumed by the runtime (deployed app). This config map contains only the client id currently:

```
{
  "product_app_id" = "1244a9f6-1608-4eba-8890-65611d6e3816"
}
```

Over time this will likely grow as a common way to access platform configuration. Additionally the paired secret would be served from key vault (likely to change with vault in the mix) using the convention "platform-product-sp-app-runtime-<env>-<product>" for example "platform-product-sp-app-runtime-dev-edge"

With the id and secret an app should be able to assume the runtime SP context and use that for it's operations against azure resources. Long term we hope to abstract this further as a pod identity requiring even less changes on the product\app side.
