({
    handleChangeRadio : function(component, event, helper) {
        var changeValue = event.getParam("value");
        var options     = component.get("v.recordTypeOptions");
        var changeLabel = options.find(option => option.value === changeValue).label;

        component.set('v.radioValue', changeValue);
        component.set('v.radioLabel', changeLabel);
    },

    handleNext : function(component, event, helper) {
        component.set('v.isLoading', true);

        // Apex Call
        helper.apexCall(component, event, helper, 'getNextInit', {
            objectName      : component.get('v.objectName'),
            recordTypeName  : 'Case'
            // recordTypeName  : component.get('v.radioValue')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            let adjustedPageLayout = [];
            for(var i = 1; i <= r.retrieveObjectLayout.layoutSectionList.length - 1; i++) {
                adjustedPageLayout.push(r.retrieveObjectLayout.layoutSectionList[i]);
            }
            component.set('v.pageLayout',           r.retrieveObjectLayout.layoutSectionList);
            component.set('v.initPageLayout',       r.retrieveObjectLayout.layoutSectionList[0]);
            component.set('v.adjustedPageLayout',   adjustedPageLayout);
            // component.set('v.recordTypeId',         r.getRecordTypeId);
            component.set('v.formulaFieldMap',      r.getFormulaFieldCondition);

            component.set('v.isNext',       true);
            component.set('v.isLoading',    false);
        }))
        .catch(function(error) {
            console.log('# handleNext error : ' + error.message);
        });
    },

    handleChangeFieldValue : function(component, event, helper) {
        var changedField    = event.getSource();
        var fieldValue      = changedField.get("v.value");
        var fieldName       = changedField.get("v.fieldName");
        var lookupFieldMap  = {};
        
        if(fieldValue == '납품후교육' || fieldValue == 'Post-delivery training') component.set('v.isDependency', true);

        if(
            fieldValue.length >= 15 
            && fieldValue.length <= 18 
            && fieldValue.indexOf(' ') == -1 
            && fieldValue.indexOf('-') == -1
        ) {
            lookupFieldMap[fieldName] = fieldValue;

            // Apex Call
            helper.apexCall(component, event, helper, 'setFormulaField', {
                objectName      : component.get('v.objectName'),
                lookupFieldMap  : lookupFieldMap,
                formulaFieldMap : component.get('v.formulaFieldMap')
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                console.log('r', r);

                if (r.flag === 'success') {
                    var inputCmp = component.find("recordFormulaField");
                    if(inputCmp) {
                        if (!Array.isArray(inputCmp)) {
                            inputCmp = [inputCmp];
                        }
        
                        inputCmp.forEach(function(cmp) {
                            let fieldName = cmp.get("v.name");
                            if (r.hasOwnProperty(fieldName)) {
                                cmp.set("v.value", r[fieldName]);
                            }
                        });
                    }
                } else {
                    component.set('v.errorMsg', 'An error occurred.');
                }
            }));
        }
    },

    handleSaveRecord : function(component, event, helper) {
        try {
            component.set('v.isLoading', true);
            var fieldMap    = {};
            var inputs      = component.find('recordField');
    
            if (!Array.isArray(inputs)) {
                inputs = [inputs];
            }
    
            inputs.forEach(function(input) {
                fieldMap[input.get("v.fieldName")] = input.get("v.value");
            });

            // Apex Call
            helper.apexCall(component, event, helper, 'saveTicket', {
                objectName      : component.get('v.objectName'),
                fieldMap        : fieldMap,
                recordTypeId    : component.get('v.recordTypeId')
            })
            .then($A.getCallback(function(result) {
                let r = result.r;

                if(r == 'success') {
                    // helper.toast(component, 'Success', 'Ticket creation was successful');
                    window.history.back();
                } else {
                    // helper.toast(component, 'Error', 'An error occurred, please contact your administrator.');
                    component.set('v.errorMsg', 'An error occurred. ' + r);
                }

                component.set('v.isLoading', false);
            }))
            
        } catch (error) {
            console.log('handleSave Error : ' + error);
        }
    },

    handleBack : function(component, event, helper) {
        window.history.back();
    },

    handleCancel: function(component, event, helper) {
        window.history.back();
    }
})