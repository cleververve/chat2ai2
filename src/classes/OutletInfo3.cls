/**
Author:         serhiivolynets
Date:           24.08.2020
Description:   
**/

global class OutletInfo3
{
	@AuraEnabled @InvocableVariable global id visitorId;
	@AuraEnabled @InvocableVariable global id outletId;

	@InvocableMethod(label='get outlet info' description='')
	global static void getOutlet(list<OutletInfo3> lRec)
	{
		set<id>sids = new set<id>();
		set<id>soutletids = new set<id>();

		for (OutletInfo3 rec : lRec)
		{
			if (rec.visitorId != null)
				sids.add(rec.visitorId);
			if (rec.outletId != null)
				soutletids.add(rec.outletId);
		}
		map<id,Visitor__c> mVis = new map<id,Visitor__c>(DM080_Visitor.getRecords(sids));

		map<id,Visitor__c> mUpdate = new map<id,Visitor__c>();
		for(OutletInfo3 rec : lRec)
		{
			Visitor__c vis = mVis.get(rec.visitorId);
			if(vis != null)
			{
				MessageOptions mo = OutletSearch.getOutletInfo(vis,rec.outletId);
				system.debug('getOutlet.mo'+mo);
				mo.send(vis);
				Visitor__c vis2 = new Visitor__c();
				vis2.Context__c = vis.Context__c;
				vis2.id = vis.Id;
				mUpdate.put(vis2.id,vis2);
			}
		}
		update mUpdate.values();
	}
}
