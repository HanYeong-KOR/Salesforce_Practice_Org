import { LightningElement, api } from 'lwc';

import getInitDatas from '@salesforce/apex/GoogleMapController.getInitDatas';

export default class GoogleMap extends LightningElement {
    @api recordId;
    isLoading = false;
    mapMarkers = [];
    markersTitle = '';
    center = {};

    connectedCallback() {
        try {
            this.isLoading = true;

            getInitDatas({
                recordId : this.recordId
            })
            .then(result => {
                this.mapMarkers = [{
                    location: {
                        Street: result.getInitDatas[0].location.Street,
                        City: result.getInitDatas[0].location.City,
                        State: result.getInitDatas[0].location.State
                    },
                    title: result.getInitDatas[0].title,
                    description: result.getInitDatas[0].description
                }];
    
                this.markersTitle = result.getInitDatas[0].title;
    
                this.center = {
                    Street: result.getInitDatas[0].location.Street,
                    PostalCode: result.getInitDatas[0].postalCode
                };

                this.isLoading = false;
            })
            .catch(error => {
                console.log('ERROR : ' + error);
                this.isLoading = false;
            });
        } catch (e) {
            console.log('ERROR : ' + e);
            this.isLoading = false;
        }
    }
}