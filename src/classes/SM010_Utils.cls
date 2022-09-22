global class SM010_Utils
{
	public static Visitor__c visr;
	public static void setVisitor(Visitor__c v)
	{
		visr = v;
	}

	public class pageReturn
	{
		public List<Object>lObj = new List<Object>();
		public Boolean bEnd = true;
		public Boolean bBegin = true;
	}




	public static pageReturn getPage(List<Object>lObj, Integer iTab, Integer iSize, Boolean bReserveSlotForPrev, Boolean bReserveSlotForNext)
	{

		pageReturn ret = new pageReturn();

		if (lObj.size() <= iSize && Test.isRunningTest() == false)
			ret.lObj = lObj;
		else
		{
			Integer iBegin;
			Integer iCurSize = iSize;

			Integer iBeginSize = iSize;
			Integer iMidSize = iSize;
			Integer iEndSize = iSize;
			if (bReserveSlotForPrev)
			{
				iMidSize -= 1;
				iEndSize -= 1;
			}
			if (bReserveSlotForNext)
			{
				iMidSize -= 1;
				iBeginSize -= 1;
			}

			if (iTab == 0)
			{
				iBegin = 0;
				iCurSize = iBeginSize;
				ret.bEnd = false;
			}
			else
			{
				ret.bBegin = false;

				//определяем, сколько вообще пейджей есть в данном массиве, как
				Decimal dMidSize = lObj.size() - iBeginSize;

				Decimal iMidCnt = dMidSize / iMidSize ; //длина массива минус длина первого пейджа деленная на длину среднего пейджа
				System.debug('iMidCnt=' + iMidCnt);
				Integer nTabs = Integer.valueOf(Math.ceil(iMidCnt)) + 1;

				System.debug('lObj.size=' + lObj.size() + ', iBeginSize=' + iBeginSize + ',nTabs=' + nTabs + ',iMidSize=' + iMidSize);
				if ((lObj.size() - (iBeginSize + (nTabs - 2) * iMidSize) == 1)// если в последнем пейдже - всего один элемент
						&& bReserveSlotForNext // и есть зарезервированное место под кнопку Next
						)
					nTabs -= 1; // тогда уменьшим к-во табов, потому что вместо кнопки Next мы покажем последний элемент

				if (iTab >= nTabs - 1)
				{
					iTab = nTabs - 1;
					iCurSize = iEndSize;
				}
				else
				{
					iCurSize = iMidSize;
					ret.bEnd = false;
				}

				iBegin = iBeginSize + (iTab - 1) * iMidSize ;
			}

			System.debug('iCurSize =' + iCurSize + ' iBegin=' + iBegin + ' lAcc.size()=' + lObj.size());
			for (Integer i = 0; i < iCurSize && (iBegin + i < lObj.size()); i++)
			{
				Object m = lObj[iBegin + i];
				ret.lObj.add(m);
			}
		}
		System.debug('getPage(' + iTab + ')=' + ret);
		return ret;
	}

//    public static string getEmojiforNum(integer input) {
//        string emoji = null;
//            switch on input {
//                when 1 {
//					emoji = '1️⃣';
//                }
//                when 2 {
//					emoji = '2️⃣';
//                }
//                when 3 {
//					emoji = '3️⃣';
//                }
//                when 4 {
//					emoji = '4️⃣';
//                }
//                when 5 {
//					emoji = '5️⃣';
//                }
//                when 6 {
//					emoji = '6️⃣';
//                }
//                when 7 {
//					emoji = '7️⃣';
//                }
//                when 8 {
//					emoji = '8️⃣';
//                }
//                when 9 {
//					emoji = '9️⃣';
//                }
//                when 10 {
//					emoji = '🔟';
//                }
//                when else {
//                    emoji = String.valueOf(input);
//                }
//            }
//        return emoji;
//    }

	public static Option getOption(Map<String, Option> mOption, String input)
	{
		Option ret = null;
		if (input == null || input == '')
		{
			return ret;
		}
		for (String index : mOption.keySet())
		{
			Option opt = mOption.get(index);
			if (opt.sLabel == null)
			{
				continue;
			}
			if (opt.sLabel.containsIgnoreCase(input) && input.length() > 1)
			{ // found match
				ret = opt;
			}
			if (opt.sLabel.equalsIgnoreCase(input))
			{ // found exact match - returning this value immediately
				ret = opt;
				break;
			}
		}
		return ret;
	}
	public static Set<String> lResponses = new Set<String>();
	public static void addResponse(Object o)
	{
		String sResp = JSON.serialize(o);
		lResponses.add(sResp);
	}

	public static void insertConversation(Decimal scoreLUIS, Decimal scoreQnA, String intentLUIS, String triggeredFlow, String language, String phone, String input, String output, Id visitorId, String errMsg)
	{
		Conversation__c conv = new Conversation__c();
		try
		{
			if (scoreLUIS > scoreQnA)
			{
				conv.NLP__c = 'LUIS';
				conv.CVCH__Score__c = scoreLUIS;
				conv.CVCH__Intent__c = intentLUIS;
			}
			else
			{
				conv.NLP__c = 'QnA';
				conv.CVCH__Score__c = scoreQnA;
			}
			conv.CVCH__Language__c = language;
			conv.CVCH__Phone__c = phone;
			conv.Error__c = errMsg;
			conv.CVCH__Output__c = output;
			if (input != null && input.length() > 32000)
				input = input.substring(0, 32000);
			conv.CVCH__Input__c = input;
			if (input != null && input.length() > 255)
				input = input.substring(0, 255);
			conv.Input2__c = input;
			conv.CVCH__Visitor__c = visitorId;
			conv.CVCH__Triggered_Flow__c = triggeredFlow;
			List<String>lResp = new List<String>();
			lResp.addAll(lResponses);
			conv.Responses__c = String.join(lResp, '; ');
			insert conv;
		}
		catch (Exception e)
		{
			return;
		}

	}

	public static void logSearchRequest(SM080_LUIS.LuisResponse respLuis)
	{
		//if (respLuis.sIntent != 'category search' && respLuis.sIntent != 'outlet search' && respLuis.sIntent != 'ikea') {
		//    return;
		//}
		String keyword1 = '';//found shop
		String keyword2 = '';//found item
		String keyword3 = '';//found item from fashion
		Map<String, Object> mEntities = new Map<String, Object>();
		String entities = respLuis.getEntities();
		if (entities != null && entities != '')
		{
			mEntities = (Map<String, Object>) JSON.deserializeUntyped(respLuis.getEntities());
		}
		else
		{
			return;
		}

		if (mEntities.get('shops') != null)
			keyword1 = String.valueOf(((List<Object>) mEntities.get('shops'))[0]);
		if (mEntities.get('item') != null)
			keyword2 = String.valueOf(((List<Object>) mEntities.get('item'))[0]);
		if (mEntities.get('fashion men') != null)
			keyword3 = String.valueOf(((List<Object>) mEntities.get('fashion men'))[0]);
		else if (mEntities.get('fashion women') != null)
			keyword3 = String.valueOf(((List<Object>) mEntities.get('fashion women'))[0]);
		else if (mEntities.get('fashion kids') != null)
			keyword3 = String.valueOf(((List<Object>) mEntities.get('fashion kids'))[0]);

		if (keyword1 == keyword2)
		{
			keyword2 = '';
		}
		if (keyword1 == keyword3)
		{
			keyword3 = '';
		}
		if (keyword2 == keyword3)
		{
			keyword3 = '';
		}

		List<Search_Request__c> lIns = new List<Search_Request__c>();
		List<Search_Request__c> lUpd = new List<Search_Request__c>();
		// then, if we have keywords, log search requests

		if (keyword1 != '' && keyword1 != null)
		{ // shop request
			Search_Request__c SR = new Search_Request__c();
			List<Search_Request__c> lSearch = new List<Search_Request__c>();
			lSearch =
			[
					select Id, CVCH__Count__c, Name
					from Search_Request__c
					where Name = :keyword1
			];
			if (lSearch.isEmpty())
			{
				SR.Name = keyword1;
				SR.CVCH__Count__c = 1;
				lIns.add(SR);
			}
			else
			{
				SR = lSearch[0];
				SR.CVCH__Count__c++;
				lUpd.add(SR);
			}
		}

		if (keyword2 != '' && keyword2 != null)
		{ // item request
			Search_Request__c SR = new Search_Request__c();
			List<Search_Request__c> lSearch = new List<Search_Request__c>();
			lSearch =
			[
					select Id, CVCH__Count__c, Name
					from Search_Request__c
					where Name = :keyword2
			];
			if (lSearch.isEmpty())
			{
				SR.Name = keyword2;
				SR.CVCH__Count__c = 1;
				lIns.add(SR);
			}
			else
			{
				SR = lSearch[0];
				SR.CVCH__Count__c++;
				lUpd.add(SR);
			}
		}

		if (keyword3 != '' && keyword3 != null)
		{ // fashion item request
			Search_Request__c SR = new Search_Request__c();
			List<Search_Request__c> lSearch = new List<Search_Request__c>();
			lSearch =
			[
					select Id, CVCH__Count__c, Name
					from Search_Request__c
					where Name = :keyword3
			];
			if (lSearch.isEmpty())
			{
				SR.Name = keyword3;
				SR.CVCH__Count__c = 1;
				lIns.add(SR);
			}
			else
			{
				SR = lSearch[0];
				SR.CVCH__Count__c++;
				lUpd.add(SR);
			}
		}

		if (!lIns.isEmpty())
		{
			insert lIns;
		}
		if (!lUpd.isEmpty())
		{
			update lUpd;
		}
	}

//
//    public static string getParam(string sparamName)
//    {
//        string sRet = ApexPages.currentPage().getParameters().get(sParamName);
//        if (sRet == null)
//        {
//            sRet = '';
//        }
//        sRet = sRet.trim();
//        if(sRet == 'null')
//            sRet = '';
//        return sRet;
//    }
//
	public static String getRestParam(String sParamName)
	{
		String sRet = (String) RestContext.request.params.get(sParamName);
		if (sRet == null)
			sRet = '';
		sRet = sRet.trim();
		if (sRet == 'null' || sRet == 'empty')
			sRet = '';
		return sRet;
	}


//    public static string getValue(string sName)
//    {
//        CVCH__Values__c val = CVCH__Values__c.getInstance(sName);
//        if(val == null)
//        {
//            if(Test.isRunningTest())
//                return '';
//            throw new MyException('Can\'t find '+sName+' in Values custom settings. Please notify admin.');
//        }
//        return val.CVCH__Value__c;
//    }

	global static String getChat2aiValue(String sName)
	{
		CVCH__Chat2ai__c val = CVCH__Chat2ai__c.getInstance(sName);
		if (val == null)
		{
			if (Test.isRunningTest())
				return '';
			throw new MyException('Can\'t find ' + sName + ' in Chat2ai 2 custom settings. Please notify admin.');
		}
		return val.CVCH__Value__c;
	}

	public static Decimal getMinResponseScore()
	{
		Decimal dRet = 40;
		String sVal = SM010_Utils.getChat2aiValue2('Response minimum score');
		if (sVal != '')
		{
			dRet = Decimal.valueOf(sVal);
		}
		return dRet;
	}

	public static String getChat2aiValue2(String sName)
	{
		CVCH__Chat2ai__c val = CVCH__Chat2ai__c.getInstance(sName);
		if (val == null)
			return '';
		return val.CVCH__Value__c;
	}

/*    public static string getFlowId(string flowName,string programId, string language)
    {
        return translate(flowName, language, true);
    }
    
    public static string getRandom(integer len)
    {
        final string chars = '0123456789';
        string ret ='';
        while(ret.length()<len)
        {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            ret += chars.substring(idx,idx+1);
        }
        return ret;
    }
*/
	public static List< CVCH__Translation__c> lTrans = new List< CVCH__Translation__c>();
	public static void saveTran()
	{
		if (!lTrans.isEmpty())
		{
			insert lTrans;
			lTrans = new List< CVCH__Translation__c>();
		}
	}
	public static String sProgramId = null;
	public static String lang = null;
	public static String translate(String str)
	{
		return translate(str, lang, false);
	}
	public static String translate(String str, String sLang)
	{
		return translate(str, sLang, false);
	}
/*    public static string translateAPI(string str)
    {

        string sRet = null;
        string sKey = getKey(str);
        if(sKey.length()>254)
            return null;
        list<CVCH__Translation__c> sObj = [select Id, CVCH__key__c, CVCH__en__c from Translation__c where CVCH__key__c = :sKey and CVCH__API_Translation__c = true];

        if(!sObj.isEmpty())
        {
            CVCH__Translation__c tr = (CVCH__Translation__c)sObj[0];
            sRet = tr.CVCH__en__c;
        }
        return sRet;
    }
    public static void addTralslationAPI(string str, string en)
    {


        string sKey = getKey(str);
        if(sKey.length()>254)
            return;
        CVCH__Translation__c tr  = new CVCH__Translation__c();
        tr.CVCH__en__c = en;
        tr.CVCH__default_value__c = en;
        tr.CVCH__key__c = str;
        tr.CVCH__API_Translation__c = true;
        lTrans.add(tr);
    }
*/
	public static MTranslation translateAPI0(String str)
	{
		MTranslation tran = new MTranslation();
		if (str != null)
		{
			String sKey = getKey(str);
			if (sKey.length() > 254)
				return null;
			if (sKey != '')
			{
				List<Translation__c> sObj =
				[
						select Id, key__c, en__c, DetectedLang__c
						from Translation__c
						where key__c = :sKey and API_Translation__c = true
				];

				if (!sObj.isEmpty())
				{
					Translation__c tr = (Translation__c) sObj[0];
					tran.text = str;
					tran.detectedlang = tr.DetectedLang__c;
					tran.translation = tr.en__c;
				}
			}
		}
		return tran;
	}
	public static void addTranslationAPI0(MTranslation tran)
	{
		String sKey = getKey(tran.text);
		if (sKey.length() > 254)
			return;
		Translation__c tr = new Translation__c();
		tr.en__c = tran.translation;
		tr.default_value__c = tran.translation;
		tr.key__c = sKey;
		tr.API_Translation__c = true;
		tr.DetectedLang__c = tran.detectedlang;
		lTrans.add(tr);
	}
	public static String translate(String str, String sLang, Boolean bFlow)
	{
		if (sLang == null || sLang == '')
			sLang = 'en';

		// это не подходит потому что при появлении нового языка фактически надо править маппы в апексе, а это пользователь сам не сможет делать
		// , и по-этому если мы скажем ему что надо будет доплачивать за время разработчиков при появлении нового языка - клиент не поймет этого.
		//нужно сделать что-то типа такого. если будет несколько/много вызовов translate за один поток выполнения, то видимо надо добавить кеширование
		String sRet;
		String sFieldName = sLang + '__c';
		String sPrId = null;
		if (sProgramId != null)
			sPrId = sProgramId.trim();//'a067E0000072LnR';
		String sKey = getKey(str);

		String sQuery = 'select Id, key__c, default_value__c, ' + sFieldName + ' from Translation__c where key__c = \'' + sKey + '\' and bFlow__c = ' + bFlow;
//        if(sPrID != null)
//            sQuery = sQuery +' and Loy_Program__c =\''+sPrId+'\'';
		System.debug('translate.sQuery = ' + sQuery);
		List<SObject> sObj = Database.query(sQuery);
		CVCH__Translation__c tr;
		System.debug(sObj);
		if (sObj.isEmpty())
		{
			tr = new CVCH__Translation__c();
//            tr.Loy_Program__c = sPrId;
			tr.CVCH__key__c = sKey;

			tr.put(sFieldName, null);
			tr.CVCH__bFlow__c = bFlow;
			if (tr.CVCH__bFlow__c != true)
				tr.CVCH__default_value__c = str;
			lTrans.add(tr);
			//           insert tr;
			sObj.add(tr);
		}
		else
		{
			tr = (CVCH__Translation__c) sObj[0];
		}
		sRet = (String) tr.get(sFieldName);
		if (sRet == null || sRet == '')
		{
			if ((tr.CVCH__default_value__c != null && tr.CVCH__default_value__c != '') || Test.isRunningTest()) // для флоу, если нет перевода, берем значение по-умолчанию
				sRet = tr.CVCH__default_value__c;
			else
					throw new MyException('Can not find translation for [' + sKey + '] in program [' + sProgramId + ']');
		}
		if (str.startsWith(' '))
			sRet = ' ' + sRet;
		if (str.endsWith(' '))
			sRet = '' + sRet + ' ';
		return sRet;
	}

	public static String getKey(String str)
	{
//        string sKey =  str.replaceAll('[^a-zA-Z0-9 -]','').trim();
		String sKey = str.trim();
		if (sKey.length() > 254)
			sKey = sKey.substring(0, 253).trim();
		return sKey;
	}

	public static Map<String, String> translateBatch(Set<String>lTranslate, String sLang)
	{
		Map<String, String> mRet = new Map<String, String>();

		Set<String>sKeys = new Set<String>();

		String sFieldName = sLang + '__c';
		for (String str : lTranslate)
		{
			String sKey = getKey(str);
			sKeys.add(sKey);
		}
		Boolean bIns = SM010_Utils.getChat2aiValue2('Insert Translations') != 'FALSE';

		String sQuery = 'select Id, key__c, default_value__c, ' + sFieldName + ' from Translation__c where  key__c in :sKeys and bFlow__c = false';
		System.debug('translate.sQuery = ' + sQuery);
		List<SObject> sObj = Database.query(sQuery);
		Map<String, CVCH__Translation__c>mTr = new Map<String, CVCH__Translation__c>();
		for (SObject obj : sObj)
		{
			CVCH__Translation__c tr = (CVCH__Translation__c) obj;
			mTr.put(tr.CVCH__key__c, tr);
		}
		for (String str : lTranslate)
		{
			String sKey = getKey(str);
			CVCH__Translation__c tr = mTr.get(sKey);
			if (tr == null)
			{
				if (bIns)
				{
					tr = new CVCH__Translation__c();
//                tr.Loy_Program__c = sPrId;
					tr.CVCH__key__c = sKey;
					tr.put(sFieldName, null);
					tr.CVCH__bFlow__c = false;
					if (tr.CVCH__bFlow__c != true)
						tr.CVCH__default_value__c = str;
					lTrans.add(tr);
					//           insert tr;
					mTr.put(tr.CVCH__key__c, tr);
				}

			}
			else
			{
				String sRet = (String) tr.get(sFieldName);
				if (str.startsWith(' '))
					sRet = ' ' + sRet;
				if (str.endsWith(' '))
					sRet = '' + sRet + ' ';
				mRet.put(str, sRet);
			}
		}
		return mRet;
	}

	public static String phone(String sPhone)
	{
		if (sPhone == null)
			return null;
		sPhone = sPhone.replaceAll('[^0-9]', '');
		if (sPhone.indexOf('00') != 0)
		{
			if (sPhone.indexOf('0') != 0)
				sPhone = '00' + sPhone;
			else
					sPhone = '0' + sPhone;
		}
		return sPhone;
	}
/*
    public static decimal toCurr(string str)
    {
        decimal ret = null;
        system.debug('SM042_Utils.toCurr(' + str + ')');
        if (str == null || str == '')
            ret = null;

        else if (!str.substring(0, 1).isNumeric())
            return null; else
        {
            system.debug('toCurr:str=>' + str);
            system.debug('toCurr:length=>' + str.length());
            system.debug('toCurr:.=>' + str.lastIndexOf('.'));
            system.debug('toCurr:,=>' + str.lastIndexOf(','));
            integer iDiv = 1;
            if (str.contains('.'))
            {
                if (str.lastIndexOf('.') == str.length() - 3)
                    iDiv = 100; else if (str.lastIndexOf('.') == str.length() - 2)
                    iDiv = 10;
            }
            if (str.contains(','))
            {
                if (str.lastIndexOf(',') == str.length() - 3)
                    iDiv = 100;

                else if (str.lastIndexOf(',') == str.length() - 2)
                    iDiv = 10;
            }


            str = str.replace('.', '');
            str = str.replace(',', '');
            ret = (decimal.valueOf(str) / iDiv);
        }


        system.debug('SM042_Utils.toCurr(' + str + ')=>' + ret);
        return ret;
    }

    public static Object findValByRegExp(String sRegExp, List<String> listGroupedText, Integer iResultGroup, String returnType, String sConvertPattern){
        Object obj;
        Pattern myPattern = Pattern.compile(sRegExp);
        for(Integer i = 0; i < listGroupedText.size(); i++){
            try{
                String sTesting = listGroupedText[i].trim();
                String sTargetVal = findByRegExp( sTesting, myPattern, iResultGroup);
                if(sTargetVal != null){
                    switch on returnType{
                        when 'Integer' {
                            obj = sTargetVal.replaceAll('[^0-9]', '');
                        }
                        when 'Currency' {
                            obj = SM010_Utils.toCurr(sTargetVal.replaceAll('[ ]', ''));
                        }
                        when 'Date' {
                            obj = SM010_Utils.convertDate(sTargetVal, sConvertPattern);//'dd/MM/yyyy');
                        }
                        when else {
                            obj = sTargetVal;
                        }
                    }
                    System.debug('findValByRegExp.sTargetVal=>'+sTargetVal);
                    if(obj != null) {
                        break;
                    }
                }
            }
            catch(Exception e){
                System.debug('Error in findValByRegExp:' + e.getMessage());
                //throw e;
            }
        }
        return obj;
    }

    private static String findByRegExp(String sTesting, Pattern myPattern, Integer iResultGroup){
        String sResult;
        Matcher myMatcher = myPattern.matcher(sTesting);
        if(myMatcher.find()) {
            sResult = myMatcher.group(iResultGroup);
        }
		system.debug('findByRegExp=>'+sResult);
        return sResult;
    }
    public static Date findDate(String sTesting,String sMatchPattern, String sconvertPattern)
    {
        Date dt;
        //String sPattern = sMatchPattern;//'Date\\s*(\\d\\d\\/\\d\\d\\/\\d\\d\\d\\d)';
        Integer iResultGroup = 1;
		List<String> lStr = sTesting.split('\n');
        Pattern myPattern = Pattern.compile(sMatchPattern);
		for(String sStr: lStr) {
            try {
 				System.debug('findDate=>'+sStr);
                dt = SM010_Utils.convertDate(findByRegExp(sStr, myPattern, iResultGroup), sconvertPattern);//'dd/MM/yyyy');
                if(dt != null) {
                    return dt;
                }
            }
            catch(Exception e){
                System.debug('findDate error: '+e.getMessage());
            }

        }
		return dt;
    }
    */
    /**
	 * @param sName
	 *
	 * @return converted date
	 */
	/*
	public static Date convertDate(String sDate, String sPattern){
		system.debug('convertDate('+sDate+','+sPattern+')');
		if(sDate == null || sPattern == null){
			return null;
		}
		Date ret = null;
		try
		{


			//      system.debug('convertDate=>'+sDate+' '+sPattern);
			Map<String, Integer> mapMonthNumByName = new Map<String, Integer>{
					'January' => 1,
					'February' => 2,
					'March' => 3,
					'April' => 4,
					'May' => 5,
					'June' => 6,
					'July' => 7,
					'August' => 8,
					'September' => 9,
					'October' => 10,
					'November' => 11,
					'December' => 12
			};
			Map<String, Integer> mapMonthNumByShortName = new Map<String, Integer>{
					'Jan' => 1,
					'Feb' => 2,
					'Mar' => 3,
					'Apr' => 4,
					'May' => 5,
					'Jun' => 6,
					'Jul' => 7,
					'Aug' => 8,
					'Sep' => 9,
					'Oct' => 10,
					'Nov' => 11,
					'Dec' => 12
			};



			String sYear = '';
			String sMonth = '';
			String sDay = '';

			List<String> listPattern = getListPattern(sPattern);

			for (Integer i = 0; i < listPattern.size(); i++) {
				String sPatternVal = listPattern[i];
				switch on sPatternVal {
					when 'd'{
						Integer iEndChar;
						if(i >= listPattern.size() - 1){
							iEndChar = sDate.length();
						}
						else{
							iEndChar = indexOfPattern( sDate, listPattern[i+1]); //sDate.indexOf(listPattern[i+1]);
						}
						sDay = sDate.left(iEndChar);
						sDate = sDate.right(sDate.length() - iEndChar);
					}
					when 'dd'{
						sDay = sDate.left(sPatternVal.length());
						sDate = sDate.right(sDate.length() - sPatternVal.length());
					}
					when 'M'{
						Integer iEndChar;
						if(i >= listPattern.size() - 1){
							iEndChar = sDate.length();
						}
						else{
							iEndChar = indexOfPattern( sDate, listPattern[i+1]); //sDate.indexOf(listPattern[i+1]);
						}
						System.debug('M: iEndChar:' + iEndChar);
						System.debug('M: sDate:' + sDate);

						sMonth = sDate.left(iEndChar);
						sDate = sDate.right(sDate.length() - iEndChar);
					}
					when 'MM'{
						sMonth = sDate.left(sPatternVal.length());
						sDate = sDate.right(sDate.length() - sPatternVal.length());
					}
					when 'MMM'{
						sMonth = String.valueOf(mapMonthNumByShortName.get(sDate.left(sPatternVal.length())));
						sDate = sDate.right(sDate.length() - sPatternVal.length());
					}
					when 'MMMMM'{
						Integer iEndCharOfMonth;
						if(i >= listPattern.size() - 1){
							iEndCharOfMonth = sDate.length();
						}
						else{
							iEndCharOfMonth = indexOfPattern( sDate, listPattern[i+1]); //sDate.indexOf(listPattern[i+1]);
						}
						sMonth = String.valueOf(mapMonthNumByName.get(sDate.left( iEndCharOfMonth )));
						sDate = sDate.right(sDate.length() - iEndCharOfMonth);
					}
					when 'yyyy'{
						sYear = sDate.left(sPatternVal.length());
						sDate = sDate.right(sDate.length() - sPatternVal.length());
					}
					when 'yy'{
						sYear = sDate.left(sPatternVal.length());
						if(Integer.valueOf(sYear)>1900)
						{

						}
						else if(Integer.valueOf(sYear) > 50){
							sYear = '19' + sYear;
						}
						else{
							sYear = '20' + sYear;
						}
						sDate = sDate.right(sDate.length() - sPatternVal.length());
					}
					when else{
						sDate = sDate.right(sDate.length() - sPatternVal.length());
					}
				}

			}

			system.debug('convertDate ret=>'+sDay+'-'+sMonth+'-'+sYear);
			System.debug('sDay:' + sDay);
			System.debug('sMonth:' + sMonth);
			System.debug('sYear:' + sYear);
			if(Integer.valueOf(sMonth) > 12 || Integer.valueOf(sDay) > 31 ){
				throw new MyException('Conversion pattern \'' + sPattern + '\' cannot be used for date ' + sDate);
			}
			ret = Date.newInstance(Integer.valueOf(sYear), Integer.valueOf(sMonth), Integer.valueOf(sDay));
			system.debug('ret=>'+ret);
		}catch(exception e)
		{
			system.debug('error.convertDate('+sDate+','+sPattern+')=>'+e.getStackTraceString()+e.getMessage());
			throw e;
		}
		return ret;
	}

	private static Integer indexOfPattern(String sText, String sTextToSearch){
		List<String> listChars = new List<String>{
				'-',
				'/',
				'.',
				' '
		};
		if (sTextToSearch == '?') {
			for (String str : listChars) {
				Integer i = sText.indexOf(str);
				if(i > -1){
					return i;
				}
			}
		}
		else {
			return sText.indexOf(sTextToSearch);
		}
		return -1;
	}

	private static List<String> getListPattern(String sPattern) {
		String sDaySign = 'd';
		String sMonthSign = 'M';
		String sYearSign = 'y';

		List<String> listPattern = new List<String>();
		for (Integer i = 0; i < sPattern.length(); i++) {
			String sPatternChar = sPattern.substring(i, i + 1);
			if (sPatternChar.equals(sDaySign)) {
				if (!listPattern.isEmpty() && listPattern[listPattern.size() - 1].contains(sDaySign)) {
					listPattern[listPattern.size() - 1] += sDaySign;
				} else {
					listPattern.add(sDaySign);
				}
				continue;
			}
			if (sPatternChar.equals(sMonthSign)) {
				if (!listPattern.isEmpty() && listPattern[listPattern.size() - 1].contains(sMonthSign)) {
					listPattern[listPattern.size() - 1] += sMonthSign;
				} else {
					listPattern.add(sMonthSign);
				}
				continue;
			}
			if (sPatternChar.equals(sYearSign)) {
				if (!listPattern.isEmpty() && listPattern[listPattern.size() - 1].contains(sYearSign)) {
					listPattern[listPattern.size() - 1] += sYearSign;
				} else {
					listPattern.add(sYearSign);
				}
				continue;
			}
			listPattern.add(sPatternChar);
		}
		System.debug('listPattern:' + listPattern);
		return listPattern;
	}
	public static map<string,string> toChat2ai(object o)
	{
		map<string,string>mRet = new map<string,string>();
		map<string,object> mTemp = (map<string,object>)JSON.deserializeUntyped(JSON.serialize(o));
		for(string sFld : mTemp.keySet())
		{
			string sVal = 'none';
			object oVal = mTemp.get(sFld);
			if(oVal != null)
			{
				sVal = ''+oVal;
			}
			mRet.put('sf_'+sFld,sVal);
		}

		return mRet;

	}
*/

	public static String encodeId(String sName)
	{
		Long int1 = Long.valueOf('1' + sName.substring(4));
		return toAlpha(int1);
	}

	public static String decodeId(String sEncoded, String prefix)
	{
		String str = '' + toInt(sEncoded);
		return prefix + str.substring(1);
	}

	static String sStr = 'QWERTYUIPASDFGHJKLZXCVBNM123456789';
	public static String toAlpha(Long d)
	{
		String sRet = '';
		Long left = d;
		Integer len = sStr.length();
		System.debug('len=' + len);
		while (left > 0)
		{
			Integer curDigit = Integer.valueOf(Math.mod(left, len));
			//		system.debug('curDigit='+curDigit);
			String sadd = sStr.substring(curDigit, curDigit + 1);
			//		system.debug('sadd='+sadd);
			sRet = sRet + sadd;
			left = Integer.valueOf(Math.floor(left / len));
		}
		return sRet;
	}

	public static Long toInt(String str)
	{
		Integer len = sStr.length();

		Long ret = 0;
		Integer strLen = str.length();
		for (Integer i = 0; i < strLen; i++)
		{
			String sChar = str.substring(str.length() - i - 1, str.length() - i);
			//		system.debug(sChar);
			Integer idx = sStr.indexOf(sChar);
			//		system.debug(idx);
			ret *= len;
			ret += idx;
		}
		return ret;
	}

	public static Flow.Interview getFlow(String sFlowName, String sTo, Map<String, Object> params)
	{
		Flow.Interview ret;
		if (SM010_Utils.getChat2aiValue2('Multi ChatBots') == 'TRUE' && sTo != null && sTo != '')
		{
			sFlowName = sFlowName + '_' + sTo;
		}
		try
		{
			ret = Flow.Interview.createInterview(sFlowName, params);
		}
		catch (Exception e)
		{
			throw new MyException('Can not find the flow \'' + sFlowName + '\'');
		}
		return ret;
	}
}
