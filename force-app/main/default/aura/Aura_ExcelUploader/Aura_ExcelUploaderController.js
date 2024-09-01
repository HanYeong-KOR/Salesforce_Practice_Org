({
    scriptsLoaded: function(component, event, helper) {
        console.log('XLSX library loaded.');
        component.set("v.libInitialized", true);
    },

    handleSearchInput: function(component, event, helper) {
        helper.handleSearchInput(component, event, helper);
    },

    handleKeyPress: function(component, event, helper) {
        helper.handleKeyPress(component, event);
    },

    handleSelectObject: function(component, event, helper) {
        helper.handleSelectObject(component, event);
    },

    handleFileChange: function(component, event, helper) {
        helper.handleFileChange(component, event);
    },

    handleUpload: function(component, event, helper) {
        helper.handleUpload(component, event);
    },

    handlePreviousButton: function(component, event, helper) {
        helper.handlePreviousButton(component);
    },

    handleRowSelect: function(component, event, helper) {
        // Handle row selection in the table
    }
})