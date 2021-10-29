/**
Author:         serhiivolynets
Date:           02.10.2021
Description:   
**/

public class SM095_Nogodi
{
	static string sURL = SM010_Utils.getChat2aiValue2('Nogodi URL');// 'https://api-dev02.noqodi.com';
	public static string getToken()
	{
		string sToken = null;
		HttpResponse rRet = SM003_Http.request(sURL + '/oauth/token/client-credentials', 'POST', getHeaders(), getBody(), 'Nogodi_getToken', null);
		map<string, Object> mObj = (map<string, Object>) JSON.deserializeUntyped(rRet.getBody());

		map<string, object>mStatus = (map<string, object>) mObj.get('statusInfo');
		if ((string) mStatus.get('status') == 'SUCCESS')
		{
			sToken = (string) mObj.get('access_token');
		}
		else
		{
			map<string, object> mErr = (map<string, object>) mStatus.get('errorCode');
			string sErrorMessage = (string) mErr.get('message');
			throw new MyException('Nogodi Error: ' + sErrorMessage);
		}
		return sToken;
	}

	public static map<string, string> getHeaders()
	{
		string sUserName = SM010_Utils.getChat2aiValue2('Nogodi clientId');
		string sPassword = SM010_Utils.getChat2aiValue2('Nogodi secret');
		map<string, string> mRet = new map<string, string>();
		mRet.put('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(sUserName + ':' + sPassword)));
		mRet.put('Content-Type', 'application/x-www-form-urlencoded');
		return mRet;
	}
	public static string getBody()
	{
		string sRet = 'grant_type=client_credentials&client_id=' + EncodingUtil.urlEncode(SM010_Utils.getChat2aiValue2('Nogodi clientId'), 'UTF-8') + '&client_secret=' + EncodingUtil.urlEncode(SM010_Utils.getChat2aiValue2('Nogodi secret'), 'UTF-8');
		return sRet;
	}
	public static map<string, string> getHeaders2(string sToken)
	{

		map<string, string> mRet = new map<string, string>();
		mRet.put('Authorization', 'Bearer ' + sToken);
		mRet.put('Content-Type', 'application/json');
		return mRet;
	}

	public static string getBody2(string sOrderId)
	{
		string merchantCode = SM010_Utils.getChat2aiValue2('Nogodi merchantCode');
		string merchantId = SM010_Utils.getChat2aiValue2('Nogodi merchantId');
		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);

		string sRet = '{\n' +
				'    "serviceType": "PRE_AUTH",\n' +
				'    "serviceMode": "NORMAL",\n' +
				'    "merchantInfo": {\n' +
				'        "merchantCode": "' + merchantCode + '",\n' +
				'        "merchantLandingURL": "http://merchantapi.com/confirm?response=",\n' +
				'        "merchantRequestId": "' + guid + '",\n' +
				'        "merchantOrderId": "' + sOrderId + '"\n' +
				'    },\n' +
				'    "paymentInfo": {\n' +
				'        "amount": {\n' +
				'            "value": 100,\n' +
				'            "currency": "AED"\n' +
				'        },\n' +
				'        "pricingInfo": {\n' +
				'            "paymentTypes": [\n' +
				'                "ECA",\n' +
				'                "CCD",\n' +
				'                "DDB"\n' +
				'            ]\n' +
				'        }\n' +
				'    }\n' +
				'}';
		return sRet;
	}

	public static string preAuth(string sOrderId)
	{
		string sURL;

		string sToken = getToken();
		HttpResponse rRet = SM003_Http.request(sURL + '/v2/payments/preAuth', 'POST', getHeaders2(sToken), getBody2(sOrderId), 'Nogodi_preAuth', null);
		map<string, object> mObj = (map<string, object>) JSON.deserializeUntyped(rRet.getBody());
		map<string, object>mStatus = (map<string, object>) mObj.get('statusInfo');
		if ((string) mStatus.get('status') == 'SUCCESS')
		{
			map<string, object> mInfo = (map<string, object>) mObj.get('paymentInfo');
			sURL = (string) mInfo.get('paymentUrl');
		}
		else
		{
			map<string, object> mErr = (map<string, object>) mStatus.get('errorCode');
			string sErrorMessage = (string) mErr.get('message');
			throw new MyException('Nogodi Error: ' + sErrorMessage);
		}
		return sURL;
	}

}
