/*

This query displays a list of all property names and their property id’s for Owner Id: 1426. 

*/

SELECT Property.Name AS PropertyName, Property.Id AS PropertyId
FROM Property
INNER JOIN OwnerProperty
ON Property.Id = OwnerProperty.PropertyId
WHERE OwnerProperty.OwnerId = 1426;



