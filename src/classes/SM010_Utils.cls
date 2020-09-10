public class SM010_Utils 
{

    public class pageReturn
    {
        public list<object>lObj = new list<object>();
        public boolean bEnd = true;
        public boolean bBegin = true;
    }

    public static pageReturn getPage(list<object>lObj,integer iTab, integer iSize,boolean bReserveSlotForPrev, boolean bReserveSlotForNext)
    {

        pageReturn ret = new pageReturn();

        if (lObj.size() <= iSize && Test.isRunningTest() == false)
            ret.lObj = lObj;
        else
        {
            integer iBegin;
            integer iCurSize = iSize;

            integer iBeginSize = iSize;
            integer iMidSize = iSize;
            integer iEndSize = iSize;
            if(bReserveSlotForPrev)
            {
                iMidsize-=1;
                iEndSize -=1;
            }
            if(bReserveSlotForNext)
            {
                iMidsize-=1;
                iBeginSize -=1;
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
                decimal dMidSize = lObj.size()-iBeginSize;

                decimal iMidCnt =  dMidSize / iMidSize ; //длина массива минус длина первого пейджа деленная на длину среднего пейджа
                system.debug('iMidCnt='+iMidCnt);
                integer nTabs = Integer.valueOf(Math.ceil(iMidCnt))+1;

                System.debug('lObj.size='+lObj.size()+', iBeginSize='+iBeginSize+',nTabs='+nTabs+',iMidSize='+iMidSize);
                if((lObj.size() -(iBeginSize +(nTabs-2)*iMidSize)==1)// если в последнем пейдже - всего один элемент
                        && bReserveSlotForNext // и есть зарезервированное место под кнопку Next
                        )
                    nTabs-=1; // тогда уменьшим к-во табов, потому что вместо кнопки Next мы покажем последний элемент

                if(iTab>=nTabs-1)
                {
                    iTab = nTabs -1;
                    iCurSize = iEndSize;
                }
                else
                {
                    iCurSize = iMidSize;
                    ret.bEnd = false;
                }

                iBegin = iBeginSize+ (iTab-1 )* iMidSize ;
            }

            system.debug('iCurSize =' + iCurSize + ' iBegin=' + iBegin + ' lAcc.size()=' + lObj.size());
            for (integer i = 0; i < iCurSize && (iBegin + i < lObj.size()); i++)
            {
                object m = lObj[iBegin + i];
                ret.lObj.add(m);
            }
        }
        system.debug('getPage('+iTab+')='+ret);
        return ret;
    }

    public static void insertConversation(decimal scoreLUIS, decimal scoreQnA, string intentLUIS, string triggeredFlow, string language, string phone, string input, string output, id visitorId, string errMsg)
    {
        Conversation__c conv = new Conversation__c();
        try
        {
            if (scoreLUIS > scoreQnA)
            {
                conv.NLP__c = 'LUIS';
                conv.score__c = scoreLUIS;
                conv.intent__c = intentLUIS;
            }
            else
            {
                conv.NLP__c = 'QnA';
                conv.score__c = scoreQnA;
            }
            conv.language__c = language;
            conv.phone__c = phone;
            conv.Error__c = errMsg;
            conv.output__c = output;
            if (input != null && input.length() > 32000)
                input = input.substring(0, 32000);
            conv.input__c = input;
            if (input != null && input.length() > 255)
                input = input.substring(0,255);
            conv.Input2__c = input;
            conv.visitor__c = visitorId;
            conv.triggered_flow__c= triggeredflow;
            insert conv;
        }
        catch(Exception e){
            return;
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
//    public static string getRestParam(string sParamName)
//    {
//        string sRet = (string)RestContext.request.params.get(sParamName);
//        if(sRet == null)
//            sRet = '';
//        sRet = sRet.trim();
//        if(sRet == 'null' || sRet == 'empty')
//            sRet = '';
//        return sRet;
//    }


    public static string getValue(string sName)
    {
        CVCH__Values__c val = CVCH__Values__c.getInstance(sName);
        if(val == null)
        {
            if(Test.isRunningTest())
                return '';
            throw new MyException('Can\'t find '+sName+' in Values custom settings. Please notify admin.');
        }
        return val.CVCH__Value__c;
    }
    
    public static string getChat2aiValue(string sName)
    {
        CVCH__Chat2ai__c val = CVCH__Chat2ai__c.getInstance(sName);
        if(val == null)
        {
            if(Test.isRunningTest())
                return '';
            throw new MyException('Can\'t find '+sName+' in Chat2ai 2 custom settings. Please notify admin.');
        }
        return val.CVCH__Value__c;
    }

    public static string getChat2aiValue2(string sName)
    {
        CVCH__Chat2ai__c val = CVCH__Chat2ai__c.getInstance(sName);
        if(val == null)
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
    public static list< CVCH__Translation__c> lTrans = new list< CVCH__Translation__c>();
    public static void saveTran()
    {
        if(!lTrans.isEmpty())
        {
            insert lTrans;
            lTrans = new list< CVCH__Translation__c>();
        }
    }
    public static string sProgramId=null; 
	public static string lang=null;    
    public static string translate(string str)
    {
        return translate(str,lang,false);
    }    
    public static string translate(string str, string sLang)
    {
        return translate(str,sLang,false);
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
    public static MTranslation translateAPI0(string str)
    {
        MTranslation tran = new MTranslation();
        
        string sKey = getKey(str);
        if(sKey.length()>254)
            return null;
        list<Translation__c> sObj = [select Id, key__c, en__c, DetectedLang__c from Translation__c where key__c = :sKey and API_Translation__c = true];

        if(!sObj.isEmpty())
        {
            Translation__c tr = (Translation__c)sObj[0];
            tran.text = str;
            tran.detectedlang = tr.DetectedLang__c;
            tran.translation = tr.en__c;
        }
        
        return tran;
    }
    public static void addTranslationAPI0(MTranslation tran)
    {
        string sKey = getKey(tran.text);
        if(sKey.length()>254)
            return;
        Translation__c tr  = new Translation__c();
        tr.en__c = tran.translation;
        tr.default_value__c = tran.translation;
        tr.key__c = tran.text;
        tr.API_Translation__c = true;
        tr.DetectedLang__c = tran.detectedlang;
        lTrans.add(tr);
    }
    public static string translate(string str, string sLang,boolean bFlow)
    {
        if(sLang == null || sLang == '')
            sLang = 'en';

        // это не подходит потому что при появлении нового языка фактически надо править маппы в апексе, а это пользователь сам не сможет делать
        // , и по-этому если мы скажем ему что надо будет доплачивать за время разработчиков при появлении нового языка - клиент не поймет этого.
        //нужно сделать что-то типа такого. если будет несколько/много вызовов translate за один поток выполнения, то видимо надо добавить кеширование
        string sRet;
        string sFieldName = sLang+'__c';
        string sPrId =null;
        if(sProgramId != null)
            sPrId = sProgramId.trim();//'a067E0000072LnR';
        string sKey = getKey(str);

        string sQuery = 'select Id, key__c, default_value__c, '+sFieldName+' from Translation__c where key__c = \''+sKey+'\' and bFlow__c = '+bFlow;
//        if(sPrID != null)
//            sQuery = sQuery +' and Loy_Program__c =\''+sPrId+'\'';
        system.debug('translate.sQuery = '+sQuery);
        list<sobject> sObj = Database.query(sQuery);
        CVCH__Translation__c tr;
        system.debug(sObj);
        if(sObj.isEmpty())
        {
            tr = new CVCH__Translation__c();
//            tr.Loy_Program__c = sPrId;
            tr.CVCH__key__c = sKey;

            tr.put(sFieldName,null);
            tr.CVCH__bFlow__c = bFlow;
            if(tr.CVCH__bFlow__c != true)
                tr.CVCH__default_value__c = str;
            lTrans.add(tr);
 //           insert tr;
            sObj.add(tr);
        }
        else
        {
            tr = (CVCH__Translation__c)sObj[0];
        }
        sRet = (string)tr.get(sFieldName);
        if(sRet == null || sRet == '')
        {
            if((tr.CVCH__default_value__c != null && tr.CVCH__default_value__c != '' )|| Test.isRunningTest()) // для флоу, если нет перевода, берем значение по-умолчанию
                sRet = tr.CVCH__default_value__c;
            else
                throw new MyException('Can not find translation for ['+sKey+'] in program ['+sProgramId+']');
        }
        if(str.startsWith(' '))
            sRet = ' '+sRet;
        if(str.endsWith(' '))
            sRet = ''+sret+' ';
        return sRet;
    }

    public static string getKey(string str)
    {
        string sKey =  str.replaceAll('[^a-zA-Z0-9 -]','').trim();
        if(sKey.length()>254)
            sKey = sKey.substring(0,253).trim();

        return sKey;
    }

    public static map<string,string> translateBatch( set<string>lTranslate, string sLang)
    {
        map<string,string> mRet = new map<string,string>();

        set<string>sKeys = new set<string>();

        string sFieldName = sLang+'__c';
        for(string str : lTranslate)
        {
            string sKey = getKey(str);
            sKeys.add(sKey);
        }
        Boolean bIns = SM010_Utils.getValue('Insert Translations') == 'TRUE';

        string sQuery = 'select Id, key__c, default_value__c, '+sFieldName+' from Translation__c where  key__c in :sKeys and bFlow__c = false';
        system.debug('translate.sQuery = '+sQuery);
        list<sobject> sObj = Database.query(sQuery);
        map<string,CVCH__Translation__c>mTr = new map<string,CVCH__Translation__c>();
        for(sobject obj: sObj)
        {
            CVCH__Translation__c tr = (CVCH__Translation__c)obj;
            mTr.put(tr.CVCH__key__c,tr);
        }
        for(string str : lTranslate)
        {
            string sKey = getKey(str);
            CVCH__Translation__c tr = mTr.get(sKey);
            if(tr == null)
            {
                if(bIns)
                {
                    tr = new CVCH__Translation__c();
//                tr.Loy_Program__c = sPrId;
                    tr.CVCH__key__c = sKey;
                    tr.put(sFieldName,null);
                    tr.CVCH__bFlow__c = false;
                    if(tr.CVCH__bFlow__c != true)
                        tr.CVCH__default_value__c = str;
                    lTrans.add(tr);
                    //           insert tr;
                    mTr.put(tr.CVCH__key__c,tr);
                }

            }
            else
            {
                string sRet = (string)tr.get(sFieldName);
                if(str.startsWith(' '))
                    sRet = ' '+sRet;
                if(str.endsWith(' '))
                    sRet = ''+sret+' ';
                mRet.put(str,sRet);
            }
        }
        return mRet;
    }

    public static string phone(string sPhone)
    {
        if(sPhone == null)
            return null;
        sPhone = sPhone.replaceAll('[^0-9]', '');
        if(sPhone.indexOf('00')!=0)
        {
            if(sPhone.indexOf('0')!= 0)
                sPhone = '00'+sPhone;
            else
                sPhone = '0'+sPhone;                
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
 *
 *
 * @param sDate: String to convert (eg. 12-31-2020)
 * @param sPattern: Syntax:
 *                  y	Year (e.g. 12 or 2012). Use either yy or yyyy.
 *                  M	Month in year. Number of M's determine length of format. Use M, MM, MMM or MMMMM
 *                  d	Day in month. Number of d's determine length of format Use either d or dd
 *          Eg. 'dd-MM-yyyy'
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
}
