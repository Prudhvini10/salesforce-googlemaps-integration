import { LightningElement, track, wire } from 'lwc';
import autocompleteAddress from '@salesforce/apex/GoogleMapsAPI.autocompleteAddress';
import calculateDistanceAndTime from '@salesforce/apex/GoogleMapsAPI.calculateDistanceAndTime';
import { style } from './googleMapsAutocomplete.css';

export default class GoogleMapsAutocomplete extends LightningElement {
    @track sourceAddress = '';
    @track destinationAddress = '';
    @track sourceSuggestions = [];
    @track destinationSuggestions = [];
    @track distance = '';
    @track duration = '';
    @track error = '';
    flyingCost = '';
    drivingCost = '';
    get hasRecommendations() {
        return (this.sourceSuggestions !== null && this.sourceSuggestions.length);
    }
    get hasDestinationRecommendations() {
        return (this.destinationSuggestions !== null && this.destinationSuggestions.length);
    }
    handleSourceChange(event) {
        this.sourceAddress = event.target.value;
        this.autocompleteAddress('source', this.sourceAddress);
    }

    handleDestinationChange(event) {
        this.destinationAddress = event.target.value;
        this.autocompleteAddress('destination', this.destinationAddress);
    }

    autocompleteAddress(type, query) {
        autocompleteAddress({ input: query })
            .then(result => {
                let data = JSON.parse(result);
                if (data.status === 'OK') {
                    if (type === 'source') {
                        this.sourceSuggestions = data.predictions;
                    } else if (type === 'destination') {
                        this.destinationSuggestions = data.predictions;
                    }
                }
            })
            .catch(error => {
                console.error('Error fetching data from Google Maps API:', error);
            });
    }
    handleAddressRecommendationSelect(event) {
       
    const suggestionId = event.currentTarget.dataset.value;
    console.log(JSON.stringify(this.suggestionId));
    // Perform actions based on the clicked suggestion (suggestionId)
    // For example, you can update the sourceAddress with the clicked suggestion.
    this.sourceAddress = this.sourceSuggestions.find(suggestion => suggestion.place_id === suggestionId).description;
    console.log(this.sourceAddress);
    this.sourceSuggestions = []; // Clear the suggestions after selection.
    }
    handleDestinationSuggestionClick(event){
        const suggestionId = event.currentTarget.dataset.value;
        console.log('value'+event.currentTarget.dataset.value);

        // Perform actions based on the clicked suggestion (suggestionId)
        // For example, you can update the sourceAddress with the clicked suggestion.
        this.destinationAddress = this.destinationSuggestions.find(suggestion => suggestion.place_id === suggestionId).description;
        this.destinationSuggestions = []; // Clear the suggestions after selection. 
    }
    handleClick() {
        console.log('inside');
        calculateDistanceAndTime({ sourceAddress: this.sourceAddress, destinationAddress: this.destinationAddress })
            .then(result => {
                if (result.error) {
                    this.error = result.error;
                } else {
                    this.distance = result.distance;
                    this.duration = result.duration;
                    this.flyingCost = result.flyingCost;
                    this.drivingCost = result.drivingCost;
                    console.log(this.duration);
                    console.log(this.distance);
                }
            })
            .catch(error => {
                this.error = error;
            });
    }
}