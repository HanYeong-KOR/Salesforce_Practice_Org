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

    handleSearchInput: function(component, event, helper) {
        var searchkeyword = event.getSource().get("v.value");
        console.log("🚀 ~ searchkeyword:", searchkeyword);
        component.set("v.searchkeyword", searchkeyword);

        if (!searchkeyword) {
            this.clearSearch(component, event, helper);
        } else {
            this.handleSearch(component, event, helper);
        }
    },

    handleKeyPress: function(component, event) {
        if (event.key === 'Enter') {
            this.handleSearch(component, event);
        }
    },

    handleSearch: function(component, event, helper) {
        try {
            console.log('hello');
            this.apexCall(component, event, helper, 'obtainObjectList', {
                searchKeyWord : component.get("v.searchkeyword")
            })
            .then($A.getCallback(function(result){
                const r = result.r;
                console.log('r : ', r);
                component.set("v.listOfSearchObjects", r);
            }));
        } catch (error) {
            console.log('handleSearch error : ' + error.message);
        }
    },

    clearSearch: function(component) {
        component.set("v.listOfSearchObjects", []);
    },

    handleSelectObject: function(component, event) {
        var objectApiName = event.currentTarget.dataset.objectName;
        component.set("v.objectApiName", objectApiName);
        this.nextScreen(component);
    },

    handleFileChange: function(component, event) {
        var file = event.getSource().get("v.files")[0];
        if (file) {
            component.set("v.fileName", file.name);
            var reader = new FileReader();
            reader.onload = $A.getCallback(function(e) {
                this.handleFileLoad(component, e);
            }.bind(this));
            console.log("🚀 ~ .then ~ r:", r);
            console.log("🚀 ~ .then ~ r:", r);
            console.log("🚀 ~ .then ~ r:", r);
            reader.readAsBinaryString(file);
        }
    },

    handleFileLoad: function(component, event) {
        var data = event.target.result;
        var workbook = XLSX.read(data, { type: 'binary' });
        var sheetName = workbook.SheetNames[0];
        var sheet = workbook.Sheets[sheetName];
        var fileData = XLSX.utils.sheet_to_json(sheet);
        component.set("v.fileData", fileData);
        component.set("v.isImported", true);
        component.set("v.isInsert", false);
        this.setTableData(component, fileData);

        helper.apexCall(component, event, helper, 'getObjectFields', {
            objectApiName : component.get("v.objectApiName")
        })
        .then($A.getCallback(function(result){
            const r = result.r;

            component.set("v.reqFields", r);
            this.mapFields(component);
        }));
    },

    setTableData: function(component, fileData) {
        if (fileData.length > 0) {
            var columns = Object.keys(fileData[0]).map(function(key) {
                return { label: key, fieldName: key, type: 'text' };
            });
            component.set("v.columns", columns);
            component.set("v.tableData", fileData);
        }
    },

    handleUpload: function(component, event) {
        var mappedData = this.mapTableData(component);

        if (component.get("v.fileData")) {
            helper.apexCall(component, event, helper, 'uploadExcelFile', {
                data : mappedData,
                objectApiName : component.get("v.objectApiName")
            })
            .then($A.getCallback(function(result){
                const r = result.r;
    
                this.showToast(component, 'Success', 'Records uploaded successfully', 'success');
            }));
        } else {
            this.showError(component, 'No file selected', 'Please select an Excel file to upload');
        }
    },

    mapTableData: function(component) {
        var tableData = component.get("v.tableData");
        var cboxes = component.find("combobox");
        var fieldMap = {};
        var mappedData = [];

        cboxes.forEach(function(cbox) {
            var value = cbox.get("v.value");
            if (value) {
                fieldMap[cbox.get("v.label")] = value;
            }
        });

        tableData.forEach(function(row) {
            var fieldMapObj = {};
            for (var key in row) {
                if (fieldMap[key]) {
                    fieldMapObj[fieldMap[key]] = row[key];
                }
            }
            mappedData.push(fieldMapObj);
        });

        return mappedData;
    },

    mapFields: function(component) {
        var columns = component.get("v.columns");
        var reqFields = component.get("v.reqFields");
        var comboboxes = component.find("combobox");

        columns.forEach(function(col, index) {
            reqFields.forEach(function(reqField) {
                var combobox = comboboxes[index];
                if (combobox && (col.label === reqField.label || col.label === reqField.value)) {
                    combobox.set("v.value", reqField.value);
                }
            });
        });
    },

    nextScreen: function(component) {
        if (component.get("v.objectApiName")) {
            component.set("v.isShow", true);
        } else {
            this.showError(component, 'Please enter Object Name', 'Please enter Object Name');
        }
    },

    handlePreviousButton: function(component) {
        component.set("v.isShow", false);
        component.set("v.fileName", '');
        component.set("v.isImported", false);
        component.set("v.isInsert", true);
        component.set("v.columns", []);
        component.set("v.tableData", []);
        component.set("v.listOfSearchObjects", []);
        component.set("v.objectApiName", '');
        component.set("v.searchkeyword", '');
    },

    showToast: function(component, title, message, variant) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "variant": variant
        });
        toastEvent.fire();
    },

    showError: function(component, title, message) {
        this.showToast(component, title, message, 'error');
    }
})