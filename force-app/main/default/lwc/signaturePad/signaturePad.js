import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';

import SIGNATURE_PAD from '@salesforce/resourceUrl/signature';

export default class SignaturePad extends LightningElement {
    @api id = '';
    @api minWidth = 0.5;
    @api maxWidth = 2;
    @api penColor = 'rgb(0,0,0)';
    @api signatureData = '';
    @api readOnly = false;
    
    signaturePad;
    canvas;

    renderedCallback() {
        if (this.signaturePad) {
            return;
        }

        Promise.all([
            loadScript(this, SIGNATURE_PAD + '/signature_pad.min.js')
        ]).then(() => {
            console.log('Loaded SIGNATUREPAD');
            this.initializeSignaturePad();
        }).catch(error => {
            console.error('Error loading signature pad script:', error);
        });
    }

    initializeSignaturePad() {
        const canvas = this.template.querySelector('canvas');
        this.signaturePad = new window.SignaturePad(canvas, {
            minWidth: this.minWidth,
            maxWidth: this.maxWidth,
            penColor: this.penColor
        });
        this.resizeCanvas(canvas);
    }

    resizeCanvas(canvas) {
        const ratio = Math.max(window.devicePixelRatio || 1, 1);
        canvas.width = canvas.offsetWidth * ratio;
        canvas.height = canvas.offsetHeight * ratio;
        canvas.getContext('2d').scale(ratio, ratio);
    }

    @api
    capture() {
        if (this.signaturePad) {
            const dataUrl = this.signaturePad.toDataURL();
            this.signatureData = dataUrl;
            console.log(this.signatureData);
        }
    }

    @api
    clear() {
        if (this.signaturePad) {
            this.signaturePad.clear();
        }
    }

    handleTouchMove(event) {
        event.stopPropagation();
    }

    handleTouch() {
        const input = this.template.querySelector('input.esignature-hide');
        if (input) {
            input.focus();
        }
    }

    get wrapperId() {
        return 'signatureWrapper' + this.id;
    }
}