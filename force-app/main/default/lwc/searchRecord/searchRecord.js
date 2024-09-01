import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import SHEETJS from '@salesforce/resourceUrl/SheetJS';
import obtainRecordList from '@salesforce/apex/LookupController.obtainRecordList';

export default class SearchRecord extends NavigationMixin(LightningElement) {
    @track searchkeyword = '';
    @track listOfSearchRecords = [];
    @track hasListOfSearchRecords = false;
    @track pageNumber = 1;
    @track pageSize = 15;
    @track isFirstPage = true;
    @track isLastPage = true;
    sheetJsLoaded = false;
    placeholder = 'Search...';

    connectedCallback() {
        loadScript(this, SHEETJS).then(() => {
            this.sheetJsLoaded = true;
        }).catch(error => {
            console.error('Failed to load SheetJS:', error);
        });
    }

    handleSearchInput(event) {
        this.searchkeyword = event.target.value;
        
        if(this.searchkeyword == null || this.searchkeyword == '') {
            this.clearSearch();
        }
    }

    handleNextPage() {
        this.pageNumber++;
        this.handleClickSearchBtn();
    }

    handlePreviousPage() {
        this.pageNumber--;
        this.handleClickSearchBtn();
    }

    handleKeyPress(event) {
        if (event.key === 'Enter') {
            this.handleSearch();
        }
    }

    clearSearch() {
        this.listOfSearchRecords = [];
        this.searchkeyword = '';
    }

    handleSelectRecord(event) {
        const selectedRecordId = event.currentTarget.dataset.recordId;
        console.log('selectedRecordId', selectedRecordId);

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedRecordId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        })
    }

    handleClickSearchBtn() {
        obtainRecordList({ 
            searchKeyWord : this.searchkeyword,
            pageNumber : this.pageNumber,
            pageSize : this.pageSize
        })
        .then(result => {
            console.log('result', result);
            this.listOfSearchRecords = result;
            if(result.length > 0) {
                this.hasListOfSearchRecords = true;
                this.isLastPage = false;
            }
            this.isFirstPage = this.pageNumber === 1;
            this.isLastPage = result.length < this.pageSize;
        })
        .catch(error => {
            console.log('obtainObjectList error', error);
        });
    }

    handleClickExcelBtn() {
        if (!this.sheetJsLoaded) {
            console.error('SheetJS is not loaded');
            return;
        }

        const data = this.listOfSearchRecords.map(record => ({
            Id: record.recordId,
            Name: record.recordName,
            Phone: record.phone,
            'Billing Address': record.billingAddress
        }));

        const worksheet = XLSX.utils.json_to_sheet(data);
        const workbook = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(workbook, worksheet, 'Accounts');

        const wbout = XLSX.write(workbook, { bookType: 'xlsx', type: 'binary' });
        const buf = new ArrayBuffer(wbout.length);
        const view = new Uint8Array(buf);

        for (let i = 0; i < wbout.length; i++) {
            view[i] = wbout.charCodeAt(i) & 0xFF;
        }

        const blob = new Blob([buf], { type: 'application/octet-stream' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = 'accounts.xlsx';
        link.click();
    }

    handlePasteBtn() {
        try {
            const tempInput = document.createElement('input');
            tempInput.value = this.searchkeyword;
            document.body.appendChild(tempInput);
            tempInput.select();
            document.execCommand('copy');
            document.body.removeChild(tempInput);
    
            const toastEvent = new ShowToastEvent({
                title: 'SUCCESS',
                message: '복사가 완료되었습니다.',
                variant: 'success'
            });
            this.dispatchEvent(toastEvent);
        } catch (e) {
            console.log('# handlePasteBtn error', e);
            const toastEvent = new ShowToastEvent({
                title: 'FAIL',
                message: '복사가 실패하였습니다.',
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        }
    }
}