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
                    helper.showToast(component, 'Error', $A.get('Label.c.ERROR_RE'), 'error');
                    let errors = response.getError();
                    console.log(methodName, errors);
                    // reject({'c':component, 'h':helper, 'r':errors, 'state' : response.getState()});
                }
            });
            $A.enqueueAction(action);
        }));
    },

    showToast: function(component, title, message, variant) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "variant": variant
        });
        toastEvent.fire();
    }
})