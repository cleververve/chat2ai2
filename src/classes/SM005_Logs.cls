global class SM005_Logs
{
    public static list<CVCH__CallOut__c>lLog = new list<CVCH__CallOut__c> ();
    public static CVCH__CallOut__c LogCallOut(string recordId,string callType, string reqBody, string respBody, datetime dtBeg, datetime dtEnd,string sErrorMessage,string sURL, string sAuth, map<string,string> headers, string sMethod)
    {
        return LogCallOut(recordId,callType, reqBody, respBody, dtBeg, dtEnd, sErrorMessage, sURL,sAuth,null,null,headers, sMethod);
    }
            public static CVCH__CallOut__c LogCallOut(string recordId,string callType, string reqBody, string respBody, datetime dtBeg, datetime dtEnd,string sErrorMessage,string sURL, string sAuth)
        {
            return LogCallOut(recordId,callType, reqBody, respBody, dtBeg, dtEnd, sErrorMessage, sURL,sAuth,null,null, null, null);
        }
        public static CVCH__CallOut__c LogCallOut(string recordId,string callType, string reqBody, string respBody, datetime dtBeg, datetime dtEnd,string sErrorMessage)
        {
            return LogCallOut(recordId,callType, reqBody, respBody, dtBeg, dtEnd, sErrorMessage, null,null,null,null,null,null);
        }
    public static CVCH__CallOut__c LogCallOut(string recordId,string callType, string reqBody, string respBody, datetime dtBeg, datetime dtEnd,string sErrorMessage,string sURL, string sAuth,string reqBody2)
    {
        return LogCallOut(recordId,callType, reqBody, respBody, dtBeg, dtEnd, sErrorMessage, sURL,sAuth,reqBody2,null, null,null);
    }


    /**
 * @author: SEV@3cconsult.dk
 * @date: 2016-11-21
 * @param: recordId - associated record id or empty string,callType - callout type, reqBody - request body, respBody - response body, dtBeg - begin datetime, dtEnd - end date time, sErrorMessage - error message or empty string
 * @functionality: that method creates callout__c record for web service callouts
 * @bizpurpose: ---
 * @changelog: ---
 * @return: ---
 * */
    
    public static CVCH__CallOut__c LogCallOut(string recordId,string callType, string reqBody, string respBody, datetime dtBeg, datetime dtEnd,string sErrorMessage,string sURL, string sAuth,string reqBody2, string respBody2, map<string,string> headers, string sMethod)
    {
        CVCH__CallOut__c c = new CVCH__CallOut__c();
        if(dtBeg != null && dtEnd != null)
        {
            c.CVCH__StartTime__c = dtBeg;
            c.CVCH__EndTime__c = dtEnd;
            c.CVCH__Duration__c = (dtEnd.getTime() - dtBeg.getTime());
        }
        c.CVCH__Record_Id__c  = recordId;
        c.CVCH__Type__c = callType;
        c.CVCH__headers__c = JSON.serialize(headers);
        c.CVCH__Method__c = sMethod;

        if(reqBody != null && reqBody.length()>131050)
            reqBody = reqBody.substring(0,131050);

        c.CVCH__Request__c =reqBody;
        if(reqBody2 != null && reqBody2.length()>131050)
            reqBody2 = reqBody2.substring(0,131050);
         c.CVCH__Request2__c =reqBody2;
        if(sErrorMessage != null && sErrorMessage.length()>254)
            sErrorMessage = sErrorMessage.substring(0, 253);
        if(sErrorMessage != null && sErrorMessage != '')
            c.CVCH__Status__c = 'Error';
        else
            c.CVCH__Status__c = 'Success';
        c.CVCH__ErrorMessage__c = sErrorMessage;
        
        if(respBody != null && respBody.length()>131050)
            respBody = respBody.substring(0,131050);
        c.CVCH__Response__c = respBody;
        if(respBody2 != null && respBody2.length()>131050)
            respBody2 = respBody2.substring(0,131050);
        c.CVCH__Response2__c = respBody2;
        if(sURL != null && sURL.length()>255)
            sURL = sURL.substring(255);
        c.CVCH__URL__c = sURL;
        c.CVCH__Authorization__c = sAuth;

        
		add(c);
        return c;
//        insert  c;       
    }
    
    
    public static void add(CVCH__CallOut__c c)
    {
        lLog.add(c);
    }
    
    global static void save()
    {
        if(!lLog.isEmpty())
        {
            Database.insert(lLog,false);
            lLog =  new list<CVCH__CallOut__c> ();
        }
    }
}
