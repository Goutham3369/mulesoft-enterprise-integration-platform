<div align="center">

# 📡 API Catalog

### **MuleSoft Enterprise Integration Platform**

[![RAML](https://img.shields.io/badge/Spec-RAML_1.0-FF4081?style=for-the-badge)](https://raml.org/)
[![REST](https://img.shields.io/badge/Architecture-REST-005B9F?style=for-the-badge)]()
[![JSON](https://img.shields.io/badge/Payload-JSON-000000?style=for-the-badge)]()

---

</div>

> [!TIP]
> **API Discovery**
> This document provides a high-level catalog of all APIs exposed by the integration platform. For interactive mocking and testing, please view the actual RAML files in Anypoint Design Center or Anypoint Exchange.

## 📋 Table of Contents

- [API Inventory Matrix](#api-inventory-matrix)
- [Authentication & Security](#authentication--security)
- [Global Rate Limiting](#global-rate-limiting)
- [Experience API Specs](#experience-api-specs)
- [Process API Specs](#process-api-specs)
- [System API Specs](#system-api-specs)

---

## 🗂️ API Inventory Matrix

| # | API Name | Layer | Port | Base Path | RAML Location |
|:--|:---------|:------|:-----|:----------|:----------|
| 1 | **Order Experience** | 🟢 Experience | `8081` | `/api/v1` | `api-specs/order-experience-api/` |
| 2 | **Customer 360** | 🟢 Experience | `8082` | `/api/v1` | `api-specs/customer-360-api/` |
| 3 | **Order Orchestration** | 🟡 Process | `8091` | `/api/v1` | `api-specs/order-process-api/` |
| 4 | **Customer Aggregation**| 🟡 Process | `8092` | `/api/v1` | `api-specs/customer-aggregation/` |
| 5 | **SAP ERP SAPI** | 🔴 System | `8101` | `/api/v1` | `api-specs/sap-system-api/` |
| 6 | **Salesforce CRM SAPI** | 🔴 System | `8102` | `/api/v1` | `api-specs/salesforce-system-api/` |
| 7 | **Payment Gateway SAPI**| 🔴 System | `8103` | `/api/v1` | `api-specs/payment-system-api/` |
| 8 | **Inventory Mgmt SAPI** | 🔴 System | `8104` | `/api/v1` | `api-specs/inventory-system-api/` |

---

## 🔒 Authentication & Security

> [!WARNING]
> **Missing Tokens**
> Requests without a valid OAuth token will be rejected at the API Gateway level (HTTP 401) before ever reaching the Mule application logic.

### Standard Headers

All API requests MUST include the following headers:

| Header | Required | Example | Description |
|:-------|:---------|:--------|:------------|
| `Authorization` | ✅ | `Bearer eyJhb...` | OAuth 2.0 JWT Access Token |
| `client_id` | ✅ | `client-1234` | Registered API client ID |
| `client_secret` | ✅ | `secret-5678` | Registered API client Secret |
| `X-Correlation-ID` | ⬜ | `abc-123-def` | UUID for distributed tracing across layers |

---

## 🚦 Global Rate Limiting

Rate limits are enforced automatically by Anypoint API Manager SLA policies.

| Tier | Requests / Min | Requests / Hour | Excess Behavior |
|:-----|:---------------|:----------------|:----------------|
| **Free** | 5 | 100 | Returns HTTP 429 Too Many Requests |
| **Standard** | 50 | 1,000 | Returns HTTP 429 Too Many Requests |
| **Premium** | 500 | 10,000 | Returns HTTP 429 Too Many Requests |

---

## 🟢 Experience API Specs

### Order Experience API
Handles B2B and B2C channel requests for order creation and status tracking.

* `POST /orders` - Place a new enterprise order.
* `GET /orders/{id}` - Retrieve order status.
* `POST /orders/{id}/cancel` - Request an order cancellation.

### Customer 360 Experience API
Provides a unified view of the customer for frontend dashboards.

* `GET /customers/{id}/360` - Get aggregated profile, orders, and support tickets.

---

## 🟡 Process API Specs

### Order Orchestration API
The core brain of the platform. Implements the Saga pattern.

* `POST /orders/orchestrate` - Begins the multi-system validation, reservation, and booking process.
* `GET /orders/{id}/saga` - View the exact step-by-step trace of the distributed transaction.
* `POST /sagas/compensate` - Manually trigger a rollback for a stuck transaction.

---

## 🔴 System API Specs

### SAP ERP System API
* `POST /orders` - Maps to SAP BAPI `BAPI_SALESORDER_CREATEFROMDAT2`.
* `GET /customers` - Maps to SAP BAPI `BAPI_CUSTOMER_GETLIST`.

### Salesforce CRM System API
* `PATCH /opportunities/{id}` - Updates CRM status as orders flow through SAP.
* `GET /accounts/{id}` - Retrieves Salesforce Account details for Customer 360.

### Payment Gateway System API
* `POST /payments` - Charges a credit card via Stripe API.
* `POST /refunds` - Refunds a transaction.

### Inventory System API
* `POST /reservations` - Locks inventory temporarily while the Saga executes.
* `GET /inventory/{sku}` - Returns real-time stock availability.

---

<div align="center">
<i>Last updated: June 2026 | Built for MuleSoft Enterprise Architecture</i>
</div>
