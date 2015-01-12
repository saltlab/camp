package com.mtgjudge;

import java.util.Vector;

public class Node {
	
	/*
	 * <State>
        <TimeStamp></TimeStamp>
        <State_ID></State_ID>
        
        <State_ClassName></State_ClassName>
        <State_Title></State_Title>
        <State_ScreenshotPath></State_ScreenshotPath>
        <State_NumberOfElements></State_NumberOfElements>
        <UIElements>
            <UIElement>
                <State_ID></State_ID>
                <UIElement_ID></UIElement_ID>
                <UIElement_Type></UIElement_Type>
                <UIElement_Label></UIElement_Label>
                <UIElement_Action></UIElement_Action>
                <UIElement_Details></UIElement_Details>
            </UIElement>
        </UIElements>
    </State>

	 */
	
	private String timestamp;
	private String id;
	private String className;
	private String title;
	private String screenShotPath;
	private int numberOfElements;

	private Vector<UiElement> uiElements;
	
	
	
	public Node(){
		timestamp="";
		id="";

		

	}



	public String getTimestamp() {
		return timestamp;
	}



	public void setTimestamp(String timestamp) {
		this.timestamp = timestamp;
	}







	public String getId() {
		return id;
	}



	public void setId(String id) {
		this.id = id;
	}









}
