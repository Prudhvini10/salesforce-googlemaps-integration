public with sharing class GoogleMapsAPI {
    String vHash = 'cHJ1ZGh2aW5pIE0=';
    @AuraEnabled(cacheable=true)
    public static String autocompleteAddress(String input) {
        String apiKey = 'AIzaSyAcWO0abOJQu6-pz0fOI21xytjDc7n5BnM';
        String endpoint = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=' + input + '&key=' + apiKey;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        return res.getBody();
    }
    @AuraEnabled
    public static Map<String, Object> calculateDistanceAndTime(String sourceAddress, String destinationAddress) {
        Map<String, Object> result = new Map<String, Object>();

        // Ensure you have set up and configured your Google Maps API key properly.
        String googleMapsApiKey = 'AIzaSyAcWO0abOJQu6-pz0fOI21xytjDc7n5BnM';

        // Prepare the source and destination addresses for the API request.
        sourceAddress = sourceAddress.replace(' ', '+');
        destinationAddress = destinationAddress.replace(' ', '+');

        // Construct the API request URL to calculate the distance and time.
        String apiUrl = 'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=' + sourceAddress +
                       '&destinations=' + destinationAddress + '&key=' + googleMapsApiKey;

        // Make an HTTP request to the Google Maps Distance Matrix API.
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl);
        request.setMethod('GET');
        Cost__mdt[] threatMappings = [SELECT MasterLabel, QualifiedApiName, Price__c ,Type__c FROM Cost__mdt];

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                // Parse the JSON response to extract the distance and duration.
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if (jsonResponse.containsKey('rows') && !((List<Object>)jsonResponse.get('rows')).isEmpty()) {
                    List<Object> rows = (List<Object>)jsonResponse.get('rows');
                    Map<String, Object> row = (Map<String, Object>)rows[0];
                    if (row.containsKey('elements') && !((List<Object>)row.get('elements')).isEmpty()) {
                        List<Object> elements = (List<Object>)row.get('elements');
                        Map<String, Object> element = (Map<String, Object>)elements[0];
                        if (element.containsKey('status') && element.get('status').equals('OK')) {
                            if (element.containsKey('distance') && ((Map<String, Object>)element.get('distance')).containsKey('text')) {
                                result.put('distance', ((Map<String, Object>)element.get('distance')).get('text'));
                                String distance = String.valueOf(result.get('distance'));
                                System.debug(distance);
                                String numericPartString =  distance.replaceAll('[^0-9.]', '');

                                // Convert the numeric part to a decimal
                                Decimal distanceDecimal = Decimal.valueOf(numericPartString);
                                for(Cost__mdt cost : threatMappings){
                                    if(cost.Type__c == 'Flying'){
                                        result.put('flyingCost',distanceDecimal*cost.Price__c);
                                    }
                                    else if(cost.Type__c == 'Driving'){
                                        result.put('drivingCost',distanceDecimal*cost.Price__c);
                                    }
                                }
                                System.debug(result);
                            }
                            if (element.containsKey('duration') && ((Map<String, Object>)element.get('duration')).containsKey('text')) {
                                result.put('duration', ((Map<String, Object>)element.get('duration')).get('text'));
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            // Handle any errors that may occur during the API request.
            result.put('error', e.getMessage());
        }

        return result;
    }
}
