/**
Author:         serhiivolynets
Date:           20.02.2022
Description:   
**/

global class Location
{
	@AuraEnabled @InvocableVariable global string address;
	@AuraEnabled @InvocableVariable global string name;
	@AuraEnabled @InvocableVariable global string url;
	@AuraEnabled @InvocableVariable global Decimal latitude;
	@AuraEnabled @InvocableVariable global Decimal longitude;

	public static Location loc;
	public static void setLocation(Location loc1)
	{
		loc = loc1;
	}

	@InvocableMethod(label='Get Location' description='Get Location')
	global static list<Location> getLocation()
	{
		list<Location> lLoc = new list<Location>();
		lLoc.add(loc);
		return lLoc;
	}
}
