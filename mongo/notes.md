#### mongo根据bindata的子类型进行查询
MongoDB comparison/sort order compares binary data in 3 steps:
1. First, the length or size of the data.
2. Then, by the BSON one-byte subtype.
3. Finally, by the data, performing a byte-by-byte comparison.
Since legacy and current UUIDs are the same length, you could search from the null UUID in type 3 to the null UUID in type 4, like:
```javascript
db.collection.find({ field: { 
                      $gte: BinData(3,"AAAAAAAAAAAAAAAAAA=="), 
                      $lt: UUID("00000000-0000-0000-0000-000000000000") 
}})
```