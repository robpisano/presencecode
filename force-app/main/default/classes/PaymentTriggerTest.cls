@isTest
public class PaymentTriggerTest {

    @testSetup
    static void createData() {
        Project__c proj = new Project__c(Name = 'Test Project');
        insert proj;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert con;
    }
    
    @isTest
    public static void testInsertPayment() {
        Test.startTest();
        Project__c p = [SELECT Id FROM Project__c LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        
        Decimal amount = 100;
        Date payDate = Date.today();
        
        Payment__c pay = new Payment__c(Amount__c = amount, Payment_Date__c = payDate, Paid_By__c = c.Id, Project__c = p.Id);
        insert pay;
        Test.stopTest();
        
        c = [SELECT Id, Earliest_Payment_Date__c, Total_Payments_Made__c FROM Contact WHERE id = :c.Id];
        p = [SELECT Id, Payments_Made__c, Earliest_Payment_Date__c FROM Project__c WHERE id = :p.Id];
        System.assertEquals(amount, c.Total_Payments_Made__c);
        System.assertEquals(payDate, c.Earliest_Payment_Date__c);
        System.assertEquals(amount, p.Payments_Made__c);
        System.assertEquals(payDate, p.Earliest_Payment_Date__c);
    }
    
    
    @isTest
    public static void testDeletePayment() {
        Test.startTest();
        Project__c p = [SELECT Id FROM Project__c LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        
        Decimal amount = 100;
        Date payDate = Date.today();
        
        List<Payment__c> payments = new List<Payment__c>();
        
        payments.add(new Payment__c(Amount__c = amount, Payment_Date__c = payDate, Paid_By__c = c.Id, Project__c = p.Id));
        payments.add(new Payment__c(Amount__c = amount + 50, Payment_Date__c = payDate - 2, Paid_By__c = c.Id, Project__c = p.Id));
        payments.add(new Payment__c(Amount__c = amount + 70, Payment_Date__c = payDate - 3, Paid_By__c = c.Id, Project__c = p.Id));
        insert payments;
        
        List<Payment__c> paymentsToDelete = new List<Payment__c>();
        paymentsToDelete.add(payments[1]);
        paymentsToDelete.add(payments[2]);
        
        delete paymentsToDelete;
        Test.stopTest();
        
        c = [SELECT Id, Earliest_Payment_Date__c, Total_Payments_Made__c FROM Contact WHERE id = :c.Id];
        p = [SELECT Id, Payments_Made__c, Earliest_Payment_Date__c FROM Project__c WHERE id = :p.Id];
        System.assertEquals(amount, c.Total_Payments_Made__c);
        System.assertEquals(payDate, c.Earliest_Payment_Date__c);
        System.assertEquals(amount, p.Payments_Made__c);
        System.assertEquals(payDate, p.Earliest_Payment_Date__c);
    }
    
    
    @isTest
    public static void testUpdatePayment() {
        Test.startTest();
        Project__c p = [SELECT Id FROM Project__c LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        
        Decimal amount = 100;
        Date payDate = Date.today();
        
        Payment__c pay = new Payment__c(Amount__c = amount - 50, Payment_Date__c = payDate + 2, Paid_By__c = c.Id, Project__c = p.Id);
        insert pay;
        
        pay.Amount__c = amount;
        pay.Payment_Date__c = payDate;
        update pay;
        
        Test.stopTest();
        
        c = [SELECT Id, Earliest_Payment_Date__c, Total_Payments_Made__c FROM Contact WHERE id = :c.Id];
        p = [SELECT Id, Payments_Made__c, Earliest_Payment_Date__c FROM Project__c WHERE id = :p.Id];
        System.assertEquals(amount, c.Total_Payments_Made__c);
        System.assertEquals(payDate, c.Earliest_Payment_Date__c);
        System.assertEquals(amount, p.Payments_Made__c);
        System.assertEquals(payDate, p.Earliest_Payment_Date__c);
    }
    
}