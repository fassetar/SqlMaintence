using System;
using System.Collections.Generic;
using System.Data.SqlClient;

class TableComparer
{
    const string ConnStr1 = "Server=SERVER1;Database=DB1;Trusted_Connection=True;";
    const string ConnStr2 = "Server=SERVER2;Database=DB2;Trusted_Connection=True;";
    const string Query = "SELECT ID, Col1, Col2 FROM dbo.MyTable"; // Adjust columns

    static void Main()
    {
        var table1 = LoadTable(ConnStr1, Query);
        var table2 = LoadTable(ConnStr2, Query);

        Console.WriteLine($"DB1 Rows: {table1.Count}, DB2 Rows: {table2.Count}");

        var keysOnlyInDb1 = new List<string>();
        var keysOnlyInDb2 = new List<string>();
        var keysWithDifferences = new List<string>();

        foreach (var key in table1.Keys)
        {
            if (!table2.ContainsKey(key))
                keysOnlyInDb1.Add(key);
            else if (table1[key] != table2[key])
                keysWithDifferences.Add(key);
        }

        foreach (var key in table2.Keys)
        {
            if (!table1.ContainsKey(key))
                keysOnlyInDb2.Add(key);
        }

        Console.WriteLine($"Only in DB1: {keysOnlyInDb1.Count}");
        Console.WriteLine($"Only in DB2: {keysOnlyInDb2.Count}");
        Console.WriteLine($"Mismatches: {keysWithDifferences.Count}");
    }

    static Dictionary<string, string> LoadTable(string connectionString, string query)
    {
        var results = new Dictionary<string, string>();
        using var conn = new SqlConnection(connectionString);
        conn.Open();

        using var cmd = new SqlCommand(query, conn);
        using var reader = cmd.ExecuteReader();

        while (reader.Read())
        {
            string key = reader["ID"].ToString(); // Primary key
            string value = $"{reader["Col1"]}|{reader["Col2"]}"; // Combine columns
            results[key] = value;
        }

        return results;
    }
}