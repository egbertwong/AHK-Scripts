#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
; 为菜单栏创建子菜单:
Menu, FileMenu, Add, &New, FileNew
Menu, FileMenu, Add, &Open, FileOpen
Menu, FileMenu, Add, &Save, FileSave
Menu, FileMenu, Add, Save &As, FileSaveAs
Menu, FileMenu, Add  ; 分隔线.
Menu, FileMenu, Add, E&xit, FileExit
Menu, HelpMenu, Add, &About, HelpAbout

; 创建用来附加子菜单的菜单栏:
Menu, MyMenuBar, Add, &File, :FileMenu
Menu, MyMenuBar, Add, &Help, :HelpMenu

; 添加菜单栏到窗口:
Gui, Menu, MyMenuBar

; 创建主编辑控件并显示窗口:
Gui, +Resize  ; 让用户可以调整窗口的大小.
Gui, Add, Edit, vMainEdit WantTab W600 R20
Gui, Show,, Untitled
CurrentFileName :=""  ; 表示当前没有文件.
return

FileNew:
GuiControl,, MainEdit  ; 清空编辑控件.
return

FileOpen:
Gui +OwnDialogs  ; 强制用户响应 FileSelectFile 对话框后才能返回到主窗口.
FileSelectFile, SelectedFileName, 3,, Open File, Text Documents (*.txt)
if not SelectedFileName   ; 没有选择文件.
    return
Gosub FileRead
return

FileRead:  ; 调用者已经设置了 SelectedFileName 变量.
FileRead, MainEdit, %SelectedFileName%  ; 读取文件的内容到变量中.
if ErrorLevel
{
    MsgBox Could not open "%SelectedFileName%".
    return
}
GuiControl,, MainEdit, %MainEdit%  ; 在控件中显示文本.
CurrentFileName := SelectedFileName
Gui, Show,, %CurrentFileName%   ; 在标题栏显示文件名.
return

FileSave:
if not CurrentFileName   ; 还没有选择文件, 所以执行另存为操作.
    Goto FileSaveAs
Gosub SaveCurrentFile
return

FileSaveAs:
Gui +OwnDialogs  ; 强制用户响应 FileSelectFile 对话框后才能返回到主窗口.
FileSelectFile, SelectedFileName, S16,, Save File, Text Documents (*.txt)
if not SelectedFileName ; 没有选择文件.
    return
CurrentFileName := SelectedFileName
Gosub SaveCurrentFile
return

SaveCurrentFile:  ; 调用者已经确保了 CurrentFileName 不为空.
if FileExist(CurrentFileName)
{
    FileDelete %CurrentFileName%
    if ErrorLevel
    {
        MsgBox The attempt to overwrite "%CurrentFileName%" failed.
        return
    }
}
GuiControlGet, MainEdit  ; 获取编辑控件的内容.
FileAppend, %MainEdit%, %CurrentFileName%  ; 保存内容到文件.
; 成功时在标题栏显示文件名 (以防 FileSaveAs 调用时的情况):
Gui, Show,, %CurrentFileName%
return

HelpAbout:
Gui, About:+owner1  ; 让主窗口 (Gui #1) 成为 "关于对话框" 的父窗口.
Gui +Disabled  ; 禁用主窗口.
Gui, About:Add, Text,, Text for about box.
Gui, About:Add, Button, Default, OK
Gui, About:Show
return

AboutButtonOK:  ; 上面的 "关于对话框" 需要使用这部分.
AboutGuiClose:
AboutGuiEscape:
Gui, 1:-Disabled  ; 重新启用主窗口 (必须在下一步之前进行).
Gui Destroy  ; 销毁关于对话框.
return

GuiDropFiles:  ; 对拖放提供支持.
Loop, Parse, A_GuiEvent, `n
{
    SelectedFileName := A_LoopField  ; 仅获取首个文件 (如果有多个文件的时候).
    break
}
Gosub FileRead
return

GuiSize:
if (ErrorLevel = 1)  ; 窗口被最小化了. 无需进行操作.
    return
; 否则, 窗口的大小被调整过或被最大化了. 调整编辑控件的大小以匹配窗口.
NewWidth := A_GuiWidth - 20
NewHeight := A_GuiHeight - 20
GuiControl, Move, MainEdit, W%NewWidth% H%NewHeight%
return

FileExit:     ; 用户在 File 菜单中选择了 "Exit".
GuiClose:  ; 用户关闭了窗口.
ExitApp