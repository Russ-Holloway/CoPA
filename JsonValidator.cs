using System;
using System.IO;
using System.Text.Json;

class Program
{
    static void Main()
    {
        try
        {
            string jsonFile = @"infrastructure/deployment.json";
            string jsonContent = File.ReadAllText(jsonFile);
            
            // Attempt to parse the JSON
            JsonDocument.Parse(jsonContent);
            
            Console.WriteLine("JSON syntax validation successful!");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"JSON validation failed: {ex.Message}");
        }
    }
}
