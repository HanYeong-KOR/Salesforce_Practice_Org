({
    apexCall : function( component, event, helper, methodName, params ) {
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.' + methodName);

            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(helper, function(response) {
                    if (response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'h':helper, 'r':response.getReturnValue(), 'state' : response.getState()});
                    } else {
                        let errors = response.getError();
                        console.log(methodName, errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    toast: function (component, type, mmg) {
        // try {
        //     let toastEvent = $A.get("e.force:showToast");
        //     toastEvent.setParams({
        //         type: type,
        //         message: mmg
        //     });
        //     toastEvent.fire();
            
        // } catch (error) {
        //     console.log('toast error', error.message);
        // }
        component.find('notifLib').showToast({
            "title": type,
            "message": mmg,
            "variant": type
        });
    },
})