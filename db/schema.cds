namespace ses.services;

using { managed, sap.common.CodeList } from '@sap/cds/common';

// ============================================================================
// CODE LISTS  (value-help / dropdowns)
// ============================================================================

// SES document status: N=New, A=Approved/Released, R=Rejected,
// I=Invoiced, C=Cancelled
entity SESStatusCodes : CodeList {
    key code : String(1)  @title: 'Status';
}

// ============================================================================
// ENTITY: PurchaseOrder  (PO Header — read-only reference data)
// Top table in SES_App (list of orders for a vendor)
// ============================================================================
@readonly
entity PurchaseOrder : managed {
    key POnumber         : String(10)  @title: 'Purchase Order Number';
        vendor           : String(10)  @title: 'Vendor'                 not null;
        vendorName       : String(80)  @title: 'Vendor Name';                       // "Name" column
        shortText        : String(60)  @title: 'Short Text';
        startDate        : Date        @title: 'Start Date';
        endDate          : Date        @title: 'End Date';
        ers              : Boolean     @title: 'ERS'                    default false;
        finalInvoice     : Boolean     @title: 'Final Invoice'          default false;
        deliveryComplete : Boolean     @title: 'Delivery Completed'     default false;
        purchasingOrg    : String(4)   @title: 'Purchasing Organization';           // EKORG
        companyCode      : String(4)   @title: 'Company Code';                       // BUKRS / CoCd
        currency         : String(3)   @title: 'Currency'               default 'EUR';
        creationDate     : Date        @title: 'Creation Date';
        status           : String(1)   @title: 'Status';                             // release/created/rejected indicator
        items            : Composition of many PurchaseOrderItem
                               on items.POnumber = $self.POnumber;
}

// ============================================================================
// ENTITY: PurchaseOrderItem  (PO Line Item — read-only reference data)
// ============================================================================
@readonly
entity PurchaseOrderItem : managed {
    key POnumber           : String(10)  @title: 'Purchase Order Number';
    key POitem             : String(5)   @title: 'PO Item Number';
        plant              : String(4)   @title: 'Plant';                            // WERK
        materialGroup      : String(9)   @title: 'Material Group';                   // MATKL
        shortText          : String(60)  @title: 'Short Text';
        purchaseOrder      : Association to PurchaseOrder
                                 on purchaseOrder.POnumber = POnumber;
        serviceEntrySheets : Composition of many SESHeader
                                 on  serviceEntrySheets.POnumber = $self.POnumber
                                 and serviceEntrySheets.POitem   = $self.POitem;
}

// ============================================================================
// ENTITY: SESHeader  (Service Entry Sheet Header)
// Header section in SES_Data + bottom table in SES_App
// ============================================================================
entity SESHeader : managed {
    key SESno            : String(10)    @title: 'Service Entry Sheet Number';       // iSES Number
        POnumber         : String(10)    @title: 'Purchase Order Number'  not null;
        POitem           : String(5)     @title: 'PO Item Number'         not null;
        shortText        : String(60)    @title: 'Short Text'             not null;   // Shorttext* (required)
        externalNumber   : String(20)    @title: 'External Number';
        date             : Date          @title: 'Date';
        dateTo           : Date          @title: 'Date To';
        creationDate     : Date          @title: 'Creation Date';
        transmissionDate : Date          @title: 'Transmission Date';
        bookingDate      : Date          @title: 'Booking Date';                      // Booking to
        approver         : String(12)    @title: 'Approver';
        storageLocation  : String(40)    @title: 'Storage Location';
        barcode          : String(40)    @title: 'Barcode';
        totalValue       : Decimal(15,2) @title: 'Total Value'           default 0;   // iSES Value / Netprice
        totalQuantity    : Decimal(13,3) @title: 'Total Quantity'        default 0;
        currency         : String(3)     @title: 'Currency'              default 'EUR';
        longtext         : LargeString   @title: 'Long Text';                         // Longtext section
        status           : Association to SESStatusCodes default 'N' @title: 'Status';

        poItem           : Association to PurchaseOrderItem
                               on  poItem.POnumber = POnumber
                               and poItem.POitem   = POitem;
        items            : Composition of many SESItem
                               on items.SESno = $self.SESno;
        attachments      : Composition of many Attachment
                               on attachments.SESno = $self.SESno;
}

// ============================================================================
// ENTITY: SESItem  (Service Entry Sheet Line Items)
// "Lean services" table in SES_Data
// ============================================================================
entity SESItem : managed {
    key SESno         : String(10)    @title: 'Service Entry Sheet Number';
    key SESitem       : String(5)     @title: 'SES Item Number';                     // Line Nr.
        serviceNumber : String(18)    @title: 'Service Number';
        serviceText   : String(80)    @title: 'Service Text';
        unit          : String(3)     @title: 'Unit';
        quantity      : Decimal(13,3) @title: 'L Quantity'              default 0;
        fQuantity     : Decimal(13,3) @title: 'F Quantity'             default 0;
        price         : Decimal(15,2) @title: 'Price'                  default 0;
        value         : Decimal(15,2) @title: 'Line Item Value'        default 0;
        currency      : String(3)     @title: 'Currency'              default 'EUR';
        plant         : String(4)     @title: 'Plant';
        accountAssign : String(2)     @title: 'Account Assignment';                   // "Account ..."
        sakto         : String(10)    @title: 'G/L Account';                          // SAKTO
        profitCenter  : String(10)    @title: 'Profit Center';
        POitem        : String(5)     @title: 'PO Item';
        contractItem  : String(5)     @title: 'Contract Item';                        // Contr.-Item
        remark        : String(255)   @title: 'Remark';
        sesHeader     : Association to SESHeader
                            on sesHeader.SESno = SESno;
}

// ============================================================================
// ENTITY: Attachment  (files attached to a SES document)
// "Attachments" section in SES_Data — PDF, TXT, JPEG ...
// ============================================================================
entity Attachment : managed {
    key ID          : UUID          @title: 'ID'  @Core.Computed;
        SESno       : String(10)    @title: 'Service Entry Sheet Number';
        description : String(255)   @title: 'Description';
        attachType  : String(4)     @title: 'Attachment Type';                        // PDF / TXT / JPG
        fileName    : String(255)   @title: 'File Name';
        content     : LargeBinary   @title: 'Content'  @Core.MediaType: mediaType;    // raw file bytes
        mediaType   : String(255)   @title: 'Media Type' @Core.IsMediaType: true;     // MIME type
        sesHeader   : Association to SESHeader
                          on sesHeader.SESno = SESno;
}
