({
    scriptsLoaded: function(component, event, helper) {
        helper.setChart(component, event, helper);
    },

    handleSearchChart: function(component, event, helper) {
        helper.updateChart(component, event, helper);
    },

    handleClickTargetEditBtn: function(component, event, helper) {
        component.set("v.isModal", true);
    },
    
    handleCloseModal: function(component, event, helper) {
        component.set("v.isModal", false);
    }
})