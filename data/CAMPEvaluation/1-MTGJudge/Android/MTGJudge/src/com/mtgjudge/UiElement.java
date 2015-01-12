package com.mtgjudge;

public class UiElement {
	
	/*
	 * <UIElement>
                <State_ID></State_ID>
                <UIElement_ID></UIElement_ID>
                <UIElement_Type></UIElement_Type>
                <UIElement_Label></UIElement_Label>
                <UIElement_Action></UIElement_Action>
                <UIElement_Details></UIElement_Details>
            </UIElement>
	 */
	
	private String elementId,type,label,action,details;
	
	
	
	public UiElement(){
		
	}



	public String getLabel() {
		return label;
	}



	public void setLabel(String label) {
		this.label = label;
	}



	public String getDetails() {
		return details;
	}



	public void setDetails(String details) {
		this.details = details;
	}



	public String getType() {
		return type;
	}



	public void setType(String type) {
		this.type = type;
	}



	public String getAction() {
		return action;
	}



	public void setAction(String action) {
		this.action = action;
	}



	public String getElementId() {
		return elementId;
	}



	public void setElementId(String elementId) {
		this.elementId = elementId;
	}

}
