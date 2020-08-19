@RestResource(urlMapping='/nexmo/*')
global class SM031_Nexmo
{

	//       public static boolean skipLoyalty = true;
	public static boolean skipLoyalty()
	{
		string sSkip = null;
		try
		{
			sSkip = SM010_Utils.getValue('skipLoyalty');
		}
		catch (Exception e)
		{
		}
		return sSkip == 'TRUE';
	}
	public static list<MessageOptions> getResponse(NexmoMessage__c mess, Visitor__c visr)
	{

		list<MessageOptions> lret = new list<MessageOptions>();
		boolean bProceeded = false;
        boolean TriggerDefaultFlow = false;
        string translatedText = '';
        translatedText = SM080_Translate.translate(mess.Text__c);
        system.debug('Translated input: '+translatedText);
        SM080_LUIS.LuisResponse respLuis = SM080_LUIS.queryPhrase(translatedText,visr.language__c);
		SM080_QnA.QnAResponse respQnA = SM080_QnA.queryPhrase(translatedText,visr.language__c);
        
        if (respLuis.dScore < Decimal.valueOf(SM010_Utils.getValue('Response treshold score')) && respQnA.dScore < Decimal.valueOf(SM010_Utils.getValue('Response treshold score')))
        {
            TriggerDefaultFlow = true; // We will trigger Default Flow, if both scores are below set treshold            
        }
        if (visr.Had_First_Interaction__c == false)
        {
            bProceeded = true;
            Map<String, Object> params = new Map<String, Object>();
            
            params.put('visphone', visr.Id__c);
            params.put('ChatNumber', visr.Chat_Number__c);
            params.put('channel', visr.chanel__c);
            Flow.Interview chat2aiflow = Flow.Interview.createInterview('Welcome_Flow', params);
            chat2aiflow.Start();
        }
        else if (visr.GDPR_Consent__c == 'No Access' && (visr.Context__c == '' || visr.Context__c == null)) //Restrict Non-GDPR users
        {
            bProceeded = true;
            Map<String, Object> params = new Map<String, Object>();
            params.put('visitorId', visr.id);
            params.put('originalmessage', mess.Text__c);
            
            Flow.Interview flow = Flow.Interview.createInterview('GDPR_CHECK', params);
            flow.start();            
        }
        else if (visr.GDPR_Consent__c == 'No Access' && visr.Context__c != '' && visr.Context__c != null)
        {
            bProceeded = true;
            Map<String, Object> params = new Map<String, Object>();
            params.put('visitorId', visr.id);
            params.put('originalmessage', mess.Text__c);
            
            MessageOptions mo = (MessageOptions) JSON.deserialize(visr.Context__c, MessageOptions.class);
            system.debug('GDPR MessageOptions='+mo);
            Option opt = mo.mOptions.get(mess.Text__c);
            if (opt != null && opt.sFlow != null)
            {
                if (opt.sName != null)
                    params.put(opt.sName, opt.sValue);
                if (opt.sName2 != null)
                    params.put(opt.sName2, opt.sValue2);
                if (opt.sName3 != null)
                    params.put(opt.sName3, opt.sValue3);
                Flow.Interview flow = Flow.Interview.createInterview(opt.sFlow, params);
                flow.start();
            }
            else
            {
                Flow.Interview flow = Flow.Interview.createInterview('GDPR_CHECK', params);
            	flow.start();
            }
        }
        else if (!TriggerDefaultFlow && respLuis.dScore>respQnA.dScore && respLuis.sIntent == 'exit')
        {
            bProceeded = true;
            Map<String, Object> params = new Map<String, Object>();
            params.put('visitorId', visr.id);
            params.put('originalmessage', mess.Text__c);
            Flow.Interview flow = Flow.Interview.createInterview('Main_Menu', params);
            flow.start();
            Visitor__c v = new Visitor__c(Id = visr.id, Next_flow__c = null);
            update v;
        }
        else if (visr.Next_Flow__c != null && visr.Next_Flow__c != '')
        {
            bProceeded = true;
            Map<String, Object> params = new Map<String, Object>();
            params.put('visitorId', visr.id);
            params.put('input', mess.Text__c);
            
            Flow.Interview flow = Flow.Interview.createInterview(visr.Next_Flow__c, params);
            flow.start();
        }
		else if (visr.Context__c != null && visr.Context__c != '')
		{
			MessageOptions mo = (MessageOptions) JSON.deserialize(visr.Context__c, MessageOptions.class);
            system.debug('MessageOptions='+mo);
			if (mo.sType == 'Input')
			{
				bProceeded = true;
				Visitor__c v = new Visitor__c(Id = visr.id);
				v.put(mo.sFieldName, mess.Text__c);
                v.Context__c = '';
				update v;
                if (mo.sConfirmMessage != null && mo.sConfirmMessage != '')
                {
                   // sendText(visr.id__c,visr.Chat_Number__c,mo.sConfirmMessage);
                }
                if (mo.sFlow != null && mo.sFlow != '')
                {
                    Map<String, Object> params = new Map<String, Object>();
                    params.put('visitorId', visr.id);

                    Flow.Interview flow = Flow.Interview.createInterview(mo.sFlow, params);
                    flow.start();
                }
			}
			else
			{
				system.debug('getting option ' + mess.Text__c + ' from ' + mo.mOptions);
				Option opt = mo.mOptions.get(mess.Text__c);
				if (opt != null)
				{
					system.debug('found option ' + opt);
					if (opt.sType == 'QnA')
					{
						integer qnaid = integer.valueOf(opt.sValue);
						
						SM080_QnA.QnAResponse respQnA2 = SM080_QnA.getQNA(qnaid,visr.language__c);
						lret.add(new MessageOptions(respQnA2));
						bProceeded = true;
					}else 
                    {
						bProceeded = true;
//						if (opt.sFieldName != null && opt.sFieldName != '')
//						{
//							system.debug('update ' + visr);
//							Visitor__c v = new Visitor__c(Id = visr.id);
//							v.put(opt.sFieldName, opt.sValue);
//							update v;
//						}
//                        v.Context__c = '';
//                        update v;

						if (opt.sFlow != null)
						{
							Map<String, Object> params = new Map<String, Object>();
							params.put('visitorId', visr.id);
                            params.put('originalmessage', mess.Text__c);
							if (opt.sName != null)
								params.put(opt.sName, opt.sValue);
                            if (opt.sName2 != null)
                                params.put(opt.sName2, opt.sValue2);
                            if (opt.sName3 != null)
                                params.put(opt.sName3, opt.sValue3);
							Flow.Interview flow = Flow.Interview.createInterview(opt.sFlow, params);
							flow.start();
						}
					}
				}
			}

		}
        if (!bProceeded && TriggerDefaultFlow)
        {
            bProceeded = true;
            Map<String, Object> params = new Map<String, Object>();
            params.put('visitorId', visr.id);
            params.put('originalmessage', mess.Text__c);
            
            Flow.Interview flow = Flow.Interview.createInterview('Default_Flow', params);
            flow.start();// trigger default flow
        }
		if (!bProceeded)
		{ 
			/*if(mess.Text__c != null && mess.Text__c.startsWith('search '))
			{
				string sText = mess.Text__c;
				string sCategory = sText.substring(7);
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', visr.id);
				params.put('keyword',sCategory);

				Flow.Interview flowSearch = Flow.Interview.createInterview('search', params);
				flowSearch.Start();
			}
			else*/
			{
				//SM080_LUIS.LuisResponse respLuis = SM080_LUIS.queryPhrase(mess.Text__c,visr.language__c);
				//SM080_QnA.QnAResponse respQnA = SM080_QnA.queryPhrase(mess.Text__c,visr.language__c);
				system.debug('LUIS score=' + respLuis.dScore + ',QnA score=' + respQnA.dScore);
				if (respLuis.dScore > respQnA.dScore)
				{
					Map<String, Object> params = new Map<String, Object>();
					params.put('visitorId', visr.id);
					params.put('intent', respLuis.sIntent);
					params.put('entities', respLuis.getEntities());
					params.put('originalmessage', mess.Text__c);
					Flow.Interview chat2aiflow = Flow.Interview.createInterview('LUIS', params);
//                Flow.Interview.chat2ai chat2aiflow = new Flow.Interview.chat2ai(params);
					chat2aiflow.Start();
				}
				else
						lret.add(new MessageOptions(respQnA));
			}

		}
        /*if (visr.Had_First_Interaction__c == false)
        {
            Visitor__c v = new Visitor__c(Id = visr.Id, Had_First_Interaction__c = true);
            update v;
        }*/
		return lret;
	}

	global static NexmoMessage__c parse(string jsonbody)
	{
		system.debug('parse.start ' + jsonbody);
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonbody);
		system.debug(m);
		string message_uuid = (string) m.get('message_uuid');
		map<string, object> mFrom = (map<string, object>) m.get('from');
		string sFrom = SM010_Utils.phone((string) mFrom.get('number'));
		string sChannel = (string) mFrom.get('type');
		map<string, object> mTo = (map<string, object>) m.get('to');
		string sTo = (string) mTo.get('number');
		map<string, object> mMess = (map<string, object>) m.get('message');
		map<string, object> mCon;
		try
		{
			mCon = (map<string, object>) mMess.get('content');
		}
		catch (Exception e)
		{
			return null;
		}

		string messageText = (string) mcon.get('text');
		NexmoMessage__c mess = new NexmoMessage__c();
		mess.Name = message_uuid;
		mess.From__c = sFrom;
		mess.To__c = sTo;
		mess.Text__c = messageText;
		mess.Channel__c = sChannel;

		System.debug('parse.return ' + mess);
		return mess;
	}

	public static Visitor__c getVisitor(string sid, string sChatNumber, string channel)
	{
		Visitor__c ret;
		list<Visitor__c> lVisitors = DM080_Visitor.getRecordsbyNumber(sid);

		if (!lVisitors.isEmpty())
        {
            ret = lVisitors[0];
        }else
		{
			ret = new Visitor__c(Id__c = sid, Context__c = null, Chat_Number__c = sChatNumber, Chanel__c = channel);
		}
		return ret;
	}

	@HttpPost
	global static list<NexmoMessage__c> getMessage()
	{
		return getMessage0(RestContext.request.requestBody.toString());
	}
	global static list<NexmoMessage__c> getMessage0(string jsonbody)
	{
		Visitor__c visr;
		datetime dtBeg = datetime.now();
		string errMsg = '';
		NexmoMessage__c mess0 = new NexmoMessage__c();
		list<NexmoMessage__c>lMess = new list<NexmoMessage__c>();
		try
		{
			mess0 = parse(jsonbody);
			if (mess0 == null)
				return lMess;
			visr = getVisitor(mess0.From__c, mess0.To__c, mess0.Channel__c);

			mess0.Received__c = dtBeg;
			//Use deserializer via maps here
//            list<NexmoMessage__c> lold = [select id from NexmoMessage__c where Name = :mess0.name];
//            if(lold.isEmpty())
			{
				list<MessageOptions> aRetStr = getResponse(mess0, visr);
				system.debug(aRetStr);
				if (aRetStr != null)
				{

					mess0.Response2__c = String.join(aRetStr, '\t');
					if (mess0.Response2__c != null && mess0.Response2__c.length() > 32000)
						mess0.Response2__c = mess0.Response2__c.substring(0, 32000);
					string sPrevContext = visr.Context__c;
					for (MessageOptions opt : aRetStr)
					{
						opt.send(visr);
					}
					if (sPrevContext != visr.Context__c)
					{
						Visitor__c v = new Visitor__c(Id = visr.Id, Context__c = visr.Context__c);
						update v;
					}
					lMess.add(mess0);
				}
			}
		}
		catch (MyException e)
		{
			errMsg = e.getMessage();
			if (mess0 != null && mess0.From__c != null)
			{
				sendText(mess0.From__c, errMsg, mess0.To__c);
			}
			if (Test.isRunningTest())
				throw e;
		}
		catch (Exception e)
		{
			errMsg = '' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString();
			if (mess0 != null && mess0.From__c != null)
				sendText(mess0.From__c, errMsg, mess0.To__c);
			if (Test.isRunningTest())
				throw e;
		}
		finally
		{
			if (mess0 != null)
			{
				SM005_Logs.LogCallOut('', 'Nexmo', jsonbody, JSON.serialize(lMess), dtBeg, Datetime.now(), errMsg);
				SM005_Logs.save();
				SM010_Utils.saveTran();
				if (mess0 != null)
				{
					mess0.Responded__c = Datetime.now();
					mess0.Duration__c = mess0.Responded__c.getTime() - mess0.Received__c.getTime();
				}
				if (lMess != null)
					insert lMess;
			}
		}
		return lMess;
	}

	public static void sendText(string sTo, string messageText, string sFrom)
	{
		SM042_NexmoOut2.sendText(sTo, messageText, sFrom);
	}

