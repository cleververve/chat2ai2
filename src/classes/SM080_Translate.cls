/**
Author:         serhiivolynets
Date:           07.07.2020
Description:   
**/

public class SM080_Translate
{
    public static MTranslation translate0(string sText)
    {
        MTranslation tran;
        
        tran = SM010_Utils.translateAPI0(sText);
        if (tran == null || tran.translation == null)
        {
            tran = new MTranslation();
            string sURL = SM010_Utils.getChat2aiValue('Microsoft Translator URL');
			sURL = sURL+'&to=en';
			HttpResponse resp = SM003_Http.request(sURL,'POST', getHeaders(),getBody(sText), 'MS translate', NULL, 'SM080_TranslateMock');
			string sResp = resp.getBody();
			object oResp = JSON.deserializeUntyped(sResp);
            tran.translation = (string)JPath.get0(oResp,'[1]/translations/[1]/text');
            tran.detectedlang = (string)JPath.get0(oResp,'[1]/detectedLanguage/language');
            tran.text = sText;
            if (tran.translation != null)
                SM010_Utils.addTranslationAPI0(tran);
        }
        
        return tran;
    }
    
	public static map<string, string> getHeaders()
	{
		map<string, string> ret = new map<string, string>();
		ret.put('Content-Type', 'application/json');
		ret.put('Ocp-Apim-Subscription-Key', SM010_Utils.getChat2aiValue('Microsoft Translator Key'));
		String sGlobal =  SM010_Utils.getChat2aiValue2('Ocp-Apim-Subscription-Region');
		if(sGlobal != '')
			ret.put('Ocp-Apim-Subscription-Region',sGlobal);
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
