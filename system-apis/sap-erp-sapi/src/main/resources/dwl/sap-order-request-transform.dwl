%dw 2.0
output application/json

// Transform incoming canonical order format to SAP BAPI/OData Sales Order format
var orderTypeMapping = {
    "STANDARD": "OR",
    "RUSH": "SO",
    "RETURN": "RE",
    "CREDIT_MEMO": "CR",
    "DEBIT_MEMO": "DR"
}

var deliveryPriorityMapping = {
    "LOW": "03",
    "NORMAL": "02",
    "HIGH": "01",
    "URGENT": "01"
}
---
{
    SalesOrderType: orderTypeMapping[payload.orderType] default "OR",
    SalesOrganization: payload.salesOrganization default "1000",
    DistributionChannel: payload.distributionChannel default "10",
    OrganizationDivision: payload.division default "00",
    SoldToParty: payload.customerId default "",
    PurchaseOrderByCustomer: payload.purchaseOrderNumber default "",
    CustomerPaymentTerms: payload.paymentTerms default "0001",
    RequestedDeliveryDate: if (payload.requestedDeliveryDate != null) 
        (payload.requestedDeliveryDate as Date {format: "yyyy-MM-dd"}) as String {format: "yyyy-MM-dd'T00:00:00'"} 
        else null,
    DeliveryPriority: deliveryPriorityMapping[payload.deliveryPriority] default "02",
    HeaderBillingBlockReason: if (payload.holdForReview default false) "01" else "",
    TransactionCurrency: payload.currency default "USD",
    SDDocumentReason: payload.orderReason default "",
    SalesOrderDate: now() as String {format: "yyyy-MM-dd'T00:00:00'"},
    to_Item: (payload.items default []) map ((item, idx) -> {
        SalesOrderItem: ((idx + 1) * 10) as String {format: "000000"},
        Material: item.materialNumber default item.sku default "",
        SalesOrderItemText: item.description default "",
        RequestedQuantity: item.quantity as String default "1",
        RequestedQuantityUnit: item.unit default "EA",
        Plant: item.plant default "1000",
        StorageLocation: item.storageLocation default "",
        CustomerMaterial: item.customerMaterialNumber default "",
        MaterialGroup: item.materialGroup default "",
        to_PricingElement: if (item.unitPrice != null) [{
            ConditionType: "PR00",
            ConditionRateValue: item.unitPrice as String default "0",
            ConditionCurrency: payload.currency default "USD",
            ConditionQuantity: "1",
            ConditionQuantityUnit: item.unit default "EA"
        }] ++ (if (item.discountPercent != null) [{
            ConditionType: "K004",
            ConditionRateValue: item.discountPercent as String default "0",
            ConditionCurrency: "%"
        }] else []) else []
    }),
    to_Partner: [
        {
            PartnerFunction: "AG",
            Customer: payload.customerId default ""
        }
    ] ++ (if (payload.shipToParty != null) [{
        PartnerFunction: "WE",
        Customer: payload.shipToParty
    }] else []) ++ (if (payload.billToParty != null) [{
        PartnerFunction: "RE",
        Customer: payload.billToParty
    }] else []),
    to_Text: if (payload.notes != null) [{
        TextID: "0001",
        Language: "EN",
        LongText: payload.notes
    }] else []
}
