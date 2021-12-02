trigger PaymentTrigger on Payment__c (after insert, after update, after delete) {
    PaymentTriggerHandler.updateRelatedPaymentFields(Trigger.oldMap, Trigger.newMap);
}