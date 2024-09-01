import { LightningElement } from 'lwc';

export default class SnakeGame extends LightningElement {
    canvas;
    context;
    box = 20;
    snake = [];
    food = {};
    direction = 'RIGHT';
    gameInterval;

    connectedCallback() {
        this.snake[0] = { x: 9 * this.box, y: 10 * this.box };
        this.food = this.randomFoodPosition();
        this.gameInterval = setInterval(this.draw.bind(this), 100);
        window.addEventListener('keydown', this.changeDirection.bind(this));
    }

    disconnectedCallback() {
        clearInterval(this.gameInterval);
        window.removeEventListener('keydown', this.changeDirection.bind(this));
    }

    renderedCallback() {
        this.canvas = this.template.querySelector('canvas');
        this.context = this.canvas.getContext('2d');
    }

    randomFoodPosition() {
        return {
            x: Math.floor(Math.random() * 19 + 1) * this.box,
            y: Math.floor(Math.random() * 19 + 1) * this.box
        };
    }

    changeDirection(event) {
        const key = event.keyCode;
        if (key === 37 && this.direction !== 'RIGHT') {
            this.direction = 'LEFT';
        } else if (key === 38 && this.direction !== 'DOWN') {
            this.direction = 'UP';
        } else if (key === 39 && this.direction !== 'LEFT') {
            this.direction = 'RIGHT';
        } else if (key === 40 && this.direction !== 'UP') {
            this.direction = 'DOWN';
        }
    }

    collision(newHead, snakeArray) {
        for (let i = 0; i < snakeArray.length; i++) {
            if (newHead.x === snakeArray[i].x && newHead.y === snakeArray[i].y) {
                return true;
            }
        }
        return newHead.x < 0 || newHead.x >= 400 || newHead.y < 0 || newHead.y >= 400;
    }

    draw() {
        this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
        
        for (let i = 0; i < this.snake.length; i++) {
            this.context.fillStyle = (i === 0) ? 'green' : 'white';
            this.context.fillRect(this.snake[i].x, this.snake[i].y, this.box, this.box);

            this.context.strokeStyle = 'red';
            this.context.strokeRect(this.snake[i].x, this.snake[i].y, this.box, this.box);
        }

        this.context.fillStyle = 'red';
        this.context.fillRect(this.food.x, this.food.y, this.box, this.box);

        let snakeX = this.snake[0].x;
        let snakeY = this.snake[0].y;

        if (this.direction === 'LEFT') snakeX -= this.box;
        if (this.direction === 'UP') snakeY -= this.box;
        if (this.direction === 'RIGHT') snakeX += this.box;
        if (this.direction === 'DOWN') snakeY += this.box;

        if (snakeX === this.food.x && snakeY === this.food.y) {
            this.food = this.randomFoodPosition();
        } else {
            this.snake.pop();
        }

        const newHead = { x: snakeX, y: snakeY };

        if (this.collision(newHead, this.snake)) {
            clearInterval(this.gameInterval);
            alert('Game Over');
        }

        this.snake.unshift(newHead);
    }
}