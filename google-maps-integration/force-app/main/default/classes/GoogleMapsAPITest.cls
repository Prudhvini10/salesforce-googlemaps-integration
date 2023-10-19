@isTest
public class GoogleMapsAPITest {
    // Create a mock class that implements HttpCalloutMock
    public class GoogleMapsAPIMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            // Create a mock response here, simulating the behavior of the external web service
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"predictions": [{ "description": "San Francisco" }]}');
            response.setStatusCode(200);
            return response;
        }
    }

    @isTest
    static void testAutocompleteAddress() {
        // Associate the mock class with a specific endpoint
        Test.setMock(HttpCalloutMock.class, new GoogleMapsAPIMock());

        // Test data setup
        String input = '123 West Main Street, Independence, KS, USA';
        String input1 = '3650 County Road 3700, Independence, KS, USA';

        // Call the method to be tested
        String response = GoogleMapsAPI.autocompleteAddress(input);
        Map<String, Object> response1 = GoogleMapsAPI.calculateDistanceAndTime(input, input1);

        // Add assertions to verify the behavior of your autocompleteAddress method
        System.assertNotEquals(null, response, 'Response should not be null.');
        // You can add more specific assertions based on the expected behavior of your method.
    }

    // Continue adding test methods for other scenarios as needed
    @isTest
    static void testCalculateDistanceAndTime() {
        // Test data setup
        String sourceAddress = '123 West Main Street, Independence, KS, USA';
        String destinationAddress = '3650 County Road 3700, Independence, KS, USA';

        // Associate the mock class with a specific endpoint
        Test.setMock(HttpCalloutMock.class, new GoogleMapsAPIMock());

        // Call the method to be tested
        Map<String, Object> result = GoogleMapsAPI.calculateDistanceAndTime(sourceAddress, destinationAddress);
        

        // Add assertions to verify the behavior of your calculateDistanceAndTime method
        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assert(result.containsKey('distance'), 'Result should contain distance.');
        System.assert(result.containsKey('duration'), 'Result should contain duration.');
        System.assert(result.containsKey('flyingCost'), 'Result should contain flyingCost.');
        System.assert(result.containsKey('drivingCost'), 'Result should contain drivingCost.');
        System.assertNotEquals(null, result.get('flyingCost'), 'flyingCost should not be null.');
        System.assertNotEquals(null, result.get('drivingCost'), 'drivingCost should not be null.');
        System.assertNotEquals(null, result.get('error'), 'Error should not be null.');
        // You can add more specific assertions based on the expected behavior of your method.
    }

    // Create a mock class that implements HttpCalloutMock
    

    @isTest
    static void testCalculateDistanceAndTimeWithInvalidInput() {
        // Test data setup with invalid input
        String sourceAddress = 'Invalid Source';
        String destinationAddress = 'Invalid Destination';

        // Call the method to be tested
        Map<String, Object> result = GoogleMapsAPI.calculateDistanceAndTime(sourceAddress, destinationAddress);

        // Add assertions to verify the behavior of your calculateDistanceAndTime method with invalid input
        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assertNotEquals(null, result.get('error'), 'Error should not be null.');
        // You can add more specific assertions based on the expected behavior of your method with invalid input.
    }

}