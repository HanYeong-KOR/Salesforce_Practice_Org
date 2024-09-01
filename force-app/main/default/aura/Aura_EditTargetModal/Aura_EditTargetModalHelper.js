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

    showToast: function (message, type) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            type: type
        });
        toastEvent.fire();
    },

    closeModal : function(component, helper) {
        var closeModalEvent = component.getEvent("closeModal");

        if (!$A.util.isEmpty(closeModalEvent)) {
            closeModalEvent.fire();
        }
    }
})