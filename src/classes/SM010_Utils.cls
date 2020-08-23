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

    public static string getParam(string sparamName)
    {
        string sRet = ApexPages.currentPage().getParameters().get(sParamName);
        if (sRet == null)
        {
            sRet = '';
        }
        sRet = sRet.trim();
        if(sRet == 'null')
            sRet = '';
        return sRet;
    }

    public static string getRestParam(string sParamName)
    {
        string sRet = (string)RestContext.request.params.get(sParamName);
        if(sRet == null)
            sRet = '';
        sRet = sRet.trim();
        if(sRet == 'null' || sRet == 'empty')
            sRet = '';
        return sRet;
    }

    public static string getValue(string sName)
    {
        Values__c val = Values__c.getInstance(sName);
        if(val == null)
        {
            if(Test.isRunningTest())
                return '';
            throw new MyException('Can\'t find '+sName+' in Values custom settings. Please notify admin.');
        }
        return val.Value__c;
    }

    public static list< Translation__c> lTrans = new list< Translation__c>();
    public static void saveTran()
    {
        if(!lTrans.isEmpty())
        {
            insert lTrans;
            lTrans = new list< Translation__c>();
        }
    }
    public static string sProgramId=null; 
	public static string lang=null;    

    public static string translate(string str, string sLang)
    {
        return translate(str,sLang,false);
    }
    public static string translateAPI(string str)
    {

        string sRet = null;
        string sKey = getKey(str);
        if(sKey.length()>254)
            return null;
        list<Translation__c> sObj = [select Id, key__c, en__c from Translation__c where key__c = :sKey and API_Translation__c = true];

        if(!sObj.isEmpty())
        {
            Translation__c tr = (Translation__c)sObj[0];
            sRet = tr.en__c;
        }
        return sRet;
    }
    public static void addTralslationAPI(string str, string en)
    {


        string sKey = getKey(str);
        if(sKey.length()>254)
            return;
        Translation__c tr  = new Translation__c();
        tr.en__c = en;
        tr.default_value__c = en;
        tr.key__c = str;
        tr.API_Translation__c = true;
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
        Translation__c tr;
        system.debug(sObj);
        if(sObj.isEmpty())
        {
            tr = new Translation__c();         
//            tr.Loy_Program__c = sPrId;
            tr.key__c = sKey;

            tr.put(sFieldName,null);
            tr.bFlow__c = bFlow;
            if(tr.bFlow__c != true)
                tr.default_value__c = str;
            lTrans.add(tr);
 //           insert tr;
            sObj.add(tr);
        }
        else
        {
            tr = (Translation__c)sObj[0];
        }
        sRet = (string)tr.get(sFieldName);
        if(sRet == null || sRet == '')
        {
            if((tr.default_value__c != null && tr.default_value__c != '' )|| Test.isRunningTest()) // для флоу, если нет перевода, берем значение по-умолчанию
                sRet = tr.default_value__c;
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
        map<string,Translation__c>mTr = new map<string,Translation__c>();
        for(sobject obj: sObj)
        {
            Translation__c tr = (Translation__c)obj;
            mTr.put(tr.key__c,tr);
        }
        for(string str : lTranslate)
        {
            string sKey = getKey(str);
            Translation__c tr = mTr.get(sKey);
            if(tr == null)
            {
                if(bIns)
                {
                    tr = new Translation__c();
//                tr.Loy_Program__c = sPrId;
                    tr.key__c = sKey;
                    tr.put(sFieldName,null);
                    tr.bFlow__c = false;
                    if(tr.bFlow__c != true)
                        tr.default_value__c = str;
                    lTrans.add(tr);
                    //           insert tr;
                    mTr.put(tr.key__c,tr);
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
}
