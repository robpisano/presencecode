public class PaymentTriggerHandler {
    
    public static void updateRelatedPaymentFields(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        Map<Id, Date> contactDateMap = new Map<Id, Date>();
        Map<Id, Decimal> contactAmountMap = new Map<Id, Decimal>();
        Map<Id, Date> projectDateMap = new Map<Id, Date>();
        Map<Id, Decimal> projectAmountMap = new Map<Id, Decimal>();
        Set<Id> paymentIds = new Set<Id>();
        
        if (newMap != null && newMap.size() > 0) { // insert and update handler
            paymentIds = newMap.keySet();
            for (Id paymentId : paymentIds) {
                Payment__c newPayment = (Payment__c)newMap.get(paymentId);
                Decimal amountDelta = oldMap != null && oldMap.containsKey(paymentId) ? newPayment.Amount__c - ((Payment__c)oldMap.get(paymentId)).Amount__c : newPayment.Amount__c;
                if (!contactDateMap.containsKey(newPayment.Paid_By__c)) {
                    contactDateMap.put(newPayment.Paid_By__c, newPayment.Payment_Date__c);
                    contactAmountMap.put(newPayment.Paid_By__c, amountDelta);
                } else {
                    if (contactDateMap.get(newPayment.Paid_By__c) > newPayment.Payment_Date__c) {
                        contactDateMap.put(newPayment.Paid_By__c, newPayment.Payment_Date__c);
                    }
                    Decimal newAmount = contactAmountMap.get(newPayment.Paid_By__c) + amountDelta;
                    contactAmountMap.put(newPayment.Paid_By__c, newAmount);
                }
                if (!projectDateMap.containsKey(newPayment.Project__c)) {
                    projectDateMap.put(newPayment.Project__c, newPayment.Payment_Date__c);
                    projectAmountMap.put(newPayment.Project__c, amountDelta);
                } else {
                    if (projectDateMap.get(newPayment.Project__c) > newPayment.Payment_Date__c) {
                        projectDateMap.put(newPayment.Project__c, newPayment.Payment_Date__c);
                    }
                    Decimal newAmount = projectAmountMap.get(newPayment.Project__c) + amountDelta;
                    projectAmountMap.put(newPayment.Project__c, newAmount);
                }
            }
        } else { // delete handler
            paymentIds = oldMap.keySet();
            for (Id paymentId : paymentIds) {
                Payment__c payment = (Payment__c)oldMap.get(paymentId);
                if (!contactAmountMap.containsKey(payment.Paid_By__c)) {
                    contactAmountMap.put(payment.Paid_By__c, payment.Amount__c * -1);
                } else {
                    Decimal newAmount = contactAmountMap.get(payment.Paid_By__c) - payment.Amount__c;
                    contactAmountMap.put(payment.Paid_By__c, newAmount);
                }
                if (!projectAmountMap.containsKey(payment.Project__c)) {
                    projectAmountMap.put(payment.Project__c, payment.Amount__c * -1);
                } else {
                    Decimal newAmount = projectAmountMap.get(payment.Project__c) - payment.Amount__c;
                    projectAmountMap.put(payment.Project__c, newAmount);
                }
            }
        }
        
        List<Contact> contacts = [SELECT Id, Earliest_Payment_Date__c, Total_Payments_Made__c, (SELECT Id, Payment_Date__c FROM Payments__r WHERE (NOT Id IN :paymentIds)) FROM Contact WHERE Id IN :contactAmountMap.keySet()];
        List<Project__c> projects = [SELECT Id, Payments_Made__c, Earliest_Payment_Date__c, (SELECT Id, Payment_Date__c FROM Payments__r WHERE (NOT Id IN :paymentIds)) FROM Project__c WHERE Id IN :projectAmountMap.keySet()];
        
        if (contacts != null && contacts.size() > 0) {
            for (Contact c : contacts) {
                if (c.Total_Payments_Made__c == null) c.Total_Payments_Made__c = 0;
                c.Total_Payments_Made__c = c.Total_Payments_Made__c + contactAmountMap.get(c.Id);
                if (contactDateMap != null && (c.Earliest_Payment_Date__c == null || contactDateMap.get(c.Id) <= c.Earliest_Payment_Date__c)) {
                    c.Earliest_Payment_Date__c = contactDateMap.get(c.Id);
                } else {
                    Date earliestDate = contactDateMap != null ? contactDateMap.get(c.Id) : null;
                    for (Payment__c payment : c.Payments__r) {
                        earliestDate = earliestDate == null || payment.Payment_Date__c < earliestDate ? payment.Payment_Date__c : earliestDate;
                    }
                    c.Earliest_Payment_Date__c = earliestDate;
                }
            }
            update contacts;
        }
        if (projects != null && projects.size() > 0) {        
            for (Project__c proj : projects) {
                if (proj.Payments_Made__c == null) proj.Payments_Made__c = 0;
                proj.Payments_Made__c = proj.Payments_Made__c + projectAmountMap.get(proj.Id);
                if (projectDateMap != null && (proj.Earliest_Payment_Date__c == null || projectDateMap.get(proj.Id) <= proj.Earliest_Payment_Date__c)) {
                    proj.Earliest_Payment_Date__c = projectDateMap.get(proj.Id);
                } else {
                    Date earliestDate = projectDateMap != null ? projectDateMap.get(proj.Id) : null;
                    for (Payment__c payment : proj.Payments__r) {
                        earliestDate = earliestDate == null || payment.Payment_Date__c < earliestDate ? payment.Payment_Date__c : earliestDate;
                    }
                    proj.Earliest_Payment_Date__c = earliestDate;
                }
            }
            update projects;
        }
    }
    
}