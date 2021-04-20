<<<<<<< HEAD
# github actions playground

A repo to play around with github actions.
=======
# COS E2E
![Build](https://github.com/MediaMarktSaturn/cos-e2e/workflows/ci/badge.svg)

End to end testing for customer order services.

## Requirements
- JDK 11
- Gradle 6 (optional)

## Specs

- [Callback Spec](#callback-spec)
- [COSMOS Spec](#cosmos-spec)
- [Digital Article Activation Spec](#digital-article-activation-spec)
- [Enrichment Flow Spec](#enrichment-flow-spec)
- [FISCAS Notification Spec](#fiscas-notification-spec)
- [Create Fulfillment Spec](#create-fulfillment-spec)
- [Mirakl Order Creation Spec](#mirakl-order-creation-spec)
- [Mirakl Order Update Spec](#mirakl-order-update-spec)
- [Cancel Order Spec](#cancel-order-spec)
- [MMS Order Item Update Spec](#mms-order-item-update-spec)
- [Notify Customer Spec](#notify-customer-spec)
- [Resolve Reservation Spec](#resolve-reservation-spec)
- [Shipment Confirmation Spec](#shipment-confirmation-spec)
- [Sterling Export Spec](#sterling-export-spec)
- [Create Order Spec](#create-order-spec)
- [MMS Order Item Added Spec](#mms-order-item-added-spec)
- [Return Order Spec](#return-order-spec)

## Deactivated Specs (TODO)
Following specs are currently deactivated and should be enabled, again:

| Spec                                                                | Description                                                                                           |
| ------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| [Callback Spec](#callback-spec)                                     | Services in Pick and Pack flow (Sterling-Client amongst others) has to be reworked (see [Epic COS-95](https://jira.media-saturn.com/browse/COS-95)). |
| [Mirakl Order Update Spec](#mirakl-order-update-spec)               | COS Api Spec has to be finalize and Mirakl-Gateway has to implemented the change.                     |
| [Enrichment Flow Spec](#enrichment-flow-spec)                       | Temporarily disabled as the enrichment flow needs to be reworked to avoid timing issues on consuming OrderInitiatedEvents and OrderEnrichedEvents. |


## Incomplete Specs (TODO)
Following specs are not complete yet and should be completed asap once the services are adjusted accordingly in integration:

| Spec                                              | Description                                                                                                                     |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| [Enrichment Flow Spec](#enrichment-flow-spec)     | The order-storage-service and sap-client-export have to store/forward the business partner ids along with the order.            |
| [Order Item Update Spec](#mms-order-item-update-spec) | It's still open to clarify what to do with the prices and order totals coming from Sterling via the order_item_changed_message. |
| [Shipment Confirmation Spec](#shipment-confirmation-spec) | The shipment-gateway-service currently does not provide a way to retrieve the shipmentConfirmationId, which makes it pretty hard to test the update of shipment confirmations. |


### Callback Spec

[source](src/test/kotlin/com/mms/cos/e2e/specs/callback/CallbackSpec.kt)

1. Produce a `OrderLifeCycleEvents.OrderCreatedEvent` with one fulfillment.
2. Call the shipment API to update the created order with a callback url given in the request header.
3. Verify that the given callback url was called.

### COSMOS Spec

[source](src/test/kotlin/com/mms/cos/e2e/specs/cosmos/CosmosSpec.kt)

1. Produce an `OrderCreatedEvent`
2. Get the event from COSMOS and verify the attributes, also deserialize the event payload and verify it

### Digital Article Activation Spec

[source](src/test/kotlin/com/mms/cos/e2e/specs/daa/DigitalArticleActivationSpec.kt)

country: DE

**Case 1**

1. Produce a `OrderLifeCycleEvents.OrderCreatedEvent` containing no digital articles.
2. Produce a `OrderLegacyEvents.FulfillmentCreatedEvent` for the same order.
3. Make sure POSA, AROMA and REA were NOT called.

**Case 2**

1. Produce a `OrderLifeCycleEvents.OrderCreatedEvent` containing a digital article.
2. Produce a `OrderLegacyEvents.FulfillmentCreatedEvent` for the same order.
3. Make sure POSA, AROMA and REA were called.

**Case 3**

1. Produce a `OrderLifeCycleEvents.OrderCreatedEvent` containing a digital article.
2. Place predefined **400** responses for the POSA activation requests with the following error codes:
    * PRDUNK - PRODUCT_UNKOWN
    * EXPIRD - EXPIRED
    * ALRSET - ALREADY_SET
    * ARTNFD - ARTICLE_NOT_FOUND
3. Produce a `OrderLegacyEvents.FulfillmentCreatedEvent` for the same order.
4. Make sure
    * REA was NOT called.
    * no POSA article activation is persisted.
    * AROMA was called with a PullBack despatch advice.

### Enrichment Flow Spec

[source](src/test/kotlin/com/mms/cos/e2e/specs/enrichment/EnrichOrderSpec.kt)

#### TODO
_This test is not a real e2e test as it does not check on the Order API and the SAP API respectively if the business partner ids are stored there as well. This was because the storing of an order has not been adapted at that point in time. However, the test should be adjusted in that direction as soon as the order storage has been updated and communication to SAP API is implemented._

1. Create expected outlet in mock-service
2. Produce an `OrderInitiatedEvent`
3. Get matching `OrderPublishedEvent` via defined orderId and verify that the business partner ids have been taken from outlet

### FISCAS Notification Spec

[source](src/test/kotlin/com/mms/cos/e2e/specs/fiscas/FiscasNotificationSpec.kt)

country: ES

**Case 1**

1. Produce a turnover order (of type `CustomerOrderObject`) on the fiscas topic.
2. Expect a request (of type `CustomerInvoiceRequest`) to be sent to fiscas.

### Create Fulfillment Spec

[source](src/test/kotlin/com/mms/cos/e2e/specs/fulfillment/CreateFulfillmentSpec.kt)

**Case 1**

1. Produce a `OrderLifeCycleEvents.OrderCreatedEvent` with brand = MEDIA_MARKT and country = NL.
2. Call the Fulfillment API to create a new fulfillment.
3. Verify that the Fulfillment creation triggers the creation of a SalesOrder in SAP.

### Mirakl Order Creation Spec

[source](src/test/kotlin/com/mms/cos/e2e/specs/mirakl/MiraklOrderCreationSpec.kt)

1. Produce a `OrderLifeCycleEvents.OrderCreatedEvent` containing exactly two logistic orders.
2. Retrieve the order using the storage API.
3. Verify that the order contains two mirakl suborders, and their totals are correct.

### Mirakl Order Update Spec

[source](src/test/kotlin/com/mms/cos/e2e/specs/mirakl/MiraklOrderUpdateSpec.kt)

1. Produce a `OrderLifeCycleEvents.OrderCreatedEvent` containing two mirakl suborders.
2. Call the Mirakl Update endpoint `/customer-orders/{order-guid}/sub-orders/{mirakl-order-ref}` to update one of the mirakl suborders.
3. Retrieve the order using the storage API.
4. Verify that the mirakl suborder was updated correctly.

### Cancel Order Spec

[source](src/test/kotlin/com/mms/cos/e2e/specs/mmsorderchange/CancelOrderSpec.kt)

1. Produce an `OrderLifeCycleEvents.OrderCreatedEvent` to have a particular order at hand.
2. Produce an `OrderUpdateInitiatedEvents.OrderStateChangedEvent` to cancel the order.
3. Check that published order has been updated accordingly by verifying the corresponding `OrderPublishedEvents.OrderPublishedEvent`.
4. Verify that corresponding sales order was canceled via the SAP API.

### MMS Order Item Update Spec

[source](src/test/kotlin/com/mms/cos/e2e/specs/mmsorderchange/MmsOrderItemUpdateSpec.kt)

Cancelling an Order Item:
1. Produce an `OrderLifeCycleEvents.OrderCreatedEvent` to have a particular order at hand.
2. Produce an `OrderUpdateInitiatedEvents.OrderItemChangedEvent` to cancel an individual item of the order.
3. Check that published order has been updated accordingly by verifying the corresponding `OrderPublishedEvents.OrderPublishedEvent`.
4. Verify that the corresponding item in the corresponding sales order was canceled via the SAP API.

Updating Quantity of an Order Item:
1. Produce an `OrderLifeCycleEvents.OrderCreatedEvent` to have a particular order at hand.
2. Produce an `OrderUpdateInitiatedEvents.OrderItemChangedEvent` to update quantity and prices of an individual item of the order.
3. Check that published order has been updated accordingly by verifying the corresponding `OrderPublishedEvents.OrderPublishedEvent`.
4. Verify that the corresponding item quantity in the corresponding sales order was updated via the SAP API.
5. Verify that the prices and order totals of the corresponding item are updated in the published order

### Notify Customer Spec

[source](src/test/kotlin/com/mms/cos/e2e/specs/rea/NotifyCustomerSpec.kt)

country: DE (any country with active mirakl order export)

**Case**

1. Create an `OrderLifeCycleEvents.OrderCreatedEvent`
2. Search for the expected notification
3. Validate the notification

### Resolve Reservation Spec

[source](src/test/kotlin/com/mms/cos/e2e/specs/reservation/ResolveReservationSpec.kt)

country: DE (any country with new web shop)

**Case**

1. Create a reservation at the mock service
2. Create a `OrderLifeCycleEvents.OrderCreatedEvent`
3. Check if the reservation has been resolved

**Reservation API mock**

To make the handling of the reservations for the test easier two new paths have been added to the reservation API:

`POST /v3/reservations/{reservation_id}/mock` (for creating a mocked Reservation) and `GET /v3/reservations/{reservation_id}/mock` (for getting a mocked Reservation).
A mocked Reservation has only reservation_id, country, salesLine/brand and the resolved flag. This is the only information needed to simulate a reservation resolve.

```shell script
 http POST :8080/v3/reservations/ds4ed1cfhj78fvgf/mock  \
     X-Flow-Id:orderCreateAsyncFlow \
     X-Country:DE\
     X-Sales-Line:MM
 ```

```shell script
http GET :8080/v3/reservations/ds4ed1cfhj78fvgf/mock
```

### Shipment Confirmation Spec

[source](src/test/kotlin/com/mms/cos/e2e/specs/shipmentconfirmation/ShipmentConfirmationSpec.kt)

1. Produce an `OrderCreatedEvent` with an existing fulfillment.
2. Create a ShipmentConfirmation for this order.
2. Fetch updated order from order-storage.

### Sterling Export Spec

[source](src/test/kotlin/com/mms/cos/e2e/specs/sterling/SterlingExportSpec.kt)

**Case 1**

1. Produce a `OrderLifeCycleEvents.OrderCreatedEvent` with brand = MEDIA_MARKT and country = AT.
2. Produce a `OrderLifeCycleEvents.OrderCreatedEvent` with brand = MEDIA_MARKT and country = ES.
3. Check that both events are exported to Sterling.

**Case 2**

1. Produce a `OrderLifeCycleEvents.OrderCreatedEvent` with brand = SATURN and country = AT.
2. Produce a `OrderLifeCycleEvents.OrderCreatedEvent` with brand = MEDIA_MARKT and country = DE.
3. Check that both events are NOT exported to Sterling.

### Create Order Spec

[source](src/test/kotlin/com/mms/cos/e2e/specs/storage/CreateOrderSpec.kt)

1. Produce an `OrderCreatedEvent`
2. Fetch persisted order from order storage and verify essential attributes.

### MMS Order Item Added Spec

[source](src/test/kotlin/com/mms/cos/e2e/specs/mmsorderchange/MmsOrderItemAddedFlowSpec.kt)

1. Produce a `lifecycle.OrderCreatedEvent`
2. Produce an `init.MmsOrderItemAdditionInitiatedEvent`
3. Check that the `OrderPublishedEvent` contains new item
4. Check that the SAPs `/A_SalesOrderItem` endpoint was called to notify about item creation

### Return Order Spec

[source](src/test/kotlin/com/mms/cos/e2e/specs/returnorder/CreateReturnSpec.kt)

1. Produce a `lifecycle.OrderCreatedEvent`
2. Produce an `init.ReturnInitiatedEvent`
3. Check that the SAPs `/A_CustomerReturn` endpoint was called to create a return order
>>>>>>> dbb733d (Add check crlf action)
