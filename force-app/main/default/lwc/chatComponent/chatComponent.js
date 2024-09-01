import { LightningElement, track } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveChatMessage from '@salesforce/apex/ChatController.saveChatMessage';

export default class ChatComponent extends LightningElement {
    @track channelName = '/event/ChatMessageEvent__e';
    @track messages = [];
    @track isSubscribeDisabled = false;
    @track isUnsubscribeDisabled = true;
    @track isNickname = false;
    @track isSend = true;
    @track message = '';
    @track sender = '';
    @track count = 0;

    subscription = {};

    // handleChannelName(event) {
    //     this.channelName = event.target.value;
    // }

    handleMessageChange(event) {
        this.message = event.target.value;
        if (event.key === 'Enter') {
            this.handleSend();
        }
    }

    handleSenderChange(event) {
        this.sender = event.target.value;
    }

    handleSubscribe() {
        if(this.sender != '') {
            this.isNickname = true;
            this.isSend = false;
            const messageCallback = (response) => {
                this.messages = [...this.messages, {
                    content: response.data.payload.Content__c,
                    sender: response.data.payload.Sender__c
                }];
            };
    
            subscribe(this.channelName, -1, messageCallback).then(response => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '채팅방 입장',
                        message: '채팅방 입장에 성공하셨습니다.',
                        variant: 'success'
                    })
                );
                this.subscription = response;
                this.count += 1;
                this.toggleSubscribeButton(true);
            }).catch(error => {
                console.error('Error subscribing: ', JSON.stringify(error));
            });
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '닉네임',
                    message: '닉네임을 입력해주세요.',
                    variant: 'error'
                })
            );
        }
    }

    handleUnsubscribe() {
        this.toggleSubscribeButton(false);
        this.isNickname = false;
        this.isSend = true;

        unsubscribe(this.subscription, response => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '채팅방 종료',
                    message: '채팅방에서 나가셨습니다.',
                    variant: 'success'
                })
            );
            if(this.count > 0) {
                this.count -= 1;
            }
        }).catch(error => {
            console.error('Error unsubscribing: ', JSON.stringify(error));
        });
    }

    toggleSubscribeButton(enableSubscribe) {
        this.isSubscribeDisabled = enableSubscribe;
        this.isUnsubscribeDisabled = !enableSubscribe;
    }

    registerErrorListener() {
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }

    connectedCallback() {
        this.registerErrorListener();
    }

    handleSend() {
        if (!this.message || !this.sender) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '메세지',
                    message: '메세지를 입력해주세요.',
                    variant: 'error'
                })
            );
            return;
        }

        saveChatMessage({ content: this.message, sender: this.sender })
            .then(() => {
                console.log('메세지 전송 성공');
                this.message = '';
            })
            .catch(error => {
                console.error('Error sending message: ', JSON.stringify(error));
            });
    }
}