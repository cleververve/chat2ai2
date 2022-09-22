/**
Author:         serhiivolynets
Date:           13.03.2021
Description:   
**/

global class SM090_UploadS3
{
	@InvocableMethod(label='Upload to S3' description='OCR')
	global static List<S3Output> UploadS3(List<S3Input> lParam)
	{
		List<S3Output> lRet = new List<S3Output>();
		for(S3Input param : lParam)
		{
			lRet.add(getS3URL(param.sURL));
		}
		return lRet;
	}

	public static Map<String,String>getHeaders()
	{
		Map<String,String> mRet = new Map<String,String>();
		mRet.put('Content-Type','application/json');
		mRet.put('Accept','application/json');
		return mRet;
	}

	global class S3Input
	{

		@AuraEnabled @InvocableVariable global String sURL;
	}

	global class S3Output
	{
		@AuraEnabled @InvocableVariable global String S3URL;
		@AuraEnabled @InvocableVariable global String Error;
	}

	public static String getBody(String sURL,String sChannel, String sChatbotNumber)
	{
		Map<String, Object> mRet = new Map<String, Object>();
		mRet.put('filename', sURL);
		if(sChannel =='D360')
		{
			String sKeySettingName = 'D360-API-KEY';
			if (sChatbotNumber != null && sChatbotNumber != '' && SM010_Utils.getChat2aiValue2('Multi ChatBots') == 'TRUE')
			{
				sKeySettingName = sKeySettingName + '_' + sChatbotNumber;
			}
			Map<String, Object> mHeaders = new Map<String, Object>();
			mHeaders.put('D360-API-KEY',SM010_Utils.getChat2aiValue2(sKeySettingName));
			mHeaders.put('Content-Type','application/json');
			mRet.put('headers',mHeaders);
			mRet.put('folder','GV');
		}
		return JSON.serialize(mRet);
	}

	global static S3Output getS3URL(String sURL)
	{
		return getS3URL(sURL,null,null);
	}

	global static S3Output getS3URL(String sURL, String sChannel, String sChatbotNumber)
	{
		S3Output ret = new S3Output();
		try
		{
			HttpResponse resp = CVCH.SM003_Http.request('http://barcode-env.x49y4mrjpq.eu-central-1.elasticbeanstalk.com/upload', 'POST', getHeaders(), getBody(sURL,sChannel,sChatbotNumber), 'S3Upload', null, 'SM090_UploadS3Mock');
			Map<String, Object> mResp = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
			ret.Error = (String) mResp.get('Error');
			System.debug('S3Resp');
			System.debug(mResp);
			if (ret.Error == null || ret.Error == '')
				ret.S3URL = CVCH.SM010_Utils.getChat2aiValue('S3URL') + (String) mResp.get('URL');

		}catch (Exception e)
		{
			System.debug('Error: '+e.getMessage());
			ret.Error = 'Error: '+e.getMessage();
		}
		return ret;
	}
}
