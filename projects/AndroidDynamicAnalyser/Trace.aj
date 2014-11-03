package com.mtgjudge;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.StringWriter;
import java.security.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.Stack;
import java.util.Vector;

import java.io.File;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
 
import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSOutput;
import org.w3c.dom.ls.LSSerializer;
import org.xml.sax.SAXException;
import org.xmlpull.v1.XmlSerializer;

import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.Bitmap.Config;
import android.graphics.Canvas;
import android.os.Environment;
import android.util.Log;
import android.view.View;
import android.view.View.MeasureSpec;
import android.app.*;
import android.view.ViewGroup;
import android.graphics.*;
import android.view.*;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

/**
 * The Trace aspect injects tracing messages before and after method main of
 * class HelloWorld.
 */

aspect Trace   {

//	after(Activity activity):call(* Activity+.onCreateOptionsMenu(..)) &&this(activity){
//		
//	}
	
//	pointcut tolog1():execution(* Activity+.*(..));
//	before():tolog1(){
//		String method=thisJoinPoint.getSignature().toShortString();
//		Log.d("ATAG","==========entering"+method+",params="+Arrays.toString(thisJoinPoint.getArgs()));
//	}

	pointcut methodCalls(): 
	  execution(* com.mtgjudge..*(..))&& !within (com.mtgjudge.Trace);

	Object around(Activity activity) : methodCalls() &&this(activity) {
		if(control){
			System.out.println("COMP name:"+activity.getComponentName());
			control=false;
			DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder docBuilder = null;
			try {
				docBuilder = docFactory.newDocumentBuilder();
			} catch (ParserConfigurationException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}

			// root elements
			Document doc = docBuilder.newDocument();
			Element rootElement = doc.createElement("Model");
			doc.appendChild(rootElement);



				
				// write the content into xml file
						TransformerFactory transformerFactory = TransformerFactory.newInstance();
						Transformer transformer = null;
						
						try {
							transformer = transformerFactory.newTransformer();
						} catch (TransformerConfigurationException e1) {
							// TODO Auto-generated catch block
							e1.printStackTrace();
						}
						DOMSource source = new DOMSource(doc);
						
			
			
			if(isExternalStorageWritable()){
		        try {
		            FileOutputStream fos = new FileOutputStream(new File(Environment.getExternalStorageDirectory().toString()+"/MTG", "calls.xml"));
		            StreamResult result = new StreamResult(fos);
		        	try {
						transformer.transform(source, result);
					} catch (TransformerException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
		            fos.flush();
		            fos.close();
		        } catch (FileNotFoundException e) {
		            e.printStackTrace();
		        } catch (IOException e) {
		            e.printStackTrace();
		        }

				System.out.println("Captured");
			}
			
		} 
		
		String threadName = Thread.currentThread().getName();
		
		if(null==threadMap.get(threadName)){
			threadMap.put(threadName,0);
		}
		
		int stackDepth = threadMap.get(threadName) + 1;
		
		
		
		threadMap.put(threadName,stackDepth);

		
		String name = Thread.currentThread().getName();
		
		String indent = "";
		
		for (int index = 0; index < stackDepth; index++) {
			indent += "   ";
		}

		System.out.println("STACK:"+stackDepth+"\n"+name+":"+indent + ">>>>    "
				+ thisJoinPointStaticPart.getSignature().toString());
		methodss.add(thisJoinPointStaticPart.getSignature().toString()+"|"+Arrays.toString(thisJoinPoint.getArgs()));
		methodsArguments.put(thisJoinPointStaticPart.getSignature().toString(), thisJoinPoint.getArgs());
////////////////*//////////
		
		
//		if(!thisJoinPointStaticPart.getSignature().toString().contains("onCreate")){
//			methodsArguments.put(thisJoinPointStaticPart.getSignature().toString(), thisJoinPoint.getArgs());
//		}
//		else{
//			Object[] objs=new Object[1];
//			methodsArguments.put(thisJoinPointStaticPart.getSignature().toString(),objs );
//		}
		
		
	/*	
		Object[] tempArguments=methodsArguments.get(thisJoinPointStaticPart.getSignature().toString());
		
		//Clicking on a list item
		if(methodss.get(0).contains("onListItem")){
			for(int z=0;z<(tempArguments.length);z++){
			Log.d("Class","List:"+tempArguments[z].getClass().toString());
			
			if(tempArguments[z] instanceof TextView ){
				TextView tempLabel=(TextView) tempArguments[z];
				Log.d("Class", tempLabel.getText().toString());
			}
		}
	  }
		
		//Button
		if(!methodss.get(0).contains("onCreate")){
			for(int z=0;z<(tempArguments.length);z++){
			Log.d("Class","Class:"+tempArguments[z].getClass().toString());
			
			if(tempArguments[z] instanceof Button ){
				Button tempLabel=(Button) tempArguments[z];
				Log.d("Class", "Button"+tempLabel.getText().toString());

			}
		 }
		}
		
	  //Clicking a menu item
			if(methodss.get(0).contains("onOptionsItemSelected")){
		
				//Log.d("CLASS","Class:"+tempArguments[z].getClass().toString());
		
					//TextView tempLabel=(TextView) tempArguments[z];
					Log.d("Class", "Menu");
				    if(tempArguments[0] instanceof String){
				    	String tempLabel=(String) tempArguments[0];

				    } 	
		
		  }
		  
		  */
////////////////*//////////
		long start = System.currentTimeMillis();
		try {
			return proceed(activity);
		} finally {

			long end = System.currentTimeMillis();
			
			System.out.println(name+":"+indent + "<<<< "
					+ thisJoinPointStaticPart.getSignature().toString() + "("
					+ (end - start) + " milliseconds)");
			Log.d("ATAG","==========entering"+thisJoinPoint.getSignature().toString()+",related Elements="+Arrays.toString(thisJoinPoint.getArgs()));
			 
			threadMap.put(threadName,stackDepth - 1);
		//	methods.put(counterEdges, thisJoinPointStaticPart.getSignature().toString() );
			//methodss.add(thisJoinPointStaticPart.getSignature().toString()+"|"+Arrays.toString(thisJoinPoint.getArgs()));
			methodssArguments.add(Arrays.toString(thisJoinPoint.getArgs()));

			if(stackDepth==1){
				ViewGroup rootView=(ViewGroup) activity.findViewById(android.R.id.content).getRootView();
				Log.d("menfis",String.valueOf( rootView.getTouchables().toString()));
				getUiElements(rootView);
				//statess=tempList;
				//states.put(counterStates, statess);
				File xmlFile=new File((Environment.getExternalStorageDirectory().toString()+"/MTG/calls.xml"));
				
				
				DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
				DocumentBuilder dBuilder = null;
				try {
					dBuilder = dbFactory.newDocumentBuilder();
				} catch (ParserConfigurationException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			
					Document document = null;
					try {
						document = dBuilder.parse(xmlFile);
					} catch (SAXException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					NodeList nList=document.getElementsByTagName("Model");
					
					if(nList.getLength()==1){
						org.w3c.dom.Node model=nList.item(0);
						
						
						//APPEND STATES AND EDGES
						Date date = new Date();
						SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy h:mm:ss a");
						String formattedDate = sdf.format(date);
						String tempStateId="S"+String.valueOf(counterStates);
						String temp2=String.valueOf(counterEdges);
						
						String s1="S"+String.valueOf(counterStates-1);
						String t1="S"+String.valueOf(counterStates);
				
						Element state = document.createElement("State");
						
						Element timeStamp = document.createElement("TimeStamp");
						timeStamp.appendChild(document.createTextNode(formattedDate));
						state.appendChild(timeStamp);
						
						Element stateId = document.createElement("State_ID");
						stateId.appendChild(document.createTextNode(tempStateId));
						state.appendChild(stateId);
						
						Element stateClassName=document.createElement("State_ClassName");
						
						//get rid of redudant info
						String tempCompName=activity.getComponentName().toString();
						String[] partsCompName=tempCompName.split("\\.");
						String compName=partsCompName[partsCompName.length-1];
						String compNameTrimmed=compName.replace('}', ' ');
						System.out.println("NEWComp:"+compNameTrimmed+"\n");
						
						stateClassName.appendChild(document.createTextNode(compNameTrimmed));
						state.appendChild(stateClassName);
						
						Element stateTitle=document.createElement("State_Title");
						//stateTitle.appendChild(document.createTextNode(activity.getComponentName().toString()));
						state.appendChild(stateTitle);
						
						
						Element stateScreenshot=document.createElement("State_ScreenshotPath");
						state.appendChild(stateScreenshot);
						
						Element stateNumberOfElements=document.createElement("State_NumberOfElements");
						//stateNumberOfElements.appendChild(document.createTextNode(String.valueOf(statess.size())));
						state.appendChild(stateNumberOfElements);
						
						
						Element uiElements=document.createElement("UIElements");

						int tempSize=0;
						for(int i=0;i<statesView.size();i++){
							
							if(statesView.get(i).toString().contains("DecorView") 
									||statesView.get(i).toString().contains("LinearLayout") 
									||statesView.get(i).toString().contains("ViewStub")
									||statesView.get(i).toString().contains("TabHost")
									||statesView.get(i).toString().contains("TabWidget")
									||statesView.get(i).toString().contains("RelativeLayout")
									||statesView.get(i).toString().contains("FrameLayout")){
								
							}
							else {
							tempSize++;
							Element uiElement=document.createElement("UIElement");
							Element uiElementStateId=document.createElement("State_ID");
							Element uiId=document.createElement("UIElement_ID");
							Element uiElementType=document.createElement("UIElement_Type");
							Element uiElementLabel=document.createElement("UIElement_Label");
							Element uiElementAction=document.createElement("UIElement_Action");
							Element uiElementDetails=document.createElement("UIElement_Details");
							
							
							uiElementStateId.appendChild(document.createTextNode(tempStateId));
							uiId.appendChild(document.createTextNode("E"+String.valueOf(i+1)));
							String tempType=statesView.get(i).toString();
							String[] parts=tempType.split("\\{");
							String part1 = parts[0];
							String[] types=part1.split("\\.");
							String finalType=types[types.length-1];
							System.out.println("Type of ELE:"+finalType+"\n");
							uiElementType.appendChild(document.createTextNode(finalType));
							
							if(statesView.get(i) instanceof TextView){
								TextView tv1=(TextView) statesView.get(i);
								uiElementLabel.appendChild(document.createTextNode(tv1.getText().toString()));
							}
							
							if(statesView.get(i) instanceof ListView){
								ListView lv1=(ListView) statesView.get(i);
								uiElementDetails.appendChild(document.createTextNode(String.valueOf(lv1.getCount())));
							}
							
							uiElement.appendChild(uiElementStateId);
							uiElement.appendChild(uiId);
							uiElement.appendChild(uiElementType);
							uiElement.appendChild(uiElementLabel);
							uiElement.appendChild(uiElementAction);
							uiElement.appendChild(uiElementDetails);
							
							
							uiElements.appendChild(uiElement);
							}
						}
						
						stateNumberOfElements.appendChild(document.createTextNode(String.valueOf(tempSize)));
						tempSize=0;
						state.appendChild(uiElements);
						//APPEND EDGES
						
						Element edge = document.createElement("Edge");
						
						Element timeStampEdge = document.createElement("TimeStamp");
						timeStampEdge.appendChild(document.createTextNode(formattedDate));
						edge.appendChild(timeStampEdge);

						
						Element sourceStateId = document.createElement("Source_State_ID");
						sourceStateId.appendChild(document.createTextNode(s1));
						edge.appendChild(sourceStateId);
						
						Element sourceTargetId = document.createElement("Target_State_ID");
						sourceTargetId.appendChild(document.createTextNode(t1));
						edge.appendChild(sourceTargetId);
						
						Element touchedElement=document.createElement("TouchedElement");
						Element TeUiElementType=document.createElement("UIElement_Type");
						Element TeUiElementLabel=document.createElement("UIElement_Label");
						Element TeUiElementAction=document.createElement("UIElement_Action");
						Element TeUiElementDetails=document.createElement("UIElement_Details");
						
						
						String[] arguments=methodss.get(0).split("\\|");
						String touchedElementString=arguments[1];
						String tempMethodValue=arguments[0];
						//touchedElement.appendChild(document.createTextNode(touchedElementString));
		
							Object[] tempArguments=methodsArguments.get(tempMethodValue);
							//Clicking on a list item
							if(methodss.get(0).contains("onListItem")){
								for(int z=0;z<(tempArguments.length);z++){
								Log.d("CLASS","Class:"+tempArguments[z].getClass().toString());
								
								if(tempArguments[z] instanceof TextView ){
									TextView tempLabel=(TextView) tempArguments[z];
									Log.d("Class", tempLabel.getText().toString());
									TeUiElementType.appendChild(document.createTextNode("ListViewCell"));
									TeUiElementLabel.appendChild(document.createTextNode(tempLabel.getText().toString()));
									TeUiElementAction.appendChild(document.createTextNode("ListViewCellClicked"));
								}
							}
						  }
							
							//Button
							if(!methodss.get(0).contains("onCreate")){
								for(int z=0;z<(tempArguments.length);z++){
								Log.d("CLASS","Class:"+tempArguments[z].getClass().toString());
								
								if(tempArguments[z] instanceof Button ){
									Button tempLabel=(Button) tempArguments[z];
									Log.d("Class", tempLabel.getText().toString());
									TeUiElementType.appendChild(document.createTextNode("Button"));
									String [] trim=tempMethodValue.split("\\.");
									String action=trim[trim.length-1];
									String actionNoArgument[]=action.split("\\(");
									TeUiElementLabel.appendChild(document.createTextNode(tempLabel.getText().toString()));
									TeUiElementAction.appendChild(document.createTextNode(actionNoArgument[0]));
								}
							 }
							}
							
							//Edit Text
							if(!methodss.get(0).contains("onCreate")){
								for(int z=0;z<(tempArguments.length);z++){
								Log.d("CLASS","Class:"+tempArguments[z].getClass().toString());
								
								if(tempArguments[z] instanceof EditText ){
									Button tempLabel=(Button) tempArguments[z];
									Log.d("Class", tempLabel.getText().toString());
									TeUiElementType.appendChild(document.createTextNode("UIButton"));
									String [] trim=tempMethodValue.split("\\.");
									String action=trim[trim.length-1];
									String actionNoArgument[]=action.split("\\(");
									TeUiElementLabel.appendChild(document.createTextNode(tempLabel.getText().toString()));
									TeUiElementAction.appendChild(document.createTextNode(actionNoArgument[0]));
								}
							 }
							}
							  //Clicking a menu button
							if(methodss.get(0).contains("onCreateOptions")){
										Log.d("Class","Menu Button clicked");
								
								    	TeUiElementType.appendChild(document.createTextNode("MenuButton"));
								    	TeUiElementLabel.appendChild(document.createTextNode("MenuButton"));
								    	TeUiElementAction.appendChild(document.createTextNode("MenuButtonClicked"));
								    	
						
						  }
						  //Clicking a menu item
								if(methodss.get(0).contains("onOptionsItemSelected")){
									    	TeUiElementType.appendChild(document.createTextNode("MenuItem"));
									    	TeUiElementLabel.appendChild(document.createTextNode(touchedElementString));
									    	TeUiElementAction.appendChild(document.createTextNode("MenuItemClicked")); 	
							
							  } 
							
						
						
						touchedElement.appendChild(TeUiElementType);
						touchedElement.appendChild(TeUiElementLabel);
						touchedElement.appendChild(TeUiElementAction);
						touchedElement.appendChild(TeUiElementDetails);
						edge.appendChild(touchedElement);
						
						
						Element methods=document.createElement("Methods");
						for(int i=0; i<methodss.size();i++){
							Element method=document.createElement("Method");
							String tempMethod=methodss.get(i);
							String[] tempMethodPlusArguments=tempMethod.split("\\|");
							
							String[] tempMethodSplit=tempMethodPlusArguments[0].split("\\.");
							String[] nameWithoutArgument=tempMethodSplit[tempMethodSplit.length-1].split("\\(");
							
							String finalMethodName=tempMethodSplit[tempMethodSplit.length-2]+":"+nameWithoutArgument[0];
							System.out.println("FINAL method Name:"+finalMethodName+"\n");
							method.appendChild(document.createTextNode(finalMethodName));
							methods.appendChild(method);
						}
						edge.appendChild(methods);
						model.appendChild(edge);
						model.appendChild(state);
						//END OF APPEND
						//System.out.println(document.getElementsByTagName("Model").item(0).toString());
						TransformerFactory transformerFactory = TransformerFactory.newInstance();
						Transformer transformer = null;
						
						try {
							transformer = transformerFactory.newTransformer();
						} catch (TransformerConfigurationException e1) {
							// TODO Auto-generated catch block
							e1.printStackTrace();
						}
						DOMSource source = new DOMSource(document);
						
						
						
						if(isExternalStorageWritable()){
					        try {
					            FileOutputStream fos = new FileOutputStream(new File(Environment.getExternalStorageDirectory().toString()+"/MTG", "calls.xml"));
					            StreamResult result = new StreamResult(fos);
					        	try {
									transformer.transform(source, result);
								} catch (TransformerException e) {
									// TODO Auto-generated catch block
									e.printStackTrace();
								}
					            fos.flush();
					            fos.close();
					        } catch (FileNotFoundException e) {
					            e.printStackTrace();
					        } catch (IOException e) {
					            e.printStackTrace();
					        }

							System.out.println("Captured");
						}
					}
					else{
						System.out.println("error cant attach element");
					}
					
							
				
			
				System.out.print("===========\n");
				methodss.clear();
				statess.clear();
				statesView.clear();
				methodsArguments.clear();
				counterStates++;
				counterEdges++;
			}

		}
		

	}

	private static Element addNewState(Map<Integer, ArrayList<String>> states, int counter){
			DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder docBuilder = null;
			Date date = new Date();
			SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy h:mm:ss a");
			String formattedDate = sdf.format(date);
			String temp=String.valueOf(counter);
			try {
				docBuilder = docFactory.newDocumentBuilder();
			} catch (ParserConfigurationException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}

			// root elements
			Document doc = docBuilder.newDocument();
			Element state = doc.createElement("State");
			
			Element timeStamp = doc.createElement("TimeStamp");
			timeStamp.appendChild(doc.createTextNode(formattedDate));
			state.appendChild(timeStamp);
			
			Element stateId = doc.createElement("State_ID");
			stateId.appendChild(doc.createTextNode(temp));
			state.appendChild(stateId);
			
			
		
		return state;
	}
	
	ArrayList<String> getUiElements(ViewGroup parent) 
	{  
		
		 ArrayList<String> list = new ArrayList<String>();
		//Log.d("menfis", parent.toString());
		statess.add(parent.toString());
		statesView.add(parent);
		
		//parent.onI
	    for(int i = 0; i < parent.getChildCount(); i++)
	    {
	        View child = parent.getChildAt(i);            
	        if(child instanceof ViewGroup) 
	        {
	        	getUiElements((ViewGroup)child);
	        	
	        	
	        	
	        }
	        else if(child != null)
	        {
	        	statess.add(child.toString());
	        	statesView.add(child);
	            //Log.d("menfis", child.toString());
	          
	            //Log.d("menfis",String.valueOf( child.isActivated()));
	           // child
	            //child.has
	        	//child.
	        	
	        	
	          
	        }                
	    }
	    return  list;
	    
	}
	
	
	  boolean isExternalStorageWritable() {  
	    String state = Environment.getExternalStorageState();
	    if (Environment.MEDIA_MOUNTED.equals(state)) {
	        return true;
	    }
	    return false;
	}
	
	//Stack methods = new Stack();
	int counterStates=1;
	int counterEdges=0;
	//private static Map<Integer, String> methods= new HashMap<Integer,String>();
	private static Map<Integer, ArrayList<String>> states= new HashMap<Integer,ArrayList<String>>();
	 ArrayList<String> methodss = new ArrayList<String>();
	 ArrayList<String> methodssArguments = new ArrayList<String>();
	 ArrayList<String> statess = new ArrayList<String>();
	 ArrayList<View> statesView = new ArrayList<View>();
	 private static Map<String, Object[]> methodsArguments= new HashMap<String, Object[]>();
	private static Map<String, Integer> threadMap= new HashMap<String,Integer>();
	ViewGroup globalRootView=null;
	private boolean control=true;
	


}

