/**
 * Author:         serhiivolynets
 * Date:           31.07.2022
 * Description:
 **/
@RestResource(UrlMapping='/facebookmessaging/*')
global class FacebookMessage
{
	@AuraEnabled @InvocableVariable global String wa_id;
	@AuraEnabled @InvocableVariable global String profile_name;
	@AuraEnabled @InvocableVariable global String catalog_id;
	@AuraEnabled @InvocableVariable global String sku;
	@AuraEnabled @InvocableVariable global String sFrom;
	@AuraEnabled @InvocableVariable global String id;
	@AuraEnabled @InvocableVariable global String text;
	@AuraEnabled @InvocableVariable global String timestamp;
	@AuraEnabled @InvocableVariable global String type;
	@AuraEnabled @InvocableVariable global FacebookOrderItem[] items;
	@AuraEnabled @InvocableVariable global Boolean isValid;

	@HttpPost
	global static String getMessage()
	{
		return getMessage0 (RestContext.request.requestBody.toString());
	}
	global static String getMessage0(String sBody)
	{
		Datetime dtBeg = Datetime.now();
		String sError = null;
		try
		{
			FacebookMessage mess = parse(sBody);
			if(mess != null)
				mess.handledInFlow();
		}
		catch (Exception e)
		{
			sError = e.getMessage() + ' ' + e.getStackTraceString();
		}
		SM005_Logs.LogCallOut(null, 'FacebookInboundMessage', sBody, '', dtBeg, Datetime.now(), sError);
		SM005_Logs.save();
		return '';
	}

	public boolean handledInFlow()
	{
		if(this.isValid)
		{
			Visitor__c vis = SM031_Nexmo.getVisitor(this.sFrom, null, 'D360');
			if (vis.Id == null)
				insert vis;
			String sFlow = SM010_Utils.getChat2aiValue2('Facebook Message Flow');
			if (sFlow != '')
			{
				Map<String, Object> params = new Map<String, Object>();
				params.put('message', this);
				params.put('visitorId', vis.Id);
				Flow.Interview fl = Flow.Interview.createInterview(sFlow, params);
				fl.start();
				return true;
			}
		}
		return false;
	}

	public static FacebookMessage parse(String sBody)
	{
		FacebookMessage ret = new FacebookMessage();
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(sBody);
		ret.profile_name = (String) JPath.get0(m, '/contacts/[1]/profile/name');
		ret.wa_id = (String) JPath.get0(m, '/contacts/[1]/wa_id');
		ret.catalog_id = (String) JPath.get0(m, '/messages/[1]/context/referred_product/catalog_id');
		ret.sku = (String) JPath.get0(m, '/messages/[1]/context/referred_product/product_retailer_id');
		ret.sFrom = (String) JPath.get0(m, '/messages/[1]/from');
		ret.id = (String) JPath.get0(m, '/messages/[1]/id');
		ret.text = (String) JPath.get0(m, '/messages/[1]/text/body');
		ret.timestamp = (String) JPath.get0(m, '/messages/[1]/timestamp');
		ret.type = (String) JPath.get0(m, '/messages/[1]/type');
		Object oOrder = JPath.get0(m, '/messages/[1]/order');
		if (oOrder != null)
		{
			ret.catalog_id = (String) JPath.get0(oOrder, '/catalog_id');
			ret.text = (String) JPath.get0(oOrder, '/text');
			List<Object> lItems = (List<Object>) JPath.get0(oOrder, '/product_items');
			ret.items = new List<FacebookOrderItem>();
			for (Object it : lItems)
			{
				FacebookOrderItem item = new FacebookOrderItem();
				item.SKU = (String) JPath.get0(it, '/product_retailer_id');
				item.sCurrency = (String) JPath.get0(it, '/currency');
				item.dPrice = (Decimal) JPath.get0(it, '/item_price');
				item.quantity = (Decimal) JPath.get0(it, '/quantity');
				ret.items.add(item);
			}
		}
		ret.isValid = ((ret.sku != null && ret.sku != '') || ret.items != null);
		return ret;
	}
}
