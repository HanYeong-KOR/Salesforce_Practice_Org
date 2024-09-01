import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import setConvert from '@salesforce/apex/ConvertToContractController.setConvert';

export default class ConvertToContract extends LightningElement {
    @api recordId;
    isLoading = false;

    handleConvertClick() {
        this.isLoading = true;

        setConvert({
            recordId: this.recordId
        })
        .then(result => {
            if(result == 'SUCCESS') {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title   : 'Convert Success',
                        message : '계약이 생성되었습니다.',
                        variant : 'success',
                    }),
                );

                this.handleCloseClick;
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title   : 'Convert Fail',
                        message : '계약 생성이 실패하였습니다.',
                        variant : 'error',
                    }),
                );

                this.handleCloseClick;
            }

            this.isLoading = false;
        })
        .catch(error => {
            console.log('ERROR : ', error);
            this.isLoading = false;
        });
    }

    handleCloseClick() {
        const closeAction = new CloseActionScreenEvent();
        this.dispatchEvent(closeAction);
    }

}