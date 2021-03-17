/**
Author:         serhiivolynets
Date:           13.03.2021
Description:   
**/

global class SM090_UploadS3
{

	@InvocableMethod(label='Upload to S3' description='OCR')
	global static list<S3Output> UploadS3(list<S3Input> lParam)
	{
		list<S3Output> lRet = new list<S3Output>();
		for(S3Input param : lParam)
		{
			lRet.add(getS3URL(param.sURL));
		}
		return lRet;
	}

	public static map<string,string>getHeaders()
	{
		map<string,string> mRet = new map<string,string>();
		mRet.put('Content-Type','application/json');
		mRet.put('Accept','application/json');
		return mRet;

	}

	global class S3Input
	{

		@AuraEnabled @InvocableVariable global string sURL;
	}

	global class S3Output
	{

		@AuraEnabled @InvocableVariable global string S3URL;
		@AuraEnabled @InvocableVariable global string Error;
	}


	public static string getBody(string sURL)
	{
		map<string, object> mRet = new map<string, object>();
		mRet.put('filename', sURL);
		return JSOn.serialize(mRet);

	}
	global static S3Output getS3URL(string sURL)
	{
		S3Output ret = new S3Output();
		try
		{

			HttpResponse resp = CVCH.SM003_Http.request('http://barcode-env.x49y4mrjpq.eu-central-1.elasticbeanstalk.com/upload', 'POST', getHeaders(), getBody(sURL), 'S3Upload', null, 'SM090_UploadS3Mock');

			map<string, object> mResp = (map<string, object>) JSON.deserializeUntyped(resp.getBody());
			ret.Error = (string) mResp.get('Error');
			if (ret.Error == null || ret.Error == '')
				ret.S3URL = CVCH.SM010_Utils.getChat2aiValue('S3URL') + (string) mResp.get('URL');

		}catch (Exception e)
		{
			ret.Error = 'Error: '+e.getMessage();
		}
		return ret;
	}
}
