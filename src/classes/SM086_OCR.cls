/**
Author:         serhiivolynets
Date:           02.02.2021
Description:   
**/

global class SM086_OCR
{
	global class OCRInput
	{

		@AuraEnabled @InvocableVariable global string imageurl;
		@AuraEnabled @InvocableVariable global string fileName;
	}


	global class OCROutput
	{
		@AuraEnabled @InvocableVariable global string status;
		@AuraEnabled @InvocableVariable global string error;
		@AuraEnabled @InvocableVariable global string category;
		@AuraEnabled @InvocableVariable global string currency_code;
		@AuraEnabled @InvocableVariable global string sDate;
		@AuraEnabled @InvocableVariable global date dtDate;
		@AuraEnabled @InvocableVariable global datetime dtDateTime;
		@AuraEnabled @InvocableVariable global string invoice_number;
		@AuraEnabled @InvocableVariable global decimal subtotal;
		@AuraEnabled @InvocableVariable global decimal tax;
		@AuraEnabled @InvocableVariable global decimal total;
		@AuraEnabled @InvocableVariable global string address;
		@AuraEnabled @InvocableVariable global string name;
		@AuraEnabled @InvocableVariable global Integer is_duplicate;
		@AuraEnabled @InvocableVariable global string ocr_text;
		@AuraEnabled @InvocableVariable global decimal lines_total;
		@AuraEnabled @InvocableVariable global string check_number;
		@AuraEnabled @InvocableVariable global string store_number;
		@AuraEnabled @InvocableVariable global string notes;
		@AuraEnabled @InvocableVariable global string barcode;
		@AuraEnabled @InvocableVariable global string id;
	}


	@InvocableMethod(label='OCR' description='OCR')
	global static list<OCROutput> OCR(list<OCRInput> lParam)
	{

		list<OCROutput> lRet = new list<OCROutput>();
		for (OCRInput inp : lParam)
		{
			OCROutput out = callIt(inp.imageurl, inp.fileName);
			lRet.add(out);

		}
		return lRet;
	}

	public static OCROutput callIt(string sURL, string sName)
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
	public static OCROutput parse(string sBodyResp)
	{
		system.debug('parse '+sBodyResp);
		map<string, object> mResp = (map<string, object>) JSON.deserializeUntyped(sBodyResp);
		OCROutput resp = new OCROutput();
		resp.status = 'success';
		resp.category = (string) mResp.get('category');
		resp.currency_code = (string) mResp.get('currency_code');
		resp.sDate = (string) mResp.get('date');
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

		resp.invoice_number = (string) mResp.get('invoice_number');
		resp.subtotal = (decimal) mResp.get('subtotal');
		resp.tax = (decimal) mResp.get('tax');
		resp.total = (decimal) mResp.get('total');
		resp.is_duplicate = (integer) mResp.get('is_duplicate');
		resp.ocr_text = (string) mResp.get('ocr_text');
		resp.notes = (string) mResp.get('notes');
		resp.id =  ''+(integer) mResp.get('id');
		list<object> lbarcodes = (list<object>) mResp.get('barcodes');
		if(lbarcodes != null)
		{
			for(object obj : lbarcodes)
			{
				map<string,object> mBar = (map<string,object>)obj;
				resp.barcode = (string)mBar.get('data');
			}
		}

//		resp.store_number=checknumber(resp.ocr_text,'DHFC');
//		if(resp.store_number == null || resp.store_number =='')
//			resp.store_number=checknumber(resp.ocr_text,'DFC');


		map<string, object> mAddress = (map<string, object>) mResp.get('vendor');
		if (mAddress != null)
		{
			system.debug('mAddress='+mAddress);
			resp.store_number=(string)mAddress.get('vendor_type');
			resp.address = (string) mAddress.get('address');
			resp.name = (string) mAddress.get('name');
		}
		if(mResp.get('line_items') != null)
		{
			resp.lines_total = 0;
			list<object> lObj = (list<object>)mResp.get('line_items');
			for(object obj: lObj)
			{
				map<string,object> mLine = (map<string,object>) obj;
				if(mLine.get('total') != null)
				{
					resp.lines_total += (decimal) mLine.get('total');
				}
			}
		}
		system.debug('resp');
		system.debug(resp);
		return resp;
	}
	public static Map<String, String> headers()
	{
		map<string, string> mRet = new map<string, string>();
		mRet.put('AUTHORIZATION', SM010_Utils.getChat2aiValue('Veryfi AUTHORIZATION'));//'apikey admin.viafone:e4a4b481e34e238557250d4605baeb09');
		mRet.put('CLIENT-ID', SM010_Utils.getChat2aiValue('Veryfi CLIENT-ID'));//'vrfkh1ka3NNMlU9hK8Psw4dv8Sa99Op1Rxffy5N');
		mRet.put('Content-Type', 'application/json');
		system.debug(mRet);
		return mRet;
	}


	public static string getBody(string sURL, string sName)
	{
		map<string, string> mRet = new map<string, string>();
		mRet.put('file_url', sURL);
		mRet.put('file_name', sName);
		return json.serialize(mRet);
	}
}
