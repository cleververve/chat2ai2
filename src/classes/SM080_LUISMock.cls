/**
Author:         serhiivolynets
Date:           25.06.2020
Description:   
**/

global class SM080_LUISMock implements HttpCalloutMock
{
	global static HTTPResponse respond(HTTPRequest req)
	{
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);
		String reqBody = '{"query":"would you change the metropolitan museum of art roof garden reservation to 8:00 tonight","prediction":{"topIntent":"RestaurantReservation.ChangeReservation","intents":{"RestaurantReservation.ChangeReservation":{"score":0.9546011},"RestaurantReservation.DeleteReservation":{"score":0.0305679}},"entities":{"RestaurantReservation.PlaceName":["metropolitan museum of art roof garden"],"RestaurantReservation.Time":["8:00","tonight"],"$instance":{"RestaurantReservation.PlaceName":[{"type":"RestaurantReservation.PlaceName","text":"metropolitan museum of art roof garden","startIndex":21,"length":38,"score":0.9852,"modelTypeId":1,"modelType":"Entity Extractor","recognitionSources":["model"]}],"RestaurantReservation.Time":[{"type":"RestaurantReservation.Time","text":"8:00","startIndex":75,"length":4,"score":0.9990256,"modelTypeId":1,"modelType":"Entity Extractor","recognitionSources":["model"]},{"type":"RestaurantReservation.Time","text":"tonight","startIndex":80,"length":7,"score":0.999200761,"modelTypeId":1,"modelType":"Entity Extractor","recognitionSources":["model"]}]}}}}';
		res.setBody(reqBody);
		return res;
	}
}