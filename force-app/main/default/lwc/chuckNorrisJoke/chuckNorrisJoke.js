import { LightningElement, track } from 'lwc';

import getRandomChuckNorrisJoke from '@salesforce/apex/ChuckNorrisController.getRandomChuckNorrisJoke';
import translateJoke from '@salesforce/apex/PapagoController.translateJoke';

export default class ChuckNorrisJoke extends LightningElement {
    isLoading = false;
    @track joke;
    @track error;
    @track korText;

    connectedCallback() {
        this.isLoading = true;
        // Fetch a random Chuck Norris joke when the component is loaded
        this.getRandomJoke();
        this.isLoading = false;
    }

    getRandomJoke() {
        this.isLoading = true;
        getRandomChuckNorrisJoke()
            .then(result => {
                this.joke       = JSON.parse(result);
                this.korText    = '';
                this.isLoading  = false;
            })
            .catch(error => {
                this.error      = error.message;
                this.isLoading  = false;
            });
    }

    getTranslate() {
        this.isLoading = true;
        let text = this.template.querySelector('[data-id="engValue"]').innerHTML;

        translateJoke({
            question : text
        })
        .then(result => {
            this.korText    = result;
            this.isLoading  = false;
        })
        .catch(error => {
            console.log('ERROR', error);
            this.isLoading = false;
        });
    }
}