//	public static void sendText(string sTo, list<string> aMessageText, string sFrom)
//	{
//		if (aMessageText != null && !aMessageText.isEmpty())
//			SM033_NexmoOut.sendTextAsync(sTo, aMessageText, sFrom, sFrom);
//	}

//	public static string getLanguage(CVL__Loy_Member__c mem)
//	{
//		if (mem.language__c == null || mem.language__c == '')
//		{
//			mem.language__c = 'en';
//		}
//		return mem.language__c;
//	}
//
//	public static string tran(string str)
//	{
//		return SM010_Utils.translate(str);
//	}
//
//	public static void setLanguage(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		if (resp.parameters != null)
//		{
//			string lang = resp.parameters.get('lang');
//			if (lang != null)
//			{
//				mem.language__c = lang;
//			}
//			SM010_Utils.lang = getLanguage(mem);
//		}
//	}

//	public static list<string> offers(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		mem.WhatsAppContext__c = 'offers';
//		list< string>lret = new list<string>();
//		lret.add(/*SM033_URLShorter.shorter*/('http://www.360mall.com/en/offers/') + ' \n\n' +
//				tran('Is there anything else I can help you with:') + '\n' + '\n' +
//				tran('1 - More on 360MALL') + '\n' +
//				tran('0 - Back to Menu'));
//		return lret;
//	}

