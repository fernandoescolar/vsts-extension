[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)]
    $zip,
    [String] [Parameter(Mandatory = $true)]
    $trg
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
		public static void Extract(string source, string target)
        {
            if (!File.Exists(source))
                throw new FileNotFoundException("File '" + source + "' not found");
            if (!Directory.Exists(target))
                Directory.CreateDirectory(target);


            System.Console.WriteLine("Extracting in " + target);
            using (var zipStream = new StreamReader(source))
            {
                using (var zip = new ZipArchive(zipStream.BaseStream, ZipArchiveMode.Read))
                {
                    foreach (var entry in zip.Entries)
                    {
                        System.Console.WriteLine(" Extract " + entry.FullName);
                        var filePath = Path.Combine(target, entry.FullName);
						if (!Directory.Exists(Path.GetDirectoryName(filePath)))
                            Directory.CreateDirectory(Path.GetDirectoryName(filePath));
                        using (var writer = new StreamWriter(filePath))
                        {
                            using (var reader = entry.Open())
                            {
                                reader.CopyTo(writer.BaseStream);
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
[Utilities.Zip]::Extract("$zip", "$trg") 
    