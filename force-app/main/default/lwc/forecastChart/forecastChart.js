import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';

import CHARTJS from '@salesforce/resourceUrl/ChartJS';

import getLoaded from '@salesforce/apex/ForecastChartController.getLoaded';
import setFilter from '@salesforce/apex/ForecastChartController.setFilter';

export default class ForecastChart extends LightningElement {
    @track isLoading = true;
    @track isModal = false;
    @track chartInstance;
    @track monthList = [];
    @track rows = [];
    winRateDefault = 'all';
    typeDefault = 'Stacked';

    get winRate() {
        return [
            { label: 'All', value: 'all' },
            { label: '10%', value: '10' },
            { label: '20%', value: '20' },
            { label: '50%', value: '50' },
            { label: '60%', value: '60' },
            { label: '70%', value: '70' },
            { label: '75%', value: '75' },
            { label: '90%', value: '90' },
            { label: '100%', value: '100' }
        ];
    }

    get type() {
        return [
            { label: '월별', value: 'monthType' },
            { label: '누적', value: 'Stacked' }
        ];
    }

    async connectedCallback() {
        try {
            await loadScript(this, CHARTJS);
            console.log('CHARTJS loaded');
            this.setChart();
        } catch (error) {
            console.error('Error loading CHARTJS: ', error);
        }
    }

    async setChart() {
        try {
            const canvas = this.template.querySelector('.barChart');
            if (!canvas) {
                console.error('Canvas element not found');
                return;
            }

            const result = await getLoaded();

            this.monthList = result.months;
            this.rows = result.datas.chartRow;

            this.chartInstance = new Chart(canvas, {
                type: 'bar',
                data: {
                    labels: this.monthList,
                    datasets: this.rows
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'top',
                        },
                        title: {
                            display: false,
                            text: 'Forecasting Chart'
                        }
                    },
                    scales: {
                        x: {
                            stacked: true,
                        },
                        y: {
                            stacked: true,
                            ticks: {
                                beginAtZero: true,
                                callback: function(value) {
                                    return value / 1000000 + 'M';
                                }
                            }
                        }
                    }
                }
            });
            this.isLoading = false;
        } catch (e) {
            console.error('setChart error: ', e);
        }
    }

    handleSearchChart() {
        try {
            let chance = this.template.querySelector('[data-id = "winRate"]').value;
            let type = this.template.querySelector('[data-id = "type"]').value;
    
            const canvas = this.template.querySelector('.barChart');
            if (!canvas) {
                console.error('Canvas element not found');
                return;
            }
    
            if (this.chartInstance) {
                this.chartInstance.destroy();
            }
    
            setFilter({
                chance: chance,
                type: type
            })
            .then(result => {
                this.rows = result.chartRow;
    
                this.chartInstance = new Chart(canvas, {
                    type: 'bar',
                    data: {
                        labels: this.monthList,
                        datasets: this.rows
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                position: 'top',
                            },
                            title: {
                                display: false,
                                text: 'Forecasting Chart'
                            }
                        },
                        scales: {
                            x: {
                                stacked: true,
                            },
                            y: {
                                stacked: true,
                                ticks: {
                                    beginAtZero: true,
                                    callback: function(value) {
                                        return value / 1000000 + 'M';
                                    }
                                }
                            }
                        }
                    }
                });
            })
            .catch(error => {
                console.log('setFilter error : ' + error);
            });
        } catch (e) {
            console.log('handleSearchChart error ::: ' + JSON.stringify(e));
        }
    }

    handleClickTargetEditBtn() {
        this.isModal = true;
    }

    handleCloseModal() {
        this.isModal = false;
    }
}