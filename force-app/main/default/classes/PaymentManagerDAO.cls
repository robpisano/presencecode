public class PaymentManagerDAO {
    @AuraEnabled(cacheable=true)
    public static List<Contact> retrievePayments() {
        return [SELECT Id, Name, Earliest_Payment_Date__c, Total_Payments_Made__c, (SELECT Id, Project__r.Name, Payment_Date__c, Amount__c FROM Payments__r ORDER BY Payment_Date__c) FROM Contact WHERE Earliest_Payment_Date__c != null];
    }

    @AuraEnabled
    public static List<Project__c> retrieveProjects(){
        return [SELECT Id, Name FROM Project__c ORDER BY Name];
    }

    @AuraEnabled
    public static void updatePayment(Payment__c payment){
        try {
            update payment;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void deletePayment(Payment__c payment){
        try {
            delete payment;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void insertPayment(String contactId, String projectId, Date payDate, Decimal amount){
        try {
            Payment__c payment = new Payment__c(Paid_By__c = contactId, Project__c = projectId, Amount__c = amount, Payment_Date__c = payDate);
            insert payment;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
