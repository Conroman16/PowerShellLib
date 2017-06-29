# C# because PowerShell is bad at Win32
$cSharpSignature = @"
    [DllImport("User32.dll", EntryPoint = "SetWindowText")]
    private static extern int SetWindowText(IntPtr hWnd, string text);

    [DllImport("User32.dll", EntryPoint = "FindWindowEx")]
    private static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindow);

    [DllImport("User32.dll", EntryPoint = "SendMessage")]
    private static extern int SendMessage(IntPtr hWnd, int uMsg, int wParam, string lParam);

    public static void Open(string text = null, string title = null)
    {
        // Start Notepad
        Process notepad = Process.Start(new ProcessStartInfo("notepad.exe"));
        if (notepad == null || notepad.HasExited)
            return;

        notepad.WaitForInputIdle();

        // Set the Notepad window title if one was specified
        if (!string.IsNullOrEmpty(title))
            SetWindowText(notepad.MainWindowHandle, title);

        // Set the Notepad window text if specified
        if (!string.IsNullOrEmpty(text))
        {
            // Get a pointer to Notepad's editor pane
            IntPtr child = FindWindowEx(notepad.MainWindowHandle, new IntPtr(0), "Edit", null);

            // Send that editor pane a WM_SETTEXT message with the text we want
            SendMessage(child, 0x000C, 0, text);
        }
    }
"@

# Build the C# so it can be used in this module
Add-Type -Name "Helpers" -Namespace "Notepad" -MemberDefinition $cSharpSignature -UsingNamespace "System.Diagnostics"

function Open-Notepad{
param([string]$WindowText, [string]$WindowTitle)
    [Notepad.Helpers]::Open($WindowText, $WindowTitle)
}
