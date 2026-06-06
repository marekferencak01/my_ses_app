'use strict';

module.exports = (srv) => {

    const { PurchaseOrder, PurchaseOrderItem, SESHeader, SESItem } = srv.entities;

    // =========================================================================
    // FUNCTION: getPurchaseOrdersByVendor
    // Returns all POs with their line items for the given vendor number.
    // =========================================================================
    srv.on('getPurchaseOrdersByVendor', async (req) => {
        const { vendor } = req.data;
        if (!vendor) return req.error(400, 'Vendor number is required');

        const orders = await SELECT.from(PurchaseOrder).where({ vendor });
        for (const order of orders) {
            order.items = await SELECT.from(PurchaseOrderItem)
                .where({ POnumber: order.POnumber });
        }
        return orders;
    });

    // =========================================================================
    // SESItem: auto-compute value = price * quantity before write (if not given)
    // =========================================================================
    srv.before(['CREATE', 'UPDATE'], SESItem, (req) => {
        const { price, quantity, value } = req.data;
        if (value == null && price != null && quantity != null) {
            req.data.value = parseFloat((price * quantity).toFixed(2));
        }
    });

    // =========================================================================
    // SESHeader totals: recompute whenever a child SESItem is written or removed
    // =========================================================================
    srv.after(['CREATE', 'UPDATE'], SESItem, async (data, req) => {
        const SESno = (Array.isArray(data) ? data[0] : data)?.SESno ?? req.data?.SESno;
        if (SESno) await _recalcTotals(SESno);
    });

    srv.after('DELETE', SESItem, async (_, req) => {
        const SESno = req.params?.[0]?.SESno;
        if (SESno) await _recalcTotals(SESno);
    });

    async function _recalcTotals(SESno) {
        const items = await SELECT.from(SESItem).where({ SESno });
        const totalValue    = items.reduce((s, i) => s + (+i.value    || 0), 0);
        const totalQuantity = items.reduce((s, i) => s + (+i.quantity || 0), 0);
        await UPDATE(SESHeader)
            .set({
                totalValue:    parseFloat(totalValue.toFixed(2)),
                totalQuantity: parseFloat(totalQuantity.toFixed(3)),
            })
            .where({ SESno });
    }
};
