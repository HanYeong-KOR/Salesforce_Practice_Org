import { LightningElement, api, wire, track } from 'lwc';
import fetchAccountNews from '@salesforce/apex/GoogleNewsController.fetchAccountNews';

export default class NewsBoard extends LightningElement {
    @api recordId; // Account record ID
    @track newsArticles;
    @track pages = [];
    @track disablePrevious = true;
    @track disableNext = false;
    @track error;
    pageNumber = 1;
    pageSize = 10;
    totalResults;

    connectedCallback() {
        fetchAccountNews({ 
            accountId : this.recordId,
            pageNumber : this.pageNumber,
            pageSize : this.pageSize
        })
        .then(result => {
            console.log(result);
            this.newsArticles = result;
            this.disableNext = result.length < this.pageSize;
            this.disablePrevious = this.pageNumber === 1;
            // this.totalResults = result[0].totalResults;
            this.totalResults = 100;
            this.calculatePages();
        })
        .catch(err => {
            console.log('fetchAccountNews error : ' + err);
            this.error = JSON.stringify(err);
        })
    }

    handlePrevious() {
        if (this.pageNumber > 1) {
            this.pageNumber -= 1;
            this.connectedCallback();
        }
    }

    handleNext() {
        this.pageNumber += 1;
        this.connectedCallback();
    }

    handlePageClick(event) {
        this.pageNumber = parseInt(event.target.dataset.page, 10);
        this.connectedCallback();
    }

    calculatePages() {
        const totalPages = Math.ceil(this.totalResults / this.pageSize); // Assuming you have totalResults
        this.pages = [];
        for (let i = 1; i <= totalPages; i++) {
            this.pages.push(i);
        }
    }
}