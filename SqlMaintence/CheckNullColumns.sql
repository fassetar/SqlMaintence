DECLARE @TableName NVARCHAR(MAX) = 'YourTableName';
DECLARE @SQL NVARCHAR(MAX) = '';
DECLARE @Cols NVARCHAR(MAX) = '';

SELECT @Cols = STRING_AGG(
    'SUM(CASE WHEN [' + COLUMN_NAME + '] IS NULL THEN 1 ELSE 0 END) AS [Null_' + COLUMN_NAME + ']',
    ', '
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @TableName;

SET @SQL = '
SELECT COUNT(*) AS TotalRows, ' + @Cols + '
FROM ' + QUOTENAME(@TableName) + ';';

EXEC sp_executesql @SQL;