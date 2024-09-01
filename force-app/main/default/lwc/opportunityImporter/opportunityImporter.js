import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpportunityFields from '@salesforce/apex/OpportunityImportController.getOpportunityFields';
import insertOpportunity from '@salesforce/apex/OpportunityImportController.insertOpportunity';

export default class OpportunityImporter extends LightningElement {
    isLoading = false;
    isPasted = false;
    mapcols = [];
    reqFields = [];
    showConfirmModal = false;

    rowCount = 0;
    status = 'Standby';

    successMsg;
    errorMsg;

    handlePaste(event) {
        this.isLoading = true;
        this.isPasted = true;
        this.successMsg = '';
        this.errorMsg = '';
        getOpportunityFields().then(result => {
            const table = this.template.querySelector('c-opportunity-import-table');
            this.mapcols = table.columns;
            this.reqFields = result;
            this.rowCount = table.tableData.length;
            this.status = 'Standby';
            const confirmButton = this.template.querySelector('[data-id="insertButton"]');
            confirmButton.disabled = false;
        }).catch(error => {
            console.log(error);
        }).finally(() => {
            this.mapFields();
            this.isLoading = false;
        })
    }

    handleConfirmButton(event) {
        event.target.disabled = true;
        this.status = 'Inserting'
        this.isLoading = true;
        const mappedData = this.mapTableData();
        
        insertOpportunity({tableData: mappedData}).then(() => {
            this.status = 'Success'
            this.isLoading = false;
            this.errorMsg = '';
            this.successMsg = 'Loaded ' + mappedData.length + ' records';
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Import Success',
                    message : 'Successfully loaded ' + mappedData.length + ' records.',
                    variant : 'success',
                }),
            );
            this.showConfirmModal = false;
            const confirmButton = this.template.querySelector('[data-id="insertButton"]');
            confirmButton.disabled = true;
        }).catch(error => {
            this.status = 'Error'
            this.isLoading = false;
            this.successMsg = '';
            this.errorMsg = error.body.message;
            this.dispatchEvent(
                new ShowToastEvent({
                    title : error.statusText,
                    message : error.body.message,
                    variant : 'error',
                }),
            );
        });
    }

    mapFields() {
        this.mapcols.forEach((mapcol, index, array) => {
            this.reqFields.forEach(reqField => {
                const combobox = this.template.querySelectorAll('lightning-combobox')[index];
                if(combobox !== undefined && (mapcol.label === reqField.label || mapcol.label === reqField.value)) {
                    combobox.value = reqField.value;
                }
            });
        });
    }

    mapTableData() {
        const table = this.template.querySelector('c-opportunity-import-table');
        const cboxes = this.template.querySelectorAll('lightning-combobox');
        const fieldMap = {};
        const mappedData = [];
        cboxes.forEach(cbox => {
            if(cbox.value !== null && cbox.value !== undefined) {
                fieldMap[cbox.label] = cbox.value;
            }
        });
        table.tableData.forEach(row => {
            let fieldMapObj = {};
            for(const [key, value] of Object.entries(row)) {
                if(fieldMap[key] !== undefined) {
                    fieldMapObj[fieldMap[key]] = value;
                }
            }
            mappedData.push(fieldMapObj);
        });
        return mappedData;
    }

    handleRowSelect(event) {
        const deleteButton = this.template.querySelector('[data-id="deleteButton"]');
        deleteButton.disabled = event.detail;
    }

    handleDeleteButton() {
        let newData = this.template.querySelector('c-opportunity-import-table').deleteCheckedRows();
        this.template.querySelector('[data-id="deleteButton"]').disabled = true;
        this.rowCount = newData.length;
    }

    showModal() {
        this.showConfirmModal = true;
    }

    hideModal() {
        this.showConfirmModal = false;
    }

    fireCloseEvent() {
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }
}