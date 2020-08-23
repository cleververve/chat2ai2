/**
Author:         serhiivolynets
Date:           09.08.2020
Description:   
**/

global class OutletSearch
{
	string sSearchFlow = SM010_Utils.getChat2aiValue('search');
	string sDefaultDetailsFlow = SM010_Utils.getChat2aiValue('get_outlet_info');
	string sDefaultBackFlow = SM010_Utils.getChat2aiValue('Main_Menu');
	string sGenderFlow = SM010_Utils.getChat2aiValue('search_select_gender');

	@AuraEnabled @InvocableVariable public id visitorId;
	@AuraEnabled @InvocableVariable public string keyword;
	@AuraEnabled @InvocableVariable public string gender;
	@AuraEnabled @InvocableVariable public string detailsFlow;
	@AuraEnabled @InvocableVariable public string backFlow;
	@AuraEnabled @InvocableVariable public integer pageNum;
	@AuraEnabled @InvocableVariable public string entities;
	@AuraEnabled @InvocableVariable public string type;
	Visitor__c vis;


	@InvocableMethod(label='search outlets by category' description='')
	global static void search(list<OutletSearch> search)
	{
		set<id>sids = new set<id>();

		system.debug('Search flow start');
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
		map<id, Visitor__c> mVis = new map<id, Visitor__c>(DM080_Visitor.getRecords(sids));
		map<id, Visitor__c> mUpdate = new map<id, Visitor__c>();
		for (OutletSearch srch : search)
		{
			srch.vis = mVis.get(srch.visitorId);
			system.debug('gender: ' + srch.gender);
			system.debug('keyword: ' + srch.keyword);
			Map<string, object> mEntities = new map<string, object>();
			if (srch.entities != null && srch.entities != '')
			{
				mEntities = (Map<string, object>) JSON.deserializeUntyped(srch.entities);
				system.debug(mEntities);
				if (mEntities.get('gender') != null)
					srch.gender = String.valueOf(((list<object>) mEntities.get('gender'))[0]);
				if (mEntities.get('shops') != null)
					srch.keyword = String.valueOf(((list<object>) mEntities.get('shops'))[0]);
				if (mEntities.get('item') != null)
					srch.keyword = String.valueOf(((list<object>) mEntities.get('item'))[0]);
				if (mEntities.get('fashion men') != null)
					srch.keyword = String.valueOf(((list<object>) mEntities.get('fashion men'))[0]);
				else if (mEntities.get('fashion women') != null)
					srch.keyword = String.valueOf(((list<object>) mEntities.get('fashion women'))[0]);
				else if (mEntities.get('fashion kids') != null)
					srch.keyword = string.valueOf(((list<object>) mEntities.get('fashion kids'))[0]);
			}
			system.debug('gender2: ' + srch.gender);
			system.debug('keyword2: ' + srch.keyword);
			MessageOptions opt = srch.OutletSearch();
			if (opt != null)
			{
				opt.send(srch.vis);

				Visitor__c vis2 = new Visitor__c
						(
								keyword__c = srch.keyword
								, id = srch.vis.id
								, Context__c = srch.vis.Context__c
						);
				mUpdate.put(vis2.id, vis2);
			}
			else
			{
				Visitor__c vis2 = new Visitor__c(keyword__c = srch.keyword, id = srch.vis.id);
				mUpdate.put(vis2.id, vis2);
			}
		}
		update mUpdate.values();
	}


	public MessageOptions outletSearch()
	{
		MessageOptions ret = new MessageOptions(vis.Id);

		if (keyword == null || keyword == '')
			throw new MyException('The search key is not specified');

		system.debug(keyword);
		keyword = keyword.replaceAll('_', ' ').replaceAll('-', '&');
		system.debug(keyword);
		string sKeyword = keyword;
		if (genderSpecific(keyword))
		{
			if (gender == '' || gender == null)
			{
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', vis.id);
				Flow.Interview flow = Flow.Interview.createInterview(sGenderFlow, params);
				flow.start();
				return null;
			}

			if (gender != '' && gender != 'all' && gender != null)
				sKeyWord = gender + ' ' + keyword;
		}

		list<account>lAcc = new list<account>();
		if (type == 'outlet')
			lAcc = searchAccByKeyWord(sKeyword, false, true);
		else
				lAcc = searchAccByKeyWord(sKeyword, true, false);


		if (lAcc.isEmpty())
			ret = MessageOptions.message(vis.id, SM010_Utils.translate('There is no any shops by keyword ', vis.language__c) + sKeyWord);
		else if (lAcc.size() == 1 && Test.isRunningTest() == false)
			ret = getOutletInfo(vis, lAcc[0].Id);
//		else if (vis.Chanel__c == 'whatsapp')
			ret = options(lAcc);
//		else
//				ret = carousel (lAcc);
		return ret;
	}


	public static account getAccountRecord(id accountId)
	{
		return
		[
				select id,
						name,Image__c,phone,website,location__c, name_ar__c, name_en__c, name_it__c, url__c
				from account
				where id = :accountId
		];
	}


	public list<account> searchAccByKeyWord(string sKeyWord0, boolean srchCat, boolean srchName)
	{
		map<id, account> mret = new map<id, account>();
		string sKeyWord = '%' + sKeyWord0 + '%';
		string sKeyWord1 = sKeyWord0.toUpperCase();
		list<Category__c> lCat =
		[
				select account__r.id,Account__r.name
				from Category__c
				where Category__c = :sKeyWord1 and account__r.id != null
		];
		for (category__c cat : lCat)
		{
			if (cat.account__r.id != null)
				mret.put(cat.account__r.id, null);
		}
		set<id> mrkeyset = new set<id>();
		if (srchCat)
		{
			for (id i : mret.keyset())
				mrkeyset.add(i);
		}

		string langname = getNameFieldName(vis.language__c);
		list<sobject> lobj = new list<sobject>();
		string sQuery = '';
		if (srchName)
			sQuery = 'select id,Name,Image__c,phone,website,location__c, ' + langname + ', url__c from account where (id in :mrkeySet or ' + langname + ' like :sKeyWord or name like :sKeyWord or location__c = :sKeyWord0)  order by name';
			//and (recordType.name = 'Outlet' or recordType.name = 'Location')
		else
				sQuery = 'select id,Name,Image__c,phone,website,location__c, ' + langname + ', url__c from account where id in :mrkeySet order by ' + langname;
		system.debug(sQuery);
		lobj = Database.query(sQuery);
		system.debug(lObj);
		list<account> lacc = new list<account>();
		for (sobject o : lobj)
		{
			lacc.add((Account) o);
		}
		for (account acc : lAcc)
		{
			mret.put(acc.id, acc);
		}
		list<account> lret = new list<account>();
		for (account a : mret.values())
		{
			if (a != null)
			{
				if (a.name == 'IKEA' && !lret.isempty())
					lret.add(0, a);
				else
						lret.add(a);
			}
		}
		return lret;
	}

	public static string getNameFieldName(string lang)
	{
		string sRet = 'name_en__c';
		if (lang != '' && lang != null)
			sRet = 'name_' + lang + '__c';
		return sRet;
	}

	public static string getName(account acc, string lang)
	{
		system.debug('getName(' + lang + ').' + acc);
		string sRet = (string) acc.get(getNameFieldName(lang));
		if (sRet == null || sRet == '')
			sRet = acc.Name;
		system.debug('getName.ret=' + sRet);
		return sRet;
	}

	public static integer iSize = 10;


	public static boolean genderSpecific(string sKeyWord)
	{
		return (GenderCat__c.getInstance(sKeyWord) != null);
	}


	public MessageOptions options(list<account>lacc)
	{
		SM010_Utils.pageReturn page = SM010_Utils.getPage(lAcc, pageNum, 10, false, true);
		MessageOptions ret = new MessageOptions(vis.Id);
		ret.sType = 'msg_options';


		for (object obj : page.lObj)
		{
			account acc = (account) obj;
			if (acc.location__c != null && acc.location__c != '')
				ret.lOptions.add(getOption(acc, vis.language__c, detailsFlow));
		}
		if (page.bEnd == false)
		{
			Option opt = new Option();
			opt.sLabel = SM010_Utils.translate('Next', vis.language__c);
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
			opt.sLabel = SM010_Utils.translate('Previous', vis.language__c);
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
			opt.sLabel = SM010_Utils.translate('Back to previous menu', vis.language__c);
			opt.sFlow = backFlow;
			ret.lOptions.add(opt);
		}
		ret.sMessage = SM010_Utils.translate('Please find your search results:', vis.language__c);
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

	public static MessageOptions getOutletInfo(Visitor__c vis, id outletId)
	{
		MessageOptions mo = new MessageOptions(vis.Id);
		mo.sType = 'carousel';
		account acc = getAccountRecord(outletId);
		mo.lItems.add(getTemplate(acc, vis.language__c, true, null));
		return mo;
	}

	public static CarouselItem getTemplate(account acc, string language, boolean bCall, string sBackMenuFlow)
	{
		CarouselItem temp = new CarouselItem();

		temp.title = getName(acc, language);
		temp.imageURL = acc.image__c;
		if (acc.url__c != null)
			temp.subtitle = acc.url__c;

		if (bCall && acc.Phone != null)
			temp.subtitle = SM010_Utils.translate('Call Now ', language) + ' ' + acc.Phone;

		string sToId = acc.location__c;
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

	public Option getOption(account acc, string language, string sFlow)
	{
		Option ret = new Option();
		ret.sLabel = getName(acc, language);
		ret.sFlow = sFlow;
		ret.sName = 'outletId';
		ret.sValue = acc.Id;
		system.debug('getOption.return=' + ret);
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
