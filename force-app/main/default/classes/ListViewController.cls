/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 08-16-2024
 * @last modified by  : Hanyeong Choi
**/
public with sharing class ListViewController {

    ApexPages.StandardSetController setCon;
    public String           error       { get; set; }
    public PageReference    originalUrl { get; set; }

    public ListViewController(ApexPages.StandardSetController controller) {
        setCon = controller;
    }

    public String getMySelectedSize() {
        return setCon.getSelected().size() + '';
    }

    public List<SObject> getRecordSet() {
        return setCon.getSelected();
    }
    
    public PageReference deleteRecords(){
        originalUrl = setCon.cancel();
        delete setCon.getSelected();
        return originalUrl;
    }
}