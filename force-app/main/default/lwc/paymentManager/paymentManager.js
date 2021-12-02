import { LightningElement, wire, api, track} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import retrievePayments from '@salesforce/apex/PaymentManagerDAO.retrievePayments';
import retrieveProjects from '@salesforce/apex/PaymentManagerDAO.retrieveProjects'; 
import updatePayment from '@salesforce/apex/PaymentManagerDAO.updatePayment';
import deletePayment from '@salesforce/apex/PaymentManagerDAO.deletePayment'; 
import insertPayment from '@salesforce/apex/PaymentManagerDAO.insertPayment';

const contactColumns = [
    {label: 'Name', fieldName: 'Name', type: 'string', sortable: false, hideDefaultActions: true},
    {label: 'Total Payments Made', fieldName: 'Total_Payments_Made__c', type: 'currency', cellAttributes: { alignment: 'left' }, sortable: false, hideDefaultActions: true},
    {label: 'Earliest Payment Date', fieldName: 'Earliest_Payment_Date__c', type: 'date', sortable: false, hideDefaultActions: true}
];

export default class PaymentManager extends LightningElement {
    @track contactList;
    @track errorMsg = '';
    contactColumns = contactColumns;

    @wire(retrievePayments, {})
    populatePayments(result) {
        const {data, error} = result;
        this.contactList = [];
        if (data) {
            console.log(data);
            data.forEach(contact => {
                this.contactList.push(contact);
            })
            console.log(this.contactList);
        } else if (error) {
            console.log(error);
            this.errorMsg = error;
        }
    }

    get contactList2() {
        console.log(this.contactList);
        return this.contactList;
    }
}