//	public static list<string> events(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		mem.WhatsAppContext__c = 'events';
//		list< string>lret = new list<string>();
//		lret.add(/*SM033_URLShorter.shorter*/('http://www.360mall.com/en/event/') + ' \n\n' +
//				tran('Is there anything else I can help you with:') + '\n' + '\n' +
//				tran('1 - More on 360MALL') + '\n' +
//				tran('0 - Back to Menu'));
//		return lret;
//	}

//	public static list<string> openHours(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		mem.WhatsAppContext__c = 'openHours';
//		list< string>lret = new list<string>();
//		lret.add(tran('Here\'s our Stores opening Hours:') + '\n' + '\n' +
//				tran('10:00 am – 10:00 pm (Sunday – Wednesday)') + '\n' +
//				tran('10:00 am – 11:00 pm (Thursday – Saturday)') + '\n' + '\n' +
//				tran('Is there anything else I can help you with:') + '\n' + '\n' +
//				//             tran('1 - More on 360MALL')+'\n'+
//				tran('0 - Back to Menu'));
//		return lret;
//	}
//
//	public static string more(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		mem.WhatsAppContext__c = 'more';
//		string ret = tran('How about learning more on:') + '\n' +
//				//          tran('Choose an option below:')+'\n'+'\n'+
//				tran('1 - Mall Events,') + '\n' +
//				tran('2 - Mall Offers,') + '\n' +
//				tran('3 - Mall Timings  ') + '\n' +
//				tran('0 - Back to Main Menu');
//		return ret;
//	}
//	public static string mainMenu(CVL__Loy_Member__c mem)
//	{
//		if (skipLoyalty())
//			return mainMenu2(mem);
//
//		mem.WhatsAppContext__c = 'menu';
//		mem.WhatsAppPageIndex__c = 0;
//		string ret = '\n\n' + tran('Would you  like to:') + '\n' + '\n' +
//				tran('1 - Earn points now,') + '\n' +
//				tran('2 - Check your balance or') + '\n' +
//				tran('3 - Check out the list of participating restaurants') + '\n' +
//				tran('4 - Know more') + '\n' +
//				'\n' +
//				tran('Simply type the number of your choice below...') + '\n';
//		return ret;
//	}
//	public static list<string> changeName(CVL__Loy_Member__c mem, NexmoMessage__c mess)
//	{
//		list<string> lret = new list<string>();
//		if (mess.Text__c != null && mess.Text__c != '')
//		{
//			account acc = new account(Id = mem.CVL__Account__c);
//			acc.Name = mess.Text__c;
//			update acc;
//			lret.add(tran('Thanks! Nice to meet you ') + acc.Name);//+'\n'+tran('By the way, you may ask me anything related to 360 Mall at any time.'));
//			if (!skipLoyalty())
//			{
//				lret.add(
//						tran('Did you know about our Dine&Win Program? ') + '\n' +
//								tran('It\'s simple, collect a total of 100 points from our participating restaurants in our Food Lounge on Level 1 to redeem a complimentary movie ticket at Cinespace.') + '\n' +
//								tran('You earn 10 point for each 1 KWD spent. \n Enjoy!'));
//			}
//
//			//          lret.add(mainMenu(mem));
//			lret.addAll(mainMenu3(mem));
//		}
//		else
//		{
//			lret.add(tran('Please enter non-empty name:'));
//		}
//		return lret;
//	}
//	public static list<string> yesRestraunts(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		list<string>lret = new list<string>();
//		lret.addAll(participating2(mem, resp));
//		lret.add(mainMenu(mem));
//		return lret;
//	}
//
//	public static list<string> noRestraunts(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		list<string>lret = new list<string>();
//		lret.add(tran('Ok, maybe later… '));
//		lret.add(mainMenu(mem));
//		return lret;
//	}
//
//
//	public static list<string> welcome(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		list<string>lret = new list<string>();
//		string str = string.format(tran('Welcome back {0}! I hope you are doing well today.'), new String[]
//		{
//				mem.Full_Name__c
//		});
//		if (!skipLoyalty())
//			str += '\n' + string.format(tran('Your current balance is {0}.'), new String[]
//			{
//					'' + mem.CVL__Points_2__c
//			});
//		lret.add(str);
//		if (!skipLoyalty())
//			lret.add(tran('If you want to continue earning more points, visit participating restaurants: ') + 'http://www.360mall.com/en/dine/');
//		return lret;
//	}
//	public static list<string> participating2(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		list<string>lret = new list<string>();
//		lret.add(tran('You can find out about the participating restaurants here: ') + 'http://www.360mall.com/en/dine/');
//		return lret;
//	}
//
//	public static list<string> participating(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		list<string>lret = new list<string>();
//
//		list<account>lacc = SM022_OutletsSearch.searchAccByKeyWord('', mem.CVL__Program__c, SM010_Utils.lang);
//		decimal iBegin = mem.WhatsAppPageIndex__c;
//		if (iBegin == null)
//			iBegin = 0;
//		boolean bEnd = true;
//		integer i = 0;
//		for (account acc : lacc)
//		{
//			if (i >= iBegin)
//			{
//				if (i >= iBegin + 4)
//				{
//					bEnd = false;
//					break;
//				}
//				lret.add(acc.name + '\n' + acc.Website);
//			}
//			i++;
//		}
//
//		if (bEnd)
//			lret.add(mainMenu(mem));
//		else
//		{
//			lret.add(tran('1 - More results') + '\n' + tran('0 - Main Menu'));
//			mem.WhatsAppPageIndex__c = i;
//			mem.WhatsAppContext__c = 'participating';
//		}
//		return lret;
//	}

/*    public static list<account> searchAccByKeyWord(string sKeyWord,string programId)
    {
        map<id,account> mret = new map<id,account>();
        sKeyWord = '%'+sKeyWord+'%';
        list<Category__c> lCat = [select account__r.id from Category__c where Category__c like :sKeyWord and account__r.id != null and account__r.Loy_Program__c = :programId ];
        for(category__c cat :lCat)
        {
            if(cat.account__r.id != null)
            	mret.put(cat.account__r.id,null);
        }
        map<id,account> mret2 = new map<id,account>();        
        list<account>lacc = [select id, name,Image__c,phone,website from account where website != null AND Loy_Program__c =:programId and (id in :mret.keySet() or name like :sKeyWord) order by name];
        for(account acc :lAcc)
        {
            mret2.put(acc.id,acc);
        }
        return (mret2.values());
    }
 */
