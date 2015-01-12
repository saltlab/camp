package redmine.webguild.redmineandroid;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.ArrayList;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.InputSource;
import org.xml.sax.XMLReader;

public class InternetData {

	ArrayList<String> toReturn=new ArrayList<String>();
	
	public ArrayList<String> getTaskInfo(String login,String pass,String URL)
	{
		RLoginization test=new RLoginization();
		String returned = null;
		final StringBuffer fprint=new StringBuffer();
		try {
			returned = test.getData(login,pass,URL);
			//��������, ���������
			InputStream xmlStream = new ByteArrayInputStream(returned.getBytes("UTF-8"));
			//-------------------
			SAXParserFactory spf=SAXParserFactory.newInstance();
			SAXParser sp=spf.newSAXParser();
			XMLReader xr=sp.getXMLReader();
			TasksInfo work=new TasksInfo();
			xr.setContentHandler(work);
			//������
			xr.parse(new InputSource(xmlStream));
			
			
			ArrayList <String> result = work.getInformation();
			toReturn=result;
			/*StringBuffer print =new StringBuffer();
			for(String key : result){
				//System.out.println(key);
				print.append("\n"+key);
				}*/
			
			
			
			
	}
		catch(Exception e)
		{
			System.out.println("Error " + e );
		}
		return toReturn;
}
	


public ArrayList<String> getTaskFullInfo(String login,String pass,String URL)
{
	RLoginization test=new RLoginization();
	String returned = null;
	final StringBuffer fprint=new StringBuffer();
	try {
		returned = test.getData(login,pass,URL);
		//��������, ���������
		InputStream xmlStream = new ByteArrayInputStream(returned.getBytes("UTF-8"));
		//-------------------
		SAXParserFactory spf=SAXParserFactory.newInstance();
		SAXParser sp=spf.newSAXParser();
		XMLReader xr=sp.getXMLReader();
		TasksFullInfo work=new TasksFullInfo();
		xr.setContentHandler(work);
		//������
		xr.parse(new InputSource(xmlStream));
		
		ArrayList <String> result = work.getFullInformation();
		/*StringBuffer print =new StringBuffer();
		for(String key : result){
			//System.out.println(key);
			print.append("\n"+key);
			}
		
		fprint.append(print);
		*/
		toReturn=result;
		
		
}
	catch(Exception e)
	{
		System.out.println("Error " + e );
	}
	return toReturn;
}

}
