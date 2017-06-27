# C# because PowerShell is bad at Win32
$cSharpSignature = @"
    [DllImport("User32.dll", EntryPoint = "SetWindowText")]
    private static extern int SetWindowText(IntPtr hWnd, string text);

    [DllImport("User32.dll", EntryPoint = "FindWindowEx")]
    private static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindow);

    [DllImport("User32.dll", EntryPoint = "SendMessage")]
    private static extern int SendMessage(IntPtr hWnd, int uMsg, int wParam, string lParam);

    public static void OpenWithText(string message = null, string title = null)
    {
        Process notepad = Process.Start(new ProcessStartInfo("notepad.exe"));
        if (notepad != null)
        {
            notepad.WaitForInputIdle();

            if (!string.IsNullOrEmpty(title))
                SetWindowText(notepad.MainWindowHandle, title);

            if (!string.IsNullOrEmpty(message))
            {
                IntPtr child = FindWindowEx(notepad.MainWindowHandle, new IntPtr(0), "Edit", null);
                SendMessage(child, 0x000C, 0, message);
            }
        }
    }
"@

# Build the C# so we can use it
Add-Type -Name "Helpers" -Namespace "Notepad" -MemberDefinition $cSharpSignature -UsingNamespace "System.Diagnostics"

function Open-Notepad{
param([string]$text, [string]$title)
    [Notepad.Helpers]::OpenWithText($text, $title)
}