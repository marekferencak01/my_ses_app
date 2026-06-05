namespace ses.services;

using { managed } from '@sap/cds/common';

// ----------------------------------------------------------------------------
// Enum: SES Document Status
// ----------------------------------------------------------------------------
type SESStatus : String(1) enum {
    New      = 'N';
    Approved = 'A';
    Rejected = 'R';
}

// ----------------------------------------------------------------------------
// Entity: PurchaseOrder  (PO Header — read-only reference data)
// ----------------------------------------------------------------------------
@readonly
entity PurchaseOrder : managed {
    key POnumber      : String(10)  @title: 'Purchase Order Number';
        vendor        : String(10)  @title: 'Vendor'                    not null;
        creationDate  : Date        @title: 'Creation Date';
        purchasingOrg : String(4)   @title: 'Purchasing Organization';
        companyCode   : String(4)   @title: 'Company Code';
        items         : Composition of many PurchaseOrderItem
                            on items.POnumber = $self.POnumber;
}

// ----------------------------------------------------------------------------
// Entity: PurchaseOrderItem  (PO Line Item — read-only reference data)
// ----------------------------------------------------------------------------
@readonly
entity PurchaseOrderItem : managed {
    key POnumber           : String(10)  @title: 'Purchase Order Number';
    key POitem             : String(5)   @title: 'PO Item Number';
        plant              : String(4)   @title: 'Plant';
        materialGroup      : String(9)   @title: 'Material Group';
        purchaseOrder      : Association to PurchaseOrder
                                 on purchaseOrder.POnumber = POnumber;
        serviceEntrySheets : Composition of many SESHeader
                                 on  serviceEntrySheets.POnumber = $self.POnumber
                                 and serviceEntrySheets.POitem   = $self.POitem;
}

// ----------------------------------------------------------------------------
// Entity: SESHeader  (Service Entry Sheet Header)
// ----------------------------------------------------------------------------
entity SESHeader : managed {
    key SESno         : String(10)    @title: 'Service Entry Sheet Number';
        POnumber      : String(10)    @title: 'Purchase Order Number'   not null;
        POitem        : String(5)     @title: 'PO Item Number'          not null;
        status        : SESStatus     @title: 'Status'                  default 'N';
        creationDate  : Date          @title: 'Creation Date';
        totalValue    : Decimal(15,2) @title: 'Total Value';
        totalQuantity : Decimal(13,3) @title: 'Total Quantity';
        poItem        : Association to PurchaseOrderItem
                            on  poItem.POnumber = POnumber
                            and poItem.POitem   = POitem;
        items         : Composition of many SESItem
                            on items.SESno = $self.SESno;
        attachments   : Composition of many Attachments
                            on attachments.SESno = $self.SESno;
}

// ----------------------------------------------------------------------------
// Entity: SESItem  (Service Entry Sheet Line Items)
// ----------------------------------------------------------------------------
entity SESItem : managed {
    key SESno         : String(10)    @title: 'Service Entry Sheet Number';
    key SESitem       : String(5)     @title: 'SES Item Number';
        serviceNumber : String(18)    @title: 'Service Number';
        value         : Decimal(15,2) @title: 'Value';
        quantity      : Decimal(13,3) @title: 'Quantity';
        sesHeader     : Association to SESHeader
                            on sesHeader.SESno = SESno;
}

// ----------------------------------------------------------------------------
// Entity: Attachments  (Binary attachments linked to a Service Entry Sheet)
// ----------------------------------------------------------------------------
entity Attachments : managed {
    key ID          : UUID              @Core.Computed: true   @title: 'Attachment ID';
        SESno       : String(10)                               @title: 'Service Entry Sheet Number';
        description : String(255)                              @title: 'Description';
        attachType  : String(4)                                @title: 'Attachment Type';
        content     : LargeBinary       @Core.MediaType: mediaType
                                                               @title: 'Content';
        mediaType   : String(255)       @Core.IsMediaType: true
                                                               @title: 'Media Type';
        sesHeader   : Association to SESHeader
                          on sesHeader.SESno = SESno;
}

// ----------------------------------------------------------------------------
// Entity: Roles
// ----------------------------------------------------------------------------
type RoleCode : String(10) enum {
    Admin = 'ADMIN';
    User  = 'USER';
}

entity Roles {
    key code : RoleCode @title: 'Role Code';
}
