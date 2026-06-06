using SESService from './ses-service';

// ============================================================================
// PurchaseOrder — Filter Bar, Presentation Variant, Line Item
// ============================================================================

annotate SESService.PurchaseOrder with @(

    UI.SelectionFields: [ vendor, POnumber, companyCode, purchasingOrg ],

    UI.SelectionVariant: {
        SelectOptions: [{
            PropertyName: vendor,
            Ranges       : []
        }]
    },

    UI.PresentationVariant: {
        RequestAtLeast : [ vendor ],
        SortOrder      : [{ Property: creationDate, Descending: true }],
        Visualizations : [ '@UI.LineItem' ]
    },

    UI.LineItem: [
        { Value: POnumber,      Label: 'PO Number'      },
        { Value: vendorName,    Label: 'Vendor Name'    },
        { Value: shortText,     Label: 'Short Text'     },
        { Value: startDate,     Label: 'Start Date'     },
        { Value: endDate,       Label: 'End Date'       },
        { Value: currency,      Label: 'Currency'       },
        { Value: creationDate,  Label: 'Creation Date'  },
        { Value: status,        Label: 'Status'         },
        { Value: companyCode,   Label: 'Company Code'   },
        { Value: purchasingOrg, Label: 'Purch. Org.'   }
    ]
);

// vendor is mandatory in the filter bar — list stays empty until filled
annotate SESService.PurchaseOrder with {
    vendor @(
        Common.FieldControl : #Mandatory,
        UI.HiddenFilter     : false
    );
}

// ============================================================================
// SESHeader — Line Item + Object Page Facets
// ============================================================================

annotate SESService.SESHeader with @(

    UI.LineItem: [
        { Value: SESno,        Label: 'SES Number'    },
        { Value: POnumber,     Label: 'PO Number'     },
        { Value: POitem,       Label: 'PO Item'       },
        { Value: shortText,    Label: 'Short Text'    },
        { Value: creationDate, Label: 'Creation Date' },
        { Value: totalValue,   Label: 'Total Value'   },
        { Value: currency,     Label: 'Currency'      },
        { Value: date,         Label: 'Date From'     },
        { Value: dateTo,       Label: 'Date To'       },
        { Value: status_code,  Label: 'Status'        }
    ],

    UI.FieldGroup #HeaderLeft: {
        Label : 'SES Header',
        Data  : [
            { Value: SESno,          Label: 'SES Number'      },
            { Value: POnumber,       Label: 'PO Number'       },
            { Value: POitem,         Label: 'PO Item'         },
            { Value: shortText,      Label: 'Short Text'      },
            { Value: externalNumber, Label: 'External Number' },
            { Value: status_code,    Label: 'Status'          }
        ]
    },

    UI.FieldGroup #HeaderRight: {
        Label : 'Dates & Values',
        Data  : [
            { Value: date,             Label: 'Date From'         },
            { Value: dateTo,           Label: 'Date To'           },
            { Value: creationDate,     Label: 'Creation Date'     },
            { Value: transmissionDate, Label: 'Transmission Date' },
            { Value: bookingDate,      Label: 'Booking Date'      },
            { Value: totalValue,       Label: 'Total Value'       },
            { Value: totalQuantity,    Label: 'Total Quantity'    },
            { Value: currency,         Label: 'Currency'          }
        ]
    },

    UI.FieldGroup #HeaderExtra: {
        Label : 'Additional Info',
        Data  : [
            { Value: approver,         Label: 'Approver'          },
            { Value: storageLocation,  Label: 'Storage Location'  },
            { Value: barcode,          Label: 'Barcode'           }
        ]
    },

    UI.FieldGroup #Longtext: {
        Label : 'Long Text',
        Data  : [
            { Value: longtext, Label: 'Long Text' }
        ]
    },

    UI.Facets: [
        {
            $Type  : 'UI.CollectionFacet',
            Label  : 'General',
            Facets : [
                {
                    $Type  : 'UI.ReferenceFacet',
                    Target : '@UI.FieldGroup#HeaderLeft',
                    Label  : 'SES Header'
                },
                {
                    $Type  : 'UI.ReferenceFacet',
                    Target : '@UI.FieldGroup#HeaderRight',
                    Label  : 'Dates & Values'
                }
            ]
        },
        {
            $Type  : 'UI.ReferenceFacet',
            Target : '@UI.FieldGroup#HeaderExtra',
            Label  : 'Additional Info'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            Target : '@UI.FieldGroup#Longtext',
            Label  : 'Long Text'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            Target : 'items/@UI.LineItem',
            Label  : 'Lean Services'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            Target : 'attachments/@UI.LineItem',
            Label  : 'Attachments'
        }
    ]
);

// Mandatory fields on SESHeader
annotate SESService.SESHeader with {
    shortText @Common.FieldControl: #Mandatory;
    POnumber  @Common.FieldControl: #Mandatory;
    POitem    @Common.FieldControl: #Mandatory;
}

// ============================================================================
// SESItem — Line Item
// ============================================================================

annotate SESService.SESItem with @(
    UI.LineItem: [
        { Value: SESitem,       Label: 'Item'          },
        { Value: serviceNumber, Label: 'Service No.'   },
        { Value: serviceText,   Label: 'Service Text'  },
        { Value: unit,          Label: 'Unit'          },
        { Value: quantity,      Label: 'L Quantity'    },
        { Value: fQuantity,     Label: 'F Quantity'    },
        { Value: price,         Label: 'Price'         },
        { Value: value,         Label: 'Value'         },
        { Value: currency,      Label: 'Currency'      },
        { Value: plant,         Label: 'Plant'         },
        { Value: sakto,         Label: 'G/L Account'   },
        { Value: profitCenter,  Label: 'Profit Center' },
        { Value: remark,        Label: 'Remark'        }
    ]
);

// Mandatory fields on SESItem
annotate SESService.SESItem with {
    SESno   @Common.FieldControl: #Mandatory;
    SESitem @Common.FieldControl: #Mandatory;
}

// ============================================================================
// Attachment — Line Item
// ============================================================================

annotate SESService.Attachment with @(
    UI.LineItem: [
        { Value: fileName,    Label: 'File Name'   },
        { Value: attachType,  Label: 'Type'        },
        { Value: mediaType,   Label: 'MIME Type'   },
        { Value: description, Label: 'Description' }
    ]
);

// ============================================================================
// Value Helps
// ============================================================================

// SESHeader.status → SESStatusCodes
annotate SESService.SESHeader with {
    status @(
        Common.ValueListWithFixedValues: true,
        Common.ValueList: {
            CollectionPath : 'SESStatusCodes',
            Parameters     : [{
                $Type             : 'Common.ValueListParameterOut',
                LocalDataProperty : status_code,
                ValueListProperty : 'code'
            }]
        }
    );
}

// SESHeader.POnumber → PurchaseOrder
annotate SESService.SESHeader with {
    POnumber @(
        Common.ValueList: {
            CollectionPath : 'PurchaseOrder',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterOut',
                    LocalDataProperty : POnumber,
                    ValueListProperty : 'POnumber'
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'vendorName'
                }
            ]
        }
    );
}

// SESHeader.POitem → PurchaseOrderItem filtered by POnumber
annotate SESService.SESHeader with {
    POitem @(
        Common.ValueList: {
            CollectionPath : 'PurchaseOrderItem',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterOut',
                    LocalDataProperty : POitem,
                    ValueListProperty : 'POitem'
                },
                {
                    $Type             : 'Common.ValueListParameterIn',
                    LocalDataProperty : POnumber,
                    ValueListProperty : 'POnumber'
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'shortText'
                }
            ]
        }
    );
}
