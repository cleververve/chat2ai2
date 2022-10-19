@IsTest
public class SM031_NexmoTEST
{
	@TestSetup
	public static void createData()
	{
		List<CVCH__Chat2ai__c> lcust = new List<CVCH__Chat2ai__c>();
		CVCH__Chat2ai__c cust1 = new CVCH__Chat2ai__c();
		cust1.Name = 'Chat2ai Flow';
		cust1.CVCH__Value__c = 'send_options';
		lcust.add(cust1);

		CVCH__Chat2ai__c cust2 = new CVCH__Chat2ai__c();
		cust2.Name = 'Response minimum score';
		cust2.CVCH__Value__c = '50';
		lcust.add(cust2);

		CVCH__Chat2ai__c cust3 = new CVCH__Chat2ai__c();
		cust3.Name = 'Default Flow';
		cust3.CVCH__Value__c = 'send_options';
		lcust.add(cust3);

		CVCH__Chat2ai__c cust4 = new CVCH__Chat2ai__c();
		cust4.Name = 'GDPR Flow';
		cust4.CVCH__Value__c = 'send_options';
		lcust.add(cust4);

		CVCH__Chat2ai__c cust5 = new CVCH__Chat2ai__c();
		cust5.Name = 'Main Menu Flow';
		cust5.CVCH__Value__c = 'send_options';
		lcust.add(cust5);

		CVCH__Chat2ai__c cust6 = new CVCH__Chat2ai__c();
		cust6.Name = 'Welcome Flow';
		cust6.CVCH__Value__c = 'test';
		lcust.add(cust6);

		CVCH__Chat2ai__c cust7 = new CVCH__Chat2ai__c();
		cust7.Name = 'Default Flow 2';
		cust7.CVCH__Value__c = 'test';
		lcust.add(cust7);

		CVCH__Chat2ai__c cust8 = new CVCH__Chat2ai__c();
		cust8.Name = 'CREATE VISITOR BEFORE FLOWS';
		cust8.CVCH__Value__c = 'TRUE';
		lcust.add(cust8);

		CVCH__Chat2ai__c cust9 = new CVCH__Chat2ai__c();
		cust9.Name = 'Salesforce URL';
		cust9.CVCH__Value__c = 'google.com';
		lcust.add(cust9);

		CVCH__Chat2ai__c cust10 = new CVCH__Chat2ai__c();
		cust10.Name = 'Facebook Message Flow';
		cust10.CVCH__Value__c = 'test';
		lcust.add(cust10);

		insert lcust;
	}


    public static CVCH__Visitor__c createExistingVisitor(String GDPR)
	{
		CVCH__Visitor__c vis = new CVCH__Visitor__c();
		vis.CVCH__GDPR_Consent__c = GDPR;
		vis.CVCH__Had_First_Interaction__c = true;
		vis.CVCH__Chat_Number__c = '1234567890';
		vis.CVCH__Id__c = '009876543211';
		vis.CVCH__Chanel__c = 'D360';
		vis.CVCH__language__c = 'it';
		insert vis;
		return vis;
	}

