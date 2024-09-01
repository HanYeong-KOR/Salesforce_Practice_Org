export class Bar {
    constructor(x, canvasWidth, canvasHeight){
        this.width = 100;
        this.height = 10;

        this.x = x;
        this.y = canvasHeight - this.height;

        this.vx = 0;
        this.canvasWidth = canvasWidth;

        this.fillColor = "#3b81eb";
    }

    draw(ctx){
        this.x += this.vx;

        if(this.x < 0){ this.x = 0; }
        if(this.x + this.width > this.canvasWidth){ this.x = this.canvasWidth - this.width; }

        ctx.fillStyle = this.fillColor;
        ctx.beginPath();
        ctx.fillRect(this.x, this.y, this.width, this.height);
    }
}