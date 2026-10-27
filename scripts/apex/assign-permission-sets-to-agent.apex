User u = [
    SELECT Id, Username, Name
    FROM User
    WHERE Username LIKE '%agentforce%'
    AND (NOT Username LIKE '%test%')
    LIMIT 1
];

System.debug('User Id: ' + u.Id + ' | Username: ' + u.Username + ' | Name: ' + u.Name);

// B2BBuyer is intentionally excluded: it requires the B2B Buyer permission set
// license, which the agent user's license does not support.
Set<String> targetPermissionSetNames = new Set<String>{
    'AgentforceServiceAgentUser',
    'CommerceUser'
};

List<PermissionSet> permissionSets = [
    SELECT Id, Name, NamespacePrefix
    FROM PermissionSet
    WHERE NamespacePrefix = 'force'
    AND Name IN :targetPermissionSetNames
];

System.debug('Found Permission Sets: ' + permissionSets.size());

Set<Id> assignedPermissionSetIds = new Set<Id>();
for (PermissionSetAssignment psa : [
    SELECT PermissionSetId
    FROM PermissionSetAssignment
    WHERE AssigneeId = :u.Id
]) {
    assignedPermissionSetIds.add(psa.PermissionSetId);
}

List<PermissionSetAssignment> toInsert = new List<PermissionSetAssignment>();

for (PermissionSet ps : permissionSets) {
    System.debug('Permission Set Id: ' + ps.Id + ' | Name: ' + ps.Name + ' | Namespace: ' + ps.NamespacePrefix);

    if (!assignedPermissionSetIds.contains(ps.Id)) {
        toInsert.add(new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetId = ps.Id
        ));
    }
}

if (!toInsert.isEmpty()) {
    List<Database.SaveResult> results = Database.insert(toInsert, false);
    Integer inserted = 0;
    for (Integer i = 0; i < results.size(); i++) {
        if (results[i].isSuccess()) {
            inserted++;
        } else {
            System.debug('Failed to assign permission set ' + toInsert[i].PermissionSetId + ': ' + results[i].getErrors()[0].getMessage());
        }
    }
    System.debug('Inserted ' + inserted + ' permission set assignments.');
} else {
    System.debug('No new permission set assignments needed.');
}