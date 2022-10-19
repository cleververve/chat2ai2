global class SM005_Logs
{
    public static List<CVCH__CallOut__c>lLog = new List<CVCH__CallOut__c> ();
    public static CVCH__CallOut__c LogCallOut(String recordId,String callType, String reqBody, String respBody, Datetime dtBeg, Datetime dtEnd,String sErrorMessage,String sURL, String sAuth, Map<String,String> headers, String sMethod)
    {
        return LogCallOut(recordId,callType, reqBody, respBody, dtBeg, dtEnd, sErrorMessage, sURL,sAuth,null,null,headers, sMethod);
    }
            public static CVCH__CallOut__c LogCallOut(String recordId,String callType, String reqBody, String respBody, Datetime dtBeg, Datetime dtEnd,String sErrorMessage,String sURL, String sAuth)
        {
            return LogCallOut(recordId,callType, reqBody, respBody, dtBeg, dtEnd, sErrorMessage, sURL,sAuth,null,null, null, null);
        }
        public static CVCH__CallOut__c LogCallOut(String recordId,String callType, String reqBody, String respBody, Datetime dtBeg, Datetime dtEnd,String sErrorMessage)
        {
            return LogCallOut(recordId,callType, reqBody, respBody, dtBeg, dtEnd, sErrorMessage, null,null,null,null,null,null);
        }
    public static CVCH__CallOut__c LogCallOut(String recordId,String callType, String reqBody, String respBody, Datetime dtBeg, Datetime dtEnd,String sErrorMessage,String sURL, String sAuth,String reqBody2)
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
    
    public static CVCH__CallOut__c LogCallOut(String recordId,String callType, String reqBody, String respBody, Datetime dtBeg, Datetime dtEnd,String sErrorMessage,String sURL, String sAuth,String reqBody2, String respBody2, Map<String,String> headers, String sMethod)
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
        c.CVCH__ResponseId__c = getResponseId(respBody);
		add(c);
        return c;
//        insert  c;       
    }
    public static String getResponseId (String respBody)
    {
        String sRet = null;

        if(respBody != null)
        {
            try
            {
                Object o = JSON.deserializeUntyped(respBody);

                String uuid = (String)JPath.safeGet(o,'/message_uuid');
                if(uuid == null || uuid == '')
                {
                    System.debug('getResponseId');
                    System.debug(o);
                    uuid = (String)JPath.safeGet(o,'/messages[1]/id');
                }
                if(uuid != '' && uuid != null)
                {
                    sRet = uuid;
                }
            }catch(Exception e)
            {}
        }
        return sRet;
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
            lLog =  new List<CVCH__CallOut__c> ();
        }
    }
}
