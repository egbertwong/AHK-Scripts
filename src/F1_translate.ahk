#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

$F1::
    KeyWait, F1, T0.6 ; wait 0.6s
    if (ErrorLevel)
        sendinput {F1} ; long press
    else {
        KeyWait, F1, D T0.3 ; wait 0.3s
        if (ErrorLevel)
            translate("auto","zh-CN") ; single press
        else
            translate("auto","en") ; double press
    }
    KeyWait, F1
return

; Google Translate:
translate(from := "auto", to := "zh-CN")
{
    Clipboard := ""
    SendInput, ^c
    ClipWait, 1
    if ErrorLevel
        Return
    
    ; Later two lines transform multiline string to single line string, and save results in clipboard. This is very useful when copying multiline string from pdf.
    Clipboard:=RegExReplace(Clipboard,"\r\n[ #;%]*([\x{3002}\x{ff1b}\x{ff0c}\x{ff1a}\x{201c}\x{201d}\x{ff08}\x{ff09}\x{3001}\x{ff1f}\x{300a}\x{300b}\x{4e00}-\x{9fa5}])","$1")
    Clipboard:=RegExReplace(Clipboard,"\r\n[ #;%]*"," ")
    ; Clipboard:=RegExReplace(Clipboard,"\r\n[ #;%]*([A-z])"," $1")
    ; Clipboard:=RegExReplace(Clipboard,"\r\n[ #;%]*([^A-z])","$1")
    
    if (to == "en") ;translate other language to english
    {
        MsgBox, ,,% GoogleTranslate(Clipboard,from,to).full, 3
    }
    else ; translate other language to chinese or get chinese pinyin
    { 
        a:=StrLen(RegExReplace(Clipboard,"[^\x{3002}\x{ff1b}\x{ff0c}\x{ff1a}\x{201c}\x{201d}\x{ff08}\x{ff09}\x{3001}\x{ff1f}\x{300a}\x{300b}\x{4e00}-\x{9fa5}]","")) ;calculate chinese charactor length
        b:=StrLen(Clipboard) ;total string length
        c:=a/b ; chinese charactor percent
        if (c >0.8) ;if most charactor is chinese charactor, don't translate to chinese
        {
            if (b>4) ;When string length is long, just show it. 
                msgbox,,,%clipboard% ,2
            else ;When string length is short, show it's pinyin.
                MsgBox, ,,% GoogleTranslate(Clipboard).pinyin, 3
        }
        else ; if most charactor isn't chinese charactor, translate to chinese
        {
            if(b<30) ;When string length is short, show message box just 3 seconds.
                MsgBox, ,,% GoogleTranslate(Clipboard).full, 3
            else ; if not, show message unless user close it.
                MsgBox, ,,% GoogleTranslate(Clipboard).full,
        }
    }
}

GoogleTranslate(str, from := "auto", to := "zh-CN") {
    JSON := new JSON
    JS := JSON.JS, JS.( GetJScript() )
    
    sJson := SendRequest(JS, str, to, from)
    oJSON := JSON.Parse(sJson)
    
    if !IsObject(oJSON[2]) {
        for k, v in oJSON[1]
            trans .= v[1]
    }
    else {
        MainTransText := oJSON[1, 1, 1]
        for k, v in oJSON[2] {
            trans .= "`n+"
            for i, txt in v[2]
                trans .= (MainTransText = txt ? "" : "`n" . txt)
        }
    }
    if !IsObject(oJSON[2])
        MainTransText := trans := Trim(trans, ",+`n ")
    else
        trans := MainTransText . "`n+`n" . Trim(trans, ",+`n ")
    
    from := oJSON[3]    
    pinyin := oJSON[1,2,3]
    trans := Trim(trans, ",+`n ")
Return {main: MainTransText, full: trans, from: from , pinyin: pinyin}
}

SendRequest(JS, str, tl, sl) {
    ComObjError(false)
    url := "https://translate.google.cn/translate_a/single?client=webapp&sl="
    . sl . "&tl=" . tl . "&hl=" . tl
    . "&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&ie=UTF-8&oe=UTF-8&otf=1&ssel=3&tsel=3&pc=1&kc=2"
    . "&tk=" . JS.("tk").(str)
    body := "q=" . URIEncode(str)
    contentType := "application/x-www-form-urlencoded;charset=utf-8"
    userAgent := "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
Return JSON.GetFromUrl(url, body, contentType, userAgent)
}

URIEncode(str, encoding := "UTF-8") {
    VarSetCapacity(var, StrPut(str, encoding))
    StrPut(str, &var, encoding)
    
    While code := NumGet(Var, A_Index - 1, "UChar") {
        bool := (code > 0x7F || code < 0x30 || code = 0x3D)
        UrlStr .= bool ? "%" . Format("{:02X}", code) : Chr(code)
    }
Return UrlStr
}

GetJScript()
{
    script =
(
    var TKK = ((function() {
        var a = 561666268;
        var b = 1526272306;
        return 406398 + '.' + (a + b);
    })());
    
    function b(a, b) {
        for (var d = 0; d < b.length - 2; d += 3) {
            var c = b.charAt(d + 2),
        c = "a" <= c ? c.charCodeAt(0) - 87 : Number(c),
        c = "+" == b.charAt(d + 1) ? a >>> c : a << c;
        a = "+" == b.charAt(d) ? a + c & 4294967295 : a ^ c
        }
        return a
    }

    function tk(a) {
        for (var e = TKK.split("."), h = Number(e[0]) || 0, g = [], d = 0, f = 0; f < a.length; f++) {
            var c = a.charCodeAt(f);
            128 > c ? g[d++] = c : (2048 > c ? g[d++] = c >> 6 | 192 : (55296 == (c & 64512) && f + 1 < a.length && 56320 == (a.charCodeAt(f + 1) & 64512) ?
            (c = 65536 + ((c & 1023) << 10) + (a.charCodeAt(++f) & 1023), g[d++] = c >> 18 | 240,
            g[d++] = c >> 12 & 63 | 128) : g[d++] = c >> 12 | 224, g[d++] = c >> 6 & 63 | 128), g[d++] = c & 63 | 128)
        }
        a = h;
        for (d = 0; d < g.length; d++) a += g[d], a = b(a, "+-a^+6");
            a = b(a, "+-3^+b+-f");
        a ^= Number(e[1]) || 0;
        0 > a && (a = (a & 2147483647) + 2147483648);
        a `%= 1E6;
        return a.toString() + "." + (a ^ h)
    }
)
    Return script
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