import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import saveSignatureNew from '@salesforce/apex/SignatureContainerController.saveSignatureNew';

export default class SignaturePadContainer extends LightningElement {
    @api recordId;
    @api isDisplay = false;
    @api showModalSpinner = false;

    handleClear() {
        this.template.querySelector('c-signature-pad').clear();
    }

    handleAcceptSignature() {
        const signatureComponent = this.template.querySelector('c-signature-pad');
        signatureComponent.capture();
        
        let strDataURI = signatureComponent.signatureData;
        strDataURI = strDataURI.replace(/^data:image\/(png|jpg);base64,/, "");
        
        try {
            if (strDataURI.length < 4096) {
                this.showToast('warning', 'Signature Verification', 'Please ensure the signature is valid.');
                signatureComponent.initializeSignaturePad();
            } else {
                this.showModalSpinner = true;
                saveSignatureNew({ signatureBody: strDataURI, parentId: this.recordId })
                    .then(result => {
                        if (result) {
                            this.showToast('success', 'Confirmation', 'Signature saved successfully.');
                            this.showModalSpinner = false;
                            this.isDisplay = true;
                            this.dispatchEvent(new CustomEvent('refresh'));
                        } else {
                            this.showToast('error', 'Error', 'Failed to save signature.');
                            this.showModalSpinner = false;
                            this.isDisplay = true;
                            signatureComponent.clear();
                        }
                    })
                    .catch(error => {
                        console.error('Error saving signature:', error);
                    });
            }
        } catch (e) {
            console.error(e);
        }
    }

    showToast(variant, title, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}