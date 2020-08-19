public class SM005_Logs 
{
    public static list<CallOut__c>lLog = new list<CallOut__c> ();
            public static CallOut__c LogCallOut(string recordId,string callType, string reqBody, string respBody, datetime dtBeg, datetime dtEnd,string sErrorMessage,string sURL, string sAuth)
        {
            return LogCallOut(recordId,callType, reqBody, respBody, dtBeg, dtEnd, sErrorMessage, sURL,sAuth,null,null);
        }
        public static CallOut__c LogCallOut(string recordId,string callType, string reqBody, string respBody, datetime dtBeg, datetime dtEnd,string sErrorMessage)
        {
            return LogCallOut(recordId,callType, reqBody, respBody, dtBeg, dtEnd, sErrorMessage, null,null,null,null);
        }
    public static CallOut__c LogCallOut(string recordId,string callType, string reqBody, string respBody, datetime dtBeg, datetime dtEnd,string sErrorMessage,string sURL, string sAuth,string reqBody2)
    {
        return LogCallOut(recordId,callType, reqBody, respBody, dtBeg, dtEnd, sErrorMessage, sURL,sAuth,reqBody2,null);
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
    
    public static CallOut__c LogCallOut(string recordId,string callType, string reqBody, string respBody, datetime dtBeg, datetime dtEnd,string sErrorMessage,string sURL, string sAuth,string reqBody2, string respBody2)
    {
        CallOut__c c = new CallOut__c();
        if(dtBeg != null && dtEnd != null)
        {
            c.StartTime__c = dtBeg;
            c.EndTime__c = dtEnd;
            c.Duration__c = (dtEnd.getTime() - dtBeg.getTime());
        }
        c.Record_Id__c  = recordId;
        c.Type__c = callType;
        if(reqBody != null && reqBody.length()>131050)
            reqBody = reqBody.substring(0,131050);

        c.Request__c =reqBody;
        if(reqBody2 != null && reqBody2.length()>131050)
            reqBody2 = reqBody2.substring(0,131050);
         c.Request2__c =reqBody2;       
        if(sErrorMessage != null && sErrorMessage.length()>254)
            sErrorMessage = sErrorMessage.substring(0, 253);
        if(sErrorMessage != null && sErrorMessage != '')
            c.Status__c = 'Error'; 
        else
            c.Status__c = 'Success';                 
        c.ErrorMessage__c = sErrorMessage;         
        
        if(respBody != null && respBody.length()>131050)
            respBody = respBody.substring(0,131050);
        c.Response__c = respBody;
        if(respBody2 != null && respBody2.length()>131050)
            respBody2 = respBody2.substring(0,131050);
        c.Response2__c = respBody2;
        if(sURL != null && sURL.length()>255)
            sURL = sURL.substring(255);
        c.URL__c = sURL;
        c.Authorization__c = sAuth;

        
		add(c);
        return c;
//        insert  c;       
    }
    
    
    public static void add(CallOut__c c)
    {
        lLog.add(c);
    }
    
    public static void save()
    {
        if(!lLog.isEmpty())
        {
            insert lLog;
            lLog =  new list<CallOut__c> ();
        }
    }
    
}