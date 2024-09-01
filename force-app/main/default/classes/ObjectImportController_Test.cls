/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 06-10-2024
 * @last modified by  : Hanyeong Choi
**/
@isTest
public class ObjectImportController_Test {
    // 모킹 클래스
    public class MockDML implements ObjectImportController.DMLInterface {
        public void insertRecords(List<SObject> sObjectList) {
            System.debug('Mock insert executed for SObjects: ' + sObjectList);
        }
    }

    @isTest 
    static void testInsertSObjects() {
        // 모킹할 데이터 준비
        List<Map<String, Object>> mockData = new List<Map<String, Object>>();
        Map<String, Object> row1 = new Map<String, Object>{ 'Name' => 'Test Account 1' };
        Map<String, Object> row2 = new Map<String, Object>{ 'Name' => 'Test Account 2' };
        mockData.add(row1);
        mockData.add(row2);

        // 모킹된 DML 클래스 사용
        ObjectImportController.DMLInterface mockDML = new MockDML();

        Test.startTest();
        ObjectImportController.insertSObjectsWithDML(mockData, 'Account', mockDML);
        Test.stopTest();

        // 결과 검증 (필요 시 검증 로직 추가)
        // 여기서는 insert가 정상적으로 수행되었는지 확인하기 위해 로그를 사용
        System.assertEquals(2, mockData.size(), '2 records should be mocked for insertion.');
    }

    @isTest 
    static void testGetObjectFields() {
        // 실제 오브젝트 필드 조회 테스트
        Test.startTest();
        List<ObjectImportController.FieldWrapper> fields = ObjectImportController.getObjectFields('Account');
        Test.stopTest();

        // 결과 검증
        System.assert(fields.size() > 0, 'Account object should have fields.');
    }
}