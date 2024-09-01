({
    apexCall : function( component, event, helper, methodName, params ) {
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.' + methodName);
            
            action.setParams(params);
            action.setCallback(helper, function(response) {
                if (response.getState() === 'SUCCESS') {
                    resolve({'c':component, 'h':helper, 'r':response.getReturnValue(), 'state' : response.getState()});
                } else {
                    //helper.showToast('error', 'Error', $A.get('Label.c.ERROR_RE'));
                    let errors = response.getError();
                    console.log(methodName, errors);
                    // reject({'c':component, 'h':helper, 'r':errors, 'state' : response.getState()});
                }
            });
            $A.enqueueAction(action);
        }));
    },

    setChart: function(component, event, helper) {
        component.set("v.isLoading", true);
        helper.apexCall(component, event, helper, 'getLoaded', {})
        .then($A.getCallback(function(result){
            const r = result.r;
            component.set("v.monthList", r.months);
            component.set("v.rows", r.datas.chartRow);

            var canvas = component.find("barChart").getElement();
            var chartInstance = new Chart(canvas, {
                type: 'bar',
                data: {
                    labels: component.get("v.monthList"),
                    datasets: component.get("v.rows")
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'top' },
                        title: { display: false, text: 'Forecasting Chart' }
                    },
                    scales: {
                        x: { stacked: true },
                        y: {
                            stacked: true,
                            ticks: {
                                beginAtZero: true,
                                callback: function(value) { return value / 1000000 + 'M'; }
                            }
                        }
                    }
                }
            });
            component.set("v.chartInstance", chartInstance);
            component.set("v.isLoading", false);
        }))
        .catch(function(err) {
            console.log('error', err);
        });
    },

    updateChart: function(component, event, helper) {
        component.set("v.isLoading", true);
        var chance = component.find("winRate").get("v.value");
        var type = component.find("type").get("v.value");

        helper.apexCall(component, event, helper, 'setFilter', {
            chance: chance, 
            type: type
        })
        .then($A.getCallback(function(result){
            const r = result.r;
            component.set("v.rows", r.chartRow);

            var chartInstance = component.get("v.chartInstance");
            chartInstance.destroy();

            var canvas = component.find("barChart").getElement();
            chartInstance = new Chart(canvas, {
                type: 'bar',
                data: {
                    labels: component.get("v.monthList"),
                    datasets: component.get("v.rows")
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'top' },
                        title: { display: false, text: 'Forecasting Chart' }
                    },
                    scales: {
                        x: { stacked: true },
                        y: {
                            stacked: true,
                            ticks: {
                                beginAtZero: true,
                                callback: function(value) { return value / 1000000 + 'M'; }
                            }
                        }
                    }
                }
            });
            component.set("v.chartInstance", chartInstance);
            component.set("v.isLoading", false);
        }));
    },
})