import { LightningElement, track } from 'lwc';

import getInitDatas from '@salesforce/apex/PapagoController.getInitDatas';

export default class PapagoComponent extends LightningElement {
  @track engText;
  isLoading = false;

  handleTranslateBtnClick() {
    try {
      this.isLoading = true;
      let text = this.template.querySelector('[data-id="translateKor"]').value;

      getInitDatas({
        question : text
      })
      .then(result => {
        this.engText = result.getTranslateInfo;
        this.isLoading = false;
      })
      .catch(error => {
        console.log('ERROR', error);
        this.isLoading = false;
      });
    } catch(e) {
      console.log('ERROR', e);
      this.isLoading = false;
    }
  }
}