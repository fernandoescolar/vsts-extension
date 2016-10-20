[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)]
    $src,
	[String] [Parameter(Mandatory = $true)]
    $zip,
    [String]
    $filter = "",
    [String]
    $recursive = $true
)


$Assem = ( 
    "System.IO.Compression, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"
) 

$Source = @"
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;

namespace Utilities
{
    public static class Zip
    {
        public static void Create(string folder, string filter, string target, bool recursive)
        {
            if (!Directory.Exists(folder))
                throw new DirectoryNotFoundException("Folder '" + folder + "' not found");

            
            var searchPatterns = new List<string>();
            if (!string.IsNullOrEmpty(filter))
            {
                var filters = filter.Split(new[] { '\r', '\n', ',', ';' }, System.StringSplitOptions.RemoveEmptyEntries);
                if (filters != null) searchPatterns.AddRange(filters);
            }
            if (searchPatterns.Count == 0) searchPatterns.Add("*");
            if (File.Exists(target)) File.Delete(target);

			System.Console.WriteLine("Compressing in " + target);
            var filesToAdd = searchPatterns.SelectMany(searchPattern => Directory.EnumerateFiles(folder, searchPattern, recursive ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly)).ToList();
            using (var zipStream = new StreamWriter(target))
            {
                using (var zip = new ZipArchive(zipStream.BaseStream, ZipArchiveMode.Create, true))
                {
                    foreach (var file in filesToAdd)
                    {
                        var name = file;
                        if (name.StartsWith(folder)) name = name.Substring(folder.Length);
                        if (name.StartsWith("\\")) name = name.Substring(1);
						System.Console.WriteLine(" Adding " + name);
                        var entry = zip.CreateEntry(name);
                        using (var writer = new StreamWriter(entry.Open()))
                        {
                            using (var reader = new StreamReader(file))
                            {
                                reader.BaseStream.CopyTo(writer.BaseStream);
                            }
                        }
                    }
                }
            }
			System.Console.WriteLine("Done");
        }
    }
}
"@ 

Add-Type -ReferencedAssemblies $Assem -TypeDefinition $Source -Language CSharp  

if ($recursive -eq "true" -or $recursive -eq "True" -or $recursive -eq "TRUE" -or $recursive -eq 1) { $recursive = $true }
else { $recursive = $false }


[Utilities.Zip]::Create($src, $filter, $zip, $recursive)