//	public static string earn(CVL__Loy_Member__c mem)
//	{
//		CVL__Loy_Transaction__c txn = new CVL__Loy_Transaction__c ();
//		txn.Account__c = mem.CVL__Account__c;
//		txn.CVL__Member__c = mem.Id;
//		txn.CVL__Type__c = 'Accural';
//		txn.CVL__Status__c = 'Initial';
//		txn.PIN__c = SM018_ChatTransaction.getUniquePIN(mem.CVL__Program__c);
//		if (test.isRunningTest())
//			txn.PIN__c = '1111';
//		insert txn;
//		map<string, string>mPar = new map<string, string>();
//		mPar.put('txnId', txn.id);
//		//mPar.put('flowName','earn');
//		string ret = tran('Please give this CODE to the cashier: ') + '\n' + '\n' + txn.PIN__c + '\n' + '\n' + tran(' (Customer PIN will expire in 12 hours)');
//		return ret;
//
//	}

//	public static void redeem(CVL__Loy_Member__c mem, string sFrom)
//	{
//		SM005_Session.refresh(mem);
//		redeem(mem.Id, sFrom);
//	}
//	@future(CallOut = true)
//	public static void redeem(id memId, string sFrom)
//	{
//		redeem0(memId, sFrom);
//	}
//
//	public static void redeem0(id memId, string sFrom)
//	{
//		CVL__Loy_Member__c mem = DM003_LoyMember.getRecordforWhatsApp(memId);
//		list<string>lret = new list<string>();
//
//		try
//		{
//			SM010_Utils.lang = getLanguage(mem);
//			SM010_Utils.sProgramId = mem.CVL__Program__c;
//			decimal points = mem.CVL__Points_2__c;
//
//			list<promo_campaign__c> lCamp =
//			[
//					select id,
//							Promo_message__c,
//							image__c,
//							name,
//							message__c,
//							Reedem_Amount__c
//					from promo_campaign__c
//					where
//					Loy_Program__c = :mem.CVL__Program__c
//					and (Expiry_Date__c = null OR Expiry_Date__c > TODAY)
//			];
//
//			if (lCamp.isEmpty())
//			{
//				lret.add(tran('You don\'t have any coupons at the moment.'));
//			}
//			else
//			{
//				lret.add(tran('Enjoy the movie of your choice at Cinescape 360 MALL'));
//				string sText = '';
//				decimal iBegin = mem.WhatsAppPageIndex__c;
//				if (iBegin == null)
//					iBegin = 0;
//				boolean bEnd = true;
//				integer i = 0;
//				for (promo_campaign__c camp : lCamp)
//				{
//
//					if (i >= iBegin)
//					{
//						if (i >= iBegin + 4)
//						{
//							bEnd = false;
//							break;
//						}
//						sText += camp.name + '\n';
//
//						boolean bShowButton = false;
//						if (camp.Reedem_Amount__c != null && camp.Reedem_Amount__c != 0 && points > 0 && points > camp.Reedem_Amount__c)
//						{
//							integer tic = Integer.valueof(points) / Integer.valueOf(camp.Reedem_Amount__c);
//							//                           sText+= tran('Take up to ')+tic+tran(' coupons.')+'\n';
//							bShowButton = true;
//						}
//						else if (camp.Reedem_Amount__c != null && camp.Reedem_Amount__c != 0 && points != null && points < camp.Reedem_Amount__c)
//						{   //format
//							//         Earn {9} more points to get {one complimentary movie ticket from Cinescape!}
//							sText += +String.format(tran('Earn {0} more points to get this coupon.'), new String[]
//							{
//									String.valueOf((camp.Reedem_Amount__c - points))
//							}) + '\n\n';
//						}
//						else
//						{
//							//                          sText+=  camp.message__c+'\n';
//							bShowButton = true;
//						}
//						if (bShowButton)
//						{
//							string sURL = SM033_URLShorter.shorter(SM010_Utils.getValue('web_url') + 'redeem.html?campId=' + camp.id + '&sessId=' + mem.Session__c + '&from=' + sFrom);
//							//                          sText += tran('Redeem: ')+sURL+'\n';
//							sText += string.format(tran('Redeem: {0}'), new String[]
//							{
//									sURL
//							}) + '\n\n';
//						}
//						string sURL2 = SM033_URLShorter.shorter(SM010_Utils.getValue('web_url') + 'terms2.html?id=' + camp.id + '&from=' + sFrom);
//						sText += string.format(tran('T&C: {0}'), new String[]
//						{
//								sURL2
//						});
//						i++;
//						lret.add(sText);
//					}
//				}
//				if (!bEnd)
//				{
//					lret.add(tran('1 - More results') + '\n' + tran('0 - Main Menu'));
//					mem.WhatsAppPageIndex__c = i;
//					mem.WhatsAppContext__c = 'redeem';
//				}
//			}
//			if (!lret.isEmpty())
//			{
//				SM033_NexmoOut.sendText(mem.Phone__c, lret, mem.NexmoNumber__c, mem.NexmoNumber__c);
//			}
//
//			update mem;
//		}
//		catch (Exception e)
//		{
//			SM033_NexmoOut.sendText(mem.Phone__c, '' + e.getLineNumber() + ' ' + e.getMessage(), mem.NexmoNumber__c, mem.NexmoNumber__c);
//		}
//		finally
//		{
//			SM005_Logs.save();
//			SM010_Utils.saveTran();
//		}
//	}

