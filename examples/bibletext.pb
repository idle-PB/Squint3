;an example of scaning a text file to build a dictionary 
;to display it in sorted order and search for an item 

XIncludeFile "..\squint3.pbi"

UseModule SQUINT

EnableExplicit 

Global sq.isquint = SquintNew()

Procedure CBSearch(*key,*value,*userData) ;Can add items to a list if wanted 
  PrintN(PeekS(*key,-1,#PB_UTF8) + " :frequency " + Str(*value))  
EndProcedure   

Procedure CBList(*key,*value,*userData) ;Can add items to a list if wanted 
  Static ct 
  PrintN(Str(ct) + " : " + PeekS(*key,-1,#PB_UTF8) + " :frequency " + Str(*value))  
  ct+1
EndProcedure 

OpenConsole()  

Global key.s,url.s,file.s,fn,size,*st,*chr.unicode 
Global len,ct,path.s,line.s

url.s = "https://archive.org/download/kjv-text-files/Genesis.txt"

path.s = GetUserDirectory(#PB_Directory_Downloads)  + GetFilePart(url)
If FileSize(path) < 0 
  ReceiveHTTPFile(url,path)
EndIf 

fn = OpenFile(#PB_Any,path) 
If fn 
  Repeat  
    line.s = ReadString(fn,#PB_UTF8)
    ct+1 
    *chr=@line 
    If line <> "" 
      *st=*chr 
      Repeat
        While (*chr\u > 0 And *chr\u <= 32)  
          *chr+2
          *st=*chr
        Wend  
        While ((*chr\u >= '0' And *chr\u <= '9') Or (*chr\u >= 'A' And *chr\u <= 'Z') Or (*chr\u >= 'a' And *chr\u <= 'z') Or *chr\u=39) ;'  
          len+1
          *chr+2
        Wend       
        If len 
          key = LCase(PeekS(*st,len))
          ct = sq\Get(0,@key) + 1     ;look up the word and increment its count    
          sq\Set(0,@key,ct)           ;set the word in the dictionary  
          len = 0 
          *st=*chr+2  
        EndIf   
        If *chr\u = 0 
          Break 
        EndIf 
        *chr+2
        *st=*chr
      Until *chr\u = 0    
    EndIf 
  Until Eof(fn) 
  
  sq\Walk(0,@CBList())            ;dumps the dictionary      
  PrintN("Search for ba") 
  
  Repeat 
    PrintN("enter a key to search for of type quit to end")   
    key = LCase(Input())    
    If key <> "quit" Or key <> "end" 
       sq\Enum(@key,@CBSearch())        ;search the dictionary 
    Else 
      Break 
    EndIf   
  ForEver   
    
EndIf 

sq\Free()

CloseConsole() 
