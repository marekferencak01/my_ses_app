namespace ses.services;

using { managed, sap.common.CodeList } from '@sap/cds/common';

// ============================================================================
// CODE LISTS  (value-help / dropdowns)
// ============================================================================

entity SESStatusCodes : CodeList {
    key code : String(1)  @title: 'Status';
}

// ============================================================================
// ENTITY: PurchaseOrder  (PO Header + Item merged — one PO = one PO item)
// Top table in SES_App (list of orders for a vendor)
// ============================================================================

entity PurchaseOrder : managed {
    key POnumber         : String(10)  @title: 'Purchase Order Number';
    key POitem           : String(5)   @title: 'PO Item Number'         default '00010';
        vendor           : String(10)  @title: 'Vendor'                 not null;
        vendorName       : String(80)  @title: 'Vendor Name';
        shortText        : String(60)  @title: 'Short Text';
        startDate        : Date        @title: 'Start Date';
        endDate          : Date        @title: 'End Date';
        ers              : Boolean     @title: 'ERS'                    default false;
        finalInvoice     : Boolean     @title: 'Final Invoice'          default false;
        deliveryComplete : Boolean     @title: 'Delivery Completed'     default false;
        purchasingOrg    : String(4)   @title: 'Purchasing Organization';
        companyCode      : String(4)   @title: 'Company Code';
        plant            : String(4)   @title: 'Plant';
        materialGroup    : String(9)   @title: 'Material Group';
        currency         : String(3)   @title: 'Currency'               default 'EUR';
        creationDate     : Date        @title: 'Creation Date';
        status           : String(1)   @title: 'Status';
        serviceEntrySheets : Composition of many SESHeader
                                 on  serviceEntrySheets.POnumber = $self.POnumber
                                 and serviceEntrySheets.POitem   = $self.POitem;
}

// ============================================================================
// ENTITY: SESHeader  (Service Entry Sheet Header)
// ============================================================================

entity SESHeader : managed {
    key SESno            : String(10)    @title: 'Service Entry Sheet Number';
        POnumber         : String(10)    @title: 'Purchase Order Number'  not null;
        POitem           : String(5)     @title: 'PO Item Number'         not null;
        shortText        : String(60)    @title: 'Short Text'             not null;
        externalNumber   : String(20)    @title: 'External Number';
        date             : Date          @title: 'Date';
        dateTo           : Date          @title: 'Date To';
        creationDate     : Date          @title: 'Creation Date';
        transmissionDate : Date          @title: 'Transmission Date';
        bookingDate      : Date          @title: 'Booking Date';
        approver         : String(12)    @title: 'Approver';
        storageLocation  : String(40)    @title: 'Storage Location';
        barcode          : String(40)    @title: 'Barcode';
        totalValue       : Decimal(15,2) @title: 'Total Value'           default 0;
        totalQuantity    : Decimal(13,3) @title: 'Total Quantity'        default 0;
        currency         : String(3)     @title: 'Currency'              default 'EUR';
        longtext         : LargeString   @title: 'Long Text';
        status           : Association to SESStatusCodes default 'N' @title: 'Status';

        purchaseOrder    : Association to PurchaseOrder
                               on  purchaseOrder.POnumber = POnumber
                               and purchaseOrder.POitem   = POitem;
        items            : Composition of many SESItem
                               on items.SESno = $self.SESno;
        attachments      : Composition of many Attachment
                               on attachments.SESno = $self.SESno;
}

// ============================================================================
// ENTITY: SESItem  (Service Entry Sheet Line Items / "Lean services")
// ============================================================================

entity SESItem : managed {
    key SESno         : String(10)    @title: 'Service Entry Sheet Number';
    key SESitem       : String(5)     @title: 'SES Item Number';
        serviceNumber : String(18)    @title: 'Service Number';
        serviceText   : String(80)    @title: 'Service Text';
        unit          : String(3)     @title: 'Unit';
        quantity      : Decimal(13,3) @title: 'L Quantity'              default 0;
        fQuantity     : Decimal(13,3) @title: 'F Quantity'             default 0;
        price         : Decimal(15,2) @title: 'Price'                  default 0;
        value         : Decimal(15,2) @title: 'Line Item Value'        default 0;
        currency      : String(3)     @title: 'Currency'              default 'EUR';
        plant         : String(4)     @title: 'Plant';
        accountAssign : String(2)     @title: 'Account Assignment';
        sakto         : String(10)    @title: 'G/L Account';
        profitCenter  : String(10)    @title: 'Profit Center';
        POitem        : String(5)     @title: 'PO Item';
        contractItem  : String(5)     @title: 'Contract Item';
        remark        : String(255)   @title: 'Remark';
        sesHeader     : Association to SESHeader
                            on sesHeader.SESno = SESno;
}

// ============================================================================
// ENTITY: Attachment  (files attached to a SES document)
// ============================================================================

entity Attachment : managed {
    key ID          : UUID          @title: 'ID'  @Core.Computed;
        SESno       : String(10)    @title: 'Service Entry Sheet Number';
        description : String(255)   @title: 'Description';
        attachType  : String(4)     @title: 'Attachment Type';
        fileName    : String(255)   @title: 'File Name';
        content     : LargeBinary   @title: 'Content'  @Core.MediaType: mediaType;
        mediaType   : String(255)   @title: 'Media Type' @Core.IsMediaType: true;
        sesHeader   : Association to SESHeader
                          on sesHeader.SESno = SESno;
}
