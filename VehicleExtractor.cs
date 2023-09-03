using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

public class VehicleExtractor
{
    #region NOT TESTED
    public static string ReadConFile(string file)
    {
        if (!File.Exists(file))
        {
            Console.WriteLine(file + " not found");
            return "";
        }
        return File.ReadAllText(file);
    }

    public static string ConvertBlockCommentsConContent(string concontent)
    {
        string content = "";
        string beginremregexpr = "^\\s*beginrem\\s*";
        string endremregexpr = "^\\s*endrem\\s*";
        bool bInsideBlockComment = false;
        string[] lines = Regex.Split(concontent, "\\r?\\n");
        for (int i = 0; i < lines.Length; i++)
        {
            string line = lines[i];
            if (bInsideBlockComment)
            {
                Match m = Regex.Match(line, endremregexpr, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
                if (m.Success)
                {
                    bInsideBlockComment = false;
                    content += "rem " + line + "\\r\\n";
                    continue;
                }
                content += "rem " + line + "\\r\\n";
                continue;
            }
            Match m2 = Regex.Match(line, beginremregexpr, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
            if (m2.Success)
            {
                bInsideBlockComment = true;
                content += "rem " + line + "\\r\\n";
                continue;
            }
            content += line + "\\r\\n";
        }
        return content;
    }

    public static string cbInsideCommentLine(string concontent, int i, string line, string params1)
    {
        string content = params1;
        return content;
    }

    public static string cbOutsideCommentLine(string concontent, int i, string line, string params1)
    {
        string content = params1;
        content += line + "\\r\\n";
        return content;
    }

    public static string PreProcessCommentsConContent(string concontent, Func<string, int, string, string, string> cbInsideCommentLine, Func<string, int, string, string, string> cbOutsideCommentLine)
    {
        string content = "";
        string remregexpr = "^\\s*rem\\s+(.*)\\s*";
        string beginremregexpr = "^\\s*beginrem\\s*";
        string endremregexpr = "^\\s*endrem\\s*";
        bool bInsideBlockComment = false;
        string[] lines = Regex.Split(concontent, "\\r?\\n");
        for (int i = 0; i < lines.Length; i++)
        {
            string line = lines[i];
            if (bInsideBlockComment)
            {
                Match m = Regex.Match(line, endremregexpr, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
                if (m.Success)
                {
                    bInsideBlockComment = false;

                    content = cbInsideCommentLine(concontent, i, line, content);

                    continue;
                }

                content = cbInsideCommentLine(concontent, i, line, content);

                continue;
            }
            Match m2 = Regex.Match(line, remregexpr, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
            if (m2.Success)
            {

                content = cbInsideCommentLine(concontent, i, line, content);

                continue;
            }
            Match m3 = Regex.Match(line, beginremregexpr, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
            if (m3.Success)
            {
                bInsideBlockComment = true;

                content = cbInsideCommentLine(concontent, i, line, content);

                continue;
            }

            content = cbOutsideCommentLine(concontent, i, line, content);

        }
        return content;
    }

    public static string cbConditionCode(string concontent, int i, string line, string params1)
    {
        string content = params1;
        return content;
    }

    public static string cbOtherCode(string concontent, int i, string line, string params1)
    {
        string content = params1;
        content += line + "\\r\\n";
        return content;
    }

    public static string cbInsideTrueCondition(string concontent, int i, string line, string params1)
    {
        string content = params1;
        content += line + "\\r\\n";
        return content;
    }

    public static string cbInsideFalseCondition(string concontent, int i, string line, string params1)
    {
        string content = params1;
        return content;
    }

    public static string PreProcessIfConContent(string concontent, ref int i, Func<string, int, string, string, string> cbConditionCode, Func<string, int, string, string, string> cbOtherCode, Func<string, int, string, string, string> cbInsideTrueCondition, Func<string, int, string, string, string> cbInsideFalseCondition)
    {
        string content = "";
        string ifregexpr = "^\\s*if\\s+";
        string ifeqregexpr = "^\\s*if\\s+(\\S*)\\s*==\\s*(\\S*)\\s*";
        string ifneregexpr = "^\\s*if\\s+(\\S*)\\s*!=\\s*(\\S*)\\s*";
        string elseifregexpr = "^\\s*elseIf\\s+";
        string elseifeqregexpr = "^\\s*elseIf\\s+(\\S*)\\s*==\\s*(\\S*)\\s*";
        string elseifneregexpr = "^\\s*elseIf\\s+(\\S*)\\s*!=\\s*(\\S*)\\s*";
        string elseregexpr = "^\\s*else\\s*";
        string endifregexpr = "^\\s*endIf\\s*";
        bool bInsideCondition = false;
        bool bInsideTrueCondition = false;
        bool bFoundTrueCondition = false;
        string[] lines = Regex.Split(concontent, "\\r?\\n");
        for (i = 0; i < lines.Length; i++)
        {
            string line = lines[i];
            if (bInsideCondition)
            {
                Match m =
                    Regex.Match(line,
                                elseifeqregexpr,
                                RegexOptions.IgnoreCase |
                                RegexOptions.CultureInvariant);
                if (m.Groups.Count == 3)
                {

                    content =
                        cbConditionCode(concontent,
                                        i,
                                        line,
                                        content);

                    if (bInsideTrueCondition)
                    {
                        bInsideTrueCondition = false;
                        continue;
                    }
                    if ((!bFoundTrueCondition) &&
                        (m.Groups[1].Value.Equals(m.Groups[2].Value)))
                    {
                        bInsideTrueCondition = true;
                        bFoundTrueCondition = true;
                    }
                    continue;
                }
                m =
                    Regex.Match(line,
                                elseifneregexpr,
                                RegexOptions.IgnoreCase |
                                RegexOptions.CultureInvariant);
                if (m.Groups.Count == 3)
                {

                    content =
                        cbConditionCode(concontent,
                                        i,
                                        line,
                                        content);

                    if (bInsideTrueCondition)
                    {
                        bInsideTrueCondition = false;
                        continue;
                    }
                    if ((!bFoundTrueCondition) &&
                        (!m.Groups[1].Value.Equals(m.Groups[2].Value)))
                    {
                        bInsideTrueCondition = true;
                        bFoundTrueCondition = true;
                    }
                    continue;
                }
                m =
                    Regex.Match(line,
                                elseregexpr,
                                RegexOptions.IgnoreCase |
                                RegexOptions.CultureInvariant);
                if (m.Success)
                {

                    content =
                        cbConditionCode(concontent,
                                        i,
                                        line,
                                        content);

                    if (bInsideTrueCondition)
                    {
                        bInsideTrueCondition = false;
                        continue;
                    }
                    if (!bFoundTrueCondition)
                    {
                        bInsideTrueCondition = true;
                        bFoundTrueCondition = true;
                    }
                    continue;
                }
                m =
                    Regex.Match(line,
                                endifregexpr,
                                RegexOptions.IgnoreCase |
                                RegexOptions.CultureInvariant);
                if (m.Success)
                {

                    content =
                        cbConditionCode(concontent,
                                        i,
                                        line,
                                        content);

                    bInsideCondition = false;
                    bInsideTrueCondition = false;
                    bFoundTrueCondition = false;
                    continue;
                }
                if (bInsideTrueCondition)
                {

                    // If multiple conditions inside...
                    m =
                       Regex.Match(line,
                                   ifregexpr,
                                   RegexOptions.IgnoreCase |
                                   RegexOptions.CultureInvariant);
                    if (m.Success)
                    {
                        // Get the content block starting at the current line
                        string[] contentBlock = new List<string>(lines).GetRange(i, lines.Length - i).ToArray();
                        int iblock = 0;
                        content += PreProcessIfConContent(string.Join(Environment.NewLine, contentBlock), ref iblock, cbConditionCode, cbOtherCode, cbInsideTrueCondition, cbInsideFalseCondition);
                        i += (iblock - 1);
                        continue;
                    }

                    content =
                        cbInsideTrueCondition(concontent,
                                              i,
                                              line,
                                              content);

                }
                else
                {

                    // If multiple conditions inside...
                    m =
                       Regex.Match(line,
                                   ifregexpr,
                                   RegexOptions.IgnoreCase |
                                   RegexOptions.CultureInvariant);
                    if (m.Success)
                    {
                        // Get the content block starting at the current line
                        string[] contentBlock = new List<string>(lines).GetRange(i, lines.Length - i).ToArray();
                        int iblock = 0;
                        content += PreProcessIfConContent(string.Join(Environment.NewLine, contentBlock), ref iblock, cbInsideFalseCondition, cbInsideFalseCondition, cbInsideFalseCondition, cbInsideFalseCondition);
                        i += (iblock - 1);
                        continue;
                    }

                    content =
                        cbInsideFalseCondition(concontent,
                                               i,
                                               line,
                                               content);

                }
            }
            Match m2 =
               Regex.Match(line,
                           ifeqregexpr,
                           RegexOptions.IgnoreCase |
                           RegexOptions.CultureInvariant);
            if (m2.Groups.Count == 3)
            {

                content =
                   cbConditionCode(concontent,
                                   i,
                                   line,
                                   content);

                bInsideCondition = true;
                bInsideTrueCondition = false;
                bFoundTrueCondition = false;
                if (m2.Groups[1].Value.Equals(m2.Groups[2].Value))
                {
                    bInsideTrueCondition = true;
                    bFoundTrueCondition = true;
                }
                continue;
            }
            m2 =
                Regex.Match(line,
                            ifneregexpr,
                            RegexOptions.IgnoreCase |
                            RegexOptions.CultureInvariant);
            if (m2.Groups.Count == 3)
            {

                content =
                    cbConditionCode(concontent,
                                    i,
                                    line,
                                    content);

                bInsideCondition = true;
                bInsideTrueCondition = false;
                bFoundTrueCondition = false;
                if (!m2.Groups[1].Value.Equals(m2.Groups[2].Value))
                {
                    bInsideTrueCondition = true;
                    bFoundTrueCondition = true;
                }
                continue;
            }

            // If multiple conditions inside...
            if (Regex.Match(line, elseifregexpr, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant).Success)
            {
                break;
            }
            else if (Regex.Match(line, elseregexpr, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant).Success)
            {
                break;
            }
            else if (Regex.Match(line, endifregexpr, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant).Success)
            {
                break;
            }

            content = cbOtherCode(concontent, i, line, content);

        }
        return content;
    }

    public static string PreProcessArgsConContent(string concontent, string v_arg1, string v_arg2, string v_arg3, string v_arg4, string v_arg5, string v_arg6, string v_arg7, string v_arg8, string v_arg9)
    {
        string content = "";
        foreach (string line in Regex.Split(concontent, "\\r?\\n"))
        {
            if ((v_arg1 != null) && (v_arg1 != "")) { line.Replace("v_arg1", v_arg1); } else { line.Replace("v_arg1", "\"null\""); }
            if ((v_arg2 != null) && (v_arg2 != "")) { line.Replace("v_arg2", v_arg2); } else { line.Replace("v_arg2", "\"null\""); }
            if ((v_arg3 != null) && (v_arg3 != "")) { line.Replace("v_arg3", v_arg3); } else { line.Replace("v_arg3", "\"null\""); }
            if ((v_arg4 != null) && (v_arg4 != "")) { line.Replace("v_arg4", v_arg4); } else { line.Replace("v_arg4", "\"null\""); }
            if ((v_arg5 != null) && (v_arg5 != "")) { line.Replace("v_arg5", v_arg5); } else { line.Replace("v_arg5", "\"null\""); }
            if ((v_arg6 != null) && (v_arg6 != "")) { line.Replace("v_arg6", v_arg6); } else { line.Replace("v_arg6", "\"null\""); }
            if ((v_arg7 != null) && (v_arg7 != "")) { line.Replace("v_arg7", v_arg7); } else { line.Replace("v_arg7", "\"null\""); }
            if ((v_arg8 != null) && (v_arg8 != "")) { line.Replace("v_arg8", v_arg8); } else { line.Replace("v_arg8", "\"null\""); }
            if ((v_arg9 != null) && (v_arg9 != "")) { line.Replace("v_arg9", v_arg9); } else { line.Replace("v_arg9", "\"null\""); }

            content += line + "\\r\\n";
        }
        return content;
    }

    public static string PreProcessConstsConContent(string concontent)
    {
        string[] constNames = null;
        string[] constValues = null;

        string content = "";
        foreach (string line in Regex.Split(concontent, "\\r?\\n"))
        {
            Match m = Regex.Match(line, "^\\s*const\\s+(\\S+)\\s*=\\s*(\\S+)\\s*", RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
            if (m.Groups.Count == 3)
            {
                Array.Resize(ref constNames, constNames.Length + 1);
                constNames[constNames.Length - 1] = m.Groups[1].Value;
                Array.Resize(ref constValues, constValues.Length + 1);
                constValues[constValues.Length - 1] = m.Groups[2].Value;
            }
            else if (constNames != null)
            {
                for (int i = 0; i < constNames.Length; i++)
                {
                    string regescconstName = Regex.Escape(constNames[i]);
                    line.Replace(regescconstName, constValues[i]);
                }
            }

            content += line + "\\r\\n";
        }
        return content;
    }

    public static string PreProcessVarsConContent(string concontent)
    {
        string[] varNames = null;
        string[] varValues = null;
        bool[] bVarArrowAssignments = null;

        string content = "";
        foreach (string line in Regex.Split(concontent, "\\r?\\n"))
        {
            Match m = Regex.Match(line, "^\\s*var\\s+(\\S+)\\s*=\\s*(\\S+)\\s*", RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
            if (m.Groups.Count == 3)
            {
                Array.Resize(ref varNames, varNames.Length + 1);
                varNames[varNames.Length - 1] = m.Groups[1].Value;
                Array.Resize(ref varValues, varValues.Length + 1);
                varValues[varValues.Length - 1] = m.Groups[2].Value;
                Array.Resize(ref bVarArrowAssignments, bVarArrowAssignments.Length + 1);
                bVarArrowAssignments[bVarArrowAssignments.Length - 1] = false;
            }
            else if (varNames != null)
            {
                for (int i = 0; i < varNames.Length; i++)
                {
                    string regescvarName = Regex.Escape(varNames[i]);
                    m = Regex.Match(line, "^\\s*" + regescvarName + "\\s*=\\s*(\\S+)\\s*", RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
                    if (m.Groups.Count == 2)
                    {
                        varValues[i] = m.Groups[1].Value;
                        bVarArrowAssignments[i] = false;
                    }
                    else
                    {
                        m = Regex.Match(line, "\\s*->\\s*" + regescvarName + "\\s*", RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
                        if (m.Groups.Count == 2)
                        {
                            bVarArrowAssignments[i] = true;
                        }
                        else if (!bVarArrowAssignments[i])
                        {
                            line.Replace(regescvarName, varValues[i]);
                        }
                    }
                }
            }

            content += line + "\\r\\n";
        }
        return content;
    }

    public static string PreProcessIncludesConLine(string line, string file)
    {
        Match m = Regex.Match(line, @"^\s*include\s+(\S+)(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?\s*", RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
        if (m.Groups.Count >= 2)
        {
            string resRelPath = m.Groups[1].Value;
            string includedFile = Path.Combine(new FileInfo(file).DirectoryName, resRelPath);
            if (new FileInfo(includedFile).Extension.Equals("", StringComparison.OrdinalIgnoreCase))
            {
                includedFile = includedFile + ".con";
            }
            string v_arg1 = m.Groups[3].Value;
            string v_arg2 = m.Groups[5].Value;
            string v_arg3 = m.Groups[7].Value;
            string v_arg4 = m.Groups[9].Value;
            string v_arg5 = m.Groups[11].Value;
            string v_arg6 = m.Groups[13].Value;
            string v_arg7 = m.Groups[15].Value;
            string v_arg8 = m.Groups[17].Value;
            string v_arg9 = m.Groups[19].Value;
            int i = 0;
            string includedFileContent = PreProcessRunsConContent(PreProcessIncludesConContent(PreProcessIfConContent(PreProcessVarsConContent(PreProcessConstsConContent(PreProcessArgsConContent(PreProcessCommentsConContent(ReadConFile(includedFile), cbInsideCommentLine, cbOutsideCommentLine), v_arg1, v_arg2, v_arg3, v_arg4, v_arg5, v_arg6, v_arg7, v_arg8, v_arg9))), ref i, cbConditionCode, cbOtherCode, cbInsideTrueCondition, cbInsideFalseCondition), includedFile), includedFile);
            return includedFileContent;
        }
        else
        {
            return line;
        }
    }

    public static string PreProcessIncludesConContent(string concontent, string file)
    {
        string content = "";
        foreach (string line in concontent.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.None))
        {
            content += PreProcessIncludesConLine(line, file) + "\r\n";
        }
        return content;
    }

    public static string GetFileIncludedConLine(string line, string file)
    {
        Match m =
           Regex.Match(line,
                       "^\\s*include\\s+(\\S+)(\\s+)?(\\S+)?(\\s+)?(\\S+)?(\\s+)?(\\S+)?(\\s+)?(\\S+)?(\\s+)?(\\S+)?(\\s+)?(\\S+)?(\\s+)?(\\S+)?(\\s+)?(\\S+)?(\\s+)?(\\S+)?",
                       RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
        if (m.Groups.Count >= 2)
        {
            return Path.Combine(Path.GetDirectoryName(file), m.Groups[1].Value.Replace("\"", "").Replace("/", "\\"));
        }
        else
        {
            return null;
        }
    }

    public static string PreProcessRunsConLine(string line, string file)
    {
        Match m = Regex.Match(line, @"^\s*run\s+(\S+)(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?(\s+)?(\S+)?\s*", RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
        if (m.Groups.Count >= 2)
        {
            string resRelPath = m.Groups[1].Value.Replace("`", "").Replace("/", @"\");
            string runFile = Path.Combine(new FileInfo(file).DirectoryName, resRelPath);
            if (new FileInfo(runFile).Extension.Equals("", StringComparison.OrdinalIgnoreCase))
            {
                runFile = runFile + ".con";
            }
            string v_arg1 = m.Groups[3].Value;
            string v_arg2 = m.Groups[5].Value;
            string v_arg3 = m.Groups[7].Value;
            string v_arg4 = m.Groups[9].Value;
            string v_arg5 = m.Groups[11].Value;
            string v_arg6 = m.Groups[13].Value;
            string v_arg7 = m.Groups[15].Value;
            string v_arg8 = m.Groups[17].Value;
            string v_arg9 = m.Groups[19].Value;

            //int i=0
            //string runFileContent=(PreProcessRunsConContent (PreProcessIncludesConContent (PreProcessIfConContent (PreProcessVarsConContent (PreProcessConstsConContent (PreProcessArgsConContent (PreProcessCommentsConContent (ReadConFile $runFile) "cbInsideCommentLine" "cbOutsideCommentLine") $v_arg1 $v_arg2 $v_arg3 $v_arg4 $v_arg5 $v_arg6 $v_arg7 $v_arg8 $v_arg9))) ([ref]$i) "cbConditionCode" "cbOtherCode" "cbInsideTrueCondition" "cbInsideFalseCondition") $runFile) $runFile) -replace "\s*\r?\n\s*\r?\n\s*\r?\n\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n?\s*\r?\n\s*\r?\n?\s*\r?\n?","`r`n`r`n"
            string runFileContent = PreProcessRunsConContent(PreProcessIncludesConContent(PreProcessVarsConContent(PreProcessConstsConContent(PreProcessArgsConContent(PreProcessCommentsConContent(ReadConFile(runFile), cbInsideCommentLine, cbOutsideCommentLine), v_arg1, v_arg2, v_arg3, v_arg4, v_arg5, v_arg6, v_arg7, v_arg8, v_arg9))), runFile), runFile);
            return runFileContent;
        }
        else
        {
            return line;
        }
    }

    public static string PreProcessRunsConContent(string concontent, string file)
    {
        string content = "";
        foreach (string line in concontent.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.None))
        {
            content += PreProcessRunsConLine(line, file) + "\r\n";
        }
        return content;
    }

    public static string GetFileRunConLine(string line, string file)
    {
        Match m = Regex.Match(line, "^\\s*run\\s+(\\S+)(\\s+)?(\\S+)?(\\s+)?(\\S+)?(\\s+)?(\\S+)?(\\s+)?(\\S+)?(\\s+)?(\\S+)?(\\s+)?(\\S+)?(\\s+)?(\\S+)?(\\s+)?(\\S+)?(\\s+)?(\\S+)?", RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
        if (m.Groups.Count >= 2)
        {
            return Path.Combine(Path.GetDirectoryName(file), m.Groups[1].Value.Replace("\"", "").Replace("/", "\\"));
        }
        else
        {
            return null;
        }
    }
    #endregion NOT TESTED
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