//	public static void sendBalance(CVL__Loy_Member__c mem)
//	{
//		sendBalance(mem, null, null);
//	}
//	public static void sendBalance(CVL__Loy_Member__c mem, string scode, decimal quantity)
//	{
//		if (mem.Phone__c != null)
//		{
//			list<string> lText = new list<string>();
//
//			mem.WhatsAppContext__c = 'balance';
//			SM010_Utils.sProgramId = mem.CVL__Program__c;
//			SM010_Utils.lang = getLanguage(mem);
//
//			if (scode != null && quantity != null)
//			{
//				//format
//
//				string sMsg = String.format(tran('Congratulations! You have successfully redeemed {0} '), new String[]
//				{
//						'' + quantity
//				});
//				if (quantity == 1)
//					sMsg += tran('ticket.');
//				else
//						sMsg += tran('tickets.');
//				sMsg += '\n\n';
//				sMsg += String.format(tran('To complete transaction please give this code to Cashier: {0}'), new String[]
//				{
//						scode
//				});
//
//				lText.add(sMsg);
//			}
//			lText.addAll(balance(mem, true));
//			sendText(mem.Phone__c, lText, mem.NexmoNumber__c);
//		}
//		update mem;
//	}
//
//	public static list<string> balance(CVL__Loy_Member__c mem)
//	{
//		return balance(mem, false);
//	}
//
//	public static list<string> balance(CVL__Loy_Member__c mem, boolean bNew)
//	{
//		list<string> lret = new list<string>();
//
//		string sMess = '';
//		list<promo_campaign__c> lCamp =
//		[
//				select id,
//						Promo_message__c,
//						image__c,
//						name,
//						message__c,
//						Reedem_Amount__c,
//						Brand__r.Name
//				from promo_campaign__c
//				where
//				Loy_Program__c = :mem.CVL__Program__c
//				and (Expiry_Date__c = null OR Expiry_Date__c > TODAY)
//		];
//		if (bNew)
//			sMess += string.format(tran('Your new balance is {0} points. ') + '\n\n', new String[]
//			{
//					'' + mem.CVL__Points_2__c
//			});
//		else
//				sMess += string.format(tran('Your current balance is {0} points. ') + '\n\n', new String[]
//				{
//						'' + mem.CVL__Points_2__c
//				});
//		integer tic = Integer.valueof(mem.CVL__Points_2__c) / Integer.valueOf(lCamp[0].Reedem_Amount__c);
//		if (tic < 1)
//		{
//			integer miss = Integer.valueOf(lCamp[0].Reedem_Amount__c) - Integer.valueof(mem.CVL__Points_2__c);
//			sMess += string.format(tran('Earn {0} more points to get {1}s from {2}!'), new String[]
//			{
//					'' + miss, lCamp[0].name, lCamp[0].Brand__r.Name
//			});
//			lret.add(sMess);
//			lret.add(mainMenu(mem));
//		}
//		else if (tic == 1)
//		{
//			sMess += string.format(tran('You are now eligible for a {0} complimentary ticket {1} on us. '), new String[]
//			{
//					'' + tic, lCamp[0].Promo_message__c
//			}) + '\n\n'
//					+ tran('Would you like to \n1  -redeem it now or\n0 - go to Main Menu?');
//			lret.add(sMess);
//		}
//		else if (tic > 1)
//		{
//			sMess += string.format(tran('You are now eligible for {0} complimentary tickets {1} on us. '), new String[]
//			{
//					'' + tic, lCamp[0].Promo_message__c
//			}) + '\n\n'
//					+ tran('Would you like to \n1  -redeem it now or\n0 - go to Main Menu?');
//			lret.add(sMess);
//		}
//		return lret;
//	}
//
//	public static string getProgramId(string sTo)
//	{
//		if (Test.isRunningTest())
//			return SM010_Utils.sProgramId;
//		return SM010_Utils.getValue('whatsAppProgramId');
//	}
//
//	public static CVL__Loy_Member__c register0(string sProgramId, string sLastName, string sPhone)
//	{
//		return register0(sProgramId, sLastName, sPhone, 'en');
//	}
//	public static CVL__Loy_Member__c register0(string sProgramId, string sLastName, string sPhone, string sLang)
//	{
//		if (sProgramId == null)
//		{
//			sProgramId = SM010_Utils.getValue('Default_Program_Id');
//		}
//		id typeId = null;
//		list<recordtype> lType =
//		[
//				select id
//				from recordtype
//				where sobjecttype = 'Account' and name = 'Customer'
//		];
//		if (!lType.isEmpty())
//			typeId = lType[0].id;
//		list<account> lAcc =
//		[
//				select id
//				from account
//				where phone = :sPhone and RecordTypeId = :typeId
//		];
//
//		account acc = null;
//		if (!lAcc.isEmpty())
//		{
//			acc = lAcc[0];
//			acc.name = slastname;
//			update acc;
//		}
//		else
//		{
//			acc = new account();
//			acc.name = slastname;
//			acc.Phone = sPhone;
//
//			if (typeId != null)
//				acc.RecordTypeId = typeId;
//			insert acc;
//		}
//		CVL__Loy_Member__c mem = null;
//		list<CVL__Loy_Member__c> lMem =
//		[
//				select id,CVL__Account__c,WhatsAppContext__c,language__C,CVL__Program__c
//				from CVL__Loy_Member__c
//				where CVL__Account__c = :acc.id and CVL__Program__c = :sProgramId
//		];
//		if (!lMem.isEmpty())
//		{
//			mem = lMem[0];
//		}
//		else
//		{
//			mem = new CVL__Loy_Member__c();
//			mem.CVL__Program__c = sProgramId;
//			mem.CVL__Account__c = acc.id;
//			mem.CVL__Joined_Date__c = date.today();
//			mem.WhatsAppContext__c = 'getName';
//			mem.language__c = sLang;//'en';
//			mem.IsActive__c = true;
//			mem.Channel__c = 'WhatsApp';
//			insert mem;
//		}
//		return mem;
//	}
//
//	public static void sendEarnConfirm(CVL__Loy_Transaction__c txn, CVL__Loy_Member__c mem)
//	{
//		SM010_Utils.lang = getLanguage(mem);
//		SM010_Utils.sProgramId = mem.CVL__Program__c;
//		mem.WhatsAppContext__c = 'balance';
//		list<string>lText = new list<string>();
//
//		string txt = string.format(tran ('Congratulations, you have successfully earned {0} points at {1}'), new String[]
//		{
//				'' + Integer.valueOf(txn.CVL__Accrued_Points_2__c), '' + txn.Account__r.name
//		});
//		lText.add(txt);
//		lText.addAll(balance(mem, true));
//
//		update(new CVL__Loy_Member__c(Id = mem.Id, WhatsAppContext__c = mem.WhatsAppContext__c));
//		sendText(mem.Phone__c, lText, mem.NexmoNumber__c);
//	}
//
//
//	public static list<string> GuestServices(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		list<string>lret = new list<string>();
//
//		lret.add('http://www.360mall.com/visitor-info/#Guest-Services' + '\n' +
//				tran('Is there anything else I can help you with?') + '\n' +
//				tran('1 - Mall Events') + '\n' +
//				tran('0 - Back to Menu') + '\n');
////        lret.add(tran('I hope you found what you are looking. How else may I help you?'));
//		return lret;
//	}
//
//
//	public static list<string> MallEvents(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		list<string>lret = new list<string>();
//		lret.add('http://www.360mall.com/en/event/' + '\n' + '\n' +
//				tran('Is there anything else I can help you with?') + '\n' + '\n' +
//				tran('1 - Mall Offers') + '\n' +
//				tran('2 - Dining') + '\n' +
//				tran('0 - Back to Menu'));
////        lret.add(tran('I hope you found what you are looking. How else may I help you?'));
//		return lret;
//	}
//
//	public static list<string> MallOffers(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		list<string>lret = new list<string>();
//		lret.add('http://www.360mall.com/offers/' + '\n' +
//				tran('Is there anything else I can help you with?') + '\n' +
//				tran('1 - Mall Timings') + '\n' +
//				tran('0 - Back to Menu'));
////        lret.add(tran('I hope you found what you are looking. How else may I help you?'));
//		return lret;
//	}
//
//	public static list<string> MallTimings(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		list<string>lret = new list<string>();
//		/*lret.add(tran('Here\'s our opening Hours: ')+'\n'+
//				 tran('10:00 am – 10:00 pm (Sunday – Wednesday)')+'\n'+
//				 tran('10:00 am – 11:00 pm (Thursday – Saturday)')+'\n'+*/
//		lret.add(
//				tran('STORES & RESTAURANTS') + '\n\n' +
//						tran('10:00 am – 10:00 pm (Sunday – Wednesday)') + '\n' +
//						tran('10:00 am – 11:00 pm (Thursday – Saturday)') + '\n\n' +
//						tran('INFUNITY, FREEZE CLUB & THE BOWL ROOM') + '\n\n' +
//						tran('3:00 pm – 11:00 pm (Sunday – Wednesday)') + '\n' +
//						tran('12:00 pm – 12:00 am (Thursday & Friday)') + '\n' +
//						tran('12:00 pm – 11:00 pm (Saturday) Flight Experience') + '\n' +
//						tran('3:00 pm – 11:00 pm (Sunday – Saturday)') + '\n\n' +
//						tran('Is there anything else I can help you with?') + '\n' +
////				tran('1 - More on 360MALL')+'\n'+
//						tran('0 - Back to Menu'));
////        lret.add(tran('I hope you found what you are looking. How else may I help you?'));
//		return lret;
//	}
//	public static list<string>Dining(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		list<string>lret = new list<string>();
//		lret.add(tran('Choose category below:') + '\n' +
//				tran('1 - Restaurants') + '\n' +
//				tran('2 - Cafes') + '\n\n' +
//				tran('0 - Back to Menu'));
//		/*lret.add('http://www.360mall.com/en/dine/'+'\n'+
//				 tran('Is there anything else I can help you with?')+'\n'+
//			tran('1 - Entertainment')+'\n'+
//			 tran('0 - Back to Menu'));*/
////         lret.add(tran('I hope you found what you are looking. How else may I help you?'));
//		return lret;
//	}
//
//	public static list<string>Entertainment(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		list<string>lret = new list<string>();
//		string lang = getLanguage(mem);
//		list<account> lacc = SM022_OutletsSearch.searchAccByKeyWord('Entertainment', mem.CVL__Program__c, 'en');
//		//lret.add('http://www.360mall.com/en/entertainment/'+'\n'+
//		for (account a : lacc)
//		{
//			lret.add((String) a.get('name_' + lang + '__c') + '\n' + a.url__c);
//		}
//		lret.add('Is there anything else i can help you with?' + '\n' + '1 - Directions' + '\n' + '0 - Back to Menu');
////         lret.add(tran('I hope you found what you are looking. How else may I help you?'));
//		return lret;
//	}
//
//	public static list<string> Shops(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		mem.WhatsAppContext__c = 'Shops';
//		list<string>lret = new list<string>();
//		lret.add(tran('Choose category below:') + '\n' +
//				tran('1 - Children & Maternity') + '\n' +
//				tran('2 - Cosmetics, Fragrances') + '\n' +
//				tran('3 - Department Stores') + '\n' +
//				tran('4 - Eyewear') + '\n' +
//				tran('5 - Footwear') + '\n' +
//				tran('6 - Health, Fitness') + '\n' +
//				tran('7 - Home') + '\n' +
//				tran('8 - Hypermerket') + '\n' +
//				tran('9 - Jewellery, Watches') + '\n' +
//				tran('10 - Leather Luggage, Handbags') + '\n' +
//				tran('11 - Lingerie') + '\n' +
//				tran('12 - Men`s Fashion') + '\n' +
//				tran('13 - Services') + '\n' +
//				tran('14 - Specialty Food') + '\n' +
//				tran('15 - Sportswear') + '\n' +
//				tran('16 - Toys') + '\n' +
//				tran('17 - Unisex Fashion') + '\n' +
//				tran('18 - Woman`s Fashion') + '\n\n' +
//				tran('0 - Back to Menu'));
//		/*lret.add('http://www.360mall.com/shopping/'+'\n\n'+
//				 tran('Is there anything else I can help you with?')+'\n\n'+
//				 tran('1 - Entertainment')+'\n'+
//				 tran('0 - Back to Menu'));  */
//		return lret;
//	}
//
//
//	public static list<string> WayFinder(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
//	{
//		mem.WhatsAppContext__c = 'wayfinder1';
//		list<string>lret = new list<string>();
//		lret.add(tran('Where would you like to go? (example: Gucci)'));
//		return lret;
//	}
//
//	public static account getOutletByKeyWord(string keyWord, CVL__Loy_Member__c mem)
//	{
//		account ret = null;
//		string lang = getLanguage(mem);
//		if (keyWord != null && keyWord != '')
//		{
//
//			list<account> lacc = SM022_OutletsSearch.searchAccByKeyWord(keyWord, mem.CVL__Program__c, lang);
//			if (!lacc.isEmpty())
//			{
//				for (account acc : lacc)
//				{
//					if (acc.Location__c != null && acc.Location__c != '')
//					{
//						return acc;
//					}
//				}
//			}
//
//		}
//		return null;
//	}
//	public static string getLocationId(string keyWord, CVL__Loy_Member__c mem)
//	{
//		string sRet = null;
//		account acc = getOutletByKeyWord(keyWord, mem);
//		if (acc != null)
//			sRet = acc.Location__c;
//
//		return sRet;
//	}
//	public static string WayFinderErr()
//	{
//		return tran('Please try again by making sure you spelled the store name correctly or click the following link to access the map:') + '\n' +
//				getFinderURL(null, null) + '\n\n' +
//				'1 - Try Again' + '\n' +
//				'0 - Main Menu';
//	}
//	public static list<string> WayFinder1(CVL__Loy_Member__c mem, NexmoMessage__c mess)
//	{
//		list<string>lret = new list<string>();
//
//		mem.WayFinder_Destination__c = getLocationId(mess.Text__c, mem);
//
//		if (mem.WayFinder_Destination__c != null && mem.WayFinder_Destination__c != '')
//		{
//			lret.addAll(WayFinder1_1(mem));
//		}
//		else
//		{
//			mem.WhatsAppContext__c = 'wayfindererr';
//			lret.add(WayFinderErr());
//		}
//
//		return lret;
//	}
//
//	public static list<string> WayFinder1_1(CVL__Loy_Member__c mem)
//	{
//		list<string>lret = new list<string>();
//		mem.WhatsAppContext__c = 'wayfinder2';
//		lret.add(tran('What is your current location? (example: Gucci)'));
//		return lret;
//	}
//
//
//	public static list<string> WayFinder2(CVL__Loy_Member__c mem, NexmoMessage__c mess)
//	{
//		list<string>lret = new list<string>();
//		mem.WayFinder_Source__c = getLocationId(mess.Text__c, mem);
//
//		if (mem.WayFinder_Source__c != null && mem.WayFinder_Source__c != '')
//		{
//			lret.add(tran('Open this link to view the direction on our map: ') + getFinderURL(mem.WayFinder_Source__c, mem.WayFinder_Destination__c) + '\n\n' + mainMenu(mem));
//		}
//		else
//		{
//			mem.WhatsAppContext__c = 'wayfindererr1';
//			lret.add(WayFinderErr());
//		}
//		return lret;
//	}
//	public static string getFinderURL(string sSource, string sDest)
//	{
//		string sRet = 'https://beta.aislelabs.net/o/misc/webnavigate/gl/index-wp.jsp?id=65&sid=52&alwaysshowspacelabel=true&selectedtab=2';//'https://beta.aislelabs.net/o/misc/webnavigate/gl/index-wp.jsp?id=65&sid=52&alwaysshowspacelabel=true&selectedtab=2';
//		if (sSource != null)
//		{
//			sRet = sRet + '&startingid=' + sSource;
//		}
//		if (sDest != null)
//		{
//			sRet = sRet + '&destinationid=' + sDest;
//		}
//		return SM033_URLShorter.shorter(sRet);
//	}
//
//	public static string mainMenu2(CVL__Loy_Member__c mem)
//	{
//		mem.WhatsAppContext__c = 'menu2';
//		mem.WhatsAppPageIndex__c = 0;
//		string ret = '\n\n' + tran('Would you like to know more about:') + '\n' +
//				tran('1 - Mall Events') + '\n' +
//				tran('2 - Mall Offers') + '\n' +
//				//          tran('3 - Mall Timings')+'\n'+
//				tran('3 - Dining') + '\n' +
//				tran('4 - Entertainment') + '\n' +
//				tran('5 - Shops') + '\n' +
//				tran('6 - Guest Services') + '\n' +
//				tran('7 - Mall Timings') + '\n' +
//				tran('8 - Directions') + '\n' +
////            tran('8 - Directions ')   +'\n'+
//				'\n' +
//				tran('Simply type the number of your choice below or type what\'s on your mind...');
//		return ret;
//	}
//
//	public static list<string> mainMenu3(CVL__Loy_Member__c mem)
//	{
//		list<string>lret = new list<string>();
//
//		mem.WhatsAppContext__c = 'menu3';
//		mem.WhatsAppPageIndex__c = 0;
//		lret.add(tran('You may ask me anything related to 360 MALL at any time. Simply browse the options below and type the number of your choice'));
//		lret.add('http://www.360mall.com/en/event/' + '\n\n' + '1 - Mall Events');
//		lret.add('http://www.360mall.com/en/offers/' + '\n\n' + '2 - Mall Offers');
//		lret.add('http://www.360mall.com/en/dine/' + '\n\n' + '3 - Dining');
//		lret.add('http://www.360mall.com/en/entertainment/' + '\n\n' + '4 - Entertainment');
//		lret.add('http://www.360mall.com/en/shopping/' + '\n\n' + '5 - Shopping');
//		lret.add('http://www.360mall.com/en/visitor-info/' + '\n\n' + '6 - Guest Services');
//		lret.add(tran('For more info on:') + '\n' +
//				tran('7 - Mall Timings') + '\n' +
//				tran('8 - Directions'));
//		return lret;
//	}
	/*
   public static list<string> searchCategory(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp, string fromMenu){
	   integer count = 0;
	   list<string> lret = new list<string>();
	   if (resp.speech != null)
		   lret.add(resp.speech);
	   string cat = resp.intentName;
	   if (FromMenu == 'Shops'){
		   cat = cat.remove('Shops ');
		   mem.WhatsAppContext__c = 'category';
	   }
	   if (FromMenu == 'Dining'){
		   cat = cat.remove('Dining ');
		   mem.WhatsAppContext__c = 'category1';
	   }
	   if (FromMenu != 'Dining' && FromMenu != 'Shops')
		   mem.WhatsAppContext__c = 'category';

	   string lang = getLanguage(mem);
	   list<account> lacc = SM022_OutletsSearch.searchAccByKeyWord(cat, mem.CVL__Program__c, 'en');
	   /*if (fromMenu == 'Rest'){
		   for (account a:lacc){
			   lret.add((String)a.get('name_'+lang+'__c'));
		   }
	   }else{
		for (account a:lacc){
			if (count < 5){
				lret.add((String)a.get('name_'+lang+'__c') + '\n' + a.url__c);
				count++;
			}
		}
		if (lacc.size()>5 && FromMenu != 'Rest'){
			lret.add('Is there anything else i can help you with?'+'\n'+'1 - Directions'+'\n'+'2 - View more'+'\n'+'0 - Back to Menu');
		}else{
			lret.add('Is there anything else i can help you with?'+'\n'+'1 - Directions'+'\n'+'0 - Back to Menu');
		}

		//lret.add(cat);
		return lret;
	}
	public static list<string> Parking(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp){
		list<string>lret = new list<string>();
		lret.add(
			tran('360 MALL offers free outdoor parking as well as paid indoor parking.')+'\n\n'+
			tran('360 MALL multilevel car park charges are as follow (cash only):')+'\n\n'+
			tran('0.200 Fils for first hour')+'\n'+
			tran('0.100 Fils second hour ')+'\n'+
			tran('0.050 Fils any extra hours ')+'\n\n'+
			tran('A 5 KD charge will apply for lost car park tickets.')+'\n\n'+
			tran('Or allow our highly trained valet parking attendants to assist you with parking your car. ')+'\n\n'+
			tran('This service costs 3 K.D. and is available at Gate 1 and 2.')+'\n\n\n'+
			tran('Please note that parking overnight at 360 MALL multi level car park is not permitted.')+'\n'+
			tran('Vehicles will be towed away and the owner will be liable for all costs related.'));
		lret.add(
			tran('Is there anything else I can help you with?')+'\n'+
			tran('0 - Back to Menu'));
		return lret;
	}

	public static list<string> Restrooms(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp){
		list<string>lret = new list<string>();
		lret.add(
			tran('Choose one of our washrooms:')+'\n'+
			tran('1 - Men’s WC Mezzanine')+'\n'+
			tran('2 - Women’s WC Mezzanine')+'\n'+
			tran('3 - Men’s WC Ground Floor')+'\n'+
			tran('4 - Women’s WC Ground Floor')+'\n'+
			tran('5 - Men’s WC 1st Floor')+'\n'+
			tran('6 - Women’s WC 1st Floor')+'\n'+
			tran('7 - Men`s WC 2nd Floor')+'\n'+
			tran('8 - Women`s WC 2nd Floor')+'\n'+
			tran('9 - Basement 1 Men’s WC')+'\n'+
			tran('10 - Basement 1 Women’s WC')
		);
		return lret;
	}

	public static list<string> PrayerRooms(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp){
		list<string>lret = new list<string>();
		lret.add(
			tran('We offer dedicated prayer rooms for men and women.')+'\n'+
			tran('Prayer rooms are located in the Middle Basement.')+'\n\n'+
			tran('1 - Men`s Prayer Rooms')+'\n'+
			tran('2 - Women`s Prayer Rooms')
		);
		return lret;
	}



//        public static list<string> getResponseOld(NexmoMessage__c mess)
//    {
//
//        list<string> lret = new list<string>();
//        string sProgramId =  getProgramId(mess.To__c);
//        SM010_Utils.sProgramId = sProgramId;
//		SM010_Utils.lang = 'en';
//        CVL__Loy_Member__c mem = DM003_LoyMember.getRecordforWhatsApp(mess.From__c,sProgramId);
//        if(mem == null)
//        {
//            SM032_DialogFlow.Resp resp = SM032_DialogFlow.query('',mess.Text__c,'en','360MALL_dialogflow');
//            mem = register0(sProgramId, mess.From__c, mess.From__c);
//            mem.NexmoNumber__c = mess.To__c;
//
//            if(resp.action == 'language')
//                setLanguage(mem, resp);
//            lret.add(tran('Welcome to 360 MALL. My name is Nouf. I will be your virtual companion during your journey with us.'));
//            lret.add(tran('I see it\'s your first time chatting with me. What\'s your name? (example: Mohammed)'));
//        }
//        else
//        {
//            mem.NexmoNumber__c = mess.To__c;
//            SM010_Utils.lang = getLanguage(mem);
//
//            if(mem.WhatsAppContext__c == 'getName')
//                lret.addAll(changeName(mem,mess));
//			else if (mem.WhatsAppContext__c == 'wayfinder1')
//                    lret.addAll(WayFinder1(mem,mess));
//				else if (mem.WhatsAppContext__c == 'wayfinder2')
//                    lret.addAll(WayFinder2(mem,mess));
//            else
//            {
//                SM032_DialogFlow.Resp resp = SM032_DialogFlow.query(mem.WhatsAppContext__c,mess.Text__c,mem.Language__c,'360MALL_dialogflow');
//                mem.WhatsAppContext__c = null;
//                if(resp.action == 'menu')
//                    lret.add(mainMenu(mem));
//                else if(resp.action == 'more')
//                    lret.add(more(mem,resp));
//                else if(resp.action == 'events')
//                    lret.addAll(events(mem,resp));
//                 else if(resp.action == 'offers')
//                    lret.addAll(offers(mem,resp));
//                 else if(resp.action == 'openHours')
//                    lret.addAll(openHours(mem,resp));
//                else if(resp.action == 'language')
//                {
//					setLanguage(mem, resp);
//                    lret.add(mainMenu(mem));
//                }
//                else if(resp.action == 'input.welcome')
//                {
//                    lret.addAll(welcome(mem,resp));
////                   lret.add(mainMenu(mem));
//                    lret.addAll(mainMenu3(mem));
//                }
//                else if (resp.action =='earn' && !skipLoyalty())
//                {
//
//                    lret.add(tran('Make sure you\'re at one of our participating restaurants to earn points. View restaurants: https://www.360mall.com/en/participatingrestaurants')+'\n');
//                      lret.add(earn(mem));
//                }
//
//
//                else if (resp.action == 'redeem'  && !skipLoyalty())
//                    redeem(mem,mess.To__c);
//                else if (resp.action == 'balance'  && !skipLoyalty())
//                {
//					mem.WhatsAppContext__c = 'balance';
//                    lret.addAll(balance(mem));
//                }
//                 else if (resp.action == 'participating')
//                 {
//                     lret.addAll(participating2(mem,resp));
//                     lret.add(mainMenu(mem));
//                 }
//                else if(resp.action == 'yesRestraunts')
//                {
//                    lret.addAll(yesRestraunts(mem,resp));
//                }
//                else if(resp.action == 'noRestraunts' || (resp.action == 'smalltalk.confirmation.no' && mem.WhatsAppContext__c == 'aksRestraunts'))
//                    lret.addAll(noRestraunts(mem,resp));
//                else if(resp.action == 'GuestServices')
//                    lret.addAll(GuestServices(mem,resp));
//                 else if(resp.action == 'MallEvents')
//                    lret.addAll(MallEvents(mem,resp));
//                 else if(resp.action == 'MallOffers')
//                    lret.addAll(MallOffers(mem,resp));
//                 else if(resp.action == 'MallTimings')
//                    lret.addAll(MallTimings(mem,resp));
//                 else if(resp.action == 'Dining')
//                    lret.addAll(Dining(mem,resp));
//                else if(resp.action == 'Shops')
//                    lret.addAll(Shops(mem,resp));
//                 else if(resp.action == 'Entertainment')
//                    lret.addAll(Entertainment(mem,resp));
// 				else if (resp.action == 'wayfinder')
//                    lret.addAll(WayFinder(mem,resp));
// 				else if (resp.action == 'wayfinder1')
//                    lret.addAll(WayFinder1_1(mem));
//                else if (resp.action == 'category')
//                    lret.addAll(SearchCategory(mem,resp,'main'));
//                else if (resp.action == 'category1')
//                    lret.addAll(SearchCategory(mem,resp,'Shops'));
//                else if (resp.action == 'category2')
//                    lret.addAll(SearchCategory(mem,resp,'Dining'));
//                else if (resp.action == 'restroom')
//                    lret.addAll(Restrooms(mem,resp));
//                else if (resp.action == 'parking')
//                    lret.addAll(Parking(mem,resp));
//                else if (resp.action == 'prayerrooms')
//                    lret.addAll(PrayerRooms(mem,resp));
//                else if (resp.action == 'direction')
//                {
//                    string sRet = resp.speech;
//
//                    account acc = getOutletByKeyWord(resp.intentName,mem);
//                    if (acc != null){
//                        if(acc.Location__c != null && acc.Location__c != '')
//                        {
//                            mem.WhatsAppContext__c = 'Outlet';
//                            mem.WayFinder_Destination__c = acc.Location__c;
//                    	}
//                    }
//                    lret.addAll(WayFinder1_1(mem));
//                }
//                else
//                {
//                    string sRet = resp.speech;
//
//                    account acc = getOutletByKeyWord(resp.intentName,mem);
//                    if (acc != null)
//                    {
////						lret.add(acc.name);
//                        if(acc.Website != '' && acc.Website != null)
//                            sRet+='\n'+acc.Website;
//						if(acc.Phone != '' && acc.Phone != null)
//                        	sRet+='\n'+tran('Call Now: ')+acc.Phone;
//
//                        if(acc.Location__c != null && acc.Location__c != '')
//                        {
//                            mem.WhatsAppContext__c = 'Outlet';
//                            mem.WayFinder_Destination__c = acc.Location__c;
//            				sRet+='\n\n'+tran('1 - Get Direction')+'\n'+tran('0 - Back to Menu');
//                        }
//                    }
//                    lret.add(sRet);
//                }
//            }
//        }
//        Database.update(mem,false);
//        return lret;
//    }
*/


}