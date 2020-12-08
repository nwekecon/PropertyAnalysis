/* The query below lists all properties belonging to Owner Id =5597, with HomeValueType = 'current' 
 However, there is an issue from the result as Property 3 has two conflicting values and we can not easily tell which on is the latest entry.
 
 Note here also that although PropertyHomeValue table did not have a CreatedOn date for (Property 3 with value of 2.00), 
When I use a join to retrive the CreatedOn date from the Property Table, they deem to be created on the same date. 

 This is further complicated given that the CeatedOn date for the two conflicting entries are the same, making it diffiuclt to know which of the values 2.0 and 3million for Property 3 is the most current.

 so How do we know which of these is the most current?

*/

----

SELECT  Property.Id, Property.Name, PropertyHomeValue.Value, PropertyHomeValueType.HomeValueType, OwnerProperty.OwnerId, Property.CreatedOn
FROM Property
INNER JOIN PropertyHomeValue
ON Property.Id = PropertyHomeValue.PropertyId
INNER JOIN PropertyHomeValueType
ON PropertyHomeValue.HomeValueTypeId = PropertyHomeValueType.Id
INNER JOIN OwnerProperty
ON Property.Id = OwnerProperty.PropertyId
WHERE PropertyHomeValueType.HomeValueType = 'Current' AND OwnerProperty.OwnerId = 1426
ORDER BY Property.Name,  PropertyHomeValue.Value  DESC

---

/*

But how about sorting by row number instead to help us know which of the two entry value for Property 3 is the latest?
In the next  chunck of query that follows where we used Row_Number Over Partition and Order By CreatedOn date in DESC shows that 'BI Property 3' with value of 3million was indeed the lates record amon the conflicting Property 3 values
*/


/* return list of Property paritioned by date of creation, with most recent on top */


SELECT   [PartitionDates].Id,  [PartitionDates].Name,  [PartitionDates].CreatedOn,  [dbo].[PropertyHomeValue].Value

FROM (

		/*This retrieves relevant columns from Property Table and sorts them on Row_Number sorted by date created so that the lastest on is on top*/

		SELECT	Property.Id, Property.Name, Property.CreatedOn, 
				ROW_NUMBER() OVER (PARTITION BY Property.Id, Property.Name ORDER BY Property.CreatedOn ) [RowNumber]
		FROM Property

	  ) [PartitionDates]

INNER JOIN OwnerProperty

ON [PartitionDates].Id = OwnerProperty.PropertyId

INNER JOIN PropertyHomeValue

ON [PartitionDates].Id = PropertyHomeValue.PropertyId

WHERE [PartitionDates].[RowNumber] =1 AND OwnerProperty.OwnerId = 1426


/* so based on the above,  we have established that BI Property 3 with the most current value is that of 3 million which is larger, 
we can then use the TOP 3 keyword to knock of the stale vale of 2.00
*/





SELECT  TOP 3 [PartitionDates].Id,  [PartitionDates].Name,  [PartitionDates].CreatedOn,  [dbo].[PropertyHomeValue].Value

FROM (

		/*This retrieves relevant columns from Property Table and sorts them on Row_Number sorted by date created so that the lastest on is on top*/

		SELECT	Property.Id, Property.Name, Property.CreatedOn, 
				ROW_NUMBER() OVER (PARTITION BY Property.Id, Property.Name ORDER BY Property.CreatedOn ) [RowNumber]
		FROM Property

	  ) [PartitionDates]

INNER JOIN OwnerProperty

ON [PartitionDates].Id = OwnerProperty.PropertyId

INNER JOIN PropertyHomeValue

ON [PartitionDates].Id = PropertyHomeValue.PropertyId

WHERE [PartitionDates].[RowNumber] =1 AND OwnerProperty.OwnerId = 1426

