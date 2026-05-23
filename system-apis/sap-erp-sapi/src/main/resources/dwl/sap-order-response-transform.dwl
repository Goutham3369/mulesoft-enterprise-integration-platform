%dw 2.0
output application/json

// Transform SAP OData Sales Order response to canonical order format
var statusMapping = {
    "A": "OPEN",
    "B": "APPROVED",
    "C": "IN_PROGRESS",
    "D": "COMPLETED",
    "E": "CANCELLED"
}

var deliveryStatusMapping = {
    "": "NOT_DELIVERED",
    "A": "NOT_DELIVERED",
    "B": "PARTIALLY_DELIVERED",
    "C": "FULLY_DELIVERED"
}

var billingStatusMapping = {
    "": "NOT_BILLED",
    "A": "NOT_BILLED",
    "B": "PARTIALLY_BILLED",
    "C": "FULLY_BILLED"
}

var sapOrders = payload.d.results default []
---
{
    orders: sapOrders map ((order) -> {
        orderId: order.SalesOrder default "",
        orderType: order.SalesOrderType default "",
        salesOrganization: order.SalesOrganization default "",
        distributionChannel: order.DistributionChannel default "",
        division: order.OrganizationDivision default "",
        customer: {
            id: order.SoldToParty default "",
            name: order.SoldToPartyName default "",
            purchaseOrderNumber: order.PurchaseOrderByCustomer default ""
        },
        pricing: {
            netAmount: order.TotalNetAmount as Number default 0,
            taxAmount: order.TaxAmount as Number default 0,
            grossAmount: (order.TotalNetAmount as Number default 0) + (order.TaxAmount as Number default 0),
            currency: order.TransactionCurrency default "USD"
        },
        status: {
            overall: statusMapping[order.OverallSDProcessStatus] default order.OverallSDProcessStatus default "UNKNOWN",
            delivery: deliveryStatusMapping[order.OverallDeliveryStatus] default "UNKNOWN",
            billing: billingStatusMapping[order.OverallBillingStatus] default "UNKNOWN",
            rejection: order.OverallSDDocumentRejectionSts default ""
        },
        dates: {
            orderDate: order.SalesOrderDate default "",
            createdDate: order.CreationDate default "",
            requestedDeliveryDate: order.RequestedDeliveryDate default "",
            lastModified: order.LastChangeDate default ""
        },
        lineItemCount: sizeOf(order.to_Item.results default [])
    }),
    pagination: {
        offset: vars.offset as Number default 0,
        limit: vars.limit as Number default 20,
        total: payload.d.__count as Number default sizeOf(sapOrders),
        hasMore: sizeOf(sapOrders) == (vars.limit as Number default 20)
    },
    metadata: {
        source: "SAP_ERP",
        correlationId: vars.correlationId default "",
        retrievedAt: now() as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"}
    }
}
