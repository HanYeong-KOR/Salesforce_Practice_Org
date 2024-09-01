({
    scriptsLoaded : function(component, event, helper) {
        console.log('SheetJS loaded');
        component.set("v.sheetJsLoaded", true);
    },

    handleClickExcelBtn: function(component, event, helper) {
        try {
            if (!component.get("v.sheetJsLoaded")) {
                console.error('SheetJS is not loaded');
                return;
            }
    
            var listOfSearchRecords = component.get("v.listOfSearchRecords");
            var data = listOfSearchRecords.map(function(record) {
                return {
                    Id: record.recordId,
                    Name: record.recordName,
                    Phone: record.phone,
                    'Billing Address': record.billingAddress
                };
            });
    
            var worksheet = XLSX.utils.json_to_sheet(data);
            var workbook = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(workbook, worksheet, 'Accounts');
    
            var wbout = XLSX.write(workbook, { bookType: 'xlsx', type: 'binary' });
            var buf = new ArrayBuffer(wbout.length);
            var view = new Uint8Array(buf);
    
            for (var i = 0; i < wbout.length; i++) {
                view[i] = wbout.charCodeAt(i) & 0xFF;
            }
    
            var blob = new Blob([buf], { type: 'application/octet-stream' });
            var link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = 'accounts.xlsx';
            link.click();
        } catch (error) {
            console.log('# handleClickExcelBtn error', error.message);
        }
    },

    handleSearchInput : function(component, event, helper) {
        try {
            component.set('v.searchkeyword', event.target.value);
        } catch (error) {
            console.log('# handleSearchInput error', error.message);
        }
    },

    handleKeyPress : function(component, event, helper) {
        console.log(event.getSource().getParams());
        if (event.keyCode === 13) {
            this.handleSearchInput(component, event, helper);
        }
    },

    handleClickSearchBtn : function(component, event, helper) {
        try {
            var searchKeyword = component.get("v.searchkeyword");
            var pageNumber = component.get("v.pageNumber");
            var pageSize = component.get("v.pageSize");

            helper.apexCall(component, event, helper, 'obtainRecordList', {
                searchKeyWord : searchKeyword,
                pageNumber : pageNumber,
                pageSize : pageSize
            })
            .then($A.getCallback(function(result){
                const r = result.r;

                if(r.length > 0) {
                    component.set('v.listOfSearchRecords', r);
                    component.set('v.hasListOfSearchRecords', true);
                    component.set('v.isLastPage', false);
                }

                component.set('v.isFirstPage', pageNumber === 1);
                component.set('v.isLastPage', r.length < pageSize);
            }))
            .catch(function(err){ 
                console.log('error', err.message);
            });
        } catch (error) {
            console.log('# handleClickSearchBtn error : ' + error);
        }
    },

    handlePasteBtn : function(component, event, helper) {
        try {
            var searchKeyword = component.get("v.searchkeyword");            
            var textArea = document.createElement("textarea");
            textArea.value = searchKeyword;
            document.body.appendChild(textArea);
            textArea.select();
            document.execCommand('copy');
            document.body.removeChild(textArea);
        } catch (error) {
            console.log('# handlePasteBtn error', error);
        }
    },

    handleSelectRecord : function(component, event, helper) {
        var selectedRecordId = event.currentTarget.dataset.recordId;
        console.log('selectedRecordId', selectedRecordId);

        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedRecordId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        };
        navService.navigate(pageReference);
    },

    handlePreviousPage : function(component, event, helper) {
        try {
            var pageNumber = component.get('v.pageNumber');
            component.set('v.pageNumber', pageNumber--);
    
            this.handleClickSearchBtn(component, event, helper);
        } catch (error) {
            console.log('# handlePreviousPage error', error.message);
        }
    },

    handleNextPage : function(component, event, helper) {
        try {
            var pageNumber = component.get('v.pageNumber');
            component.set('v.pageNumber', pageNumber++);
    
            // this.handleClickSearchBtn(component, event, helper);
            // this.handleClickSearchBtn;
        } catch (error) {
            console.log('# handleNextPage error', error.message);
        }
    }
})