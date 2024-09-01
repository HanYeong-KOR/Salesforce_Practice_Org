import { LightningElement, track } from 'lwc';

import { Block } from 'c/breakoutGame_Block';
import { Bar } from 'c/breakoutGame_Bar';
import { Ball } from 'c/breakoutGame_Ball';

export default class BreakoutGame extends LightningElement {
    @track canvasWidth = 300;
    @track canvasHeight = 500;

    app;

    renderedCallback() {
        this.initializeGame();
    }

    initializeGame() {
        const canvas = this.template.querySelector('canvas');
        this.app = new App(canvas);
    }
}

class App {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = this.canvas.getContext("2d");

        this.bar = new Bar(100, this.canvas.width, this.canvas.height);

        this.initializeBlocks();

        this.ball = new Ball(10, this.canvas.width, this.canvas.height, this.bar, this.blocks, this.initializeBlocks.bind(this));

        const moveSpeed = 10;

        window.addEventListener('keydown', (e) => {
            if (e.key === "ArrowRight") { this.bar.vx = moveSpeed; }
            if (e.key === "ArrowLeft") { this.bar.vx = -moveSpeed; }
            if (e.key == " ") { this.ball.isGameStart = true; }
        });

        window.addEventListener('keyup', (e) => {
            if (e.key === "ArrowRight" || e.key == "ArrowLeft") { this.bar.vx = 0; }
        });

        window.requestAnimationFrame(this.animate.bind(this));
    }

    initializeBlocks() {
        const blockWidth = 50;
        const blockHeight = 20;

        this.blocks = [];

        for (let i = 0; i <= this.canvas.width - blockWidth; i += blockWidth) {
            for (let j = 50; j <= 200; j += blockHeight) {
                this.blocks.push(new Block(i, j));
            }
        }

        if (this.ball) {
            this.ball.blocks = this.blocks;
        }
    }

    draw() {
        this.ctx.fillStyle = "#102330";
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);

        this.bar.draw(this.ctx);
        this.ball.draw(this.ctx);
    }

    animate() {
        this.draw();
        window.requestAnimationFrame(this.animate.bind(this));
    }
}