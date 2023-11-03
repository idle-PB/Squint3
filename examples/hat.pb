;Hat test windows only 
;hashes the key to 64 bits and sets it in numeric mode, key is retrivable in the array from the stored value    
;trie size is the total set which is the array + trie, map sise is the peak size 

XIncludeFile "../squint3.pbi"

UseModule SQUINT

EnableExplicit 


Global sq.isquint = SquintNew()

Global res,key.s,out.s,a,col,numkeys = 1<<18
Global ct,st,st1,et,et1,m1.s,m2.s,m3.s
Global Dim *arRand(numkeys) 
 

Procedure RandomRange(size,min,max) 
  Protected a,*mem,*out.Ascii  
  
  *mem = AllocateMemory(size) 
  *out = *mem 
  For a = 1 To size  
    *out\a = Random(max,min)    
    *out+1 
  Next   
  
  ProcedureReturn *mem 
  
EndProcedure 

Procedure.s PrintMemInfo() 
  Protected pid,hp, pmc.PROCESS_MEMORY_COUNTERS 
  Static pf,ps 
  
  Protected  out.s 
  pid = GetCurrentProcessId_();
  If pid 
  hp = OpenProcess_(#PROCESS_QUERY_INFORMATION | #PROCESS_VM_READ,0,pid) 
  If hp 
    
    GetProcessMemoryInfo_(hp,@pmc,SizeOf(PROCESS_MEMORY_COUNTERS)) 
    pf = (pmc\PageFaultCount - pf) 
    ps = (pmc\PeakWorkingSetSize - ps) 
    out = "page faults " + FormatNumber(pf,0,".",",") + #CRLF$ 
    out + "peak set " + FormatNumber(ps/1024/1024,2,".",",") + " mb" + #CRLF$ 
    out + "total set " + FormatNumber(pmc\PeakWorkingSetSize/1024/1024,2,".",",") + " mb" + #CRLF$ 
    CloseHandle_(hp) 
  EndIf   
EndIf 

ProcedureReturn out 

EndProcedure 

Global KeySize = 512

For a = 1 To numkeys 
  *arRand(a) = RandomRange(KeySize,'A','Z')          ;make a random range of keys 
Next 

m1 = PrintMemInfo() 
st = ElapsedMilliseconds()
For a = 1 To numkeys  
   SquintSetNumeric(sq,*arRand(a),*arRand(a),KeySize,1)   ;set the numeric key with bhash=1 
Next     
et = ElapsedMilliseconds() 
m2 = PrintMemInfo() 

st1 = ElapsedMilliseconds()  
Global NewMap mp(numkeys) 
For a = 1 To numkeys 
   mp(PeekS(*arRand(a),KeySize,#PB_Ascii)) = *arRand(a)
Next  
et1 = ElapsedMilliseconds()   
m3 =  PrintMemInfo() 

out + "Times to set " + Str(numkeys) + " Squint " + StrF(et-st) + "ms vs Map " + StrF(et1-st1) + " ms" + #CRLF$   

st =  ElapsedMilliseconds() 
For a = 1 To numkeys 
  res = squintGetNumeric(sq,*arRand(a),KeySize,1) | a 
Next    
et = ElapsedMilliseconds()  

st1 = ElapsedMilliseconds()  
For a = 1 To numkeys 
   res = mp(PeekS(*arRand(a),KeySize,#PB_Ascii)) | a 
Next  
et1 = ElapsedMilliseconds()   
out + "Times to get " + Str(numkeys) + " Squint " + StrF(et-st) + "ms vs Map " + StrF(et1-et) + " ms" + #CRLF$   
out + "key size " + FormatNumber((numkeys*KeySize)/1024/1024,2,".",",") + " mb " + "trie size " + FormatNumber(SquintSize(sq)/1024/1024,2,".",",") + " mb" + #CRLF$    
out + "base " + m1 + #CRLF$ 
out + "squint " + m2 + #CRLF$ 
out + "map " + m3  + #CRLF$ 

sq\Free()

SetClipboardText(out) 
MessageRequester("hat",out) 

