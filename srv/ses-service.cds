using { ses.services as db } from '../db/schema';

// ============================================================================
// SES Service — Service Entry Sheet management
// ============================================================================
service SESService @(path: '/ses') {

    // -----------------------------------------------------------------------
    // Reference data (read-only)
    // -----------------------------------------------------------------------
    @readonly
    entity PurchaseOrder     as projection on db.PurchaseOrder;

    @readonly
    entity PurchaseOrderItem as projection on db.PurchaseOrderItem;

    @readonly
    entity SESStatusCodes    as projection on db.SESStatusCodes;

    // -----------------------------------------------------------------------
    // SES documents
    // -----------------------------------------------------------------------
    entity SESHeader         as projection on db.SESHeader;
    entity SESItem           as projection on db.SESItem;

    // -----------------------------------------------------------------------
    // Attachments — LargeBinary streaming enabled via @Core.MediaType on content
    // -----------------------------------------------------------------------
    entity Attachment        as projection on db.Attachment;

    // -----------------------------------------------------------------------
    // Entry-point: find all POs (with line items) for a given vendor number
    // -----------------------------------------------------------------------
    function getPurchaseOrdersByVendor(vendor : String) returns array of PurchaseOrder;
}
