/**
Author:         serhiivolynets
Date:           08.09.2021
Description:   
**/

global class SM086_OCR_train
{
	global class OCRInputTrain
	{
		@AuraEnabled @InvocableVariable global date dtDate;
		@AuraEnabled @InvocableVariable global string vendorName;
		@AuraEnabled @InvocableVariable global integer total;
		@AuraEnabled @InvocableVariable global string documentID;
	}

	@InvocableMethod(label='Train OCR' description='Train OCR')
	global static void OCR(list<OCRInputTrain> lParam)
	{
		for (OCRInputTrain inp : lParam)
		{
			callIt(inp.documentID, inp.dtDate, inp.total, inp.vendorName);
		}
	}

	public static Map<String, String> headers()
	{
		map<string, string> mRet = new map<string, string>();
		mRet.put('AUTHORIZATION', CVCH.SM010_Utils.getChat2aiValue('Veryfi AUTHORIZATION'));//'apikey admin.viafone:e4a4b481e34e238557250d4605baeb09');
		mRet.put('CLIENT-ID', CVCH.SM010_Utils.getChat2aiValue('Veryfi CLIENT-ID'));//'vrfkh1ka3NNMlU9hK8Psw4dv8Sa99Op1Rxffy5N');
		mRet.put('Content-Type', 'application/json');
		mRet.put('Accept', 'application/json');
		return mRet;
	}
	public static void callIt(string sDocument, date dtDate, integer total, string sVendorName)
	{
		try
		{
			HttpResponse resp = CVCH.SM003_Http.request(CVCH.SM010_Utils.getChat2aiValue('Veryfi URL') + sDocument+'/', //https://api.veryfi.com/api/v7/partner/documents/
					'PUT',
					headers(), getBody(total, dtDate, sVendorName), 'Veryfi OCR Train', NULL, 'SM086_OCRMock');
		}
		catch (Exception e)
		{
			if (Test.isRunningTest())
				throw e;
		}
	}
	public static string getBody(Integer total, Date dt, string sVendorName)
	{
		map<string, object> mRet = new map<string, object>();
		mRet.put('total', '' + total);
		mRet.put('data', Datetime.newInstance(dt, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'));
		map<string, string> mVen = new map<string, string>();
		mVen.put('name', sVendorName);
		mRet.put('vendor', mVen);
		return json.serialize(mRet);
	}
}
