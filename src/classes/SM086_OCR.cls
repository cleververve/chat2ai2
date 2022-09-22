/**
Author:         serhiivolynets
Date:           02.02.2021
Description:   
**/

global class SM086_OCR
{
	global class OCRInput
	{

		@AuraEnabled @InvocableVariable global String imageurl;
		@AuraEnabled @InvocableVariable global String fileName;
	}


	global class OCROutput
	{
		@AuraEnabled @InvocableVariable global String status;
		@AuraEnabled @InvocableVariable global String error;
		@AuraEnabled @InvocableVariable global String category;
		@AuraEnabled @InvocableVariable global String currency_code;
		@AuraEnabled @InvocableVariable global String sDate;
		@AuraEnabled @InvocableVariable global Date dtDate;
		@AuraEnabled @InvocableVariable global Datetime dtDateTime;
		@AuraEnabled @InvocableVariable global String invoice_number;
		@AuraEnabled @InvocableVariable global Decimal subtotal;
		@AuraEnabled @InvocableVariable global Decimal tax;
		@AuraEnabled @InvocableVariable global Decimal total;
		@AuraEnabled @InvocableVariable global String address;
		@AuraEnabled @InvocableVariable global String name;
		@AuraEnabled @InvocableVariable global Integer is_duplicate;
		@AuraEnabled @InvocableVariable global String ocr_text;
		@AuraEnabled @InvocableVariable global Decimal lines_total;
		@AuraEnabled @InvocableVariable global String check_number;
		@AuraEnabled @InvocableVariable global String store_number;
		@AuraEnabled @InvocableVariable global String notes;
		@AuraEnabled @InvocableVariable global String barcode;
		@AuraEnabled @InvocableVariable global String id;
		@AuraEnabled @InvocableVariable global String externalId;
		@AuraEnabled @InvocableVariable global Decimal cashback;
		@AuraEnabled @InvocableVariable global Decimal discount;
		@AuraEnabled@InvocableVariable global List<OCRItem> items;
	}

	global class OCRItem
	{
		@AuraEnabled @InvocableVariable global Date dtDate;
		@AuraEnabled @InvocableVariable global String sDate;
		@AuraEnabled @InvocableVariable global String description;
		@AuraEnabled @InvocableVariable global Decimal discount;
		@AuraEnabled @InvocableVariable global String id;
		@AuraEnabled @InvocableVariable global Integer order;
		@AuraEnabled @InvocableVariable global Decimal price;
		@AuraEnabled @InvocableVariable global Decimal quantity;

		@AuraEnabled @InvocableVariable global String reference;
		@AuraEnabled @InvocableVariable global String section;
		@AuraEnabled @InvocableVariable global String sku;
		@AuraEnabled @InvocableVariable global Decimal tax;
		@AuraEnabled @InvocableVariable global Decimal tax_rate;
		@AuraEnabled @InvocableVariable global Decimal total;

		@AuraEnabled @InvocableVariable global String type;
		@AuraEnabled @InvocableVariable global String unit_of_measure;
		@AuraEnabled @InvocableVariable global Decimal cashback;
	}


	@InvocableMethod(label='OCR' description='OCR')
	global static List<OCROutput> OCR(List<OCRInput> lParam)
	{

		List<OCROutput> lRet = new List<OCROutput>();
		for (OCRInput inp : lParam)
		{
			OCROutput out = callIt(inp.imageurl, inp.fileName);
			lRet.add(out);

		}
		return lRet;
	}

	public static OCROutput callIt(String sURL, String sName)
	{
		OCROutput ret;
		try
		{
			HttpResponse resp = SM003_Http.request(SM010_Utils.getChat2aiValue('Veryfi URL'), //https://api.veryfi.com/api/v7/partner/documents/
					'POST', headers(), getBody(sURL, sName), 'Veryfi OCR', NULL, 'SM086_OCRMock');
			ret = parse(resp.getBody());
		}
		catch (Exception e)
		{
			if(Test.isRunningTest())
				throw e;
			ret = new OCROutput();
			ret.status = 'error';
			ret.error = e.getMessage();
		}
		return ret;
	}
//	public static string checknumber(string sText, string sPrefix)
//	{
//		string sRet = '';
//		if(sText != null && sText.indexOf(sPrefix)>=0)
//		{
//			integer i = sText.indexOf(sPrefix)+4;
//			for(;i<sText.length();i++)
//			{
//				string sPart = sText.substring(i,i+1);
//				if(sPart.isNumeric())
//					sRet=sRet+sPart;
//				else
//						return sRet;
//			}
//		}
//		return sRet;
//	}
	public static OCROutput parse(String sBodyResp)
	{
		System.debug('parse '+sBodyResp);
		Map<String, Object> mResp = (Map<String, Object>) JSON.deserializeUntyped(sBodyResp);
		OCROutput resp = new OCROutput();
		resp.items = new List<OCRItem>();
		resp.status = 'success';
		resp.category = (String) mResp.get('category');
		resp.currency_code = (String) mResp.get('currency_code');
		resp.sDate = (String) mResp.get('date');
		try
		{
			resp.dtDate = Date.valueOf(resp.sDate);
		}
		catch(Exception e)
		{

		}

		try
		{
			resp.dtDateTime = Datetime.valueOf(resp.sDate);

		}
		catch(Exception e)
		{
			if (Test.isRunningTest())
				throw e;
		}

		resp.invoice_number = (String) mResp.get('invoice_number');
		resp.subtotal = (Decimal) mResp.get('subtotal');
		resp.tax = (Decimal) mResp.get('tax');
		resp.total = (Decimal) mResp.get('total');
		resp.is_duplicate = (Integer) mResp.get('is_duplicate');
		resp.ocr_text = (String) mResp.get('ocr_text');
		resp.notes = (String) mResp.get('notes');
		resp.id =  ''+(Integer) mResp.get('id');

		resp.discount = (Decimal)mResp.get('discount');
		resp.cashback = (Decimal)mResp.get('cashback');

		List<Object> lbarcodes = (List<Object>) mResp.get('barcodes');
		if(lbarcodes != null)
		{
			for(Object obj : lbarcodes)
			{
				Map<String,Object> mBar = (Map<String,Object>)obj;
				resp.barcode = (String)mBar.get('data');
			}
		}

//		resp.store_number=checknumber(resp.ocr_text,'DHFC');
//		if(resp.store_number == null || resp.store_number =='')
//			resp.store_number=checknumber(resp.ocr_text,'DFC');


		Map<String, Object> mAddress = (Map<String, Object>) mResp.get('vendor');
		if (mAddress != null)
		{
			System.debug('mAddress='+mAddress);
			resp.store_number=(String)mAddress.get('vendor_type');
			resp.address = (String) mAddress.get('address');
			resp.name = (String) mAddress.get('name');
			resp.externalId = (String) mAddress.get('external_id');

		}
		if(mResp.get('line_items') != null)
		{
			resp.lines_total = 0;
			List<Object> lObj = (List<Object>)mResp.get('line_items');
			for(Object obj: lObj)
			{
				OCRItem item = new OCRItem();



				Map<String,Object> mLine = (Map<String,Object>) obj;
				item.sDate = (String)mLine.get('date');
				try
				{
					item.dtDate = Date.valueOf(item.sDate);
				}
				catch(Exception e)
				{
				}
				item.type =  (String)mLine.get('type');
				item.total = (Decimal)mLine.get('total');
				item.id = ''+(integer)mLine.get('id');
				item.description = (String)mLine.get('description');
				item.discount = (Decimal)mLine.get('discount');
				item.cashback = (Decimal)mLine.get('cashback');
				item.order = (Integer)mLine.get('order');
				item.price = (Decimal)mLine.get('price');
				item.quantity =(Decimal)mLine.get('quantity');
				item.reference = (String)mLine.get('reference');
				item.section = (String)mLine.get('section');
				item.sku = (String)mLine.get('sku');
				item.tax = (Decimal)mLine.get('tax');
				item.tax_rate = (Decimal)mLine.get('tax_rate');
				item.unit_of_measure = (String)mLine.get('unit_of_measure');
				resp.items.add(item);
				if(mLine.get('total') != null)
				{
					resp.lines_total += (Decimal) mLine.get('total');
				}
			}
		}
		System.debug('resp');
		System.debug(resp);
		return resp;
	}
	public static Map<String, String> headers()
	{
		Map<String, String> mRet = new Map<String, String>();
		mRet.put('AUTHORIZATION', SM010_Utils.getChat2aiValue('Veryfi AUTHORIZATION'));//'apikey admin.viafone:e4a4b481e34e238557250d4605baeb09');
		mRet.put('CLIENT-ID', SM010_Utils.getChat2aiValue('Veryfi CLIENT-ID'));//'vrfkh1ka3NNMlU9hK8Psw4dv8Sa99Op1Rxffy5N');
		mRet.put('Content-Type', 'application/json');
		System.debug(mRet);
		return mRet;
	}


	public static String getBody(String sURL, String sName)
	{
		Map<String, String> mRet = new Map<String, String>();
		mRet.put('file_url', sURL);
		mRet.put('file_name', sName);
		return JSON.serialize(mRet);
	}
}
