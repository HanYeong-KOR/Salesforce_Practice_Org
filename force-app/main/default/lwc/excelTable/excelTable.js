import { LightningElement, api, track } from 'lwc';

export default class ExcelTable extends LightningElement {
    @api excelData;
    @api excelColumns;

    handleRowSelect(event) {
        // Row selection logic here
    }
}