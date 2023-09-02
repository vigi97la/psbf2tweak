using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;

public class VehicleExtractor
{
    public static void MergeTemplateMultipleDefinitions(string extractedFolder, bool bShowOutput = true, bool bShowExtendedOutput = false)
    {
        if (string.IsNullOrEmpty(extractedFolder) || !Directory.Exists(extractedFolder))
        {
            Console.Error.WriteLine("Error: Invalid parameter (objectsFolder)");
            return;
        }
        string cachefile = Path.Combine(extractedFolder, "cache_db.csv");
        if (string.IsNullOrEmpty(cachefile) || !File.Exists(cachefile))
        {
            Console.Error.WriteLine("Error: cache_db.csv not found");
            return;
        }

        List<bool> templateValidityList = new List<bool>();
        List<string> templateNameList = new List<string>();
        List<string> templateTypeList = new List<string>();
        List<List<string>> templateChildrenList = new List<List<string>>();
        List<List<string>> templateFilesList = new List<List<string>>();

        using (StreamReader sr = new StreamReader(cachefile))
        {
            while (!sr.EndOfStream)
            {
                string line = sr.ReadLine();
                string[] cols = line.Split(';');
                string templateName = cols[0];
                string templateType = cols[1];
                string templateFile = cols[2];
                List<string> templateChildren = new List<string>();
                int i;
                for (i = 2; i < cols.Length; i++)
                {
                    if (cols[i].Contains("\\"))
                    {
                        break;
                    }
                    string templateChild = cols[i];
                    if (!string.IsNullOrEmpty(templateChild) && !templateChildren.Contains(templateChild, StringComparer.InvariantCultureIgnoreCase))
                    {
                        templateChildren.Add(templateChild);
                    }
                }
                List<string> templateFiles = new List<string>();
                for (; i < cols.Length; i++)
                {
                    templateFile = cols[i];
                    if (!string.IsNullOrEmpty(templateFile) && !templateFiles.Contains(templateFile, StringComparer.InvariantCultureIgnoreCase))
                    {
                        templateFiles.Add(templateFile);
                    }
                }
                templateFile = templateFiles[0];
                if (bShowExtendedOutput)
                {
                    Console.WriteLine(string.Format("{0} {1} ({2})", templateType, templateName, templateFile));
                }

                templateValidityList.Add(true);
                templateNameList.Add(templateName);
                templateTypeList.Add(templateType);
                templateChildrenList.Add(templateChildren);
                templateFilesList.Add(templateFiles);
            }
        }

        string tmpcachefile = Path.Combine(extractedFolder, "cache_db.csv.tmp");
        using (StreamWriter sw = new StreamWriter(tmpcachefile))
        {
            for (int ii = 0; ii < templateNameList.Count; ii++)
            {
                if (!templateValidityList[ii])
                {
                    continue;
                }
                string templateName = templateNameList[ii];
                string templateType = templateTypeList[ii];
                List<string> templateChildren = templateChildrenList[ii];
                List<string> templateFiles = templateFilesList[ii];

                for (int j = ii + 1; j < templateNameList.Count; j++)
                {
                    if (!templateValidityList[j])
                    {
                        continue;
                    }
                    if (templateNameList[j].Equals(templateName, StringComparison.InvariantCultureIgnoreCase))
                    {
                        string tmpTemplateType = templateTypeList[j];
                        List<string> tmpTemplateChildren = templateChildrenList[j];
                        List<string> tmpTemplateFiles = templateFilesList[j];
                        bool bAddTmpTemplateFirst = false;
                        if (!templateType.Equals(tmpTemplateType, StringComparison.InvariantCultureIgnoreCase))
                        {
                            Console.WriteLine(string.Format("Warning: Multiple definitions of {0} with a different type ({1} vs. {2})", templateName, templateType, tmpTemplateType));
                            if (templateType.Equals("ObjectTemplate", StringComparison.InvariantCultureIgnoreCase) ||
                                templateType.Equals("aiTemplate", StringComparison.InvariantCultureIgnoreCase) ||
                                templateType.Equals("weaponTemplate", StringComparison.InvariantCultureIgnoreCase))
                            {
                                bAddTmpTemplateFirst = true;
                                templateType = tmpTemplateType;
                            }
                        }
                        else
                        {
                            if (bShowOutput)
                            {
                                Console.WriteLine(string.Format("Multiple definitions of {0} {1}", templateType, templateName));
                            }
                        }
                        if (tmpTemplateChildren != null && tmpTemplateChildren.Count > 0)
                        {
                            if (bAddTmpTemplateFirst)
                            {
                                for (int k = tmpTemplateChildren.Count - 1; k >= 0; k--)
                                {
                                    string tmpTemplateChild = tmpTemplateChildren[k];
                                    if (!templateChildren.Contains(tmpTemplateChild, StringComparer.InvariantCultureIgnoreCase))
                                    {
                                        templateChildren.Insert(0, tmpTemplateChild);
                                    }
                                }
                            }
                            else
                            {
                                foreach (string tmpTemplateChild in tmpTemplateChildren)
                                {
                                    if (!templateChildren.Contains(tmpTemplateChild, StringComparer.InvariantCultureIgnoreCase))
                                    {
                                        templateChildren.Add(tmpTemplateChild);
                                    }
                                }
                            }
                        }
                        if (tmpTemplateFiles != null && tmpTemplateFiles.Count > 0)
                        {
                            if (bAddTmpTemplateFirst)
                            {
                                for (int k = tmpTemplateFiles.Count - 1; k >= 0; k--)
                                {
                                    string tmpTemplateFile = tmpTemplateFiles[k];
                                    if (!templateFiles.Contains(tmpTemplateFile, StringComparer.InvariantCultureIgnoreCase))
                                    {
                                        templateFiles.Insert(0, tmpTemplateFile);
                                    }
                                }
                            }
                            else
                            {
                                foreach (string tmpTemplateFile in tmpTemplateFiles)
                                {
                                    if (!templateFiles.Contains(tmpTemplateFile, StringComparer.InvariantCultureIgnoreCase))
                                    {
                                        templateFiles.Add(tmpTemplateFile);
                                    }
                                }
                            }
                        }
                        templateValidityList[j] = false;
                    }
                }

                sw.Write(string.Format("{0};{1}", templateName, templateType));
                foreach (string element in templateChildren)
                {
                    if (!string.IsNullOrEmpty(element))
                    {
                        sw.Write(string.Format(";{0}", element));
                    }
                }
                foreach (string element in templateFiles)
                {
                    if (!string.IsNullOrEmpty(element))
                    {
                        sw.Write(string.Format(";{0}", element));
                    }
                }
                sw.WriteLine();
                string templateFile = templateFiles[0];
            }
        }

        string cachefileBackup = Path.Combine(extractedFolder, "cache_db.csv.bak");
        if (!File.Exists(cachefileBackup))
        {
            File.Move(cachefile, cachefileBackup);
        }
        else
        {
            File.Delete(cachefile);
        }
        File.Move(tmpcachefile, cachefile);
    }
}
