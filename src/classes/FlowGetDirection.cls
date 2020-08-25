global class FlowGetDirection {
    
	global class FlowInput
	{
		/*moved*/@AuraEnabled @InvocableVariable global id visitorId;
        /*moved*/@AuraEnabled @InvocableVariable global string location;
        /*moved*/@AuraEnabled @InvocableVariable global string type;
        /*moved*/@AuraEnabled @InvocableVariable global string programId;
        /*moved*/@AuraEnabled @InvocableVariable global string sLang;
        /*moved*/@AuraEnabled @InvocableVariable global string entities;
	}

    /*moved*/@InvocableMethod(label='old do not use' description='Takes current/desired location and gives link to the google maps')
	global static void send(list<FlowInput> lParam)
	{
        system.debug('FlowGetDirection.start');
        list<string>lret = new list<string>();
        set<id>sids = new set<id>();
        
        for(FlowInput inp: lParam)
        {
        	sids.add((id)inp.visitorId);
        }
        
        map<id,CVCH__Visitor__c> mVis = new map<id,CVCH__Visitor__c>(DM080_Visitor.getRecords(sids));
        
        for(FlowInput inp: lParam)
		{
            CVCH__Visitor__c vis = mVis.get((id)inp.visitorId);
            
            Map<string,object> mEntities = new map<string,object>();
            if (inp.entities != null && inp.entities != '')
            {
                mEntities = (Map<string,object>)JSON.deserializeUntyped(inp.entities);
                system.debug(mEntities);
             	if (mEntities.get('shops') != null)
                {
                    inp.location = String.valueOf(((list<object>)mEntities.get('shops'))[0]);
                    inp.type = 'get FROMID';
                }
                             
            }
            if(inp.type == 'get TOID')
            {
                system.debug('type = get TOID');
                SM042_NexmoOut2.sendText(vis.CVCH__Id__c,SM010_Utils.translate('Please enter your desired location',vis.CVCH__language__c),vis.CVCH__Chat_Number__c);
                vis.CVCH__Next_Flow__c = 'Direction_GET_FROMID';
                
            }
            if(inp.type == 'get FROMID')
            {
                system.debug('type = get FROMID');
                
                list<account> laccto = new list<account>();
                laccto = searchAccByKeyWord(inp.location, inp.programId, inp.sLang);
                if (!laccto.isEmpty())
                {
                    vis.CVCH__Location__c = laccto[0].CVCH__location__c;
                    SM042_NexmoOut2.sendText(vis.CVCH__Id__c,SM010_Utils.translate('Please enter your current location',vis.CVCH__language__c),vis.CVCH__Chat_Number__c);
                    vis.CVCH__Next_Flow__c = 'Direction_GET_LINK';
                }else
                {
                    SM042_NexmoOut2.sendText(vis.CVCH__Id__c,SM010_Utils.translate('Sorry I couldn’t understand that. Please type the correct spelling of the nearby store or type "menu" to go back.',vis.language__c),vis.Chat_Number__c);
                    vis.CVCH__Next_Flow__c = 'Direction_GET_FROMID';
                }     
            }
            if(inp.type == 'get LINK')
            {
                system.debug('type = get LINK');
                list<account> laccfrom = new list<account>();
                string sFrom;
                string sTo = vis.CVCH__Location__c;
                laccfrom = searchAccByKeyWord(inp.Location, inp.programId, inp.sLang);
                system.debug(laccfrom);
                if (!laccfrom.isEmpty())
                {
                    sFrom = laccfrom[0].CVCH__location__c;
                    string directionurl = getFinderURL(sFrom, sTo);
                    SM042_NexmoOut2.sendText(vis.CVCH__Id__c,directionurl,vis.CVCH__Chat_Number__c);
                    vis.CVCH__Next_Flow__c = null;
                }else
                {
                    SM042_NexmoOut2.sendText(vis.CVCH__Id__c,SM010_Utils.translate('Sorry I couldn’t understand that. Please type the correct spelling of the nearby store or type "menu" to go back.',vis.language__c),vis.Chat_Number__c);
                    vis.CVCH__Next_Flow__c = 'Direction_GET_LINK';
                }
            }
        }
        update mVis.values();
    }


    public static string getFinderURL(string fromLocation, string toLocation)
    {
        string sRet = 'https://www.google.com/maps/dir/?api=1';
        if(fromLocation != null)
        {
            sRet = sRet +'&origin='+EncodingUtil.urlEncode(fromLocation,'UTF-8');
        }
        if(toLocation != null)
        {
            sRet = sRet +'&destination='+EncodingUtil.urlEncode(toLocation,'UTF-8');
        }
        return sRet;
    }


    public static list<account> searchAccByKeyWord(string sKeyWord0,string programId,string language)
    {
        //if (programId == null || programId == '')
        //    programId = 'a067E0000091g5H';
        if (language == null || language == '')
            language = 'en';
        map<id,account> mret = new map<id,account>();
        string sKeyWord = '%'+sKeyWord0+'%';
        list<CVCH__Category__c> lCat = [select CVCH__account__r.id from CVCH__Category__c where CVCH__Category__c like :sKeyWord and CVCH__account__r.id != null];// and account__r.Loy_Program__c = :programId ];
        for(CVCH__category__c cat :lCat)
        {
            if(cat.CVCH__account__r.id != null)
                mret.put(cat.CVCH__account__r.id,null);
        }
        set<id> mrkeyset = new set<id>();
        for(id i: mret.keyset())
            mrkeyset.add(i);
        string langname;
        if (language == 'en')
            langname = 'name_en__c';
        if (language == 'ar')
            langname = 'name_ar__c';
        if (language == 'it')
            langname = 'name_it__c';
        list<sobject> lobj = Database.query('select id, name,Image__c,phone,website,location__c, name_ar__c, name_en__c, name_it__c, url__c from account where (id in :mrkeySet or '+langname+' like :sKeyWord or name like :sKeyWord or location__c = :sKeyWord0) order by name');
        // or '+langname+' like :sKeyWord or name like :sKeyWord
        list<account> lacc = new list<account>();
        for (sobject o: lobj){
            lacc.add((Account)o);
        }
        //list<account>lacc = [select id, name,Image__c,phone,website,location__c, name_ar__c, name_en__c, name_it__c from account where Loy_Program__c =:programId and (id in :mret.keySet() or name like :sKeyWord) and (recordType.name = 'Outlet' or recordType.name = 'Location')order by name];
        for(account acc :lAcc)
        {
            mret.put(acc.id,acc);
        }
        mret.values().sort();
        return (mret.values());
    }

}
