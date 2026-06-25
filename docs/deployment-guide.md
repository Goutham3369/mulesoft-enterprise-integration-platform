<div align="center">

# 🚢 Deployment & Operations Guide

### **MuleSoft Enterprise Integration Platform**

[![CloudHub](https://img.shields.io/badge/Deployment-CloudHub_2.0-00A1E0?style=for-the-badge&logo=cloud&logoColor=white)](https://www.mulesoft.com/platform/saas/cloudhub-ipaas-cloud-based-integration)
[![Docker](https://img.shields.io/badge/Local-Docker_Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)

---

</div>

> [!NOTE]
> **Purpose**
> This guide details how to spin up the local development infrastructure via Docker, import the projects into Anypoint Studio, and deploy the applications to CloudHub using the automated CI/CD pipeline.

## 📋 Table of Contents

- [Local Development Setup](#local-development-setup)
- [Docker Compose Infrastructure](#docker-compose-infrastructure)
- [Anypoint Studio Import](#anypoint-studio-import)
- [CloudHub Deployment](#cloudhub-deployment)
- [Environment Variables & Secrets](#environment-variables--secrets)

---

## 💻 Local Development Setup

### 1. Prerequisites

| Tool | Minimum Version | Installation |
|:-----|:--------|:-------|
| **Java JDK** | 17 LTS | [Adoptium](https://adoptium.net/) |
| **Maven** | 3.9+ | [Download](https://maven.apache.org/) |
| **Docker** | 24+ | [Docker Desktop](https://www.docker.com/) |
| **Anypoint Studio** | 7.x | [Download](https://www.mulesoft.com/lp/dl/anypoint-mule-studio) |

### 2. Configure Maven Settings

You must configure your `~/.m2/settings.xml` with your Anypoint Exchange credentials to download the Mule runtime dependencies:

```xml
<server>
    <id>anypoint-exchange-v3</id>
    <username>~~~Token~~~</username>
    <password>${env.ANYPOINT_TOKEN}</password>
</server>
```

---

## 🐳 Docker Compose Infrastructure

> [!TIP]
> **Instant Local Environment**
> The `docker-compose.yml` provides all required infrastructure dependencies for local development, meaning you don't need to install databases or message brokers manually.

```bash
# Start all background services (ActiveMQ, Prometheus, Grafana)
docker compose up -d

# View logs to ensure they started successfully
docker compose logs -f

# Shut down the environment when finished
docker compose down
```

---

## 🎨 Anypoint Studio Import

1. **Open Anypoint Studio 7.x**
2. Select **File → Import → Anypoint Studio → Anypoint Studio Project from File System**
3. Select the root directory of the cloned repository.
4. Select all API modules (`sap-erp-sapi`, `order-orchestration-papi`, etc.) and the `common-modules` shared library.
5. Click **Finish**.

> [!WARNING]
> **Run Configurations**
> When running the Mule Applications locally in Studio, ensure you pass `-Denv=local` in the VM arguments so it picks up the correct `local.yaml` property files.

---

## ☁️ CloudHub Deployment

The repository includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that automates deployments. 

### Worker Sizing Matrix

| Environment | Experience APIs | Process APIs | System APIs |
|:------------|:---------------|:-------------|:------------|
| **DEV** | 1 × 0.1 vCore | 1 × 0.1 vCore | 1 × 0.1 vCore |
| **Staging** | 1 × 0.2 vCore | 1 × 0.2 vCore | 1 × 0.1 vCore |
| **Production** | 2 × 0.2 vCore (HA) | 2 × 0.2 vCore (HA) | 2 × 0.1 vCore (HA) |

### Deployment via Maven CLI (Manual Fallback)

If the pipeline is down, you can manually deploy using the Mule Maven Plugin:

```bash
mvn clean deploy -DmuleDeploy \
  -Denv=prod \
  -Danypoint.username=${ANYPOINT_USERNAME} \
  -Danypoint.password=${ANYPOINT_PASSWORD} \
  -Dcloudhub.environment=Production \
  -Dcloudhub.workerType=SMALL \
  -Dcloudhub.workers=2
```

---

## 🔐 Environment Variables & Secrets

> [!CAUTION]
> **Do not commit raw passwords!**
> All passwords and API keys in property files must be encrypted using the MuleSoft Secure Properties Tool.

### Example Encrypted YAML Configuration

```yaml
# config/prod.yaml
sap:
  host: "sap-prod.internal.enterprise.com"
  password: "![aBcD1234EfGh5678IJKL9012MnOp3456]"
db:
  password: "![XyZa0987BcDe6543FgHi2109JkLm8765]"
```

<div align="center">
<i>Last updated: June 2026 | Built for MuleSoft Enterprise Architecture</i>
</div>
