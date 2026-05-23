%dw 2.0
output application/json

// Transform customer data between canonical format and SAP Business Partner format
var sapCustomers = payload.d.results default []

var customerCategoryMapping = {
    "1": "PERSON",
    "2": "ORGANIZATION",
    "3": "GROUP"
}
---
{
    customers: sapCustomers map ((bp) -> {
        customerId: bp.BusinessPartner default "",
        customerCategory: customerCategoryMapping[bp.BusinessPartnerCategory] default "UNKNOWN",
        companyName: bp.BusinessPartnerFullName default "",
        firstName: bp.FirstName default "",
        lastName: bp.LastName default "",
        displayName: if (bp.BusinessPartnerCategory == "2") 
            bp.BusinessPartnerFullName default "" 
            else trim((bp.FirstName default "") ++ " " ++ (bp.LastName default "")),
        isBlocked: bp.BusinessPartnerIsBlocked default false,
        language: bp.Language default "EN",
        industry: bp.IndustrySector default "",
        legalForm: bp.LegalForm default "",
        taxNumbers: {
            taxNumber1: bp.TaxNumber1 default "",
            taxNumber2: bp.TaxNumber2 default "",
            vatRegistration: bp.VATRegistration default ""
        },
        addresses: (bp.to_BusinessPartnerAddress.results default []) map ((addr) -> {
            addressId: addr.AddressID default "",
            country: addr.Country default "",
            region: addr.Region default "",
            city: addr.CityName default "",
            postalCode: addr.PostalCode default "",
            street: addr.StreetName default "",
            houseNumber: addr.HouseNumber default "",
            formattedAddress: trim(
                (addr.HouseNumber default "") ++ " " ++ 
                (addr.StreetName default "") ++ ", " ++ 
                (addr.CityName default "") ++ " " ++ 
                (addr.Region default "") ++ " " ++ 
                (addr.PostalCode default "") ++ ", " ++ 
                (addr.Country default "")
            )
        }),
        createdDate: bp.CreationDate default "",
        lastModified: bp.LastChangeDate default ""
    }),
    pagination: {
        total: sizeOf(sapCustomers),
        hasMore: sizeOf(sapCustomers) == (vars.limit as Number default 50)
    },
    metadata: {
        source: "SAP_ERP",
        correlationId: vars.correlationId default "",
        retrievedAt: now() as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"}
    }
}
