/**
Author:         serhiivolynets
Date:           09.08.2020
Description:   
**/

global class OutletSearch
{
	String sSearchFlow = SM010_Utils.getChat2aiValue('search');
	String sDefaultDetailsFlow = SM010_Utils.getChat2aiValue('get_outlet_info');
	String sDefaultBackFlow = SM010_Utils.getChat2aiValue('Main_Menu');
	String sGenderFlow = SM010_Utils.getChat2aiValue('search_select_gender');

	@AuraEnabled @InvocableVariable global Id visitorId;
	@AuraEnabled @InvocableVariable global String keyword;
	@AuraEnabled @InvocableVariable global String gender;
	@AuraEnabled @InvocableVariable global String detailsFlow;
	@AuraEnabled @InvocableVariable global String backFlow;
	@AuraEnabled @InvocableVariable global Integer pageNum;
	@AuraEnabled @InvocableVariable global String entities;
	@AuraEnabled @InvocableVariable global String type;
	CVCH__Visitor__c vis;

	@InvocableMethod(label='search outlets by category' description='')
	global static void search(List<OutletSearch> search)
	{
		Set<Id>sids = new Set<Id>();

		System.debug('Search flow start');
		for (OutletSearch s : search)
		{
			if (s.visitorId != null)
				sids.add(s.visitorId);
			if (s.pageNum == null)
				s.pageNum = 0;
			if (s.detailsFlow == null || s.detailsFlow == '')
				s.detailsFlow = s.sDefaultDetailsFlow;
			if (s.backFlow == null || s.backFlow == '')
				s.backFlow = s.sDefaultBackFlow;
		}
		Map<Id, CVCH__Visitor__c> mVis = new Map<Id, CVCH__Visitor__c>(DM080_Visitor.getRecords(sids));
		Map<Id, CVCH__Visitor__c> mUpdate = new Map<Id, CVCH__Visitor__c>();
		for (OutletSearch srch : search)
		{
			srch.vis = mVis.get(srch.visitorId);
			System.debug('gender: ' + srch.gender);
			System.debug('keyword: ' + srch.keyword);
			Map<String, Object> mEntities = new Map<String, Object>();
			if (srch.entities != null && srch.entities != '')
			{
				mEntities = (Map<String, Object>) JSON.deserializeUntyped(srch.entities);
				System.debug(mEntities);
				if (mEntities.get('gender') != null)
					srch.gender = String.valueOf(((List<Object>) mEntities.get('gender'))[0]);
				if (mEntities.get('shops') != null)
					srch.keyword = String.valueOf(((List<Object>) mEntities.get('shops'))[0]);
				if (mEntities.get('item') != null)
					srch.keyword = String.valueOf(((List<Object>) mEntities.get('item'))[0]);
				if (mEntities.get('fashion men') != null)
					srch.keyword = String.valueOf(((List<Object>) mEntities.get('fashion men'))[0]);
				else if (mEntities.get('fashion women') != null)
					srch.keyword = String.valueOf(((List<Object>) mEntities.get('fashion women'))[0]);
				else if (mEntities.get('fashion kids') != null)
					srch.keyword = String.valueOf(((List<Object>) mEntities.get('fashion kids'))[0]);
			}
			System.debug('gender2: ' + srch.gender);
			System.debug('keyword2: ' + srch.keyword);
			MessageOptions opt = srch.outletSearch();
			if (opt != null)
			{
				opt.send(srch.vis);

				CVCH__Visitor__c vis2 = new CVCH__Visitor__c
						(
								CVCH__keyword__c = srch.keyword
								, Id = srch.vis.Id
								, CVCH__Context__c = srch.vis.CVCH__Context__c
						);
				mUpdate.put(vis2.Id, vis2);
			}
			else
			{
				CVCH__Visitor__c vis2 = new CVCH__Visitor__c(CVCH__keyword__c = srch.keyword, Id = srch.vis.Id);
				mUpdate.put(vis2.Id, vis2);
			}
		}
		update mUpdate.values();
	}


	public MessageOptions outletSearch()
	{
		MessageOptions ret = new MessageOptions(vis.Id);

		if (keyword == null || keyword == '')
			throw new MyException('The search key is not specified');

		System.debug(keyword);
		keyword = keyword.replaceAll('_', ' ').replaceAll('-', '&');
		System.debug(keyword);
		String sKeyword = keyword;
		if (genderSpecific(keyword))
		{
			if (gender == '' || gender == null)
			{
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', vis.Id);
				Flow.Interview flow = Flow.Interview.createInterview(sGenderFlow, params);
				flow.start();
				return null;
			}

			if (gender != '' && gender != 'all' && gender != null)
				sKeyword = gender + ' ' + keyword;
		}

		List<Account>lAcc = new List<Account>();
		if (type == 'outlet')
			lAcc = searchAccByKeyWord(sKeyword, false, true);
		else
				lAcc = searchAccByKeyWord(sKeyword, true, false);


		if (lAcc.isEmpty())
			ret = MessageOptions.message(vis.Id, SM010_Utils.translate('There is no any shops by keyword ', vis.CVCH__language__c) + sKeyword);
		else if (lAcc.size() == 1 && Test.isRunningTest() == false)
			ret = getOutletInfo(vis, lAcc[0].Id);
//		else if (vis.Chanel__c == 'whatsapp')
			ret = options(lAcc);
//		else
//				ret = carousel (lAcc);
		return ret;
	}


	public static Account getAccountRecord(Id accountId)
	{
		return
		[
				select Id,
						Name,CVCH__Image__c,Phone,Website,CVCH__Location__c, CVCH__name_ar__c, CVCH__name_en__c, CVCH__name_it__c, CVCH__url__c
				from Account
				where Id = :accountId
		];
	}


	public List<Account> searchAccByKeyWord(String sKeyWord0, Boolean srchCat, Boolean srchName)
	{
		Map<Id, Account> mret = new Map<Id, Account>();
		String sKeyWord = '%' + sKeyWord0 + '%';
		String sKeyWord1 = sKeyWord0.toUpperCase();
		List<CVCH__Category__c> lCat =
		[
				select CVCH__Account__r.Id,CVCH__Account__r.Name
				from CVCH__Category__c
				where CVCH__Category__c = :sKeyWord1 and CVCH__Account__r.Id != null
		];
		for (CVCH__Category__c cat : lCat)
		{
			if (cat.CVCH__Account__r.Id != null)
				mret.put(cat.CVCH__Account__r.Id, null);
		}
		Set<Id> mrkeyset = new Set<Id>();
		if (srchCat)
		{
			for (Id i : mret.keySet())
				mrkeyset.add(i);
		}

		String langname = getNameFieldName(vis.CVCH__language__c);
		List<SObject> lobj = new List<SObject>();
		String sQuery = '';
		if (srchName)
			sQuery = 'select id,Name,Image__c,phone,website,location__c, ' + langname + ', url__c from account where (id in :mrkeyset or ' + langname + ' like :sKeyWord or name like :sKeyWord or location__c = :sKeyWord0)  order by name';
			//and (recordType.name = 'Outlet' or recordType.name = 'Location')
		else
				sQuery = 'select id,Name,Image__c,phone,website,location__c, ' + langname + ', url__c from account where id in :mrkeyset order by ' + langname;
		System.debug(sQuery);
		lobj = Database.query(sQuery);
		System.debug(lobj);
		List<Account> lacc = new List<Account>();
		for (SObject o : lobj)
		{
			lacc.add((Account) o);
		}
		for (Account acc : lacc)
		{
			mret.put(acc.Id, acc);
		}
		List<Account> lret = new List<Account>();
		for (Account a : mret.values())
		{
			if (a != null)
			{
				if (a.Name == 'IKEA' && !lret.isEmpty())
					lret.add(0, a);
				else
						lret.add(a);
			}
		}
		return lret;
	}

	public static String getNameFieldName(String lang)
	{
		String sRet = 'name_en__c';
		if (lang != '' && lang != null)
			sRet = 'name_' + lang + '__c';
		return sRet;
	}

	public static String getName(Account acc, String lang)
	{
		System.debug('getName(' + lang + ').' + acc);
		String sRet = (String) acc.get(getNameFieldName(lang));
		if (sRet == null || sRet == '')
			sRet = acc.Name;
		System.debug('getName.ret=' + sRet);
		return sRet;
	}

	public static Integer iSize = 10;


	public static Boolean genderSpecific(String sKeyWord)
	{
		return (CVCH__GenderCat__c.getInstance(sKeyWord) != null);
	}


	public MessageOptions options(List<Account>lacc)
	{
		SM010_Utils.pageReturn page = SM010_Utils.getPage(lacc, pageNum, 10, false, true);
		MessageOptions ret = new MessageOptions(vis.Id);
		ret.sType = 'Options';


		for (Object obj : page.lObj)
		{
			Account acc = (Account) obj;
			if (acc.CVCH__Location__c != null && acc.CVCH__Location__c != '')
				ret.lOptions.add(getOption(acc, vis.CVCH__language__c, detailsFlow));
		}
		if (page.bEnd == false)
		{
			Option opt = new Option();
			opt.sLabel = SM010_Utils.translate('Next', vis.CVCH__language__c);
			opt.sFlow = sSearchFlow;//SM010_Utils.getFlowId('getOutletsNext', null, vis.language__c);
			opt.sName = 'pageNum';
			opt.sValue = String.valueOf(pageNum + 1);
			opt.sName2 = 'keyword';
			opt.sValue2 = keyword;
			opt.sName3 = 'gender';
			opt.sValue3 = gender;
			ret.lOptions.add(opt);
		}
		if (page.bBegin == false)
		{
			Option opt = new Option();
			opt.sLabel = SM010_Utils.translate('Previous', vis.CVCH__language__c);
			opt.sFlow = sSearchFlow;//SM010_Utils.getFlowId('getOutletsNext', null, vis.language__c);
			opt.sName = 'pageNum';
			opt.sValue = String.valueOf(pageNum - 1);
			opt.sName2 = 'keyword';
			opt.sValue2 = keyword;
			opt.sName3 = 'gender';
			opt.sValue3 = gender;
			ret.lOptions.add(opt);
		}
		if (backFlow != '' && backFlow != null)
		{
			Option opt = new Option();
			opt.sLabel = SM010_Utils.translate('Back to previous menu', vis.CVCH__language__c);
			opt.sFlow = backFlow;
			ret.lOptions.add(opt);
		}
		ret.sMessage = SM010_Utils.translate('Please find your search results:', vis.CVCH__language__c);
		return ret;
	}


//	public MessageOptions carousel(list<account>lacc)
//	{
//		MessageOptions ret = new MessageOptions();
//		ret.sType = 'carousel';
//
//		SM010_Utils.pageReturn page = SM010_Utils.getPage(lacc, pageNum, iSize, true, true);
//
////		string sCall = SM010_Utils.getRestParam('sCall');
////		boolean bCall = true;
////		if (sCall == 'false')
////			bCall = false;
//		if (page.bBegin == false)
//			ret.lItems.add(getOutletsPrev());
//		for (object obj : page.lObj)
//		{
//			ret.lItems.add(getTemplate((account) obj, vis.language__c, true, backFlow));
//		}
//
//		if (page.bEnd == false || Test.isRunningTest())
//			ret.lItems.add(getOutletsNext());
//
//		return ret;
//	}

	public static MessageOptions getOutletInfo(CVCH__Visitor__c vis, Id outletId)
	{
		MessageOptions mo = new MessageOptions(vis.Id);
		mo.sType = 'Carousel';
		Account acc = getAccountRecord(outletId);
		mo.lItems.add(getTemplate(acc, vis.CVCH__language__c, true, null));
		return mo;
	}

	public static CarouselItem getTemplate(Account acc, String language, Boolean bCall, String sBackMenuFlow)
	{
		CarouselItem temp = new CarouselItem();

		temp.title = getName(acc, language);
		temp.imageURL = acc.CVCH__Image__c;
		if (acc.CVCH__url__c != null)
			temp.subtitle = acc.CVCH__url__c;

		if (bCall && acc.Phone != null)
			temp.subtitle = SM010_Utils.translate('Call Now ', language) + ' ' + acc.Phone;

		String sToId = acc.CVCH__Location__c;
		if (sToId != '' && sToId != null)
		{
			Option opt = new Option();

			opt.sLabel = SM010_Utils.translate('Direction to ', language) + getName(acc, language);
			opt.sFlow = 'Direction_GET_FROMID';
			opt.sName = 'input';
			opt.sValue = sToId;
			temp.button2 = opt;
		}
		if (sBackMenuFlow != null && sBackMenuFlow != '')
		{
			Option but3 = new Option();
			but3.sLabel = SM010_Utils.translate('Back to previous menu', language);
			but3.sFlow = sBackMenuFlow;
			temp.button3 = but3;
		}

		return temp;
	}

	public Option getOption(Account acc, String language, String sFlow)
	{
		Option ret = new Option();
		ret.sLabel = getName(acc, language);
		ret.sFlow = sFlow;
		ret.sName = 'outletId';
		ret.sValue = acc.Id;
		System.debug('getOption.return=' + ret);
		return ret;
	}

//	public Option getOutletsNextOption()
//	{
//		Option but = new Option();
//		but.sFlow = sSearchFlow;
//		but.sName = 'keyword';
//		but.sValue = keyword;
//		but.sName2 = 'gender';
//		but.sValue2 = gender;
//		but.sName3 = 'pageNum';
//		but.sValue3 = '' + (pageNum + 1);
//		but.sLabel = SM010_Utils.translate('Next', vis.language__c);
//		return but;
//	}
//	public CarouselItem getOutletsNext()
//	{
//		CarouselItem ret = new CarouselItem();
//		ret.title = SM010_Utils.translate('Next', vis.language__c);
//		ret.imageURL = SM010_Utils.getValue('nextImage');
//		ret.button1 = getOutletsNextOption();
//		return ret;
//	}
//	public CarouselItem getOutletsPrev()
//	{
//		CarouselItem ret = new CarouselItem();
//		ret.title = SM010_Utils.translate('Prev', vis.language__c);
//		ret.imageURL = SM010_Utils.getValue('prevImage');
//		Option but = new Option();
//		but.sFlow = sSearchFlow;
//		but.sValue = keyword;
//		but.sName2 = 'gender';
//		but.sValue2 = gender;
//		but.sName3 = 'pageNum';
//		but.sValue3 = '' + (pageNum - 1);
//		but.sLabel = SM010_Utils.translate('Prev', vis.language__c);
//		ret.button1 = but;
//		return ret;
//	}
}
