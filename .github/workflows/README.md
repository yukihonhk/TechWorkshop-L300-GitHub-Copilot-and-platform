# CI/CD – Build & Deploy to Azure App Service

The **build-deploy.yml** workflow builds the .NET app as a Docker image, pushes it to Azure Container Registry (ACR), and deploys it to an Azure App Service (Linux container).

## Prerequisites

Infrastructure must already be provisioned (see `infra/` folder). You need:

| Resource | Example value |
|---|---|
| Azure Container Registry | `acrzavastoredevyukiho3bb2` |
| App Service (Web App for Containers) | `app-zavastore-dev-yuki-ho3bb2` |
| Resource Group | `rg-zavastore-dev-westus3-yuki-ho3bb2` |

## Configure GitHub Secrets

Go to **Settings → Secrets and variables → Actions → Secrets** and create:

| Secret | Description |
|---|---|
| `AZURE_CLIENT_ID` | App registration (service principal) client ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |

These are used for OIDC (federated credential) login — no passwords stored.

### Setting up OIDC federation

1. Create an App Registration in Azure AD.
2. Under **Certificates & secrets → Federated credentials**, add a credential:
   - **Issuer**: `https://token.actions.githubusercontent.com`
   - **Subject**: `repo:<owner>/<repo>:ref:refs/heads/main` (repeat for `dev` branch if needed)
   - **Audience**: `api://AzureADTokenExchange`
3. Grant the service principal **Contributor** + **AcrPush** roles on the resource group.

## Configure GitHub Variables

Go to **Settings → Secrets and variables → Actions → Variables** and create:

| Variable | Description | Example |
|---|---|---|
| `ACR_NAME` | ACR name (no `.azurecr.io`) | `acrzavastoredevyukiho3bb2` |
| `RESOURCE_GROUP` | Resource group name | `rg-zavastore-dev-westus3-yuki-ho3bb2` |
| `WEBAPP_NAME` | App Service name | `app-zavastore-dev-yuki-ho3bb2` |

## Trigger

The workflow runs on:
- Push to `dev` or `main` branch
- Manual dispatch (Actions → Run workflow)
