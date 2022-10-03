@RestResource(urlMapping='/nexmo2/*')
global class SM031_Nexmo2
{

	global static Boolean bContextChanged = false;
	global static Decimal scoreLUIS = 0;
	global static Decimal scoreQnA = 0;
	global static String intentLUIS = '';
	global static String triggeredFlow = '';
	global static SM080_LUIS.LuisResponse respLuis = null;
	global static Boolean triggeredLUIS = false;
	public static Visitor__c visUpdate = null;

	@HttpPost
	global static String getMessage()
	{
		getMessage0 (RestContext.request.requestBody.toString());
		return '';
	}

	public static List<MessageOptions> getResponse(CVCH__NexmoMessage__c mess, CVCH__Visitor__c visr)
	{
		List<MessageOptions> lret = new List<MessageOptions>();
		Boolean bProceeded = false;
		Boolean TriggerDefaultFlow = false;
		String translatedText = '';
		MTranslation tran = new MTranslation();
		tran.detectedlang = 'en';
		Boolean TriggerDefaultFlowChangeLang = false;
		Boolean flowinput = false;

		Map<String, Object> params = new Map<String, Object>();
		if (visr.Id != null)
		{
			params.put('visitorId', visr.Id);
		}
		params.put('visphone', visr.CVCH__Id__c);
		params.put('visitorName', mess.From_Name__c);
		params.put('ChatNumber', visr.CVCH__Chat_Number__c);
		params.put('channel', visr.CVCH__Chanel__c);
		params.put('originalmessage', mess.CVCH__Text__c);
		params.put('language', tran.detectedlang);
		params.put('visitorlanguage', visr.language__c);
		params.put('input', mess.CVCH__Text__c);


		if (visr.CVCH__Context__c != null && visr.CVCH__Context__c != '')
		{ //if we received input, dont have to translate it
			MessageOptions mo = (MessageOptions) JSON.deserialize(visr.Context__c, MessageOptions.class);
			if (mo.sType == 'Input')
			{
				if (mo.sInputType == 'Name' || mo.sInputType == 'Email')
				{
					flowinput = true;
				}
			}
		}

		SM080_QnA.QnAResponse respQnA = new SM080_QnA.QnAResponse();
		respQnA.dScore = 0;
		if (mess.CVCH__InputType__c == 'button')
		{
			respLuis = new SM080_LUIS.LuisResponse();
			respLuis.sIntent = mess.Text__c;
			respLuis.dScore = 100;
			respQnA = new SM080_QnA.QnAResponse();
			respQnA.dScore = 0;
			if (mess.CVCH__ImageURL__c != null && mess.CVCH__ImageURL__c != '')
			{
				mess.CVCH__Text__c = mess.CVCH__ImageURL__c;
			}
		}
		else if (mess.InputType__c == 'location')
		{
			respLuis = new SM080_LUIS.LuisResponse();
			respLuis.sIntent = 'location';
			respLuis.dScore = 100;
			respQnA = new SM080_QnA.QnAResponse();
			respQnA.dScore = 0;
			mess.CVCH__Text__c = Location.getLocation()[0].url;
		}
		else if (mess.Text__c != null)
		{
			if (visr.language__c != 'en' && !flowinput)
			{
				tran = SM080_Translate.translate0(mess.Text__c);
				translatedText = tran.translation;
			}
			else
			{
				translatedText = mess.Text__c;
			}


			//system.debug('Translated input: ' + translatedText);

			respLuis = SM080_LUIS.queryPhrase(translatedText, visr.CVCH__language__c, mess.To__c);
			if (visr.CVCH__GDPR_Consent__c != 'No Access')
			{
				respQnA = SM080_QnA.queryPhrase(translatedText, visr.CVCH__language__c, mess.To__c);
				scoreQnA = respQnA.dScore;
			}
			scoreLUIS = respLuis.dScore;
			intentLUIS = respLuis.sIntent;
			if (respLuis.dScore < SM010_Utils.getMinResponseScore() && respQnA.dScore < SM010_Utils.getMinResponseScore())
			{
				if (tran.detectedlang != visr.language__c)
				{
					TriggerDefaultFlowChangeLang = true;
				} // We will trigger Default Flow 2, if both scores are below set treshold and if user typed in different language
				else if (visr.language__c == 'en')
				{
					tran = SM080_Translate.translate0(mess.Text__c);
					if (tran.detectedlang != 'en')
					{
						TriggerDefaultFlowChangeLang = true;
					} // We will trigger Default Flow 2, if both scores are below set treshold and if user typed in different language
					else
					{
						TriggerDefaultFlow = true;
					} // We will trigger Default Flow, if both scores are below set treshold and if user typed in same language
				}
				else
				{
					TriggerDefaultFlow = true;
				} // We will trigger Default Flow, if both scores are below set treshold and if user typed in same language
			}

		}
		else
		{
			respLuis = new SM080_LUIS.LuisResponse();
			respLuis.sIntent = 'Image';
			respLuis.dScore = 100;
			respQnA = new SM080_QnA.QnAResponse();
			respQnA.dScore = 0;
			mess.CVCH__Text__c = mess.CVCH__ImageURL__c;
		}


		System.debug('mess=');
		System.debug(mess);
		if (visr.CVCH__Livechat_Session_Key__c != null && visr.CVCH__Livechat_Session_Key__c != '')
		{
			if (respLuis != null && respLuis.sIntent == 'EndChat')
			{
				LiveChatMonitor.Disconnect(visr);
			}
			else
			{
				if (respLuis.sIntent == 'Image' && mess.CVCH__Text__c != null && !mess.CVCH__Text__c.startsWith(CVCH.SM010_Utils.getChat2aiValue('S3URL')))
				{
					if (SM010_Utils.getChat2aiValue2('Skip LiveChat File S3 Upload') != 'TRUE')
					{
						SM090_UploadS3.S3Output ret = SM090_UploadS3.getS3URL(mess.CVCH__Text__c);
						if (ret.S3URL != null)
						{
							mess.CVCH__Text__c = ret.S3URL;
						}
						else
						{
							throw new MyException('Error: ' + ret.Error);
						}
					}
				}
				try
				{
					SM093_LiveAgent.ChatMessage(SM093_LiveAgent.getMessageText(mess), visr);
				}
				catch (Exception e)
				{
					String errorMess = e.getMessage();
					if (errorMess.indexOf(SM093_LiveAgent.sessionRequired) >= 0)
					{
						LiveChatStatusBatch.terminateChat(visr);
					}
				}
			}
		}
		else
		{
			String sFlow;
			if (respLuis.dScore < SM010_Utils.getMinResponseScore())
			{
				sFlow = SM099_FlowMapping.getFlow(null, mess.Text__c);
			}
			else
			{
				sFlow = SM099_FlowMapping.getFlow(respLuis.sIntent, mess.Text__c);
			}
			if (visr.CVCH__Had_First_Interaction__c == false)
			{
				System.debug('CVCH__Had_First_Interaction__c=false');
				bProceeded = true;

				if (visr.Id == null && (Test.isRunningTest() || SM010_Utils.getChat2aiValue2('CREATE VISITOR BEFORE FLOWS') == 'TRUE'))
				{
					insert visr;
					System.debug('inserted visr');
				}

				if (SM010_Utils.getChat2aiValue2('CREATE VISITOR BEFORE FLOWS') == 'TRUE' || visr.Id != null)
				{
					params.put('visitorId', visr.Id);
				}
				params.put('visitorName', mess.From_Name__c);
				System.debug('visitor=' + visr);

				String sFlow2 = SM010_Utils.getChat2aiValue2('Welcome Flow');
				if (sFlow2 != '')
				{
					System.debug('Welcome Flow: ' + JSON.serialize(params));
					SM010_Utils.getFlow(sFlow2, mess.To__c, params).start();
					triggeredFlow = 'Welcome Flow';
				}
			}
			else if (SM031_Nexmo.apexGDPR() && visr.CVCH__GDPR_Consent__c == 'No Access' && (visr.CVCH__Context__c == '' || visr.CVCH__Context__c == null)) //Restrict Non-GDPR users
			{
				System.debug('No Access');
				bProceeded = true;
				Flow.Interview flow = SM010_Utils.getFlow(SM010_Utils.getChat2aiValue('GDPR Flow'), mess.To__c, params);
				flow.start();
			}
			else if (SM031_Nexmo.apexGDPR() && visr.CVCH__GDPR_Consent__c == 'No Access' && visr.CVCH__Context__c != '' && visr.CVCH__Context__c != null)
			{
				System.debug('start flow: GDPR Flow');
				bProceeded = true;

				MessageOptions mo = (MessageOptions) JSON.deserialize(visr.CVCH__Context__c, MessageOptions.class);
				System.debug('GDPR MessageOptions=' + mo);
				Option opt = mo.mOptions.get(mess.CVCH__Text__c);
				if (opt == null)
				{
					opt = SM010_Utils.getOption(mo.mOptions, mess.CVCH__Text__c); // if input wasnt valid number of option - try to get it with label
				}
				if (opt != null && opt.sFlow != null)
				{
					if (opt.sName != null)
					{
						params.put(opt.sName, opt.sValue);
					}
					if (opt.sName2 != null)
					{
						params.put(opt.sName2, opt.sValue2);
					}
					if (opt.sName3 != null)
					{
						params.put(opt.sName3, opt.sValue3);
					}
					Flow.Interview flow = SM010_Utils.getFlow(opt.sFlow, mess.To__c, params);
					flow.start();
					triggeredFlow = 'GDPR Flow';
				}
				else if (SM010_Utils.getChat2aiValue2('GDPR Flow') != '')
				{
					Flow.Interview flow = SM010_Utils.getFlow(SM010_Utils.getChat2aiValue('GDPR Flow'), mess.To__c, params);
					flow.start();
					triggeredFlow = 'GDPR Flow';
				}

			}
			else if (sFlow != null)
			{
				SM010_Utils.getFlow(sFlow, mess.To__c, params).start();
				bProceeded = true;
			}
			else if (!TriggerDefaultFlow && !TriggerDefaultFlowChangeLang && respLuis.dScore > respQnA.dScore && respLuis.sIntent == 'exit' && SM010_Utils.getChat2aiValue2('Main Menu Flow') != '')
			{
				System.debug('start flow: Main Menu Flow');
				bProceeded = true;
				params.put('language', tran.detectedlang);
				Flow.Interview flow = SM010_Utils.getFlow(SM010_Utils.getChat2aiValue2('Main Menu Flow'), mess.To__c, params);
				flow.start();
				CVCH__Visitor__c v = new CVCH__Visitor__c(Id = visr.Id, CVCH__Next_Flow__c = null);
				if (visr.Current_Flow__c != null && visr.Current_Flow__c != '')
				{
					EventBus.publish(new User_Input__e(Input__c = mess.Text__c, Exit_Flow__c = true, VisitorId__c = visr.Id));
					v.Current_Flow__c = null;
				}
				update v;
				triggeredFlow = 'Main Menu Flow';
			}
			else if (visr.Current_Flow__c != null && visr.Current_Flow__c != '')
			{
				System.debug('FIRE USER INPUT EVENT');
				bProceeded = true;
				Map<String, Object> mEntities = new Map<String, Object>();
				String visEmail = '';
				String visName = '';
				if (respLuis.getEntities() != null && respLuis.getEntities() != '')
				{
					mEntities = (Map<String, Object>) JSON.deserializeUntyped(respLuis.getEntities());
					if (mEntities.get('email') != null)
					{
						visEmail = String.valueOf(mEntities.get('email'));
					}
					if (mEntities.get('personName') != null)
					{
						visName = String.valueOf(mEntities.get('personName'));
					}
				}
				EventBus.publish(new User_Input__e(Input__c = mess.Text__c, Exit_Flow__c = false, VisitorId__c = visr.Id, Filtered_Email__c = visEmail, Filtered_Name__c = visName));
				triggeredFlow = visr.Current_Flow__c;
			}
			else if (visr.CVCH__Next_Flow__c != null && visr.CVCH__Next_Flow__c != '')
			{
				System.debug('start flow: CVCH__Next_Flow__c');

				SM010_Utils.getFlow(visr.CVCH__Next_Flow__c, mess.To__c, params).start();
				triggeredFlow = visr.Next_Flow__c;
			}
			else if (mess.CVCH__Flow__c != null && mess.CVCH__Flow__c != '')
			{
				SM010_Utils.getFlow(mess.CVCH__Flow__c, mess.To__c, params).start();
				triggeredFlow = visr.Next_Flow__c;
				bProceeded = true;
			}
			else if (visr.CVCH__Context__c != null && visr.CVCH__Context__c != '')
			{
				System.debug('start flow: CVCH__Context__c');
				MessageOptions mo = (MessageOptions) JSON.deserialize(visr.Context__c, MessageOptions.class);
				System.debug('MessageOptions=' + mo);
				if (mo.sType == 'Input')
				{
					bProceeded = true;
					Map<String, Object> mEntities = new Map<String, Object>();
					if (respLuis.getEntities() != null && respLuis.getEntities() != '')
					{
						mEntities = (Map<String, Object>) JSON.deserializeUntyped(respLuis.getEntities());
					}
					//input type check
					if (mo.sInputType == 'Email')
					{
						if (mEntities.get('email') != null)
						{
							mess.Text__c = String.valueOf(mEntities.get('email'));
						}
						else
						{
							params.put('type', 'Email');
							Flow.Interview flow = SM010_Utils.getFlow(SM010_Utils.getChat2aiValue('Input Validation Error Flow'), mess.To__c, params);
							flow.start();
							return lret;
						}
					}
					if (mo.sInputType == 'Name')
					{
						if (mEntities.get('personName') != null)
						{
							mess.Text__c = String.valueOf(mEntities.get('personName'));
						}
						else
						{
							params.put('type', 'Name');
							Flow.Interview flow = SM010_Utils.getFlow(SM010_Utils.getChat2aiValue('Input Validation Error Flow'), mess.To__c, params);
							flow.start();
							return lret;
						}
					}

					Visitor__c v = new Visitor__c(Id = visr.Id);

					Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
					Schema.SObjectType leadSchema = schemaMap.get('CVCH__Visitor__c');
					Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
					if (mo.sFieldName != '' && mo.sFieldName != null)
					{
						try
						{
							if (fieldMap.get(mo.sFieldName).getDescribe().getType() == Schema.DisplayType.DATE)
							{
								Pattern pat = Pattern.compile('^\\d{1,2}\\/\\d{1,2}\\/\\d{4}$');
								if (!pat.matcher(mess.Text__c).matches())
								{
									String dateEx = SM010_Utils.getChat2aiValue2('INVALID_DATE');
									if (dateEx == '')
									{
										dateEx = 'Invalid date format. Please provide dd/MM/yyyy';
									}
									throw new MyException(dateEx);
								}
								v.put(mo.sFieldName, Date.parse(mess.Text__c));
							}
							else
							{
								v.put(mo.sFieldName, mess.Text__c);
							}
						}
						catch (MyException ex)
						{
							throw ex;
						}
						catch (Exception e)
						{
							v.put(mo.sFieldName, mess.Text__c);
						}

						v.Context__c = '';
						update v;
					}
					if(mo.OrchestrationInstance != '' && mo.OrchestrationInstance != null)
					{
						bProceeded = true;
						v.Context__c='';
						v.Input_Reply_Value__c = mess.Text__c;
						update v;
						SM031_Nexmo2.publishEvent(mo.OrchestrationInstance);
//						EventBus.publish(new FlowOrchestrationEvent(OrchestrationInstanceId= mo.OrchestrationInstance));
					}

					if (mo.sFlow != null && mo.sFlow != '')
					{
						if (mo.flowParamsJSON != null && mo.flowParamsJSON != '')
						{
							try
							{
								Map<String, Object> mParams2 = (Map<String, Object>) JSON.deserializeUntyped(mo.flowParamsJSON);
								params.putAll(mParams2);
							}
							catch (Exception e)
							{

							}
						}

						if (mo.sParamName != '' && mo.sParamName != null)
						{
							params.put(mo.sParamName, mess.Text__c);
						}

						Flow.Interview flow = SM010_Utils.getFlow(mo.sFlow, mess.To__c, params);
						flow.start();
						triggeredFlow = mo.sFlow;
					}

					if (mo.sFieldName == '' || mo.sFieldName == null)
					{
						if (bContextChanged != true)
						{
							CVCH__Visitor__c vis = new CVCH__Visitor__c(Id = v.Id, CVCH__Context__c = '');
							update vis;
						}
					}
				}
				else
				{
					System.debug('getting option ' + mess.CVCH__Text__c + ' from ' + mo.mOptions);
					Option opt = mo.mOptions.get(mess.CVCH__Text__c);
					if (opt == null)
					{
						opt = SM010_Utils.getOption(mo.mOptions, mess.CVCH__Text__c); // if input wasnt valid number of option - try to get it with label
					}
					if (opt != null)
					{
						System.debug('found option ' + opt);
						if (opt.sType == 'QnA')
						{
							Integer qnaid = Integer.valueOf(opt.sValue);

							SM080_QnA.QnAResponse respQnA2 = SM080_QnA.getQNA(qnaid, visr.CVCH__language__c, mess.To__c);
							lret.add(new MessageOptions(respQnA2));
							bProceeded = true;
						}
						else
						{
							bProceeded = true;
							if (opt.sFlow != null)
							{
								if (opt.sName != null)
								{
									params.put(opt.sName, opt.sValue);
								}
								if (opt.sName2 != null)
								{
									params.put(opt.sName2, opt.sValue2);
								}
								if (opt.sName3 != null)
								{
									params.put(opt.sName3, opt.sValue3);
								}
								Flow.Interview flow = SM010_Utils.getFlow(opt.sFlow, mess.To__c, params);
								flow.start();
								triggeredFlow = opt.sFlow;
							}
						}
					}
				}
			}

			if (!bProceeded && TriggerDefaultFlowChangeLang && SM010_Utils.getChat2aiValue2('Default Flow 2') != '')
			{
				System.debug('start flow: Default Flow 2');
				bProceeded = true;
				SM010_Utils.getFlow(SM010_Utils.getChat2aiValue2('Default Flow 2'), mess.To__c, params).start();
				triggeredFlow = 'Default Flow 2';
			}
			if (!bProceeded && TriggerDefaultFlow && SM010_Utils.getChat2aiValue2('Default Flow') != '')
			{
				System.debug('start flow: Default Flow');
				bProceeded = true;
				SM010_Utils.getFlow(SM010_Utils.getChat2aiValue2('Default Flow'), mess.To__c, params).start();
				triggeredFlow = 'Default Flow';
			}
			if (!bProceeded)
			{
				System.debug('start flow: Chat2ai Flow');
				System.debug('LUIS score=' + respLuis.dScore + ',QnA score=' + respQnA.dScore);
				if (respLuis.dScore > respQnA.dScore)
				{
					params.put('intent', respLuis.sIntent);
					params.put('entities', respLuis.getEntities());

					Flow.Interview chat2aiflow = SM010_Utils.getFlow(SM010_Utils.getChat2aiValue('Chat2ai Flow'), mess.To__c, params);
					chat2aiflow.start();
					triggeredFlow = intentLUIS;
					triggeredLUIS = true;
				}
				else
				{
					lret.add(new MessageOptions(respQnA));
				}
			}
		}
		return lret;
	}

	public static void publishEvent(string instanceId)
	{
		EventBus.publish(new FlowOrchestrationEvent(OrchestrationInstanceId= instanceId));
	}


	global static List<CVCH__NexmoMessage__c> getMessage0(String jsonbody)
	{
		CVCH__Visitor__c visr;
		Datetime dtBeg = Datetime.now();
		String errMsg = '';
		String sOutput = '';
		CVCH__NexmoMessage__c mess0 = new CVCH__NexmoMessage__c();
		try
		{
			mess0 = SM031_Nexmo.parseWithUniqueCheck(jsonbody);
			if (mess0 == null)
			{
				return new List<CVCH__NexmoMessage__c>();
			}

			FacebookMessage fm;
			if (mess0.Channel__c == 'D360')
			{
				fm = FacebookMessage.parse(jsonbody);
			}
			if (fm != null && fm.isValid)
			{
				fm.handledInFlow();
			}
			else
			{
				visr = SM031_Nexmo.getVisitor(mess0.CVCH__From__c, mess0.CVCH__To__c, mess0.CVCH__Channel__c);
				mess0.CVCH__Received__c = dtBeg;

				List<MessageOptions> aRetStr;
				aRetStr = getResponse(mess0, visr);
				System.debug(aRetStr);
				if (aRetStr != null)
				{
					mess0.CVCH__Response2__c = String.join(aRetStr, '\t');
					if (mess0.CVCH__Response2__c != null && mess0.CVCH__Response2__c.length() > 32000)
					{
						mess0.CVCH__Response2__c = mess0.CVCH__Response2__c.substring(0, 32000);
					}
					String sPrevContext = visr.CVCH__Context__c;
					for (MessageOptions opt : aRetStr)
					{
						opt.send(visr);
						sOutput += '\t' + opt.getBody();
					}
					if (sOutput != null && sOutput.length() > 32000)
					{
						sOutput = sOutput.substring(0, 32000);
					}
					if (sPrevContext != visr.CVCH__Context__c)
					{
						CVCH__Visitor__c v = new CVCH__Visitor__c(Id = visr.Id, CVCH__Context__c = visr.CVCH__Context__c,Input_Reply_Value__c = null);
						update v;
					}
				}
			}
		}
		catch (MyException e)
		{
			System.debug('error: ' + e);
			SM031_Nexmo.sendError0(mess0, e.getMessage(), visr);
			if (Test.isRunningTest())
			{
				throw e;
			}
		}
		catch (Exception e)
		{
			System.debug('error: ' + e.getMessage() + ' ' + e.getStackTraceString());
			SM031_Nexmo.sendError(mess0, '' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString(), visr);
			if (Test.isRunningTest())
			{
				throw e;
			}
		}
		finally
		{
			System.debug('inside getMessage0 catch:');
			System.debug(mess0);
			try
			{

				SM005_Logs.LogCallOut('', 'Nexmo', jsonbody, JSON.serialize(mess0), dtBeg, Datetime.now(), errMsg);
				SM005_Logs.save();
				SM010_Utils.saveTran();
				if (mess0 != null)
				{
					mess0.CVCH__Responded__c = Datetime.now();
					mess0.CVCH__Duration__c = mess0.CVCH__Responded__c.getTime() - mess0.CVCH__Received__c.getTime();
					insert mess0;
					SM031_Nexmo.updateVisitor(new Visitor__c(Id = visr.Id, Last_Inbound_Message__c = mess0.Id));
				}
				SM010_Utils.insertConversation(scoreLUIS, scoreQnA, intentLUIS, triggeredFlow, visr.language__c, visr.CVCH__Id__c, mess0.Text__c, sOutput, visr.Id, errMsg,'');
				if (triggeredLUIS)
				{ // if we got LUIS response for query - log Search Request for keyword, if present
					SM010_Utils.logSearchRequest(respLuis);
				}
				SM031_Nexmo.updateVisitor(new Visitor__c(Id = visr.Id, CVCH__Last_Interaction_Date__c = Datetime.now()));

				if (visUpdate != null)
				{
					update visUpdate;
				}
			}
			catch (Exception e)
			{

			}
		}
		return new List<CVCH__NexmoMessage__c>();
	}
}
