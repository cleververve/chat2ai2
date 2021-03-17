/**
Author:         serhiivolynets
Date:           02.02.2021
Description:   
**/

global class SM086_OCRMock implements HttpCalloutMock
{
	global static HTTPResponse respond(HTTPRequest req)
	{
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);
		String reqBody =
				'{ "category": "Meals & Entertainment",\n' +
				'  "currency_code": "EUR",\n' +
				'  "date": "2020-08-07 14:24:00",\n' +
				'  "invoice_number": "08110005",\n' +
				'  "line_items": [\n' +
				'    {\n' +
				'      "total": 4.2\n' +
				'    }\n' +
				'  ],\n' +
				'  "subtotal": 16.55,\n' +
				'  "tax": 1.65,\n' +
				'  "total": 18.2,\n' +
				'  "vendor": {\n' +
				'    "address": "Via Luigi Einaudi, 5, 25030 Roncadelle BS, Italy",\n' +
				'    "name": "McDonald\'s"\n' +
				'  }\n' +
				'}';
		res.setBody(reqBody);
		return res;
	}
}