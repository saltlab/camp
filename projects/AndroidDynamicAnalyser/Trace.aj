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
import android.widget.LinearLayout;

/**
 * The Trace aspect injects tracing messages before and after method main of
 * class HelloWorld.
 */

aspect Trace   {
	
//	void around():call(void android.app.Activity.setContentView(int) ){
//		
//		
//		return;
//		
//	}
	
	
//	pointcut tolog() :execution(* Activity+.onCreate*(..));
//	
//	after(Activity activity) throws InterruptedException:tolog() &&this(activity){
//		ViewGroup rootView=(ViewGroup) activity.findViewById(android.R.id.content).getRootView();
//		globalRootView=rootView;
//		//getUiElements(rootView);
//		//Log.d("menfis", "=============END=========");
//	}
	/*
	after(Activity activity): call(* Activity+.setContentView(int)) && this(activity){
		
		//View v=activity.getWindow().getDecorView().getRootView();
		System.out.println(	activity.getComponentName());
		View v=activity.findViewById(android.R.id.content).getRootView();
		ViewGroup rootView=(ViewGroup) activity.findViewById(android.R.id.content).getRootView();
		globalRootView=rootView;
		
		//System.out.println(	activity.getComponentName()+"Ui elements:"+rootView.getChildCount());
		
		//rootView.getChildCount();
		getUiElements(rootView);
		Log.d("menfis", "=============END=========");
		
		/*
		v.setDrawingCacheEnabled(true);

		// this is the important code :)  
		// Without it the view will have a dimension of 0,0 and the bitmap will be null          
		v.measure(MeasureSpec.makeMeasureSpec(0, MeasureSpec.makeMeasureSpec(100, MeasureSpec.EXACTLY)), 
		            MeasureSpec.makeMeasureSpec(0, MeasureSpec.makeMeasureSpec(100, MeasureSpec.EXACTLY)));
		v.layout(0, 0, 1000, 100); 

		v.buildDrawingCache(true);
		Bitmap b = Bitmap.createBitmap(v.getDrawingCache());
		v.setDrawingCacheEnabled(false); // clear drawing cache
		
		
		if(isExternalStorageWritable()){
	        try {
	            FileOutputStream fos = new FileOutputStream(new File(Environment.getExternalStorageDirectory().toString(), "Moe"
	                    + System.currentTimeMillis() + ".png"));
	            b.compress(CompressFormat.PNG, 100, fos);
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
	
*/
	
	
	
//	pointcut createCalls(): 
//		execution(* com.mtgjudge..*.onCreate(..))&& !within(com.mtgjudge.Trace);
//	
//	 after() : createCalls() {
//	    	System.out.print("ONCREATEEEE\n");
//	    	
//
//	    }
	
//	pointcut methodCalls(): 
//		  execution(* com.mtgjudge..*(..))&& !within(com.mtgjudge.Trace);// && !execution(* Activity+.onCreate*(..));

	
//	after(Activity activity) :methodCalls() &&this(activity)
//	{
//				//ViewGroup rootView=(ViewGroup) activity.findViewById(android.R.id.content).getRootView();
//				System.out.println( thisJoinPointStaticPart.getSignature().toString());
//				Log.d("menfis",activity.getComponentName().toString());
//				//getUiElements(rootView);
//				Log.d("menfis", "=============END=========");
//			
//		}
	
	
	

	pointcut methodCalls(): 
	  execution(* com.mtgjudge..*(..))&& !within(com.mtgjudge.Trace);

	Object around(Activity activity) : methodCalls() &&this(activity) {
		if(control){
			
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
		
		long start = System.currentTimeMillis();
		try {
			return proceed(activity);
		} finally {

			long end = System.currentTimeMillis();
			
			System.out.println(name+":"+indent + "<<<< "
					+ thisJoinPointStaticPart.getSignature().toString() + "("
					+ (end - start) + " milliseconds)");

			 
			threadMap.put(threadName,stackDepth - 1);
		//	methods.put(counterEdges, thisJoinPointStaticPart.getSignature().toString() );
			methodss.add(thisJoinPointStaticPart.getSignature().toString());
			if(stackDepth==1){
				ViewGroup rootView=(ViewGroup) activity.findViewById(android.R.id.content).getRootView();
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
						String temp=String.valueOf(counterStates);
						String temp2=String.valueOf(counterEdges);
						
						String s1=String.valueOf(counterStates-1);
						String t1=String.valueOf(counterStates);
				
						Element state = document.createElement("State");
						
						Element timeStamp = document.createElement("TimeStamp");
						timeStamp.appendChild(document.createTextNode(formattedDate));
						state.appendChild(timeStamp);
						
						Element stateId = document.createElement("State_ID");
						stateId.appendChild(document.createTextNode(temp));
						state.appendChild(stateId);
						
						
						Element uiElements=document.createElement("UIElements");
						System.out.println("\n"+"TTHE SIIIZE"+statess.size()+"\n");
						for(int i=0;i<statess.size();i++){
							Element uiElement=document.createElement("UIElement");
							Element uiId=document.createElement("UIElement_ID");
							Element uiElementType=document.createElement("UIElement_Type");
							
							uiId.appendChild(document.createTextNode(String.valueOf(i)));
							uiElementType.appendChild(document.createTextNode(statess.get(i)));
							uiElement.appendChild(uiId);
							uiElement.appendChild(uiElementType);
							uiElements.appendChild(uiElement);
							
						}
						
						state.appendChild(uiElements);
						//APPEND EDGES
						
						Element edge = document.createElement("Edge");
						
						Element timeStampEdge = document.createElement("TimeStamp");
						timeStampEdge.appendChild(document.createTextNode(formattedDate));
						edge.appendChild(timeStampEdge);
						
						Element EdgeId = document.createElement("Edge_ID");
						EdgeId.appendChild(document.createTextNode(temp2));
						edge.appendChild(EdgeId);
						
						Element sourceStateId = document.createElement("Source_State_ID");
						sourceStateId.appendChild(document.createTextNode(s1));
						edge.appendChild(sourceStateId);
						
						Element sourceTargetId = document.createElement("Source_Target_ID");
						sourceTargetId.appendChild(document.createTextNode(t1));
						edge.appendChild(sourceTargetId);
						
						Element methods=document.createElement("Methods");
						for(int i=0; i<methodss.size();i++){
							Element method=document.createElement("Method");
							method.appendChild(document.createTextNode(methodss.get(i)));
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
		
		Log.d("menfis", parent.toString());
		statess.add(parent.toString());
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
	            Log.d("menfis", child.toString());
	           // child.
	          
	        }                
	    }
	    return  list;
	    
	}
	
	
	
	
	private void captureScreen(View x) {
        View v = x;
        v.setDrawingCacheEnabled(true);
        Bitmap bmp = Bitmap.createBitmap(v.getDrawingCache());
        v.setDrawingCacheEnabled(false);
        try {
            FileOutputStream fos = new FileOutputStream(new File(Environment
                    .getExternalStorageDirectory().toString(), "SCREEN"
                    + System.currentTimeMillis() + ".png"));
            bmp.compress(CompressFormat.PNG, 100, fos);
            fos.flush();
            fos.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
	
	public boolean isExternalStorageWritable() {
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
	 ArrayList<String> statess = new ArrayList<String>();
	private static Map<String, Integer> threadMap= new HashMap<String,Integer>();
	ViewGroup globalRootView=null;
	private Vector<Node> nodes;
	private Vector<Edge> edges;
	private int edgeIdCounter;
	private int nodeIdCounter;
	private boolean control=true;
	
private Transformer createXML(){
	
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
	Element rootElement = doc.createElement("company");
	doc.appendChild(rootElement);

	// staff elements
	Element staff = doc.createElement("Staff");
	rootElement.appendChild(staff);


		
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
				return transformer;
				
				
	}

}

