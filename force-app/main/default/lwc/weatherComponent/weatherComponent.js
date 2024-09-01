import { LightningElement, track, wire } from 'lwc';

import getWeather from '@salesforce/apex/WeatherService.getWeather';

export default class WeatherComponent extends LightningElement {
    @track weatherData;
    @track error;

    connectedCallback() {
        getWeather({})
        .then(result => {
            this.weatherData = result;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.weatherData = undefined;
        })
    }
}