package com.mtgjudge;

import java.util.Vector;

public class Edge {
	
	private String timestamp;
	private String id,sourceId,targetId;
	private String touchedElement;
	private Vector<String> methods;
	
	
	
	public Edge(){
		timestamp="";
		id="";
		sourceId="";
		targetId="";
		touchedElement="";
		

	}



	public String getTimestamp() {
		return timestamp;
	}



	public void setTimestamp(String timestamp) {
		this.timestamp = timestamp;
	}



	public String getTargetId() {
		return targetId;
	}



	public void setTargetId(String targetId) {
		this.targetId = targetId;
	}



	public String getId() {
		return id;
	}



	public void setId(String id) {
		this.id = id;
	}



	public String getSourceId() {
		return sourceId;
	}



	public void setSourceId(String sourceId) {
		this.sourceId = sourceId;
	}



	public String getTouchedElement() {
		return touchedElement;
	}



	public void setTouchedElement(String touchedElement) {
		this.touchedElement = touchedElement;
	}



	public Vector<String> getMethods() {
		return methods;
	}



	public void setMethods(Vector<String> methods) {
		this.methods = methods;
	}

}
