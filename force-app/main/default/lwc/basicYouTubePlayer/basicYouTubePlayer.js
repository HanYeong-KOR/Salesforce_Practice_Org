import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import WIDGET_API from '@salesforce/resourceUrl/widget_api';
import IFRAME_API from '@salesforce/resourceUrl/iframe_api';

export default class BasicYouTubePlayer extends LightningElement {
    @api youTubeId;
    @api playListId;
    player;

    get hasYouTubeIdOrPlayListId() {
        return this.youTubeId || this.playListId;
    }

    renderedCallback() {
        if (!this.youTubeId && !this.playListId) {
            return;
        }

        if (window.YT) {
            if (this.player) {
                this.loadPlayer();
            } else {
                this.onYouTubeIframeAPIReady();
            }
        } else {
            Promise.all([
                loadScript(this, IFRAME_API),
                loadScript(this, WIDGET_API)
            ])
            .then(() => {
                console.log('onYouTubeIframeAPIReady');
                this.loadPlayer();
            })
            .catch(error => {
                this.showErrorToast(error);
            });
        }
    }

    loadPlayer() {
        if (this.playListId) {
            this.onYouTubeListIframeAPIReady();
        } else {
            this.onYouTubeIframeAPIReady();
        }
    }

    onPlayerError(e) {
        let explanation = '';
        if (e.data === 2) {
            explanation = 'Invalid YouTube ID';
        } else if (e.data === 5) {
            explanation = 'The requested content cannot be played in an HTML5 player or another error related to the HTML5 player has occurred.';
        } else if (e.data === 100) {
            explanation = 'The video requested was not found. This error occurs when a video has been removed (for any reason) or has been marked as private.';
        } else if (e.data === 101 || e.data === 150) {
            explanation = 'The owner of the requested video does not allow it to be played in embedded players.';
        }

        this.showErrorToast(explanation);
    }

    showErrorToast(explanation) {
        const evt = new ShowToastEvent({
            title: 'Error loading YouTube player',
            message: explanation,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }

    onYouTubeIframeAPIReady() {
        const containerElem = this.template.querySelector('.wrapper');
        const playerElem = document.createElement('DIV');
        playerElem.className = 'player';
        containerElem.appendChild(playerElem);

        this.player = new window.YT.Player(playerElem, {
            height: '800',
            width: '100%',
            videoId: this.youTubeId,
            events: {
                onError: this.onPlayerError.bind(this)
            }
        });
    }

    onYouTubeListIframeAPIReady() {
        const containerElem = this.template.querySelector('.wrapper');
        const playerElem = document.createElement('DIV');
        playerElem.className = 'player';
        containerElem.appendChild(playerElem);

        this.player = new window.YT.Player(playerElem, {
            height: '800',
            width: '100%',
            playerVars: {
                listType: 'playlist',
                list: this.playListId
            },
            events: {
                onError: this.onPlayerError.bind(this)
            }
        });
    }
}

/* [출처] https://developers.google.com/youtube/iframe_api_reference?hl=ko */