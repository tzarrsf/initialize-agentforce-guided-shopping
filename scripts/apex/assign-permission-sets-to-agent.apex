User u = [
    SELECT Id, Username, Name
    FROM User
    WHERE Username LIKE '%agentforce%'
    LIMIT 1
];

System.debug('User Id: ' + u.Id + ' | Username: ' + u.Username + ' | Name: ' + u.Name);

Set<String> targetPermissionSetNames = new Set<String>{
    'AgentforceServiceAgentUser',
    'CommerceUser',
    'Buyer'
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
    insert toInsert;
    System.debug('Inserted ' + toInsert.size() + ' permission set assignments.');
} else {
    System.debug('No new permission set assignments needed.');
}