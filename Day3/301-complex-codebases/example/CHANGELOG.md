# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.11.2
### Added 
- Custer sizing to readme
- Istio namespace
- Istio ca cert

### Changed 
- Account for conditional resources (citadel certs) in outputs for prod realm

## 1.11.1
## Changed
- Downgrading Helm Chart for external-dns public

## 1.11.0
### Added 
- support for namespace labels (this is how we support istio-injection per namespace)
- Public Ip Prefix (4 addresses - 2 per region)
- Added new vnet for eastus2 which now houses the eastus2 cluster to services infra subnets
### Changed
- product.k8s.namespace is now expected to be a nested object, so all for_each loops on local.namespace have been updated to reflect this. See upstream [Product](https://xxxx.visualstudio.com/Platform/_git/product/pullrequestcreate?sourceRef=feature%2F16487-istio-property&targetRef=master&sourceRepositoryId=f919e1a2-0b9b-4844-9c46-f789da1b4ba3&targetRepositoryId=f919e1a2-0b9b-4844-9c46-f789da1b4ba3) repo for details.
- Changed the APIM policy for IAM on the /registration/checkCode endpoint to a "Contains" instead of "Equals", as the endpoint includes a code in the path that will be different each time.
- AKS module version0
- Realigned eastus2 vnet connection
- Moved to MSI for AKS
- Updated AKS version 1.16.7
- Updated pods per node to 110
- Upgraded to standard LB for AKS
- Rebuilt AKS cluster
- Updated deprecated property address_prefix to address_prefixes
- Updated K8 api version for external metrics chart (Deployment in apps/v1beta2 no longer supported https://kubernetes.io/blog/2019/07/18/api-deprecations-in-1-16/)
- Updated module for flexvol, tiller
- Changed external DNS for private zones
- Updated syntax for external DNS release
- Connected APIM gateway subnet to that of eastus2
- Output to account for prod realm on limited keyvaults

### Removed
- Manually created AKS SPs
- Removed VNET rbac
- Namespace var for metric-reader local module
- Removed legacy vnet not region specific from Private DNS Zone vnet links, replaced with eastus2 and centralus vnets
- Disabling example okta app in Auto while researching consent_type bug

## 1.10.3
### Added 
- Storage Account private in core/services, storage containers private available for all products in /services
- Storage Account public in core/services, storage containers public available for all products in /services
- Outputs for storage account ID, name, primary connection string, primary key
- Nonsensitive cluster outputs for downstream consumption
- /api/entitlement/validate endpoint added to IAM
- Added Edge runtime sp to xxxx eventhub

### Changed
- Default WITH SCHEMA changed from db_owner to dbo in DB permissions assignment script
- Rewired to use artifact for ingress deploy
- Changed Edge Event Hub permissions to point to new runtime
- Edit device role endpoint in DeviceInfo Service

### Removed
- Remove cluster storage class
- Model Marketplace
- Cleanup pipeline CLI commands for runbook automation service principal

## 1.10.2
### Added 
- DB Roles to respective DB accounts.

### Changed
- Okta domain for prod
- switched sp id to app id stored as a key vault secret

### Removed
- Previous Database assignments

## 1.10.1
### Added
- Added a null check around deletion of automation service principal

## 1.10.0
### Added 
- Added tagging module to all infrastructure in /core
- Added tagging module to all services in /services/infrastructure
- IAM Endpoint for Entitlements by Okta Id
- IAM Endpoints for "Update client name in Okta" and "Create a client group"
- Added citadel certs
- Add support for var.products-based AKS and k8s features tied to AD group ids
- AKS user role access mapped to product_aks_user_group_id, a property of the aks product feature
- Each product that specifies the k8s.product_namespace property will have a namespace and two role bindings created:
  1. ns admin bound to product_namespace_admin_group_id
  2. ns viewer bound to product_namespace_viewer_group_id
- Each product that specifies is_k8s_global_viewer will have a clusterrolebinding bound to product_k8s_global_group_id
- Automation for Okta users
- Example automation for Okta apps
- New endpoints for Device Info:  /api/v2/Dimensions/Client/{clientid} and /app/v2/DimensionTypes
- Lifecycle hook for Okta app
- Min numeric rule for Okta password
- IoT related outputs (hubs, dps)
- IAM Endpoint to "Associates list of permissions to user"

### Changed
- Updated Client Configuration swagger definition
- Revved Pipeline Template Terraform version to 2.5.4
- Existing AKS/k8s config moved to core/compute/tf/modules/k8s_config/legacy.tf so it is easy to remove later
- mod_locals products that existed prior to this commit was renamed to legacy_products, to make it easy to remove later
- namespace and namespace limit resources remapped to var.products
- keyvault-roles remapped to var.products
- Added min upper/lower characters to okta user passwords
- Replace Edge Service Bus pipeline variable with pipeline artifacts

### Removed
- Removed SQL data warehouse
- Removed azure automation account associated to data warehouse and associated scripts
- Removed keyvault cert tied to `{cluster}-runbook-automation-sp`
- [env]-[product]-product-runtime/deployment accounts from db groups
- deleted xxxxdb-[env]-read/write-[database] permissions from databases
- platform-data was removed from legacy_products object since it is unused. It is now fully managed by var.products
- State commands for identity/facility service recreation
- Removed pipeline step to lookup IoT inputs, leveraging TF outputs instead

## 1.9.2
### Added 

### Changed
- mod_locals merging to avoid overwriting environment prod settings with realm prod settings

### Removed

## 1.9.1
### Added 
- Temporarily added Product Runtime to admin database group until permissions can be laxed.
- Role definition for the creation of dashboards to the observability sp
- Role assignment applied to observability sp
- Role definition created to assign read access to xxxxterraformbackend Storage account and full permissions to containers inside of SA
- Added pipeline parameters to consume the artifacts of the 'products' repo in compute and infrastructure stages
- New product pipeline output for consumption in services infrastructure
- New product based SP password creation to services
- New variable input from other pipelines or stages for some variables - starting the pathway to decoupling remote state
- Config map to product namespace with product_app_id value for consumption
- IAM (identity service) endpoint for group entitlements
- Terraform state commands to remove thrashing Terraform resources for Identity/Facility API endpoints & policy. 
### Changed
- Moved service connection to a post step after services infrastructure
- Upgrading Terraform pipeline template to 2.5.2
- Re-enabling enablePublishOutputArtifact on Terraform stages
### Removed
- Removed preinit terraform commands from compute stage
- Removed access to service connection to product write groups
- Changed FS and IAM such that all endpoints are imported via swagger and we have a consolidated policy that applies to the API with exceptions made for a couple endpoints in each one.

## 1.9.0
### Added
- Edge output variables
	- eventhub_name
	- eventhub_namespace_name
	- eventhub_consumergroup_name
- Added app centric app id as a secret with convention "<product>-product-runtime-app-id"
- Support for products and product-driven AKS configuration and permissions
- Product deployment service principal role binding as namespace-scoped cluster-admin
- ClusterRoleBinding for product contributor group to be cluster-wide admins with flag
- ClusterRoleBinding for product reader group to be cluster-wide viewer with flag
- RoleBinding for product contributor group to be namespace-scoped cluster-admin
- RoleBinding for product reader group to be namespace-scoped viewer
- AKS Admin permissions added for deployment service principal with flag
- AKS User permissions added for runtime service principal with flag
- Support non-AD ServiceAccounts for products in order to continue support for existing ADO service connections
- New azure kv kubeconfig keys for service connections using local k8s service accounts
- Added app_url tag to service principal key vault tags
- Stubbed 'assume role' in ADO connections script for future support of kubeconfig query to replace non-AD ServiceAccounts
- Added a postPlanInitStep to move existing namespaces in remote state into new resources and resource local names to preserve them
- Pipeline Service Principal to AD SQL Admin Group
- Added DBO permissions to Product Deployment Group per database
- Added Database Writer SP to Product Deployment Group
- Added Database Writer SP and Database Reader SP for Identity Service, Taxonomy Service, and LEAP databases

### Changed
- updated client configuration swagger definitions in apim_resources folder of the client configuration module
- Upgraded Terraform pipeline template to 2.5.0 to allow for pipeline output artifacts
- Deprecated non-product-based configs
- Deprecated tiller
- Simplified ClusterRoleBindings and RoleBindings
- All existing resources refactored to support product-driven configuration
- kubeconfig moved from tf_k8s_namespace into template

### Removed
- Unused templates and parameters from non-Terraform pipelines
- cluster_auth module removed in order to support for_each loops on products for product-driven configuration
- products do not reference tf_k8s_namespace module
- cluster-wide viewer cluster role binding for all namespaces
- cluster-wide cluster-admin cluster role binding for all namespaces

## 1.8.0 
### Added 
- New wifi configuration endpoint to the device Info Service swagger
- DeviceInfo Endpoints to support Location Attributes Screen

### Changed
- Updated some model values in the Device Info Service Swagger
- removed unneeded oktaTokenId from request message
- Modified output to only include storage account secret names, not entire secret object
- Updated TF template tag to support complex variable group outputs
- updated the client config swagger json file in the apim_resources folder
### Removed

## 1.7.0
### Added 
- SP role assignment for Edge Storage Container (platform-public-storage-blob-data-contributor-role)
- SP role assignment for Public Internet Platform Storage account (edge-storage-blob-delegator-role)
- Endpoint to Support Location Attributes Screen (/api/clients/UI/{clientId})
- added additional output to client-configuration output.tf and infrastructure output.tf

### Changed
- Reduced node counts for dev and test to 4 nodes. 2 for Auto

### Removed

## 1.6.0
### Added
- Added an output of IoT Hub connection string secret names for the Enterprise API 
- New policy for file-upload-content blob container to remove files 7 days after modification
- apim-demo k8s deployment test
- apim-injector README
- Added platform-data access to ADF, KV, and Databricks
- Added platform-data as a product
- Added additional tags to KV secret for downstream service connection processing
- Added EDGE SQL DB in Application Data SQL Server
- Created Device Telemetry Consumer Group, Assigned role to service principal with Consumer Group Scope
- Edge storage container to centralized storage account
- SAS token for edge storage account
- Keyvault entry for SAS token
- Outputs for name of Edge Container SAS token Keyvault entry
- Automation for creating Azure service connections for the product deployment apps
- Storage account that is publicly accessible.
- Output for newly created storage account name
- Output for primary key name stored in key vault
- Connection string name in keyvault for new storage account
- Added observability as a product

### Changed
- Cleanup Services Infrastructure outputs
- Replaced `cluster_id` with `environment_id` in EDGE module

### Removed
- State manipulations required for AzureRM 2.0 upgrade
- APIM subscription key requirement on FS, IS, TS on all environments by updating the pipeline to run the same post-process.ps1 script used by LEAP and EDGE to do the same
- Removed the APIM Subscription Key requirement from the following xxxx Platform external APIs:
    * 'facilities-service',
    * 'client-config-api',
    * 'data-retrieval-api-v2',
    * 'data-retrieval-external-api-v2',
    * 'deviceinfo-api',
    * 'edge-asset-engine-api',
    * 'edge-enterprise-api',
    * 'edge-enterprise-api-external',
    * 'identity-service',
    * 'ingestion-api-v2',
    * 'leap-services',
    * 'taxonomy-service'
## 1.5.0
### Added
- DNS TXT records for Okta domain verification
- Added product security config. Creation of Apps\SPs for runtime and deployment functionalities downstream, added outputs

### Changed
- Upgraded Terraform AzureRM Provider to 2.2

### Removed

## 1.4.1
### Added 
- additional output for store-traffic password secret name
- additional output for xxxx_common RG name for use in LEAP pipelines
- inject-apim helm chart
- realm-nonprod-vars (pipeline var template)
- auto-vars (pipeline var template)
- Additional DeviceInfo endpoints
  - GET​/api​/v2​/DeviceRoles​/Client​/{clientId}
    - Gets all device roles for the specified client v2
  - POST ​/api​/v2​/DeviceRoles​/Client​/{clientId}
    - Creates a device role with device profiles v2
  - GET ​/api​/v2​/DeviceRoles​/Client​/{clientId}​/{deviceRoleId}
    - Gets the specified device role v2

### Changed
- Updated compute azurerm provider to 2.2
- update pipeline-auto-apim-injector to deploy helm chart to auto environment/clusters
- converted LEAP and Price Integration "azurerm_azuread" resources to the "azuread" Terraform provider
- Fixed all template files to have the correct naming convention
- Fixed edge-manager traffic manager endpoints to match ingress configuration
- Fixed formatting bug in edge dev centralus rules

### Removed
- state commands for private DNS zone migration
- Removed deprecated SQL server admin AD group

## 1.4.0
### Changed
- Updated the AKS module to the new template to support the AzureRM 2.0 provider.

## 1.3.2
### Added 
- IoT Edge enrollment group, templatized enrollment group script
- Added IoT edge Intermediate CA for device signing
- Added IoT edge Intermediate Signer to APIM
- New Clients endpoint in device info apim

### Changed
- Migrated DNS zone to private DNS zone
- Updated Enrollment group script to use edge-enabled flag
- Switched extension for iot to get latest edge-enabled CLI option

## 1.3.1
### Added 
- Added the edge content render request and response queues.
- Updated the output names as per standards.
- Added the missing output variables for edge content render queues
- Added Apim_resources folder
- Added policy and swagger_definitions folders in apim_resources
- Added policy files and swagger file to folders
- Added apim.tf in client_configuration module
- Added new variables to module variables.tf
- local variables for databricks sku tier based on environment
- ARM template for deploying APIM API
- Dockerfile to build container to execute ARM template deployment
- Auto pipeline to test APIM injector
- Script to enable TDE if not enabled on SQL DW after infra is deployed
- Added internal ingress rule for config mgmt
- Ip Range filter for Leap Cosmos Db, leap_queue_listener
- Added SQL Server FQDN output
- Added LEAP Device Actuals password secret name output
- Added SQL Server FQDN output
- Added LEAP Device Actuals password secret name output
- Added internal ingress rule for config mgmt

### Changed
- Changed client_configuration module in infrastructures main.tf
- Updated Edge PostgreSQL to latest module version
- Enabled Auto Grow on PostgreSQL
- Reduced vCores in Auto, Dev, Test, Pen for Edge PostgreSQL
- switched hardcoded sku value for databricks to local variable based on environment
- Enabled TDE on DW
- Revved the SQL module for DW, renamed SQL Server to have generated postfix
- Updated name of data sql wh server name to use local variable
- Upgraded the docker template ref from 2.0.1 to 2.0.5
- Added explicit buildContexts and dockerfile refs for existing cluster signer and device signer builds
- fixed auto builds for cluster and device signers
- Migration storage account name as a means to remove any db migration backups

### Removed
- Removed LEAP Cosmos DB resources
- Removed legacy LEAP storage account, related outputs
- Removed legacy LEAP SQL database\servers, related outputs

## 1.3.0

### Added
- AAD group for Datalake read only access to storage account
- AAD role assignment for Storage Blob Data Reader access
- AD Groups Active Directory administration on SQL / Postgres servers
- AD Groups for read/write permissions on SQL / Postgres databases

## 1.2.2
### Added 
- read-only accounts to be used by ADF for the leap-device-actuals SQL database
- Added store traffic database to platform SQL server
- Added output to root for leap container
- Compute subnets to LEAP cosmos accounts
- AAD groups for LEAP cosmos access (read/write)
- Platform SQL database for LEAP Optimizer

### Changed
- Changed the names of the application data SQL Server outputs for specificity
- fixing output references for sql_elastic_pool and sql_server_name pulling
- Changed name of leap container in centralized storage from "media" to "leap".
- Changed output value of container to reflect change in container name
- The endpoints for "api/registration/checkCode/{code}" and "api/users/registration" need to work without JWT because they are accessed before user registration.  Removed these from the swagger definition so they won't auto-create and created them individually in apim.tf under identity_service using a policy that does not require JWT. 
- Updated IoT Edge Enrollment Group name

## 1.2.1
### Change
- Fix EDGE ingress host

## 1.2.0
### Added 
- Key vault secret for device actuals connection string, in ADO NET format, for use in the Databots' ADF instance


### Change
- Updated APIM endpoints to point to new EDGE resources
- Updated Ingress/Traffic manager rule for new EDGE resources
- Temporarily disable network rules on migration storage account

## 1.1.6
### Added 
- Add new endpoint to Device Info API to get device type by device ID
- Added SQL container to migration storage account
### Changed
- revved TF Template to 2.3.9
### Removed
- removed unused SQL resources

## 1.1.5
### Added
- Migrated devicelifecycle-ingestion terraform into xxxx_core
- Added outputs for devicelifecycle-ingestion service bus queue name/connection string secret name
- Storage container for price integration in centralized storage account
- Service principal for access to price integration storage container
- Service principal app for price integration
- Price integration Service principal password in keyvault
- output for service principal password keyvault name
- Output for service principal ID of price integration
- Output for name of price integration container
- Alerts for Utilization Service

### Changed
- fixed prod portal ingress path
- Fixed messagetype not being passed to eventhub messages for legacy temperature readings 

### Removed
- removed empty files core->infrastructure->modules->services->modules->iot_hub->modules
- removed old TF state commands

## 1.1.4
### Added
- Outputs and Key Vault secrets for Edge Device Simulator

### Changed
- Adjusted the schedule to pause at 8am
- rev'd version of module to 1.0 because of lifecycle attribute

## 1.1.3
### Added
- Added EDGE API names as outputs for downstream consumption via PowerShell script
- Added pipeline task in infrastructure.yaml to remove subscription key requirement for the EDGE API's
- Added Alerts for Facilities Service
- Added Alerts for Identity Service
- Added Alerts for Price Integration
- DPS Enrollment group for IoT Edge devices
- Adding an okta/enrich endpoint to FS via terraform instead of by swagger import

### Changed
- Corrected time stamp for pause runbook schedules to 5:00PM EST
- v1 api configuration for all Nile apps (FS/IS/TS) configured for jwt validation against the default okta auth server
- hardcoded the "allowed_cors_urls" on the nonprod templates so we can accept calls from portal-dev on the TEST apim instance.
- Updated tag version for Azure Diagnostic Logging module
- Removed JWT verification on the /api/okta/enrich endpoint in FS, because it is called by Okta as a token is being generated, so Okta cannot provide one.

### Removed
- v2 APIs for Identity Service and Facilities Service

## 1.1.2
### Added
- storage container called "media" in centralized storage account
- created service principal to allow creation of sas token for storage container blobs
- created service principal application
- created two role assignments for service principal
- created keyvault entries for service principal password
- LEAP device actuals SQL database
- Added platform storage account
- Updated terraform to 0.12.10 from 0.12.9
- Pipeline README
- changelog-unreleased folder for managing new unreleased changelog entries
- Added platform storage account id to outputs
- added model marketplace database to auto pipeline
- added model marketplace sql script to pipeline
- added model marketplace module to the services/infrastructure/modules
- added support for custom Okta Auth issuer in API Policies
- Device info alert
- Added TODOs for future DB removals
- Added Storage Account for temporarily holding migration data
- Contributing section to readme
- Added alerts for facility service

### Changed
- Refactored price int module to inject remote state dependencies and use a central config for okta/CORS
- Updated missing policy for data retrieval external api apim(/services/infrastructure/modules/price_integration/apim.tf)
- identity-service-swagger file
- Updated storage account instantiation to use ver. 2.1.0 of module 
- adding timezone endpoints for apim on facilities service and facilities service v2
- Updated APIM Custom Domain script to conditionally apply update, and moved to .ps1 file
- PR template clarifies and better reflects team PR policies
- Updated DataSQL WH stop/resume runbook scripts
- Okta domain, url, and portal are passed from root level mod locals for Device Info
- Updated internal ingress to use eastus2 DNS entry until HA policies can be enabled
- Update CORS policies to allow origins 127.0.0.1:8000 and localhost:8000
- modified services/infrastructure/main.tf and output.tf to include the model marketplace configuration

### Removed
- Deleted unused instance of app insights
- Cleaned up Identity Services variables and removed defaults
- Removed resource tagging module references for Cosmos DB resources
- Removed management of legacy queue password from terraform "orphaning" the secret
- Removed throughput property for new LEAP Cosmos/Mongo DBs

## 1.1.1
### Added
- Added a new resource group to house all application data
- Added connection string secret name outputs for taxonomy service
- Added output for SQL server name
- Added LEAP Device Management DB and db_name outputs
- Added task management DB
- Added Client-Configuration database
- Added LEAP Services mongodb
  
### Changed
- Refactored the SQL Access Management stage to remove variable group dependencies
- Pointed the taxonomy service database to the new consolidated application data resource group
- Reset stage -> pen/prod pipeline dependency from temporary fix in 1.1.0
- Set use_legacy_infrastructure to false in Auto for leap_queue_listener
- Retrieving SQL server name from remote state and added postfix
- Updated pen endpoint for edge apim.
- Refactored SQL DataWH Service Principal/Automation Connection/Automation Cert task 
- Adding Okta Token validation to the Taxonomy Service APIM Policy
- Updated azurerm provider in services infrastructure to 1.40 to support throughput on cosmos db
- Modified app DBs to be a complex object
- Fixed taxonomy policy typo for okta auth 

### Removed
- Removed the application-sql resource group
- Terraform state commands from pipeline
- Removed unnecessary taxonomy service outputs

## 1.1.0
### Added
- Added cluster location ingress rules with local proxies
- Added Taxonomy Service APIM Configuration & ingress rule
- Updated api/items endpoint to accept clientid in header and facilityid as externalId
- Added LEAP Services to apps
- Added platform Cosmos DB and Mongo DB accounts for use by applications
- Added LEAP Services to apps w/ new pen environment configs
- Added output for all IoT Hub Names
- Added ability to configure oauth endpoint per environment for custom auth endpoints

### Changed
- Updated legacy messages notification function to use data lake exports
- Updated Taxonomy SQL database module version
- Moved core/services under core/infrastructure
- Added k8s rbac app secret to services pipeline
- Removed planPostInitSteps for FS and IS yaml templates as they are no longer needed
- Updated Ingress and DNS configuration. TM DNS managed in terraform. (REQUIRES MANUAL REMOVAL BEFORE SERVICES DEPLOY).
- Moved items post endpoint to separate apim config to expose externally.
- Updated keyvault lookup to not collide with prod realm
- Fixed APIM name variable in LEAP Services APIM Script
- Moved services/apps/* (-LEAP) under shared services/infrastructure
- Modified LEAP outputs to support Legacy databases
- Moved device signer & ingress into services/infrastructure
- Moved all app deploys under one stage
- Elastic pool is only created in nonprod realm
- Updated sql elastic pool output for prod realm to be empty string as elastic pool does not get created in prod
- Condensed targeted auto pipelines
- Moved leap under services/infrastructure
- Revving changelog, LEAP outputs changing
- Fixing bug in SendGrid API Key script

### Removed
- Removed hot storage as it is no longer needed for device messages
- Removed shim scripts for Pipeline consolidation and Helm ingress migration
- Removed Ingress scope
- Removed default DNS Values files and replaced with overrides

## 1.0.9
### Added
- Added infrastructure for LEAP devicemanagement-queue-listener
- Added auth group for SQL server
- Added SQL database login to key vault
- Added subscription for device installed topic in edge terraform
- Added new device feature APIs in device information service
- Added LEAP optimizer terraform infrastructure to xxxx_core pipeline
- Added EDGE pipeline dependency on device info apply

### Changed
- Updated taxonomy service to reflect latest database module changes
- Changed the SQL login/user generation scripts and added conditionals to check if user/login exists
- Removed cosmos for storing device messages
- Changed log level of function and telemetry logging amount
- Implemented Helm 3 for Ingress namespace
- Revved Ingress chart from 1.24.4 to 1.26.2
- Revved DNS chart from 1.7.3 to 2.10.3
- Moved compute-infrastructure and base underneath "infrastructure"
- Ignore ingress from outside of ingress namespace

## 1.0.8

### Added
- Add NSG to pods subnet
- Added Custom Domain to APIM using SSL Cert from Keyvault via pipeline PowerShell script
- Added list/get permissions for APIM MSI to sub-elevated Keyvault required for APIM Custom Domain
- Added DNS CNAME record for {cluster}-api
- Added edge terraform infrastructure
- Added pipeline yaml file for deploying edge terraform infrastructure
- Added export cosmos collection to pipeline
- Added Pen depends on for stage environment so Pen is equivalent to Prod
- Added terraform for SQL Server and Taxonomy Service SQL database
- Added new stage for creating scoped SQL accounts per application
- Added base LEAP infrastructure and pipelines
- Added LEAP Store Traffic Service infrastructure to xxxx_core
- Added output variables for edge terraform secret names

### Changed
- Exposed items post endpoint through apim
- Remove unwanted changes in ready API of device information service
- Added environment specific APIM SKU/SKU Count
- Fixed bug with legacy messages being processed by TelemetryHotPath (meant for non legacy messages)
- Enable Advanced Threat Protection for Price Integration Storage Account
- Updated Device Info Service API definition with new endpoint
- Fixed pipeline services stages to ensure they complete before the "cluster Final" stage
- Reordered IoT hub endpoints to prevent false positives (no functional change)
- Fixed yaml pipeline code to correctly create service principal for automation account, automation certificate and update service principal cert field
- changed name of automation service principal
- reverted runbook automation scripts to use AzureRm commands instead of Az
- Used OKTA credential from key vault for EDGE terraform
- Corrected EDGE app id output, updating edge outputs to only be keyvault references
- Elevated role for ingress/observability/xxxx namespaces
- Set 'create_adsync' to true so LEAP base infrastructure is built in PEN

## 1.0.7

### Added
- Azure External Metrics API adapter, namespace and secret for custom metrics
- Moved PriceIntegration infrastructure to xxxx_core from xxxx and added pipeline deploy
- Traffic manager for multi cluster support
- Added existing endpoint for location absent URLs (eg xxxx.com, etc.)  
- observability namespace (admin)
- Ingress for facilities service, identity service, and the UI through with location suffixes. Adjusted traffic manager endpoints.
- outputs
- Moved Identity Service infrastructure to xxxx_core from xxxx and added pipeline deploy
- Moved Device Info Service infrastructure to xxxx_core from xxxx and added pipeline deploy
- Moved Facilities Service infrastructure to xxxx_core from xxxx and added pipeline deploy
- Added all platform ingress with location aware hostnames
- Authorization rules for Kubernetes service connections


### Changed
- Updated swagger file for device information service changes (device profile and device controller)
- Fixed interpolation on TM
- Add elastic consumer group to xxxx Event Hub to support POC work
- Update event hub module to use Terraform 10 formatting.
- Updated Terraform pipeline template to 2.3.7
- Added explicit message json property names for legacy device functions to ensure proper serialization on partition key
- Updated Helm pipeline template to 2.0.2
- Updated helmVersionToInstall parameter to 2.16.1
- Fixed txtOwnerId for multiple clusters
- Defaulted all APIM ingress to eastus2 until APIM multi region is setup
- Enabled Advanced Threat Detection for all Storage Accounts, upgrade storage account module version

### Removed
- Pipeline steps for 1.0.6 Terraform state cleanup

## 1.0.6

### Added
- Wired up key vault logs (AuditEvent) to log analytics workspace
- Added Penetration environment to the pipeline
- Wired up API management logs (GatewayLogs) to log analytics workspace
- Added new vnet/subnet creation logic to support multiple regions and new output to encapsulate downstream values.
- Added new AKS cluster for paired region (centralUS)
- Output Kubernetes Kubeconfigs for namespace Service Accounts to KeyVault
- Generate AzureDevOps Service connection in pipeline
- Updated version of nginx ingress controller to 0.26.1
- Updated version of helm chart to 1.24.4
- Added ARM template output for APIM id - replaced data dependency
- Added device-messages collection creation to terraform
- k8s_config local module to encapsulate the logic to configure a cluster
- Added multi cluster outputs to compute_infra
- Added terraform state commands
- Added collection creation as part of pipeline to manage RUs
- Ingress Terraform to support multiple clusters.
- ACR and VNet permissions for Central US SP

### Changed
- Updated Kubernetes version to 1.14.7
- Updated connection strings for sqldwh to use locals for db name
- Updated pipeline logic to support cluster locations for deploying storage classes
- Changed paired cosmos region to be centralus
- Changed device message partition key for legacy messages, collection name
- Moved Ingress deployment to Azure DevOps Helm Task
- Moved namespace, tiller, and flex modules to remote repos
- Upgrading to Terraform pipeline template to 2.3.6 and enabling Azure DevOps variable group outputs
- Moved Device/Cluster Signer Helm deploys out of terraform.
- Ingress Terraform kubernetes tokens now pulled from keyvault
- Ingress Helm deploy timeout increased to 2000

## 1.0.5

### Added
- Adding in APIM Service Principal outputs
- Added app insights id to outputs
- Added log analytics workspace id to outputs

### Changed
- Removed AKS diagnostic logging to log analytics workspace due to cost concerns
- Fixed Legacy message receivedOn property for proper parsing
- Updated device function app to use standard app insights key, removing function specific resource
- Git configuration for ADF in DEV environment only
- Extracted Datafactory to external module

## 1.0.4

### Changed
- increased node count in test to 6
- Fixed event hub connection string to allow sending message from function app (legacy support)
- Set default Function app settings that are set during code deploy to avoid terraform deploy reverting and reapplying later
- Remove NSG pipeline step. NSGs moved into base in previous sprint. Cleaning up empty pipeline step.
- Set event hub kafka enabled default value to true. This is not changeable and false is requiring a rebuild of the event hub every deploy. Moved auth policy for IoT hubs and named appropriately
- Updated build agents to use Azure Hosted (default in 2.3.3)
- Fixing NSG association
- Removed TF output for the PrincipalId of that Identity.  This required a separate deployment as it is dependent on the ARM Template output
- Fixed clustersigner secret name to match nonprod and prod (without a -)

## 1.0.3
### Changed
- Fixed certificate naming error and chain logic for stage and prod DPS and cluster signer certs

## 1.0.2
### Added
- Created a Cluster Signer for non prod
- Added CA trust chains to keyvault

### Changed
- Moved Facilities Service API creation from xxxx_core
- Moved Ingestion API creation from xxxx_core
- Moved agent count config to cluster-specific locals
- Enabled Managed Identity for APIM, and added an ARM Template output for the PrincipalId of that Identity

## 1.0.1
### Updated
- Changed the DPS api creation in APIM from core/services/tf to services/dps/tf.
- Moving NSG to base step - will remove step once this has been deployed to all environments
- Fixing duplicate secret name. Made secret name secret key.
- Runbook initial scratch space URL coalesce with ID (apparently the same value) - this is transiently causing the pipeline to fail
- Updated AzureRM to 1.34 across all TF, set AzureRm property: skip_provider_registration = true on all providers
- Updated Swagger Definition to include clientId in the URL path
- Removing ADF KV access policy
- Applying TF12 upgrade recommendations
- Adding Automation SP, creating connection
- Adding ADF MSI and KeyVault access
- Changing DW SQL server/database name
- Updated DL SQL password to not have special characters
- Included bug branches to trigger auto deploys
- Fixed auto function pipeline dependency
- Updated device functions to create proper partition key (shardKey) when creating a collection
- Updated tags for service bus, use local.common_tags
- Updated aks logging to call v1.1 of the diagnostic logging to log analytics module
- Changed service object level for sql datawarehouse performance level
- Revved Terraform Pipeline Template version to allow for Subscription Agent Pools
- Updated usage of blob storage module to use version 1.3
- Updating to v2.2.0 of the Terraform Pipeline Template, which removed most default values.
- Update dps script to add expiration date to certificates and enrollment groups
- Fixed DPS script bug that was creating additional enrollment group and re-registering the same certificates
- Device function to use new access policy

### Added
- Adding ADF MSI KeyVault access, added ADF tags
- Service Endpoints to ACI and Pods subnet
- Runbook-automation.tf file for creation of runbook and runbook Schedule
- keyvault entries for storage blob sas token
- keyvault entries for eventhub storage account primary and secondary connection strings
- New subnet for Azure Firewall Service
- Outputs for IoT resource group
- Added AKS diagnostic logging to log analytics workspace
- Added additional event hub access policy that contains listen and send capabilities for the device functions

### Removed
- Removed the Data Retrieval APIM resource now that it has been moved to tf_xxxx_price_integration.

## 1.0.0
### Added
- Initial launch of combined xxxx_core repo with YAML pipelines