	@isTest
    public static void TestNewVisitor()
	{

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/nexmo/';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"message_uuid":"3315e684-4491-47b9-88a2-3990e543ce6e","to":{"type":"whatsapp","number":"1234567890"},"from":{"type":"whatsapp","number":"09876543211"},"timestamp":"2020-08-22T11:13:21.798Z","message":{"content":{"type":"text","text":"hi"}},"direction":"inbound"}');

		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
		SM031_Nexmo.getMessage();
		Test.stopTest();
	}

	@isTest
    public static void TestGet()
	{

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/nexmo/';
		req.httpMethod = 'GET';
		req.requestBody = Blob.valueOf('{"message_uuid":"3315e684-4491-47b9-88a2-3990e543ce6e","to":{"type":"whatsapp","number":"1234567890"},"from":{"type":"whatsapp","number":"09876543211"},"timestamp":"2020-08-22T11:13:21.798Z","message":{"content":{"type":"text","text":"hi"}},"direction":"inbound"}');

		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
		SM031_Nexmo.testIt();
		Test.stopTest();
	}

	@IsTest
	public static  void TestLocation()
	{
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/nexmo/';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"to":"971600555559", "from":"009876543211", "channel":"whatsapp", "message_uuid":"b30de73b-7c55-4a8b-963c-9d0e1fe0b10b", "timestamp":"2022-02-17T06:13:13Z", "message_type":"location", "location":{"address":"Dubai, Dubai", "name":"Cricket Stadium Bus Stop", "url":"https://foursquare.com/v/5a34e3a9bed4831f48b6700f", "lat":25.04334831237793, "long":55.21806335449219}, "profile":{"name":"Vika"}}');

		RestContext.request = req;
		RestContext.response = res;

		createExistingVisitor('Full Access');
		Test.startTest();
		SM031_Nexmo.getMessage();
		Test.stopTest();
	}


	@isTest
    public static void testAzure()
	{
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/nexmo/';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"type":"message","id":"bf3cc9a2f5de","timestamp":"2016-10-19T20:17:52.2891902Z","serviceUrl":"https://smba.trafficmanager.net/apis","channelId":"facebook","from":{"id":"1234abcd","name":"username"},"conversation":{"id":"abcd1234","name":"conversation name"},"recipient":{"id":"12345678","name":"bot name"},"text":"Haircut on Saturday"}');

		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
		SM031_Nexmo.getMessage();
		List<CVCH__NexmoMessage__c> lmess =
		[
				select Id, CVCH__Channel__c
				from CVCH__NexmoMessage__c
				where CVCH__Channel__c = 'Azure'
		];
		System.assert(lmess.size() >= 1);
		List<CVCH__NexmoMessage__c> lmess2 =
		[
				select Id, CVCH__Channel__c
				from CVCH__NexmoMessage__c
				where CVCH__Channel__c <> 'Azure'
		];
		System.assertEquals(lmess2.size(), 0);
		Test.stopTest();
	}


	@isTest
    public static void TestReturningVisitorGDPRNotAccepted()
	{

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/nexmo/';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"message_uuid":"3315e684-4491-47b9-88a2-3990e543ce6e","to":{"type":"whatsapp","number":"1234567890"},"from":{"type":"whatsapp","number":"09876543211"},"timestamp":"2020-08-22T11:13:21.798Z","message":{"content":{"type":"text","text":"hi"}},"direction":"inbound"}');

		RestContext.request = req;
		RestContext.response = res;

		createExistingVisitor('No Access');
		Test.startTest();
		SM031_Nexmo.getMessage();
		Test.stopTest();
	}

	@isTest
    public static void TestReturningVisitorGDPRAccepted()
	{

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/nexmo/';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"message_uuid":"3315e684-4491-47b9-88a2-3990e543ce6e","to":{"type":"whatsapp","number":"1234567890"},"from":{"type":"whatsapp","number":"09876543211"},"timestamp":"2020-08-22T11:13:21.798Z","message":{"content":{"type":"text","text":"hi"}},"direction":"inbound"}');

		RestContext.request = req;
		RestContext.response = res;

		createExistingVisitor('Full Access');
		Test.startTest();
		SM031_Nexmo.getMessage();
		Test.stopTest();
	}
	public static Blob getRequestBody(String sText)
	{
		String sRet = '{"message_uuid":"3315e684-4491-47b9-88a2-3990e543ce6e","to":{"type":"whatsapp","number":"1234567890"},"from":{"type":"whatsapp","number":"09876543211"},"timestamp":"2020-08-22T11:13:21.798Z","message":{"content":{"type":"text","text":"' + sText + '"}},"direction":"inbound"}';
		return Blob.valueOf(sRet);
	}

	public static String getVisitorContext(String sType, String sFieldName)
	{
		String sRet = '{"visitorId":"a0e7E00000DhvqyQAB","sType":"' + sType + '","sMessage":"Seleziona la tua lingua: ","sFlow":"send_options","sFieldName":"' + sFieldName + '","sConfirmMessage":null,"mOptions":{"2":{"sValue3":"","sValue2":"","sValue":"it","sType":"","sName3":"","sName2":"","sName":"language","sLabel":"Italian","sFlow":"send_options","iNumber":2},"1":{"sValue3":"","sValue2":"","sValue":"111","sType":"QnA","sName3":"","sName2":"","sName":"language","sLabel":"English","sFlow":"send_options","iNumber":1}},"lOptions":[],"lItems":[],"content":"{\\"sType\\":\\"\\",\\"a\\":[{\\"sValue3\\":\\"\\",\\"sValue2\\":\\"\\",\\"sValue\\":\\"en\\",\\"sType\\":\\"\\",\\"sName3\\":\\"\\",\\"sName2\\":\\"\\",\\"sName\\":\\"language\\",\\"sLabel\\":\\"English\\",\\"sFlow\\":\\"send_options\\",\\"iNumber\\":null},{\\"sValue3\\":\\"\\",\\"sValue2\\":\\"\\",\\"sValue\\":\\"it\\",\\"sType\\":\\"\\",\\"sName3\\":\\"\\",\\"sName2\\":\\"\\",\\"sName\\":\\"language\\",\\"sLabel\\":\\"Italian\\",\\"sFlow\\":\\"send_options\\",\\"iNumber\\":null},{},{},{},{},{},{},{},{}]}"}';
		return sRet;
	}

	@isTest
    public static void TestMessageWOptions()
	{
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/nexmo/';
		req.httpMethod = 'POST';
		req.requestBody = getRequestBody('2');
		RestContext.request = req;
		RestContext.response = res;

		CVCH__Visitor__c v = createExistingVisitor('Full Access');
		v.CVCH__Context__c = getVisitorContext('options', '');
		update v;
		Test.startTest();
		SM031_Nexmo.getMessage();
		Test.stopTest();
	}

	@isTest
    public static void TestMessageWOptionsQnA()
	{
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/nexmo/';
		req.httpMethod = 'POST';
		req.requestBody = getRequestBody('1');
		RestContext.request = req;
		RestContext.response = res;

		CVCH__Visitor__c v = createExistingVisitor('Full Access');
		v.CVCH__Context__c = getVisitorContext('options', '');
		update v;
		Test.startTest();
		SM031_Nexmo.getMessage();
		Test.stopTest();
	}

	@IsTest
    public static void TestMessageNextFlow()
	{
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/nexmo/';
		req.httpMethod = 'POST';
		req.requestBody = getRequestBody('1');
		RestContext.request = req;
		RestContext.response = res;

		CVCH__Visitor__c v = createExistingVisitor('Full Access');
		v.CVCH__Next_Flow__c = 'send_options';
		update v;
		Test.startTest();
		SM031_Nexmo.getMessage();
		Test.stopTest();
	}

	@IsTest
    public static void TestMessageInput()
	{
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/nexmo/';
		req.httpMethod = 'POST';
		req.requestBody = getRequestBody('20/01/2022');
		RestContext.request = req;
		RestContext.response = res;

		CVCH__Visitor__c v = createExistingVisitor('Full Access');
		v.CVCH__Context__c = getVisitorContext('Input', 'CVCH__Date__c');

		update v;
		Test.startTest();
		SM031_Nexmo.getMessage();
		Test.stopTest();
	}


	@isTest
    public static void TestMessageNoAccessWithOptions()
	{
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/nexmo/';
		req.httpMethod = 'POST';
		req.requestBody = getRequestBody('2');
		RestContext.request = req;
		RestContext.response = res;

		CVCH__Visitor__c v = createExistingVisitor('No Access');
		v.CVCH__Context__c = getVisitorContext('options', '');
		update v;
		Test.startTest();
		SM031_Nexmo.getMessage();
		Test.stopTest();
	}


	@isTest
    public static void TestButton()
	{
		Test.startTest();
		SM031_Nexmo.getMessage0('{"message_uuid":"5a6dbb4e-cde7-4664-a40f-81d5854a03c4","to":{"type":"whatsapp","number":"1234567890"},"from":{"type":"whatsapp","number":"380668657070"},"timestamp":"2021-05-19T09:12:44.151Z","message":{"content":{"type":"button","button":{"text":"Consent 1","payload":"Yes-Button-Payload"}}},"direction":"inbound"}');
		Test.stopTest();
	}


	@isTest
	public static void TestD360ReplyButton()
	{
		createExistingVisitor('Full Access');
		Test.startTest();
		SM031_Nexmo.getMessage0('{"contacts": [{"profile": {"name": "Vika"}, "wa_id": "009876543211"}], "messages": [{"context": {"from": "1234567890", "id": "gBEGlxVScTJ4Agm_0rU46jCic50"}, "from": "971552713278", "id": "ABEGlxVScTJ4Ago-sGYSQkms-X6m", "interactive": {"button_reply": {"id": "disagree", "title": "Do not accept"}, "type": "button_reply"}, "timestamp": "1650811917", "type": "interactive"}]}');
		Test.stopTest();
	}

	@isTest
	public static void TestD360MTMButton()
	{
		createExistingVisitor('Full Access');
		Test.startTest();
		SM031_Nexmo.getMessage0('{"contacts": [{"profile": {"name": "Vika"}, "wa_id": "971552713278"}], "messages": [{"button": {"payload": "alternative mobile", "text": "No"}, "context": {"from": "97145905001", "id": "gBEGlxVScTJ4AgmnnYr599oaV-s"}, "from": "971552713278", "id": "ABEGlxVScTJ4Ago-sOj1zKh5JyEz", "timestamp": "1653642861", "type": "button"}]}');
		Test.stopTest();
	}


	@IsTest
	public static void testD360OrderReceived()
	{
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		FacebookMessage mess;
		req.requestURI = '/services/apexrest/nexmo/';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"contacts":[{"profile":{"name":"Me"},"wa_id":"971501084679"}],"messages":[{"from":"971501084679","id":"ABEGlxUBCEZ5Ago-sLHU3nt8DUkE","order":{"catalog_id":"679615539743464","product_items":[{"currency":"AED","item_price":20,"product_retailer_id":"tl8zro85g0","quantity":1},{"currency":"AED","item_price":20,"product_retailer_id":"ujootwm3or","quantity":4},{"currency":"AED","item_price":20,"product_retailer_id":"bvr32hajb6","quantity":8}],"text":"Please deliver this items"},"timestamp":"1654241486","type":"order"}]}');

		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
		SM031_Nexmo.getMessage();
		mess = FacebookMessage.parse(req.requestBody.toString());
		Test.stopTest();
		System.assertEquals(mess.wa_id,'971501084679');
		System.assertEquals(mess.profile_name,'Me');
		System.assertEquals(mess.catalog_id,'679615539743464');
		System.assertEquals(mess.sku,null);
		System.assertEquals(mess.sFrom,'971501084679');
		System.assertEquals(mess.id,'ABEGlxUBCEZ5Ago-sLHU3nt8DUkE');
		System.assertEquals(mess.text,'Please deliver this items');
		System.assertEquals(mess.timestamp,'1654241486');
		System.assertEquals(mess.type,'order');
		System.assertEquals(mess.items[0].sCurrency,'AED');
		System.assertEquals(mess.items[0].dPrice,20);
	}

	@IsTest
	public static void testD360ProductAdded()
	{

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		FacebookMessage mess;
		req.requestURI = '/services/apexrest/nexmo/';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"contacts":[{"profile":{"name":"Me"},"wa_id":"971501084679"}],"messages":[{"context":{"referred_product":{"catalog_id":"679615539743464","product_retailer_id":"tl8zro85g0"}},"from":"971501084679","id":"ABEGlxUBCEZ5Ago-sFeiVC2JHJq6","text":{"body":"hello"},"timestamp":"1654242139","type":"text"}]}');

		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
		SM031_Nexmo.getMessage();
		mess = FacebookMessage.parse(req.requestBody.toString());
		Test.stopTest();
		System.assertEquals(mess.wa_id,'971501084679');
		System.assertEquals(mess.profile_name,'Me');
		System.assertEquals(mess.catalog_id,'679615539743464');
		System.assertEquals(mess.sku,'tl8zro85g0');
		System.assertEquals(mess.sFrom,'971501084679');
		System.assertEquals(mess.id,'ABEGlxUBCEZ5Ago-sFeiVC2JHJq6');
		System.assertEquals(mess.text,'hello');
		System.assertEquals(mess.timestamp,'1654242139');
		System.assertEquals(mess.type,'text');
		System.assertEquals(mess.items,null);
	}


	@IsTest
	public static void testD360()
	{
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/nexmo/';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"contacts":[{"profile":{"name":"Me"},"wa_id":"971501084679"}],"messages":[{"from":"971501084679","id":"ABEGlxUBCEZ5Ago-sLWeMqsl_Wmw","text":{"body":"product list"},"timestamp":"1660302102","type":"text"}]}');

		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
		SM031_Nexmo.getMessage();
		Test.stopTest();
	}


	@IsTest
	public static void testD360Multi()
	{
		CVCH__Chat2ai__c [] lcust = new CVCH__Chat2ai__c []{};

		CVCH__Chat2ai__c cust1 = new CVCH__Chat2ai__c();
		cust1.Name = 'Multi ChatBots';
		cust1.CVCH__Value__c = 'TRUE';
		lcust.add(cust1);


		insert lcust;

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/nexmo/';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"contacts":[{"profile":{"name":"Me"},"wa_id":"971501084679"}],"messages":[{"from":"971501084679","id":"ABEGlxUBCEZ5Ago-sLWeMqsl_Wmw","text":{"body":"product list"},"timestamp":"1660302102","type":"text"}],"to":"1234"}');

		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
		SM031_Nexmo.getMessage();
		Test.stopTest();
	}


	@IsTest
	public static void testD360Image()
	{
		CVCH__Chat2ai__c [] lcust = new CVCH__Chat2ai__c []{};

		CVCH__Chat2ai__c cust1 = new CVCH__Chat2ai__c();
		cust1.Name = 'Multi ChatBots';
		cust1.CVCH__Value__c = 'TRUE';
		lcust.add(cust1);


		insert lcust;

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/nexmo/';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"contacts": [{"profile": {"name": "Vika"}, "wa_id": "971552713278"}], "messages": [{"from": "971552713278", "id": "ABEGlxVScTJ4Ago67FrOmV1cRkTZ", "image": {"id": "cfa95711-dd20-45dd-aed0-a3c9a7e8eb29", "mime_type": "image/jpeg", "sha256": "b5d7012ba0a5521e82cc4ce88e87af8738ed1cf65d8dc3705d707d97b7f42b1c"}, "timestamp": "1663754362", "type": "image"}], "to": "971800226255"}');

		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
		try
		{
			SM031_Nexmo.getMessage();
		}catch(Exception e){}

		Test.stopTest();
	}



	@IsTest public static  void testWS2()
	{
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/nexmo2/';
		req.httpMethod = 'POST';
		req.requestBody = getRequestBody('1');
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new SM004_SMSMock());
		SM031_Nexmo2.getMessage();
		Test.stopTest();
	}

	@IsTest
	public static  void TestEndChat()
	{
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/nexmo/';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"to":"971600555559", "from":"009876543211", "channel":"whatsapp", "message_uuid":"b30de73b-7c55-4a8b-963c-9d0e1fe0b10b", "timestamp":"2022-02-17T06:13:13Z", "message_type":"location", "location":{"address":"Dubai, Dubai", "name":"Cricket Stadium Bus Stop", "url":"https://foursquare.com/v/5a34e3a9bed4831f48b6700f", "lat":25.04334831237793, "long":55.21806335449219}, "profile":{"name":"Vika"}}');

		RestContext.request = req;
		RestContext.response = res;

		Visitor__c vis = createExistingVisitor('Full Access');
		vis.Livechat_Session_Key__c = '11111';
		vis.Livechat_affinityToken__c = '11111';
		update vis;
		Test.startTest();
		SM031_Nexmo.getMessage();
		Test.stopTest();
	}

	@IsTest
	public static void testParseRef()
	{
		String sBody = '{"contacts": [{"profile": {"name": "Vika"}, "wa_id": "971552713278"}], "messages": [{"context": {"from": "971800226255", "id": "gBEGlxVScTJ4AgkC9gh6SVJAnCk"}, "from": "971552713278", "id": "ABEGlxVScTJ4Ago-sESrb9-sK3x_", "text": {"body": "Reply"}, "timestamp": "1664862726", "type": "text"}], "to": "971800226255"}';
		Test.startTest();
		CVCH__NexmoMessage__c mess = SM031_Nexmo.parse(sBody);
		Test.stopTest();
		system.debug(mess.ReplyToId__c);
		System.assert(mess.ReplyToId__c == 'gBEGlxVScTJ4AgkC9gh6SVJAnCk');
	}


	@IsTest
	public static void testReplyTo()
	{
		Test.startTest();
		SM044_NexmoV1.sendText('111','1111','liveagent text');
		SM005_Logs.save();
		NexmoMessage__c mess = SM031_Nexmo.parse('{"to":"971800226255","from":"917978025200","channel":"whatsapp","message_uuid":"991cc4a7-d0a0-4f85-9b0e-b546f062342c","timestamp":"2022-09-15T08:36:58Z","message_type":"text","text":"No.. thank you","profile":{"name":"Ak"},"context":{"message_uuid":"111222333"}}');
		String sText = SM093_LiveAgent.getMessageText(mess);
		Test.stopTest();
		System.assertEquals(sText,'Replying to "liveagent text"\nNo.. thank you');
	}
}
