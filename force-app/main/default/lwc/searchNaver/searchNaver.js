import { LightningElement, track } from 'lwc';

import naverSearch from '@salesforce/apex/PapagoController.naverSearch';

export default class SearchNaver extends LightningElement {
    @track searchQuery = '';
    @track searchResults = [];
    @track isLoading = false;
    @track isSearch = false;

    handleChangeSearch(event) {
        this.searchQuery = event.target.value;
    }

    handleClickSearch() {
        this.isLoading = true;
        naverSearch({ question : this.searchQuery })
            .then(result => {
                this.searchResults = result;
                this.isSearch = true;
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error:', error);
                this.isLoading = false;
            });
    }

    get answer() {
        return this.searchResults;
    }
}