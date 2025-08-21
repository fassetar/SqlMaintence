DECLARE @TableName NVARCHAR(128) = 'dbo.TABLE';
DECLARE @ColumnsToCheck TABLE (ColumnName NVARCHAR(128));
DECLARE @Column NVARCHAR(128);
DECLARE @SQL NVARCHAR(MAX);

-- Add column names here you want to evaluate
INSERT INTO @ColumnsToCheck (ColumnName)
VALUES ('strMiddleName'), ('strFax'), ('Mothers_Maiden_Name');  -- example columns

-- Loop through each column and check for all NULLs
DECLARE cur CURSOR FOR
SELECT ColumnName FROM @ColumnsToCheck;

OPEN cur;
FETCH NEXT FROM cur INTO @Column;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = '
    IF NOT EXISTS (
        SELECT 1 FROM ' + @TableName + ' WHERE [' + @Column + '] IS NOT NULL
    )
    BEGIN
        PRINT ''✅ Dropping column [' + @Column + '] from [' + @TableName + '] (all values are NULL)...'';
        ALTER TABLE ' + @TableName + ' DROP COLUMN [' + @Column + '];
    END
    ELSE
    BEGIN
        PRINT ''❌ Column [' + @Column + '] contains non-NULL values. Skipping drop.'';
    END;
    ';

    EXEC sp_executesql @SQL;

    FETCH NEXT FROM cur INTO @Column;
END

CLOSE cur;
DEALLOCATE cur;