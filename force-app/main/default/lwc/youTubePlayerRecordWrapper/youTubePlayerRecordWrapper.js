import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class YouTubePlayerRecordWrapper extends LightningElement {
    @api fieldName;
    @api fieldName_playlist;
    @api objectApiName;
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    record;

    @wire(getRecord, { recordId: '$recordId', fields: '$fields2' })
    record2;

    get hasYouTubeIdOrPlayListId() {
        return this.youTubeId || this.playListId;
    }

    get youTubeId() {
        return this.record.data
            ? this.record.data.fields[this.fieldName].value
            : '';
    }

    get playListId() {
        return this.record2.data
            ? this.record2.data.fields[this.fieldName_playlist].value
            : '';
    }

    get fields() {
        return [this.objectApiName + '.' + this.fieldName];
    }

    get fields2() {
        return [this.objectApiName + '.' + this.fieldName_playlist];
    }
}