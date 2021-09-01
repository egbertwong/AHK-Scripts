#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

ctrl_cPressCount := 0
~^c::
{
    ctrl_cPressCount += 1
    SetTimer, ProcSubroutine, Off
    SetTimer, ProcSubroutine, 300
    Return
}

ProcSubroutine:
{
    ; 在计时器事件触发时，需要将其关掉
    SetTimer, ProcSubroutine, Off
    If ctrl_cPressCount = 1
    {
        ; 第一类行为
        ; MsgBox, 触发单击鼠标右键事件
    }
    Else If ctrl_cPressCount = 2
    {
        ; 第二类行为
        ;translate("auto","en") ; single press
    }
    Else If ctrl_cPressCount = 3
    {
        ;translate("auto","zh-CN") ; single press
        Gui, MyGui:New
        Gui, MyGui:Add, Text, , Source text:
        Gui, MyGui:Add, Edit, r9 w300, %Clipboard%
        Gui, MyGui:Add, Text, , Do you want to translate:
        Gui, MyGui:Add, Edit, r9 w300, Hello World!
        Gui, MyGui:Add, Text, ys, Target text:
        Gui, MyGui:Add, Edit, r9 w300, 你好世界！
        Gui, MyGui:Show
    }
    Else
    {
        MsgBox, 多次点击 %ctrl_cPressCount%
    }

    ; 在结束后，还需要将鼠标右键的按键次数置为0，以方便下次使用
    ctrl_cPressCount := 0
    Return
}

MyGuiGuiEscape:
MyGuiGuiClose:
MyGuiButtonCancel:
Gui, MyGui:Destroy

class GoogleTranslate
{
    sourceText := ""
    fixedText := ""
    targetText := ""



}

class JSON
{
    static JS := JSON._GetJScripObject()
    
    Parse(JsonString) {
        try oJSON := this.JS.("(" JsonString ")")
        catch {
            MsgBox, Wrong JsonString!
            Return
        }
        Return this._CreateObject(oJSON)
    }
    
    GetFromUrl(url, body := "", contentType := "", userAgent := "") {
        XmlHttp := ComObjCreate("Microsoft.XmlHttp")
        XmlHttp.Open("GET", url, false)
        ( contentType && XmlHttp.SetRequestHeader("Content-Type", contentType) )
        ( userAgent && XmlHttp.SetRequestHeader("User-Agent", userAgent) )
        XmlHttp.Send(body)
        Return XmlHttp.ResponseText
    }
    
    _GetJScripObject() {
        VarSetCapacity(tmpFile, (MAX_PATH := 260) << !!A_IsUnicode, 0)
        DllCall("GetTempFileName", Str, A_Temp, Str, "AHK", UInt, 0, Str, tmpFile)
        
        FileAppend,
        (
        <component>
        <public><method name='eval'/></public>
        <script language='JScript'></script>
        </component>
        ), % tmpFile
        
        JS := ObjBindMethod( ComObjGet("script:" . tmpFile), "eval" )
        FileDelete, % tmpFile
        JSON._AddMethods(JS)
        Return JS
    }
    
    _AddMethods(ByRef JS) {
        JScript =
        (
        Object.prototype.GetKeys = function () {
            var keys = []
            for (var k in this)
                if (this.hasOwnProperty(k))
                keys.push(k)
            return keys
        }
        Object.prototype.IsArray = function () {
            var toStandardString = {}.toString
            return toStandardString.call(this) == '[object Array]'
        }
        )
        JS.("delete ActiveXObject; delete GetObject;")
        JS.(JScript)
    }
    
    _CreateObject(ObjJS) {
        res := ObjJS.IsArray()
        if (res = "")
            Return ObjJS
        
        else if (res = -1) {
            obj := []
            Loop % ObjJS.length
                obj[A_Index] := this._CreateObject(ObjJS[A_Index - 1])
        }
        else if (res = 0) {
            obj := {}
            keys := ObjJS.GetKeys()
            Loop % keys.length
                k := keys[A_Index - 1], obj[k] := this._CreateObject(ObjJS[k])
        }
        Return obj
    }
}