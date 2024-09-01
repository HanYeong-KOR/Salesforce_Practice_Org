/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 08-16-2024
 * @last modified by  : Hanyeong Choi
**/
@isTest
private class ListViewController_TEST {
    static testMethod void testDeleteRecords() {
        List<Account> accounts = new List<Account>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(accounts);
        ListViewController extension = new ListViewController(sc);

        System.assertNotEquals(null, extension.deleteRecords());
    }

    static testMethod void testSelectedSize() {
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name='test'));

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(accounts);
        sc.setSelected(accounts);
        ListViewController extension = new ListViewController(sc);

        System.assertEquals('1', extension.getMySelectedSize());
    }
}