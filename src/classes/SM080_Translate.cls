/**
Author:         serhiivolynets
Date:           07.07.2020
Description:   
**/

public class SM080_Translate
{

	public static string translate(string sText)
	{
		string sRet = SM010_Utils.translateAPI(sText); // ищем в кеше
		if(sRet == null) // если в кеше не нашли
		{ // то вызываем API
			string sURL = SM010_Utils.getChat2aiValue('Microsoft Translator URL');
			sURL = sURL+'&to=en';
			HttpResponse resp = SM003_Http.request(sURL,'POST', getHeaders(),getBody(sText), 'MS translate', NULL, 'SM080_TranslateMock');
			string sResp = resp.getBody();
			object oResp = JSON.deserializeUntyped(sResp);
			sRet = (string)JPath.get0(oResp,'[1]/translations/[1]/text');
			if(sRet != null)  // если API перевел - то сохраняем в кеш для последующей записи в базу
				SM010_Utils.addTralslationAPI(sText,sRet);
		}
		return sRet;
	}

	public static map<string, string> getHeaders()
	{
		map<string, string> ret = new map<string, string>();
		ret.put('Content-Type', 'application/json');
		ret.put('Ocp-Apim-Subscription-Key', SM010_Utils.getChat2aiValue('Microsoft Translator Key'));
		return ret;
	}

	public static string getBody(string sText)
	{
		list<object> lRet = new list<object>();
		map<string,object> mChild = new map<string,object>();
		lRet.add(mChild);
		mChild.put('Text',sText);
		return json.serialize(lret);
	}
}