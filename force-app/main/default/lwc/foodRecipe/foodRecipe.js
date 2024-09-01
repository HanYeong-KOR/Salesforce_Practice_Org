import { LightningElement, track } from 'lwc';
import getFoodRecipe from '@salesforce/apex/FoodRecipe.getFoodRecipe';

export default class FoodRecipe extends LightningElement {
    @track foodName = '';
    @track ingredients = '';
    @track recipes = [];
    @track page = 1;
    @track disablePrevious = true;

    connectedCallback() {
        if(this.page == 1) {
            this.disablePrevious = true;
        }
    }

    handleFoodNameChange(event) {
        this.foodName = event.target.value;
    }

    handleIngredientsChange(event) {
        this.ingredients = event.target.value;
    }

    searchRecipes() {
        getFoodRecipe({ 
            foodName    :   this.foodName, 
            ingredients :   this.ingredients,
            offset      :   this.page
        }).then(result => {
            console.log('result', result);
            this.recipes = result;
        }).catch(error => {
            console.log('getFoodRecipe : ', error);                
        });
    }

    handlePrevious() {
        this.page--;
        this.searchRecipesl();
    }

    handleNext() {
        this.page++;
        this.searchRecipesl();
    }
}