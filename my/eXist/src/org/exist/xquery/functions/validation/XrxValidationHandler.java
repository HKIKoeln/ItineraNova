package org.exist.xquery.functions.validation;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.xml.sax.Attributes;
import org.xml.sax.SAXParseException;
import org.xml.sax.helpers.DefaultHandler;

public class XrxValidationHandler extends DefaultHandler {

	private static String NODE_ELEMENT_START = "element-start";
	private static String NODE_ELEMENT_END = "element-end";
	
	// validation error report items
	private XrxValidationReport xrxValidationReport = null;
    private List<XrxValidationReportItem> validationReport = new ArrayList<XrxValidationReportItem>();
    private XrxValidationReportItem lastItem;
    
    // validation status
    private Throwable throwed = null;	
    
	// node ID
	private String currentNodeId = "";
	private ArrayList<Integer> nodeIdArray = new ArrayList<Integer>();
	private int level = 0;
	private String lastNodeType = null;
	
	public void startDocument() {
		lastNodeType = "";
	}
	
	public void startElement(String uri, String localName, String qName, Attributes attributes) {

		if(level == 0 || lastNodeType == NODE_ELEMENT_START) {
			nodeIdArray.add(new Integer(1)); 
		} else {
			int lastPos = nodeIdArray.size() - 1;
			// System.out.println(nodeIdArray.size());
			nodeIdArray.set(lastPos, new Integer(nodeIdArray.get(lastPos) + 1));
		} 
		setCurrentNodeId();
		System.out.println("START " + getCurrentNodeId() + " " + qName);
		if(xrxValidationReport.getCurrentException() != null) 
			addItem( createValidationReportItem(xrxValidationReport.getCurrentLevel(), xrxValidationReport.getCurrentException()) );
		lastNodeType = NODE_ELEMENT_START;
		level += 1;
	}
	
	public void endElement(String uri, String localName, String qName) {
		
		// set node ID
		if(lastNodeType == NODE_ELEMENT_END) {
			int lastPos = nodeIdArray.size() - 1;
			nodeIdArray.remove(lastPos);
		}
		setCurrentNodeId();
		// System.out.println("END   " + getCurrentNodeId() + " " + qName);
		lastNodeType = NODE_ELEMENT_END;
		level -= 1;
	}
	
	// validation report item list
    private void addItem(XrxValidationReportItem newItem) {
        if (lastItem == null) {
            validationReport.add(newItem);
            lastItem = newItem;
        } else if (lastItem.getMessage().equals(newItem.getMessage())) {
            // Message is repeated
            lastItem.increaseRepeat();
        } else {
            validationReport.add(newItem);
            lastItem = newItem;
        }
    }
    private XrxValidationReportItem createValidationReportItem(int type, SAXParseException exception){
        
        XrxValidationReportItem vri = new XrxValidationReportItem();
        vri.setType(type);
        vri.setLineNumber(exception.getLineNumber());
        vri.setColumnNumber(exception.getColumnNumber());
        vri.setMessage(exception.getMessage());
        vri.setPublicId(exception.getPublicId());
        vri.setSystemId(exception.getSystemId());
        vri.setNodeId(getCurrentNodeId());
        return vri;
    }
    public List getValidationReportItemList(){
        return validationReport;
    }
    public void setXrxValidationReport(XrxValidationReport report) {
    	xrxValidationReport = report;
    }

    // validation status
    public boolean isValid(){
        return( (validationReport.size()==0) && (throwed==null) );
    }
    
	// node ID
	public String getCurrentNodeId() {
		return currentNodeId;
	}
	private void setCurrentNodeId() {
		String idString = "";
		Iterator<Integer> iter = nodeIdArray.iterator();
		while(iter.hasNext()) {
			idString += String.valueOf(iter.next());
			if(iter.hasNext()) idString += ".";
		}
		currentNodeId = idString;		
	}
}
