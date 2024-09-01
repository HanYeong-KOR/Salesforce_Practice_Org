import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getLoaded from '@salesforce/apex/ForecastChartController.getLoaded';
import setTarget from '@salesforce/apex/ForecastChartController.setTarget';

export default class EditTargetModal extends LightningElement {
    currentTarget;

    connectedCallback() {
        getLoaded({})
        .then(result => {
            this.currentTarget = result.target;
        })
        .catch(error => {
            console.log('getLoaded error', error);
        })
    }

    handleCloseModal() {
        const closeEvent = new CustomEvent('closemodal');
        this.dispatchEvent(closeEvent);
    }

    handleClickSave() {
        let target = this.template.querySelector('.qtyInp').value;

        if(target == 0 || target == null) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please enter a target.',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        } else {
            setTarget({
                value : target
            })
            .then(result => {
                this.handleCloseModal();
                window.location.reload();
            })
            .catch(error => {
                console.log('setTarget error', error);
            })
        }
    }
}