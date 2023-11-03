;squint binary mode examle 
;In binary mode your keys can be any thing that's serial upto the max key #SQUINT_MAX_KEY = 1024 
;for instance you could store strucutres like points and rect, or store long hashes        
;in this example it shows how you can mix stringkeys with binary keys  

XIncludeFile "../squint3.pbi"

UseModule SQUINT

EnableExplicit 

Global sq.isquint = SquintNew()
Global a,ikey,subtrieUC,subtrieLC, keysize = 16, numitems = 128 
Global Dim *arRandUC(numitems) 
Global Dim *arRandLC(numitems) 

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

Procedure cbEnum(*key.Ascii,*value,*udata)  
  Protected out.s 
  
  If *value 
    out.s = PeekS(*key,keysize,#PB_Ascii)  ;print the key 
    PrintN(out) 
  EndIf 
 
  ProcedureReturn  1 
  
EndProcedure   

Procedure cbWalk(*key.Ascii,*value,*udata) 
  
  PrintN(PeekS(*key,-1,#PB_Ascii))  ;prints key with is subtrie key 
    
  ProcedureReturn  1 
  
EndProcedure   

RandomSeed(1234)

OpenConsole()

subtrieUC = SquintSetNode(sq,0,@"BinaryKeysUC:",1)                    ;Create a subtrie "BinaryKeysUC:" we will store Uppercase range of keys in        
subtrieLC = SquintSetNode(sq,0,@"BinaryKeysLC:",1)                    ;Create a subtrie "BinaryKeysLC:" we will store Lowercase range of keys in  

For a = 1 To numitems  
  *arRandUC(a) = RandomRange(keysize,'A','Z')                          ;makes an array of random keys in range      
  SquintSetBinary(sq,subtrieUC,*arRandUC(a),*arRandUC(a),keysize)      ;set the binary key under the subtrie "BinaryKeysUC:" and it's value to *memery pointer
Next     

For a = 1 To numitems  
  *arRandLC(a) = RandomRange(keysize,'a','z')                          ;makes an array of random keys in range      
  SquintSetBinary(sq,subtrieLC,*arRandLC(a),*arRandLC(a),keysize)      ;set the binary key under the subtrie "BinaryKeysLC:" and it's value to *memery pointer
Next 

For a = 1 To numitems 
  If SquintGetBinary(sq,subtrieUC,*arRandUC(a),keysize) <> *arRandUC(a)  ;look up the key check to see the value matches the *memery pointer at the index a  
    MessageRequester("error","key not equal") 
    sq\Free()
    End
  EndIf 
  FreeMemory(*arRandUC(a))   
Next    

For a = 1 To numitems 
  If SquintGetBinary(sq,subtrieLC,*arRandLC(a),keysize) <> *arRandLC(a) ;look up the key check to see the value matches the *memery pointer at the index a  
    MessageRequester("error","key not equal") 
    sq\Free()
    End
  EndIf 
  FreeMemory(*arRandLC(a))
Next    

sq\WalkBinary(0,@cbWalk())  ;dumps the whole trie in sorted order subtrie "BinaryKeysLC:" comes before "BinaryKeysUC:"  
 
PrintN("Enum from B ++++++++++++") 

ikey =  'B' 
sq\EnumBinary(subtrieUC,@ikey,1,@cbEnum())  ;list the trie from 'B' under the subtrie "BinaryKeysUC:B" 

PrintN("Repeat Enum after delete ") 

sq\DeleteBinary(subtrieUC,@ikey,1,1)       ;Prune the trie from 'B' under the subTrie "BinaryKeysUC:B"     

sq\EnumBinary(subtrieUC,@ikey,1,@cbEnum()) ;list the trie from 'B' under the subtrie "BinaryKeysUC:B" 

Input()  
CloseConsole() 
sq\Free()
