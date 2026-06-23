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

Set<Id> assignedPermissionSetIds = new Set<Id>();
for (PermissionSetAssignment psa : [
    SELECT PermissionSetId
    FROM PermissionSetAssignment
    WHERE AssigneeId = :u.Id
]) {
    assignedPermissionSetIds.add(psa.PermissionSetId);
}

for (PermissionSet ps : permissionSets) {
    System.debug('Permission Set Id: ' + ps.Id + ' | Name: ' + ps.Name);

    if (assignedPermissionSetIds.contains(ps.Id)) {
        System.debug('The permission set called ' + ps.Name + ' is assigned to user ' + u.Username);
    } else {
        System.debug('The permission set called ' + ps.Name + ' is NOT assigned to user ' + u.Username);
    }
}