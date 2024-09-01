({
    doInit : function(component, event, helper) {
        component.set("v.isLoading", true);

        helper.apexCall(component, event, helper, 'getLoaded', {})
        .then($A.getCallback(function(result){
            const r = result.r;
            console.log("🚀 ~ .then ~ r:", r);

            component.set("v.currentTarget", r.target);
            
            component.set("v.isLoading", false);
        }))
        .catch(function(err) {
            console.log('error', err);
        });
    },

    handleClickSave : function(component, event, helper) {
        component.set("v.isLoading", true);
        let target = document.querySelector('.qtyInp').value;

        if(target == 0 || target == null) {
            helper.showToast('Please enter a target.', 'error');
        } else {
            helper.apexCall(component, event, helper, 'setTarget', {
                value : target
            })
            .then(
                $A.getCallback(function(result){
                    const r = result.r;
        
                    helper.closeModal(component, helper);
                    helper.showToast('Success Target Change', 'success');
                    $A.get('e.force:refreshView').fire();
                    
                    component.set("v.isLoading", false);
                })
            );
        }
    },

    handleCloseModal : function(component, event, helper) {
        helper.closeModal(component, helper);
    }
})