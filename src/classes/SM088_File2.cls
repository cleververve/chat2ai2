/**
Author:         serhiivolynets
Date:           18.02.2021
Description:   
**/

global class SM088_File2
{
	@InvocableMethod(label='Save File2' description='saves and shares the file in for parentId')
	global static list<SM088_File.FileOutput> SaveFile(list<SM088_File.FileInput> lInp)
	{
		list<SM088_File.FileOutput> lRet = new list<SM088_File.FileOutput>();
		for(SM088_File.FileInput inp : lInp)
		{
			inp.bcontent = SM088_File.getFileByURL(inp.sURL);
		}
		for(SM088_File.FileInput inp : lInp)
		{
			SM088_File.FileOutput ret = new SM088_File.FileOutput();
			ret.fileId = SM088_File.saveFile2(inp.bcontent,inp.parentId);
			lRet.add(ret);
		}
		return lRet;
	}

}
