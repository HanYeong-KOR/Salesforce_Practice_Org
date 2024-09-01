import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from "lightning/platformResourceLoader";

import uploadExcelFile from '@salesforce/apex/ExcelUploaderController.uploadExcelFile';
import getObjectFields from '@salesforce/apex/ExcelUploaderController.getObjectFields';
import obtainObjectList from '@salesforce/apex/LookupController.obtainObjectList';
import SHEETJS from '@salesforce/resourceUrl/xlsx';

export default class ExcelUploader extends LightningElement {
    @track fileName;
    @track tableData;
    @track columns;
    @track reqFields;
    @track listOfSearchObjects;
    fileData;
    objectApiName;
    isImported = false;
    libInitialized = false;
    isShow = false;
    isInsert = true;
    isCombo = true;
    searchkeyword = '';
    placeholder = 'Search...';

    renderedCallback() {
        if (this.libInitialized) {
            return;
        }
        this.libInitialized = true;

        loadScript(this, SHEETJS)
            .then(() => {
                console.log('XLSX library loaded.');
            })
            .catch(error => {
                console.error('Error loading XLSX library', error);
            });
    }

    handleSearchInput(event) {
        this.searchkeyword = event.target.value;
        
        if(this.searchkeyword == null || this.searchkeyword == '') {
            this.clearSearch();
        } else {
            this.handleSearch();
        }
    }

    handleKeyPress(event) {
        if (event.key === 'Enter') {
            this.handleSearch();
        }
    }

    
    handleSearch() {
        obtainObjectList({ searchKeyWord: this.searchkeyword })
            .then(result => {
                this.listOfSearchObjects = result;
            })
            .catch(error => {
                console.log('obtainObjectList error', error);
            });
    }

    clearSearch() {
        this.listOfSearchObjects = [];
    }

    handleSelectObject(event) {
        this.objectApiName = event.currentTarget.dataset.objectName;
        this.nextScreen();
    }

    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            this.fileName = file.name;
            const reader = new FileReader();
            reader.onload = this.handleFileLoad.bind(this);
            reader.readAsBinaryString(file);
        }
    }

    handleFileLoad(event) {
        const data = event.target.result;
        const workbook = XLSX.read(data, { type: 'binary' });
        const sheetName = workbook.SheetNames[0];
        const sheet = workbook.Sheets[sheetName];
        this.fileData = XLSX.utils.sheet_to_json(sheet);
        this.isImported = true;
        this.isInsert = false;
        this.setTableData(this.fileData);

        getObjectFields({objectApiName : this.objectApiName}).then(result => {
            const table = this.template.querySelector('c-excel-table');
            this.reqFields = result;
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error uploading file',
                    message: 'Please enter the correct object api name',
                    variant: 'error'
                })
            );
            this.handlePreviousButton();
        }).finally(() => {
            this.mapFields();
        })
    }

    mapFields() {
        this.columns.forEach((mapcol, index, array) => {
            this.reqFields.forEach(reqField => {
                const combobox = this.template.querySelectorAll('lightning-combobox')[index];
                if(combobox !== undefined && (mapcol.label === reqField.label || mapcol.label === reqField.value)) {
                    combobox.value = reqField.value;
                }
            });
        });
    }

    setTableData(fileData) {
        if (fileData.length > 0) {
            const columns = Object.keys(fileData[0]).map(key => ({
                label: key,
                fieldName: key,
                type: 'text'
            }));
            this.columns = columns;
            this.tableData = fileData;
        }
    }

    handleUpload() {
        const mappedData = this.mapTableData();

        if (this.fileData) {
            uploadExcelFile({ data: mappedData, objectApiName : this.objectApiName })
                .then(result => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Records uploaded successfully',
                            variant: 'success'
                        })
                    );
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error uploading file',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'No file selected',
                    message: 'Please select an Excel file to upload',
                    variant: 'error'
                })
            );
        }
    }

    mapTableData() {
        const table = this.template.querySelector('c-excel-table');
        const cboxes = this.template.querySelectorAll('lightning-combobox');
        const fieldMap = {};
        const mappedData = [];
        cboxes.forEach(cbox => {
            if(cbox.value !== null && cbox.value !== undefined) {
                fieldMap[cbox.label] = cbox.value;
            }
        });

        table.excelData.forEach(row => {
            let fieldMapObj = {};
            for(const [key, value] of Object.entries(row)) {
                if(fieldMap[key] !== undefined) {
                    fieldMapObj[fieldMap[key]] = value;
                }
            }
            mappedData.push(fieldMapObj);
        });
        return mappedData;
    }

    nextScreen() {
        if(this.objectApiName != '') {
            this.isShow = true;
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Please enter Object Name',
                    message : 'Please enter Object Name',
                    variant : 'error',
                }),
            );
        }
    }

    handlePreviousButton() {
        this.isShow = false;
        this.fileName = '';
        this.isImported = false;
        this.isInsert = true;
        this.columns = [];
        this.tableData = [];
        this.listOfSearchObjects = [];
        this.objectApiName = '';
        this.searchkeyword = '';
    }

    // connectedCallback() {
    //     Promise.all([
    //         loadScript(this, SHEETJS)
    //     ]).then(() => {
    //         console.log('XLSX upload completed');
    //     })
    // }

    // handleFileChange(event){
    //     const uploadedFiles = event.detail.files;
    //     console.log('uploadedFiles', uploadedFiles);

    //     if(uploadedFiles.length > 0) {   
    //         this.ExcelToJSON(uploadedFiles[0])
    //     }
    // }

    // ExcelToJSON(file) {
    //     var reader = new FileReader();

    //     reader.onload = event => {
    //         var data = event.target.result;

    //         try {
    //             var workbook = XLSX.read(data, { type: 'binary' });
    //             var sheetName = workbook.SheetNames[0];
    //             var sheet = workbook.Sheets[sheetName];
    //             var XL_row_object = XLSX.utils.sheet_to_row_object_array(sheet);
    //             this.fileData = XL_row_object;
    //             console.log('Parsed file data:', JSON.stringify(this.fileData));

    //         } catch (error) {
    //             console.error('Error parsing file:', error);
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error parsing file',
    //                     message: error.message,
    //                     variant: 'error'
    //                 })
    //             );
    //         }
    //     };

    //     reader.onerror = function(e) {
    //         console.error('Error reading file:', e);
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error while reading the file',
    //                 message: e.message,
    //                 variant: 'error'
    //             })
    //         );
    //     };

    //     reader.readAsBinaryString(file);
    // }

    // handleUpload() {
    //     if (this.fileData && this.fileData.length > 0) {
    //         console.log('Uploading data:', JSON.stringify(this.fileData));
            
    //         uploadExcelFile({ 
    //             data : JSON.stringify(this.fileData)
    //         })
    //         .then(result => {
    //             console.log('Upload result:', result);
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Success',
    //                     message: 'Records uploaded successfully',
    //                     variant: 'success'
    //                 })
    //             );
    //         })
    //         .catch(error => {
    //             console.error('Error uploading file:', error);
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error uploading file',
    //                     message: error.body.message,
    //                     variant: 'error'
    //                 })
    //             );
    //         });
    //     } else {
    //         console.warn('No data to upload');
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'No data to upload',
    //                 message: 'Please select a valid Excel file to upload',
    //                 variant: 'error'
    //             })
    //         );
    //     }
    // }
}