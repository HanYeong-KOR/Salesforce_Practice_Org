import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import saveResult from '@salesforce/apex/GuessNumberGameController.saveResult';
import deleteResult from '@salesforce/apex/GuessNumberGameController.deleteResult';
import checkGuess from '@salesforce/apex/GuessNumberGameController.checkGuess';
import savePlayer from '@salesforce/apex/GuessNumberGameController.savePlayer';
import failScore from '@salesforce/apex/GuessNumberGameController.failScore';

export default class GuessNumberGame extends LightningElement {
    @track guess;
    @track result;
    @track user;
    @track isUser = true;
    @track isRefresh = true;
    @track chance = 0;
    randomNumber = Math.floor(Math.random() * 100) + 1;
    randomResult = 0;

    connectedCallback() {
        deleteResult({
                    
        })
        .then(result => {
            saveResult({
                randomNumber : this.randomNumber
            })
            .then(result => {
                this.randomResult = this.randomNumber;
            })
            .catch(error => {
                console.log('saveResult error msg : ' + error);
            })
        })
        .catch(error => {
            console.log('deleteResult error msg : ' + error);
        })
    }

    handleUserChange(event) {
        try {
            this.user = event.target.value;
        } catch (e) {
            console.log('# handleUserChange error ::: ' + e);
        }
    }

    handleEnterUser(event) {
        try {
            if(this.user != null && this.user != '') {
                savePlayer({
                    player: this.user
                })
                .then(result => {
                    this.isUser = false;
                    this.isRefresh = false;
                    this.chance = 6;
                })
                .catch(error => {
                    console.log('savePlayer error msg : ' + error);
                })
            } else {
                const toastEvent = new ShowToastEvent({
                    title: 'FAIL',
                    message: '참가 인원을 입력해주세요.',
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
            }
        } catch (e) {
            console.log('# handleEnterUser error ::: ' + e);
        }
    }

    handleChange(event) {
        try {
            this.guess = parseInt(event.target.value, 10);
        } catch (e) {
            console.log('# handleChange error ::: ' + e);
        }
    }

    async handleSubmit() {
        try {
            const gameResult = await checkGuess({ randomResult: this.randomResult, guess: this.guess, player: this.user, chance: this.chance});

            if(gameResult == '빈값') {
                const toastEvent = new ShowToastEvent({
                    title: 'FAIL',
                    message: '추측한 숫자를 입력해주세요.',
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
            } else {
                this.chance -= 1;
                if(this.chance >= 0) {
                    this.result = gameResult;

                    if(gameResult == '정답입니다!') {
                        const toastEvent = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: '게임이 종료되었습니다.',
                            variant: 'success'
                        });
                        this.dispatchEvent(toastEvent);
                        this.isUser = true;
                    } else if(this.chance == 0 && gameResult != '정답입니다!') {
                        failScore({
                            player: this.user
                        })
                        .then(result => {
                            const toastEvent = new ShowToastEvent({
                                title: 'FAIL',
                                message: '게임이 종료되었습니다.',
                                variant: 'error'
                            });
                            this.dispatchEvent(toastEvent);
                        })
                        .catch(error => {
                            console.log('savePlayer error msg : ' + error);
                        })
                    }
                } else {
                    if(this.chance < 0) {
                        const toastEvent = new ShowToastEvent({
                            title: 'FAIL',
                            message: '기회가 모두 소진되었습니다.',
                            variant: 'error'
                        });
                        this.dispatchEvent(toastEvent);
                        this.chance = 0;
                    }
                }
            }
        } catch (e) {
            console.log('# handleSubmit error ::: ' + JSON.stringify(e));
        }
    }

    handleRestart() {
        try {
            window.location.reload();
        } catch (e) {
            console.log('# handleRestart error ::: ' + e);
        }
    }
}