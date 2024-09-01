import { LightningElement, track } from 'lwc';

import obtainObjectList from '@salesforce/apex/LookupController.obtainObjectList';
import getFieldInfo from '@salesforce/apex/LookupController.getFieldInfo';

export default class LookupObject extends LightningElement {
    @track searchkeyword = '';
    @track listOfSearchObjects = [];
    @track listOfSearchFields = [];
    @track isFields = false;
    placeholder = 'Search...';

    handleSearchInput(event) {
        this.searchkeyword = event.target.value;
        
        if(this.searchkeyword == null || this.searchkeyword == '') {
            this.clearSearch();
        } else {
            this.listOfSearchFields = [];
            this.isFields = false;
            this.handleSearch();
        }
    }

    handleKeyPress(event) {
        if (event.key === 'Enter') {
            this.handleSearch();
        }
    }

    
    handleSearch() {
        obtainObjectList({ searchKeyWord: this.searchkeyword })
            .then(result => {
                this.listOfSearchObjects = result;
            })
            .catch(error => {
                console.log('obtainObjectList error', error);
            });
    }

    clearSearch() {
        this.listOfSearchObjects = [];
        this.listOfSearchFields = [];
        this.searchkeyword = '';
        this.isFields = false;
    }

    handleSelectObject(event) {
        const selectedObjectName = event.currentTarget.dataset.objectName;

        getFieldInfo({
            objectAPI : selectedObjectName
        })
        .then(result => {
            result.sort((a, b) => (a.fieldLabel > b.fieldLabel) ? 1 : -1);

            if(result) {
                this.listOfSearchFields = [];
                this.listOfSearchFields = result;
                this.isFields = true;
            }
        })
        .catch(error => {
            console.log('getFieldInfo error', error);
        })
    }

    handleSelectField(event) {
        let fieldLabel = event.currentTarget.querySelector('.object-label').textContent;
        let fieldName = event.currentTarget.dataset.objectName;
        let fieldType = event.currentTarget.dataset.fieldType;
        
        console.log('선택한 필드 레이블:', fieldLabel);
        console.log('선택한 필드 이름:', fieldName);
        console.log('선택한 필드 유형:', fieldType);
    }
}