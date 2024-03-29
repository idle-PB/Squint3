﻿
Macro Comments() 
  ; SQUINT 3, Sparse Quad Union Indexed Nibble Trie
  ; Copyright Andrew Ferguson aka Idle (c) 2020 - 2023 
  ; Version 3.2.1
  ; PB 5.72-6.02b 32bit/64bit asm and c backends for Windows,Mac OSX,Linux,PI,M1
  ; Thanks Wilbert for the high low insight and utf8 conversion help.
  ; Squint is a compact prefix Trie indexed by nibbles into a sparse array with performance metrics close to a map
  ; It provides O(K) performance with a memory size ~32 times smaller than a 256 node trie
  ; Squint is at worst 2 times slower than a Map for set operations, look ups are closer to 1:1 or faster   
  ; as squint can bail out as soon as a char of a key isn't found unlike a map that has to evaluate the whole key. 
  ; Squint is lexographicaly sorted so sorting is magnitudes faster than what you could achieve with a map list or unsorted array 
  ; Squint also supports collections or subtries, which facilitates tasks like in memory DB's  
  ; The Numeric mode of squint behaves like a map and is closer to 1:1 perfromace with a sized map 
  ; 
  ; see https://en.wikipedia.org/wiki/Trie 
  ;     simillar structures   
  ;     https://dotat.at/prog/qp/blog-2015-10-04.html
  ;     https://cr.yp.to/critbit.html 
  ;
  ; Squint supports Set, Get, Enum, EnumNode , Walk, WalkNode, Delete and Prune with flag  
  ; String keys can be Unicode, Ascii or UTF8 the type must be specified 
  ; all string keys get mapped to UTF8 
  ; 
  ; SquintBinary functions SetBinary GetBinary EnumBinary WalkBinary, Delete and Prune with flag
  ;   
  ; SquintNumeric supports, SetNumeric GetNumeric DeleteNumeric and WalkNumeric 
  ; it's provided as a direct subtitute for a numeric map, keys are integers but can be either 4 or 8 bytes on x64 
  ; longer keys can be used with the optional hash, so it behaves like a HAT      
  ;
  ; Note you can mix string, numeric and binary keys in the same trie. 
  ; 
  ; MIT License
  ; Permission is hereby granted, Free of charge, to any person obtaining a copy
  ; of this software and associated documentation files (the "Software"), to deal
  ; in the Software without restriction, including without limitation the rights
  ; To use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  ; copies of the Software, and to permit persons to whom the Software is
  ; furnished to do so, subject to the following conditions:
  ; 
  ; The above copyright notice and this permission notice shall be included in all
  ; copies or substantial portions of the Software.
  ; 
  ; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS Or
  ; IMPLIED, INCLUDING BUT Not LIMITED To THE WARRANTIES OF MERCHANTABILITY,
  ; FITNESS For A PARTICULAR PURPOSE And NONINFRINGEMENT. IN NO EVENT SHALL THE
  ; AUTHORS Or COPYRIGHT HOLDERS BE LIABLE For ANY CLAIM, DAMAGES Or OTHER
  ; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT Or OTHERWISE, ARISING FROM,
  ; OUT OF Or IN CONNECTION With THE SOFTWARE Or THE USE Or OTHER DEALINGS IN THE
  ; SOFTWARE. 
  ;
  ; mzHash64 https://github.com/matteo65/mzHash64 
  ;
EndMacro 

DeclareModule SQUINT 
  
  #SQUINT_MAX_KEY = 1024
  
  Structure squint_node Align #PB_Structure_AlignC
    *vertex.edge
    StructureUnion
      squint.q
      value.i 
    EndStructureUnion 
  EndStructure   
  
  Structure edge   Align #PB_Structure_AlignC
    e.squint_node[0]
  EndStructure 
  
  Structure squint Align #PB_Structure_AlignC
    *vt
    size.i
    count.i
    gEnum.i
    write.i
    *root.squint_node
    sb.a[#SQUINT_MAX_KEY]
  EndStructure
  
  CompilerIf SizeOf(Integer) = 4  
    #Squint_Pmask = $ffffffff
    #Squint_Integer = 4 
  CompilerElse
    #Squint_Pmask = $ffffffffffff
    #Squint_Integer = 8 
  CompilerEndIf
  
  ;-Squint Callback prototype 
  Prototype Squint_CB(*key,*value=0,*userdata=0)
  Prototype Squint_CBFree(*mem) 
  
  Declare SquintNew()
  Declare SquintFree(*this.Squint,*pfn.Squint_CBFree=0)
  
  Declare SquintSetNode(*this.squint,*subtrie,*key,value.i,mode=#PB_Unicode)
  Declare SquintGetNode(*this.squint,*subtrie,*key,mode=#PB_Unicode,bval=1)
  Declare SquintDeleteNode(*this.squint,*subtrie,*key,prune=0,mode=#PB_Unicode)
  Declare SquintWalkNode(*this.squint,*subtrie,*pfn.squint_CB,*userdata=0) 
  Declare SquintEnum(*this.squint,*key,*pfn.squint_CB,*userdata=0,mode=#PB_Unicode)
  Declare SquintEnumNode(*this.squint,*subtrie,*key,*pfn.squint_CB,*userdata=0,mode=#PB_Unicode)
  
  Declare SquintSetNumeric(*this.squint,key.i,value.i,size=#Squint_Integer,bhash=0)
  Declare SquintGetNumeric(*this.squint,key.i,size = #Squint_Integer,bhash=0)
  Declare SquintDeleteNumeric(*this.squint,*key,size = #Squint_Integer,bhash=0)
  Declare SquintWalkNumeric(*this.squint,*pfn.squint_CB,size=#Squint_Integer,*userdata=0)  
  
  Declare SquintSetBinary(*this.squint,*subtrie,*key,value.i,size)
  Declare SquintGetBinary(*this.squint,*subtrie,*key,size)
  Declare SquintDeleteBinary(*this.squint,*subtrie,*key,size,prune=0)
  Declare SquintEnumBinary(*this.squint,*subtrie,*key,size,*pfn.squint_CB,*userdata=0)
  Declare SquintWalkBinary(*this.squint,*subtrie,*pfn.squint_CB,*userdata=0)  
  
  Declare SquintSize(*this.squint)
  Declare SquintNumKeys(*this.squint)
  
  ;-Squint Inteface iSquint  
  Interface iSquint
    Free(*pfn.Squint_CBFree=0)
    Delete(*subtrie,*key,prune=0,mode=#PB_Unicode)
    Set(*subtrie,*key,value.i,mode=#PB_Unicode)
    Get(*subtrie,*key,mode=#PB_Unicode,bval=1)
    Enum(*key,*pfn.squint_CB,*userdata=0,mode=#PB_Unicode)
    EnumNode(*subtrie,*key,*pfn.squint_CB,*userdata=0,mode=#PB_Unicode)
    Walk(*subtrie,*pfn.squint_CB,*userdata=0)
    SetNumeric(key.i,value.i,size=#Squint_Integer,bhash=0) 
    GetNumeric(key.i,size= #Squint_Integer,bhash=0) 
    DeleteNumeric(*key,size=#Squint_Integer,bhash=0)
    WalkNumeric(*pfn.Squint_CB,size=#Squint_Integer,*userdata=0)
    SetBinary(*subtrie,*key,value.i,size) 
    GetBinary(*subtrie,*key,size) 
    DeleteBinary(*subtrie,*key,size,prune=0) 
    EnumBinary(*subtrie,*key,size,*pfn.squint_CB,*userdata=0)
    WalkBinary(*subtrie,*pfn.squint_CB,*userdata=0) 
    Size()
    NumKeys()
  EndInterface
  
  DataSection: vtSquint:
    Data.i @SquintFree()
    Data.i @SquintDeleteNode() 
    Data.i @SquintSetNode()
    Data.i @SquintGetNode()
    Data.i @SquintEnum()
    Data.i @SquintEnumNode() 
    Data.i @SquintWalkNode()
    Data.i @SquintSetNumeric()
    Data.i @SquintGetNumeric()
    Data.i @SquintDeleteNumeric()
    Data.i @SquintWalkNumeric() 
    Data.i @SquintSetBinary() 
    Data.i @SquintGetBinary() 
    Data.i @SquintDeleteBinary() 
    Data.i @SquintEnumBinary()
    Data.i @SquintWalkBinary()
    Data.i @SquintSize() 
    Data.i @SquintNumKeys()
  EndDataSection   
  
EndDeclareModule

Module SQUINT
  
  EnableExplicit
  
  ;-macros 
  Macro _SETINDEX(in,index,number)
    in = in & ~(15 << (index << 2)) | (number << (index << 2))
  EndMacro
  
  Macro _GETNODECOUNT()
    CompilerIf SizeOf(integer) = 4 
      nodecount = MemorySize(*node\vertex) / SizeOf(squint_node)
    CompilerElse
      nodecount = (*node\vertex >> 48)
    CompilerEndIf
  EndMacro
  
  Macro _POKENHL(in,Index,Number)
    *Mem.Ascii = in
    *Mem + Index >> 1
    If Index & 1
      *Mem\a = (*Mem\a & $f0) | (Number & $f)
    Else
      *Mem\a = (*Mem\a & $0f) | (Number << 4)
    EndIf
  EndMacro
  
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x86 
    Macro rax : eax : EndMacro 
  CompilerEndIf   
  
  CompilerIf #PB_Compiler_Thread 
    Macro _LockMutex(mut) 
      LockMutex(mut) 
    EndMacro 
    Macro _UnlockMutex(mut)
      UnlockMutex(mut)
    EndMacro   
  CompilerElse 
    Macro _Lockmutex(mut) 
    EndMacro 
    Macro _UnlockMutex(mut)
    EndMacro   
  CompilerEndIf   
  
  Macro _gLockXCHG(var,var1) 
    CompilerIf #PB_Compiler_Backend = #PB_Backend_C 
      !__atomic_exchange_n(&p_node->f_vertex,p_new,__ATOMIC_SEQ_CST) ; 
    CompilerElse 
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
        !mov eax , [p.p_#var1]
        !mov edx , [p.p_#var]
        !xchg dword [edx] , eax
      CompilerElse 
        !mov rax , [p.p_#var1]
        !mov rdx , [p.p_#var] 
        !xchg qword [rdx] , rax
      CompilerEndIf 
    CompilerEndIf 
  EndMacro
  
  Global gEnumlock.i  
  
  Macro _gEnumlock(x)
    CompilerIf #PB_Compiler_Backend = #PB_Backend_C 
      !__atomic_exchange_n(&squintXg_genumlock,x,__ATOMIC_SEQ_CST) ; 
    CompilerElse  
      !mov rdx, x  
      !xchg qword [squint.v_gEnumlock] , rdx
    CompilerEndIf 
  EndMacro 
  
  Macro _sfence
    CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm  
      !sfence 
    CompilerElse 
      CompilerIf #PB_Compiler_Processor = #PB_Processor_Arm32 Or #PB_Compiler_Processor = #PB_Processor_Arm64
        !__sync_synchronize();
      CompilerElse   
        !__asm__("sfence" ::: "memory");   
      CompilerEndIf   
    CompilerEndIf   
  EndMacro 
  
  Macro _lfence 
    CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm   
      ;!lfence
    CompilerElse
      CompilerIf #PB_Compiler_Processor = #PB_Processor_Arm32 Or #PB_Compiler_Processor = #PB_Processor_Arm64 
        !__sync_synchronize();
      CompilerElse  
        !__asm__("lfence" ::: "memory"); 
      CompilerEndIf   
    CompilerEndIf    
  EndMacro 
  
  Macro _CONVERTUTF8() 
    
    vchar = PeekU(*key)
    
    If mode = #PB_Unicode  
      CompilerIf #PB_Compiler_Backend = #PB_Backend_C  
        If vchar > $7f
          If vchar > $7ff
            vchar = $8080E0 | (vchar >> 12) | ((vchar << 2) & $3F00) | ((vchar << 16) & $3F0000)
          Else
            vchar = $80C0 | (vchar >> 6) | ((vchar << 8) & $3F00)
          EndIf
        EndIf   
      CompilerElse  
        
        !mov	eax, [p.v_vchar] 
        !cmp eax, 0x80 
        !jb .l2 
        !cmp	eax, 0x0800
        !jae .l1
        !mov edx, eax 
        !sal	edx, 8
        !and	edx, 0x3f00 
        !sar	eax, 6
        !or	edx, eax
        !or  edx, 0x80C0 
        !mov eax,edx
        !jmp	.l2
        !.l1:
        !mov edx, eax 
        !sal	edx, 16
        !and	edx, 0x3f0000
        !mov ecx, eax 
        !sal ecx, 2 
        !and ecx, 0x3f00
        !or  edx,ecx 
        !sar eax, 12 
        !or  edx, eax 
        !or  edx, 0x8080e0 
        !mov eax,edx 
        !.l2:
        !mov	[p.v_vchar], eax  
        
      CompilerEndIf    
      
    EndIf  
    
  EndMacro 
  
  Macro _MODECHECK()
    _CONVERTUTF8()
    If mode <> #PB_Unicode
      If (vchar >> ((count&1)<<4) & $ff = 0)
        Break
      EndIf 
    EndIf
  EndMacro 
  
  Global gwrite = CreateMutex() 
  Global NewList lpointers.i() 
  
  Macro _SETNODE()
    
    If *node\vertex
      
      _GETNODECOUNT()
      If (offset <> 15 Or nodecount = 16)
        
        *this\write = *node  ;<----------------------------------Set before update
        _sfence 
        *node = *node\Vertex\e[offset] & #Squint_Pmask
      Else  
        
        offset = nodecount
        nodecount+1 
        *new = AllocateMemory((nodecount)*SizeOf(squint_node)) 
        *old = *node\vertex & #Squint_Pmask
        CopyMemory(*old,*new,(offset)*SizeOf(squint_node)) 
        
        CompilerIf #PB_Compiler_64Bit; 
          *new | ((nodecount) << 48)
        CompilerEndIf  
        
        _gLockXCHG(node,new) 
        
        _SETINDEX(*node\squint,idx,offset)
        
        *this\write = *node     ;<----------------------------------Set before update
        _sfence 
        *node = *node\Vertex\e[offset] & #Squint_Pmask
        
        FreeMemory(*old) 
        
        *this\size+SizeOf(squint_node) 
        
      EndIf 
      
    Else
      
      *node\vertex = AllocateMemory(SizeOf(squint_Node))
      
      *this\size+SizeOf(squint_node) 
      CompilerIf #PB_Compiler_64Bit; 
        *node\vertex | (1 << 48)
      CompilerEndIf
      *node\squint = -1
      _SETINDEX(*node\squint,idx,0)
      
      *this\write = *node ;<----------------------------------Set before update
      _sfence 
      *node = *node\Vertex\e[0] & #Squint_Pmask
      
    EndIf 
    
    
  EndMacro
  
  ;-General functions 
  
  ;##################################################################################
  ;# Create a new Squint Trie 
  ;#  
  ;# example    
  ;#   global sq.iSquint = SquintNew() use via an interface with isquint           
  ;#   or 
  ;#   global sq = SquintNew() or normal use      
  ;################################################################################## 
  
  Procedure SquintNew()
    
    Protected *this.squint,a
    *this = AllocateMemory(SizeOf(squint))
    If *this
      *this\vt = ?vtSquint
      *this\root = AllocateMemory(SizeOf(squint_node)*16)
      ProcedureReturn *this
    EndIf
  EndProcedure
  
  Procedure ISquintFree(*this.squint,*node.squint_node=0,*pfn.Squint_CBFree=0)
    Protected a,offset,nodecount
    If Not *node
      ProcedureReturn 0
    EndIf
    For a=0 To 15
      offset = (*node\squint >> (a<<2)) & $f
      If *node\vertex
        _GETNODECOUNT()
        If (offset <> 15 Or nodecount = 16)
          *this\size - SizeOf(squint_node)
          ISquintFree(*this,*node\Vertex\e[offset] & #Squint_Pmask)
        EndIf
      EndIf
    Next
    _LockMutex(gwrite)
    If *node\vertex
      _GETNODECOUNT()
      If *pfn 
        If *node <> *this\root 
          *pfn(*node\value)
        EndIf   
      EndIf 
      FreeMemory(*node\Vertex & #Squint_Pmask) 
      *node\vertex=0
    EndIf
    _UnlockMutex(gwrite) 
    ProcedureReturn *node
  EndProcedure
  
  ;##################################################################################
  ;# Free Squint Trie 
  ;# If you need to free your own pointers, Walk the trie 1st to free them  
  ;# then call sq\free() or SquintFree(sq)   
  ;################################################################################## 
  
  Procedure SquintFree(*this.squint,*pfn.Squint_CBFree=0)  
    
    Protected a,offset,*node.squint_node,nodecount
    *node = *this\root
    For a=0 To 15
      offset = (*node\squint >> (a<<2)) & $f
      If *node\vertex
        _GETNODECOUNT()
        If (offset <> 15 Or nodecount = 16)
          ISquintFree(*this,*node,*pfn)
        EndIf
      EndIf
    Next
    FreeMemory(*this\root)
    nodecount = *this\size 
    FreeMemory(*this) 
    ProcedureReturn  nodecount  
  EndProcedure
  ;-string functions 
  
  ;#################################################################################
  ;#    Set a node from the root or from a previously set node   
  ;#    *this.squint instance from SquintNew() 
  ;#    *subtrie 0 Or the addess of a previously stored node retuned from this function 
  ;#   
  ;#    *key   address of a null terminated string can be unicode ascii or UTF8
  ;#    value.i  non zero value or address of something  
  ;#    mode.i  Desired key format #PB_Uniocde, #PB_Ascii, #PB_UTF8  
  ;#    returns *subtrie the node       
  ;# example     
  ;#    *cars = SquintSetNode(sq,0,@"cars:",100)          the key = "cars:"        
  ;#     *toyota = squintSetNode(sq,*cars,@"Toyota:",200) the key = "cars:toyota" 
  ;#     squintSetNode(sq,*toyota,@"Corolla",201)         the key = "cars:toyota:corolla" 
  ;#     squintSetNode(sq,*toyota,@"Cameray",202)         the key = "cars:toyota:Cameray"
  ;# via interface  
  ;#     sq\set(*toyota,@"Cameray",202)                   the key = "cars:toyota:Cameray"   
  ;################################################################################## 
  
  Procedure SquintSetNode(*this.squint,*subtrie,*key,value.i,mode=#PB_Unicode)
    
    Protected *node.squint_node,idx,offset,nodecount,vchar.l,vret.l,count,*out
    Protected *new.squint_node,*old,*adr 
    
    If *subtrie = 0
      *node = *this\root & #Squint_Pmask
    Else 
      *node = *subtrie & #Squint_Pmask
    EndIf 
    _CONVERTUTF8()
    
    _LockMutex(gwrite)
    
    While vchar
      *this\write = *node   ;<----------------------------------Set the write flag with current node    
      _sfence 
      idx = (vchar >> 4) & $f
      offset = (*node\squint >> (idx<<2)) & $f
      _SETNODE()     
      idx = vchar & $0f
      offset = (*node\squint >> (idx<<2)) & $f
      _SETNODE()    
      vchar >> 8
      count+1
      If vchar = 0
        *key+2
        _MODECHECK()
      EndIf
    Wend
    idx=0
    *out = *node 
    offset = *node\squint & $f
    _SETNODE()
    
    *this\write = 0    ;<----------------------------------Clear the write flag     
    
    *this\count+1 
    
    _unLockMutex(gwrite)
    
    If value 
      *node\value = value
    EndIf 
    
    ProcedureReturn *out
    
  EndProcedure
  
  
  ;##################################################################################
  ;#    Get a node from the root or from a previously stored node aka subtrie    
  ;#    *this.squint instance from SquintNew() 
  ;#    *subtrie 0 Or the addess of a previously stored node retuned from this function 
  ;#   *key   address of a null terminated string can be unicode ascii or UTF8
  ;#    mode.i  Desired key format #PB_Uniocde, #PB_Ascii, #PB_UTF8  
  ;#    
  ;#  returns the value or subnode        
  ;#  example    
  ;#     x = squintGetNode(sq,0,@"cars:toyota:")   subtrie = root, the key = "cars:toyota"  
  ;#     x = squintGetNode(sq,*toyota,@"Corolla")  subtrie = *toyota the key evaluates to = "cars:toyota:corolla"   
  ;#     or via interface 
  ;#     x = sq\get(0,@"cars:toyota:")  subtrie = root, the key = "cars:toyota"    
  ;################################################################################## 
  
  Procedure SquintGetNode(*this.squint,*subtrie,*key,mode=#PB_Unicode,bval=1)
    
    Protected *node.squint_Node,idx,offset,nodecount,vchar.l,vret.l,count,*out
    
    If *subtrie = 0
      *node = *this\root & #Squint_Pmask
    Else 
      *node = *subtrie & #Squint_Pmask
    EndIf 
    _CONVERTUTF8()
    
    If *node\vertex
      
      While vchar
        
        If *this\write <> *node   ;dont step on same write node
          _lfence 
          offset = (*node\squint >> ((vchar & $f0) >> 2 )) & $f
          _GETNODECOUNT()
          If offset < nodecount
            *node = (*node\Vertex\e[offset] & #Squint_Pmask)
          Else
            ProcedureReturn 0
          EndIf
        Else 
          Continue 
        EndIf  
        
        If *this\write <> *node  ;dont step on same write node
          _lfence 
          offset = (*node\squint >> ((vchar & $0f) << 2)) & $f
          _GETNODECOUNT()
          If offset < nodecount
            *node = (*node\Vertex\e[offset] & #Squint_Pmask)
          Else
            ProcedureReturn 0
          EndIf
        Else 
          Continue 
        EndIf 
        
        vchar >> 8
        count+1
        If vchar = 0
          *key+2
          _MODECHECK()
        EndIf
        
      Wend
      
      *out = *node 
      offset = *node\squint & $f
      _GETNODECOUNT()
      
      If offset <= nodecount
        *node = (*node\Vertex\e[offset] & #Squint_Pmask)
        If bval 
          ProcedureReturn *node\value
        Else 
          ProcedureReturn *out  
        EndIf   
      Else
        ProcedureReturn 0
      EndIf
      
    EndIf 
    
  EndProcedure 
  
  ;##################################################################################
  ;#    Resets a keys value to 0 or deletes the childen of the node freeing up memory     
  ;#    *this.squint instance from SquintNew() 
  ;#    *subtrie 0 Or the addess of a previously stored node retuned from this function 
  ;#    *key     address of a null terminated string can be unicode ascii or UTF8
  ;#    mode.i   Desired key format 
  ;#    returns  the value or 0
  ;#    example  
  ;#    x = SquintDeleteNode(sq,*cars,@"Toyota:",1)  subnode = *cars, the key evals to "cars:toyota" prune =1 So it deletes the child nodes corrola And camery  
  ;#    x = SquintDeleteNode(sq,0,@"cars:toyota:corolla") subtrie = root, the full key = "cars:toyota:corolla" prune=0 so it set the value to 0  
  ;#    via inteface  
  ;#    sq\delete(0,@"cars:toyota:corolla")     
  ;################################################################################## 
  
  Procedure SquintDeleteNode(*this.squint,*subtrie,*key.Unicode,prune=0,mode=#PB_Unicode)
    
    Protected *node.squint_node,idx,*mem.Character,offset,nodecount,vchar.l,vret.l,count,*out
    If *subtrie = 0
      *node = *this\root & #Squint_Pmask
    Else
      *node = *subtrie  & #Squint_Pmask 
    EndIf 
    _CONVERTUTF8()
    While vchar
      offset = (*node\squint >> ((vchar & $f0) >> 2 )) & $f
      If *node\vertex
        _GETNODECOUNT()
        If (offset <> 15 Or nodecount = 16)
          *node = *node\Vertex\e[offset] & #Squint_Pmask
        EndIf
      Else
        ProcedureReturn 0
      EndIf
      If *node
        offset = (*node\squint >> ((vchar & $0f) << 2)) & $f
        If *node\vertex
          _GETNODECOUNT()
          If (offset <> 15 Or nodecount = 16)
            *node = *node\Vertex\e[offset] & #Squint_Pmask
          EndIf
        Else
          ProcedureReturn 0
        EndIf
      EndIf
      vchar >> 8
      If vchar = 0
        *key+2
        _MODECHECK()
      EndIf
    Wend
    If prune
      ISquintFree(*this,*node)
      If (*node\vertex & #Squint_Pmask) = 0
        *node\squint = 0
      EndIf
    Else
      offset = *node\squint & $f
      _GETNODECOUNT()
      If offset <= nodecount
        *node = (*node\Vertex\e[offset] & #Squint_Pmask)
        If (*node\vertex & #Squint_Pmask) = 0
          *node\squint = 0
        EndIf
      Else
        ProcedureReturn 0
      EndIf
    EndIf
  EndProcedure
  
  Procedure IEnum(*this.squint,*node.squint_Node,depth,*pfn.squint_CB,*outkey,*userdata=0)
    Protected a.i,offset,nodecount,*mem.Ascii 
    
    If Not *node
      ProcedureReturn 0
    EndIf
    
    For a =0 To 15
      
      offset = (*node\squint >> (a<<2)) & $f
      If (*node\vertex And *node\squint)
        _GETNODECOUNT()
        If (offset <> 15 Or nodecount = 16)
          _POKENHL(*outkey,depth,a)
          If IEnum(*this,*node\Vertex\e[offset] & #Squint_Pmask,depth+1,*pfn,*outkey,*userdata) = 0 
            Break 
          EndIf  
        EndIf
        
      EndIf
    Next
    
    If *node\vertex=0
      If *pfn
        PokeA(*outkey+((depth>>1)),0)
        If *pfn(*outkey,*node\value,*userdata) = 0 
          ProcedureReturn 0
        EndIf   
      EndIf
    EndIf
    ProcedureReturn *node
    
  EndProcedure
  
  ;##################################################################################
  ;#  Enumerates the Trie from a given key   
  ;#    *this.squint instance from SquintNew() 
  ;#    *subtrie 0 Or the addess of a previously stored node       
  ;#    *key address of a null terminated string can be unicode ascii Or UTF8
  ;#     mode.i  Desired key format #PB_Uniocde, #PB_Ascii, #PB_UTF8  
  ;#    *pfn.squint_CB address of callback function as Squint_CB(*key,*value=0,*userdata=0) 
  ;#        where *key is pointer to the key *value is pointer to the *value, *userDate      
  ;# example    
  ;#     squintEnum(sq,*subtrie,@"cars:toyota:",@MyCallback())       
  ;#  or via interface 
  ;#     sq\Enum@"cars:toyota:",@MyCallback())   
  ;################################################################################## 
  
  Procedure SquintEnumNode(*this.squint,*subtrie,*key,*pfn.squint_CB,*userdata=0,mode=#PB_Unicode)  
    
    Protected *node.squint_Node,idx,*mem.Ascii,offset,nodecount,depth,vchar.l,vret.l,count,*out
    Protected outkey.s{1024} 
    
    _LockMutex(gwrite) 
    
    If *subtrie = 0
      *node = *this\root
    Else
      *node = *subtrie  & #Squint_Pmask 
    EndIf 
    
    _CONVERTUTF8()
    
    While vchar 
      
      offset = (*node\squint >> ((vchar & $f0) >> 2 )) & $f
      _GETNODECOUNT()
      If offset < nodecount
        *mem = @outkey+(depth>>1) 
        *mem\a = (*mem\a & $0f) | (((vchar >> 4) & $f)<<4)
        depth+1
        *node = (*node\Vertex\e[offset] & #Squint_Pmask)
      Else
        _UnlockMutex(gwrite) 
        ProcedureReturn 0
      EndIf
      
      offset = (*node\squint >> ((vchar & $0f) << 2)) & $f
      _GETNODECOUNT()
      If offset < nodecount
        *mem = @outkey+(depth>>1) 
        *Mem\a = ((*Mem\a & $f0) | (vchar & $f))
        depth+1
        *node = (*node\Vertex\e[offset] & #Squint_Pmask)
      Else
        _UnlockMutex(gwrite) 
        ProcedureReturn 0
      EndIf
      
      vchar >> 8
      count+1
      If vchar = 0
        *key+2
        _MODECHECK()
      EndIf
    Wend
    
    IEnum(*this,*node,depth,*pfn,@outkey,*userdata)
    
    _UnlockMutex(gwrite) 
    
  EndProcedure
  
  ;##################################################################################
  ;#  Enumerates the Trie from a given key   
  ;#    *this.squint instance from SquintNew() 
  ;#    *key   address of a null terminated string can be unicode ascii or UTF8
  ;#     mode.i  Desired key format #PB_Uniocde, #PB_Ascii, #PB_UTF8  
  ;#    *pfn.squint_CB address of callback function as Squint_CB(*key,*value=0,*userdata=0) 
  ;#        where *key is pointer to the key *value is pointer to the *value, *userDate      
  ;# example    
  ;#     squintEnum(sq,@"cars:toyota:",@MyCallback())       
  ;#  or via interface 
  ;#     sq\Enum@"cars:toyota:",@MyCallback())   
  ;################################################################################## 
  
  Procedure SquintEnum(*this.squint,*key,*pfn.squint_CB,*userdata=0,mode=#PB_Unicode)
    
    SquintEnumNode(*this,0,*key,*pfn,*userdata,mode) 
    
  EndProcedure   
  
  ;##################################################################################
  ;# Walks the entire trie    
  ;#    *this.squint instance from SquintNew() 
  ;#    *pfn.squint_CB address of callback function as Squint_CB(*key,*value=0,*userdata=0) 
  ;#       where *key is pointer to the key *value is pointer to the *value, *userDate      
  ;# example    
  ;#     squintWalk(sq,@MyCallback())       
  ;#  or via interface 
  ;#     sq\Walk(@MyCallback())   
  ;################################################################################## 
  
  Procedure SquintWalk(*this.squint,*pfn.squint_CB,*userdata=0) 
    
    Protected outkey.s{#SQUINT_MAX_KEY} 
    
    _LockMutex(gwrite) 
    
    IEnum(*this,*this\root,0,*pfn,@outkey,*userdata)
    
    _unLockMutex(gwrite)
    
  EndProcedure
  
  ;##################################################################################
  ;# Walks from a subtrie    
  ;#    *this.squint instance from SquintNew() 
  ;#    *subtrie 0 Or the addess of a previously stored node  
  ;#    *pfn.squint_CB address of callback function As Squint_CB(*key,*value=0,*userdata=0) 
  ;#          
  ;# example    
  ;#     squintWalkNode(sq,*cars,@MyCallback())       
  ;#  or via interface 
  ;#     sq\Walk(*cars,@MyCallback())   
  ;################################################################################## 
  
  Procedure SquintWalkNode(*this.squint,*subtrie,*pfn.squint_CB,*userdata=0)   
    
    Protected *node, outkey.s{#SQUINT_MAX_KEY}    
    
    _LockMutex(gwrite) 
    
    If *subtrie = 0
      *node = *this\root
    Else
      *node = *subtrie  & #Squint_Pmask 
    EndIf 
    IEnum(*this,*node,0,*pfn,@outkey,*userdata)
    
    _unLockMutex(gwrite)
    
  EndProcedure
  
  ;-Binaryfunctions operate the same as the string functions with no utf8 conversion   
  
  ;#################################################################################
  ;#    Set a node from the root Or from a previously set node   
  ;#    *this.squint    instance from SquintNew() 
  ;#    *subtrie        0 or the addess of a previously stored node retuned from a Set function 
  ;#    *key            address of a the memory 
  ;#    value.i         non zero value or address of something  
  ;#    size.i          size of the key in bytes    
  ;#  example     
  ;#     pt.point  
  ;#     pt\x = 100 
  ;#     pt\y = 200   
  ;#     SquintSetBinary(sq,@pt,1,SizeOf(point))       
  ;#  via interface  
  ;#     sq\setBinary(@pt,123435,SizeOf(point)))    
  ;################################################################################## 
     
  Procedure SquintSetBinary(*this.squint,*subtrie,*key,value.i,size)
    
    Protected *node.squint_node,idx,offset,nodecount,vchar.i,vret.i,count
    Protected *old,*new,*adr,*akey.Ascii 
    
    If *subtrie = 0
      *node = *this\root & #Squint_Pmask
    Else
      *node = *subtrie  & #Squint_Pmask 
    EndIf 
            
    _LockMutex(gwrite) 
    
    *akey = *key 
    
    While count <= size  
      *this\write = *node  
      _sfence 
      idx = (*akey\a >> 4) & $f
      offset = (*node\squint >> (idx<<2)) & $f
      _SetNODE()
      idx = (*akey\a & $f)
      offset = (*node\squint >> (idx<<2)) & $f
      _SetNODE()
      *akey+1 
      count+1
    Wend
       
    _UnlockMutex(gwrite) 
    *this\write = 0    
    
    *node\value = value
    
    ProcedureReturn *node 
    
    
  EndProcedure
  
  ;##################################################################################
  ;#    Get a node from the root or from a previously stored node    
  ;#    *this.squint    instance from SquintNew() 
  ;#    *subtrie        0 Or the addess of a previously stored node retuned from this function 
  ;#    size            number of bytes used for the key      
  ;#  returns the value         
  ;#  example  
  ;#     pt.point  
  ;#     pt\x = 100 
  ;#     pt\y = 200   
  ;#     x = squintGetBinary(sq,0,@pt,sizeof(point))   
  ;#     or via interface 
  ;#     x = sq\getBinary(0,@pt,sizeof(point))        
  ;################################################################################## 
  
  Procedure SquintGetBinary(*this.squint,*subtrie,*key,size)
    
    Protected *node.squint_Node,idx,offset,nodecount,vchar.i,vret.i,count,*akey.Ascii,st  
    
    If *subtrie = 0
      *node = *this\root & #Squint_Pmask
    Else
      *node = *subtrie  & #Squint_Pmask 
    EndIf 
        
    *akey=*key 
         
    While count <= size  
      
      If *this\write <> *node   ;test to see if same as write node
        _lfence 
        offset = (*node\squint >> ((*akey\a & $f0) >> 2 )) & $f
        _GETNODECOUNT()
        If offset < nodecount
          *node = (*node\Vertex\e[offset] & #Squint_Pmask)
        Else
          ProcedureReturn 0
        EndIf
      Else 
        Continue 
      EndIf  
      
      If *this\write <> *node   ;test to see if same as write node
        _lfence 
        offset = (*node\squint >> ((*akey\a & $0f) << 2)) & $f
        _GETNODECOUNT()
        If offset < nodecount
          *node = (*node\Vertex\e[offset] & #Squint_Pmask)
        Else
          ProcedureReturn 0
        EndIf
      Else 
        Continue 
      EndIf  
      *akey+1
      count+1
    Wend
    
    ProcedureReturn *node\value
  EndProcedure
  
  ;##################################################################################
  ;#  Resets a keys value to 0 or Deletes and Prunes all child nodes freeing up memory     
  ;#      *this.squint   instance from SquintNew() 
  ;#      *subtrie       0 Or the addess of a previously stored node retuned from this function 
  ;#      *key           address of a variable or memory pointer 
  ;#      size           number of bytes used to store the key    
  ;#      prune          0 to reset value or 1 to delete and prune    
  ;#  example  
  ;#     pt.point  
  ;#     pt\x = 100 
  ;#     x = SquintDeleteBinary(sq,0,@pt,SizeOf(point))   
  ;#     or via interface 
  ;#     x = sq\DeleteBinary(0,@pt,4,1)  ;will delete all child nodes where pt\x = 100       
  ;################################################################################## 
  
  Procedure SquintDeleteBinary(*this.squint,*subtrie,*key,size,prune=0)    
    
    Protected *node.squint_node,idx,*mem.Ascii,*akey.Ascii,offset,nodecount,vchar.l,vret.l,count,*out
    If *subtrie = 0
      *node = *this\root & #Squint_Pmask
    Else
      *node = *subtrie  & #Squint_Pmask 
    EndIf 
    *akey=*key 
         
    While count < size  
      offset = (*node\squint >> ((*akey\a & $f0) >> 2 )) & $f
      If *node\vertex
        _GETNODECOUNT()
        If (offset <> 15 Or nodecount = 16)
          *node = *node\Vertex\e[offset] & #Squint_Pmask
        EndIf
      Else
        ProcedureReturn 0
      EndIf
      If *node
        offset = (*node\squint >> ((*akey\a & $0f) << 2)) & $f
        If *node\vertex
          _GETNODECOUNT()
          If (offset <> 15 Or nodecount = 16)
            *node = *node\Vertex\e[offset] & #Squint_Pmask
          EndIf
        Else
          ProcedureReturn 0
        EndIf
      EndIf
      *akey+1
      count+1
    Wend
    
    If prune
      ISquintFree(*this,*node)
      If (*node\vertex & #Squint_Pmask) = 0
        *node\squint = 0
      EndIf
    Else
      offset = *node\squint & $f
      _GETNODECOUNT()
      If offset <= nodecount
        *node = (*node\Vertex\e[offset] & #Squint_Pmask)
        If (*node\vertex & #Squint_Pmask) = 0
          *node\squint = 0
        EndIf
      Else
        ProcedureReturn 0
      EndIf
    EndIf
  EndProcedure
  
  ;##################################################################################
  ;#  Enumerates the Trie from a given key   
  ;#    *this.squint instance from SquintNew() 
  ;#    *subtrie 0 Or the addess of a previously stored node       
  ;#    *key address 
  ;#     size the size of the key 
  ;#    *pfn.squint_CB address of callback function as Squint_CB(*key,*value=0,*userdata=0) 
  ;#        where *key is pointer to the key *value is pointer to the *value, *userDate      
  ;# example    
  ;#     pt.point     
  ;#     pt\x = 100 
  ;#     we want to search for all points where x = 100, size of the search key is 4 bytes    
  ;#     squintEnumBinary(sq,*subtrie,@pt,4,@MyCallback())       
  ;#  or via interface 
  ;#     sq\Enum@"cars:toyota:",@MyCallback())   
  ;################################################################################## 
  
  Procedure SquintEnumBinary(*this.squint,*subtrie,*key,size,*pfn.squint_CB,*userdata=0)       
    
    Protected *node.squint_Node,idx,*mem.Ascii,*akey.Ascii,offset,nodecount,depth,vchar.l,vret.l,count,*out
    Protected outkey.s{1024} 
    
    _LockMutex(gwrite) 
    
    If *subtrie = 0
      *node = *this\root
    Else
      *node = *subtrie  & #Squint_Pmask 
    EndIf 
    
    *akey = *key 
    
     While count < size  
      
      offset = (*node\squint >> ((*akey\a & $f0) >> 2 )) & $f
      _GETNODECOUNT()
      If offset < nodecount
        *mem = @outkey+(depth>>1) 
        *mem\a = (*mem\a & $0f) | (((*akey\a >> 4) & $f)<<4)
        depth+1
        *node = (*node\Vertex\e[offset] & #Squint_Pmask)
      Else
        _UnlockMutex(gwrite) 
        ProcedureReturn 0
      EndIf
      
      offset = (*node\squint >> ((*akey\a & $0f) << 2)) & $f
      _GETNODECOUNT()
      If offset < nodecount
        *mem = @outkey+(depth>>1) 
        *Mem\a = ((*Mem\a & $f0) | (*akey\a & $f))
        depth+1
        *node = (*node\Vertex\e[offset] & #Squint_Pmask)
      Else
        _UnlockMutex(gwrite) 
        ProcedureReturn 0
      EndIf
      
      *akey+1
      count+1
     
    Wend
    
    IEnum(*this,*node,depth,*pfn,@outkey,*userdata)
    
    _UnlockMutex(gwrite) 
    
  EndProcedure
  
  Procedure SquintWalkBinary(*this.squint,*subtrie,*pfn.squint_CB,*userdata=0)    
    
    Protected *node, outkey.s{#SQUINT_MAX_KEY}    
    
    _LockMutex(gwrite) 
    
    If *subtrie = 0
      *node = *this\root
    Else
      *node = *subtrie  & #Squint_Pmask 
    EndIf 
    IEnum(*this,*node,0,*pfn,@outkey,*userdata)
    
    _UnlockMutex(gwrite)
    
  EndProcedure   
      
  Procedure SquintSize(*this.squint) 
    ProcedureReturn *this\size 
  EndProcedure   
  
  Procedure SquintNumKeys(*this.squint)
    ProcedureReturn *this\count 
  EndProcedure   
  
  ;-Numeric functions operate the same as a map, keys can be anything that's serial  
  
  ;#################################################################################
  ;#    Set a numeric key  
  ;#    note you can use both numeric or string keys in the same trie  
  ;#    a numeric key is an address to a variable and the required size 4 or 8 bytes on x64 
  ;#    optionally you can use a hash use a hash when you don't want large keys 
  ;#
  ;#    *this.squint instance from SquintNew() 
  ;#    *key   address of a variable or memory pointer 
  ;#    value.i non zero value or address of something  
  ;#    size.i required size in bytes    
  ;#  example     
  ;#     ikey.l = 12345 
  ;#     SquintSetNumeric(sq,@ikey,1234567,4)  the key size is 4 bytes   
  ;#     pt.point  
  ;#     pt\x = 100 
  ;#     pt\y = 200   
  ;#     SquintSetNumeric(sq,@pt,1,SizeOf(point),#true) ;hashes the key         
  ;#  via interface  
  ;#     sq\setNumeric(@ikey,123435,4)    
  ;################################################################################## 
    
  Procedure SquintSetNumeric(*this.squint,key.i,value.i,size=#Squint_Integer,bhash=0)
    
    Protected *node.squint_node,idx,offset,nodecount,vchar.i,vret.i,count,hash.q 
    Protected *old,*new,*adr,*akey.Ascii 
    *node = *this\root & #Squint_Pmask
    
    If bhash 
      *akey=key 
      hash = $D45E69F901E72147 ! bhash;
      Repeat 
        hash = $3631754B22FF2D5C * (count + *akey\a) ! (hash << 2) ! (hash >> 2);
        *akey + 1
        count+1 
      Until count >= size 
      count = 0 
      size = 8
      *akey = @hash+(#Squint_Integer-1)
    Else 
      *akey = @key+(size-1)
    EndIf 
        
    _LockMutex(gwrite) 
    
    While count <= size  
      *this\write = *node   ;<----------------------------------Set the write flag with current node    
      _sfence 
      idx = (*akey\a >> 4) & $f
      offset = (*node\squint >> (idx<<2)) & $f
      _SetNODE()
      idx = (*akey\a & $f)
      offset = (*node\squint >> (idx<<2)) & $f
      _SetNODE()
      *akey-1 
      count+1
    Wend
    
    _UnlockMutex(gwrite) 
    *this\write = 0    
    
    *node\value = value
    
  EndProcedure
    
  ;##################################################################################
  ;#    Get a numeric node     
  ;#    *this.squint instance from SquintNew() 
  ;#    *key   address of a variable or memory pointer 
  ;#    size   number of bytes used to store the key 4 or 8 x64 or an arbitatry size if using the hash     
  ;#    bhash  set to #true if your hashing the key  
  ;#    #returns the value         
  ;#  example  
  ;#    key.l = 12345  
  ;#    x = squintGetNumeric(sq,@ikey,4)   
  ;#    or via interface 
  ;#    x = sq\get(@ikey,4)      
  ;################################################################################## 
  
  Procedure SquintGetNumeric(*this.squint,key.i,size=#Squint_Integer,bhash=0)
    
    Protected *node.squint_Node,idx,offset,nodecount,vchar.i,vret.i,count,*akey.Ascii,hash.q,st  
    *node = *this\root & #Squint_Pmask
    
    If bhash 
      *akey=key 
      hash = $D45E69F901E72147 ! bhash;
      Repeat 
        hash = $3631754B22FF2D5C * (count + *akey\a) ! (hash << 2) ! (hash >> 2);
        *akey + 1
        count+1 
      Until count >= size 
      count = 0 
      size = 8
      *akey = @hash+(#Squint_Integer-1)
    Else 
      *akey = @key+(size-1)
    EndIf 
        
    While count <= size  
      
      If *this\write <> *node   ;test to see if same as write node
        _lfence 
        offset = (*node\squint >> ((*akey\a & $f0) >> 2 )) & $f
        _GETNODECOUNT()
        If offset < nodecount
          *node = (*node\Vertex\e[offset] & #Squint_Pmask)
        Else
          ProcedureReturn 0
        EndIf
      Else 
        Continue 
      EndIf  
      
      If *this\write <> *node   ;test to see if same as write node
        _lfence 
        offset = (*node\squint >> ((*akey\a & $0f) << 2)) & $f
        _GETNODECOUNT()
        If offset < nodecount
          *node = (*node\Vertex\e[offset] & #Squint_Pmask)
        Else
          ProcedureReturn 0
        EndIf
      Else 
        Continue 
      EndIf  
      *akey-1
      count+1
    Wend
    
    ProcedureReturn *node\value
  EndProcedure
  
  ;##################################################################################
  ;#  Delete Numeric resets the keys value to 0      
  ;#    *this.squint instance from SquintNew() 
  ;#    *key   address of a variable or memory pointer 
  ;#    size   number of bytes used to store the key    
  ;#  example  
  ;#     key.l = 12345  
  ;#     x = SquintDeleteNumeric(sq,@ikey,4)   
  ;#     or via interface 
  ;#     x = sq\DeleteNumeric(@ikey,4)      
  ;################################################################################## 
  
  Procedure SquintDeleteNumeric(*this.squint,key.i,size=#Squint_Integer,bhash=0)    
    Protected *node.squint_node,idx,*mem.Character,offset,nodecount,vchar.i,vret.i,count,*akey.Ascii,hash.q 
    *node = *this\root & #Squint_Pmask
    
    If bhash 
      *akey=key 
      hash = $D45E69F901E72147 ! bhash;
      Repeat 
        hash = $3631754B22FF2D5C * (count + *akey\a) ! (hash << 2) ! (hash >> 2);
        *akey + 1
        count+1 
      Until count >= size 
      count = 0 
      size = 8
      *akey = @hash+(#Squint_Integer-1)
    Else 
      *akey = @key+(size-1)
    EndIf 
        
    While count <= size 
      offset = (*node\squint >> ((*akey\a & $f0) >> 2 )) & $f
      _GETNODECOUNT()
      If offset < nodecount
        *node = (*node\Vertex\e[offset] & #Squint_Pmask)
      Else
        ProcedureReturn 0
      EndIf
      offset = (*node\squint >> ((*akey\a & $0f) << 2)) & $f
      _GETNODECOUNT()
      If offset < nodecount
        *node = (*node\Vertex\e[offset] & #Squint_Pmask)
      Else
        ProcedureReturn 0
      EndIf
      *akey-1
      count+1
    Wend
    If (*node\vertex & #Squint_Pmask) = 0
      *node\squint = 0
    EndIf
  EndProcedure
                  
  Procedure IEnumNumeric(*this.squint,*node.squint_Node,idx,depth,*pfn.squint_CB,size,*userdata=0)
    Protected a.i,offset,nodecount,*mem.Ascii,vchar.i,vret.i 
    If Not *node
      ProcedureReturn 0
    EndIf
    For a = 0 To 15 
      offset = (*node\squint >> (a<<2)) & $f
      If (*node\vertex And *node\squint)
        _GETNODECOUNT()
        If (offset <> 15 Or nodecount = 16)
          _POKENHL(@*this\sb,depth,a)
          IEnumNumeric(*this,*node\Vertex\e[offset] & #Squint_Pmask,0,depth+1,*pfn,size,*userdata)
        EndIf
      EndIf
    Next
    
    If *node\vertex=0
      vchar = PeekI(@*this\sb) 
      CompilerIf #PB_Compiler_Backend = #PB_Backend_C 
        CompilerIf #PB_Compiler_Processor = #PB_Processor_x64  
          !v_vchar = __builtin_bswap64(v_vchar);    
        CompilerElse 
          !v_vchar = __builtin_bswap32(v_vchar);     
        CompilerEndIf
      CompilerElse 
        EnableASM
        mov rax, vchar
        bswap rax;
        mov vchar,rax
        DisableASM 
      CompilerEndIf 
      
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64  
         If size = 4 
           vchar >> 32 
         EndIf
      CompilerEndIf   
      
      If *pfn   
        *pfn(@vchar,*node\value,*userdata)
      EndIf
      
    EndIf
    
    ProcedureReturn *node
  EndProcedure
  
  ;##################################################################################
  ;# Walks whole trie. note it's not thread safe yet you can only walk one thread at a time with same trie    
  ;#    *this.squint instance from SquintNew() 
  ;#    *pfn.squint_CB address of callback function as Squint_CB(*key,*value=0,*userdata=0) 
  ;#     where *key is pointer to the key *value is pointer to the *value, *userDate      
  ;# example    
  ;#     squintWalkNumeric(sq,@MyCallback())       
  ;#  or via interface 
  ;#     sq\WalkNumeric(@MyCallback())   
  ;################################################################################## 
  
  Procedure SquintWalkNumeric(*this.squint,*pfn.squint_CB,size=#Squint_Integer,*userdata=0)       
    
    Protected outkey.s{#SQUINT_MAX_KEY}        
    
    _LockMutex(gwrite) 
        
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x64  
      If size > 8 
        IEnum(*this,*this\root,0,*pfn,@outkey,*userdata)
      Else 
        IEnumNumeric(*this,*this\root,0,0,*pfn,size,*userdata)
      EndIf   
    CompilerElse 
      If size > 4 
        IEnum(*this,*this\root,0,*pfn,@outkey,*userdata)
      Else 
        IEnumNumeric(*this,*this\root,0,0,*pfn,size,*userdata)
      EndIf   
      
    CompilerEndIf  
      
    _UnLockMutex(gwrite)
    
  EndProcedure
     
  
EndModule 

CompilerIf #PB_Compiler_IsMainFile  
  
  CompilerIf Not #PB_Compiler_Thread 
    MessageRequester("squint3", "compile with thread safe")
    End 
  CompilerEndIf   
  
  UseModule Squint
  
  Procedure CBSquint(*key,*value,*userData)  
    Protected sout.s  
    sout = PeekS(*key,-1,#PB_UTF8)
    If *value 
      PrintN(sout + " " + Str(*value))
    EndIf 
    
    ProcedureReturn 1
    
  EndProcedure
  
  Procedure CBSquintWalk(*key,value,*userData)
    Static ct 
    If ct < 1000
      If value     
        PrintN(Str(PeekI(*key)) + " " + Str(value))  
      EndIf
      ct+1 
    EndIf  
  EndProcedure
  
  ;note you can use squint via raw pointer or via interface it's up to you   
  ;string keys can be either ascii, utf8 or unicode. you can also use numeric integers, while it's valid to mix them it's not really recomended yet 
  
  Global sq.isquint = SquintNew()
  Global *key,key.s,SubTrieA,SubTrie_B,val   
  
  
  CompilerIf #PB_Compiler_Debugger 
    
    
    OpenConsole() 
    ;test with interface  
    SubTrieA = sq\Set(0,@"subtrieA:",123)    ;Set returns the root of the subtrie 
    
    key = "abc"                                
    sq\Set(SubTrieA,@key,1)          ;key evaluates as subtrieA:abc  adds abc to the sub trie  
    
    key = "abcd" 
    sq\Set(SubTrieA,@key,1)          ;key evaluates as subtrieA:abcd  adds abcd to the sub trie  
       
    *key = UTF8("utf8:" + Chr($20AC) + Chr($A9))  
    sq\Set(SubTrieA,*key,2,#PB_UTF8) ;add it to the sub trie with utf8 key  
    
    key.s = "unicode:" + Chr($20AC) + Chr($A9)  
    sq\Set(SubTrieA,@key,3) ;add it to the sub trie with utf8 key 
    
    *key = Ascii("cde")               ;set ascii key  
    sq\set(SubTrieA,*key,4,#PB_Ascii) ;add to sub trie with ascii key    
    
    PrintN("value from ascii key " + Str(sq\Get(SubTrieA,*key,#PB_Ascii)))  ;get the value from the ascci key  
    
    key = "abc"                              
    PrintN("value from unicode key " + Str(sq\Get(SubTrieA,@key)))            ;get the unicode key  
    
    PrintN("the stored node aka subtrieA: = " + Str(SubTrieA))   
    PrintN(" look up subtrie node " + Str(sq\Get(0,@"subtrieA:",#PB_Unicode,0)))   
    PrintN(" look up its value  " +   Str(sq\Get(0,@"subtrieA:")))  
    
    PrintN("___ENUM from stored pointer to subtrieA")
    key = "a"
    sq\EnumNode(SubTrieA,@key,@CBSquint())    ;returns the root key + sub keys   
    
    key.s = "subtrie_b:"                      ;test raw access no interface   
    SubTrie_B = SquintSetNode(sq,0,@key,456)  ;make another sub trie root_pb 
    
    key = "abc"
    SquintSetNode(sq,SubTrie_B,@key,7)
    
    key = "bcd"
    SquintSetNode(sq,SubTrie_B,@key,8) 
    
    key = "cde"
    SquintSetNode(sq,SubTrie_B,@key,9) 
    
    key = "bcde"                              ;add a key below bcd" 
    SquintSetNode(sq,SubTrie_B,@key,10)          
    
    key = "bcdef"                             ;add a key below bcde" 
    SquintSetNode(sq,SubTrie_B,@key,11)     
    
    PrintN("++++Enum subtrie_b++++++")
    key = "subtrie_b_"
    sq\Enum(@key,@CBSquint())                 ;returns the root key + sub keys  
    
    PrintN("++++Delete and prune from bcd and Enum subtrie_b++++++")
    
    key = "bcd" 
    SquintDeleteNode(sq,SubTrie_B,@key,1)     ;Delete from bcd and prune removes the bcde bcdef node 
    
    key = "a"
    sq\Enum(@key,@CBSquint())                 ;returns the root key + sub keys   
    PrintN("Enum non existsnt") 
    
    key = "subtrie_c"
    sq\Enum(@key,@CBSquint())     
    
    PrintN("++++dump subtrie_a ++++++++")
    SquintWalkNode(sq,SubTrieA,@CBSquint())  ;returns the sub keys of SubTrie_A   
    
    PrintN("++++dump whole trie +++++")
    SquintWalkNode(sq,0,@CBSquint())          ;Dumps the entire trie      
    
    PrintN("-------Numeric------------") 
    
    ikey=-1
    sq\SetNumeric(ikey,12345)                ;Add numeric keys   
    ikey=34567
    sq\SetNumeric(34567,34567)
    ikey=23456 
    sq\SetNumeric(23456,23456) 
    
    ikey = 34567
    PrintN("get numeric key " + Str(sq\GetNumeric(34567)))                ;test get numeric    
    
    PrintN("-------Walk numeric ----") 
    sq\WalkNumeric(@CBSquintWalk())           ;walk the numeric thery return in sorted order     
    
    sq\Free() 
    
    Procedure CBSquintWalkNum(*key.Integer,value,*userData)
      PrintN(Str(*key\i) + " " + Str(value))  
    EndProcedure
    
    sq.isquint = SquintNew()
    ikey=1
    sq\SetNumeric(1,123,4)
    ikey=4
    sq\SetNumeric(4,456,4)
    ikey=8
    sq\SetNumeric(8,8910,4)
    
    ikey=1
    PrintN(Str(sq\GetNumeric(1,4))) 
    ikey=2
    PrintN(Str(sq\GetNumeric(2,4))) 
    ikey=4
    PrintN(Str(sq\GetNumeric(4,4))) 
    ikey=6
    PrintN(Str(sq\GetNumeric(6,4))) 
    ikey=8
    PrintN(Str(sq\GetNumeric(8,4))) 
    
    PrintN("-------Walk numeric ----") 
    sq\WalkNumeric(@CBSquintWalkNum(),4)      
    
    *rd = AllocateMemory(256) 
    RandomSeed(1) 
    For a = 1 To 100 
      RandomData(*rd,256)
      sq\SetNumeric(*rd,a,256,1)  ;set a bigkey using hash  
      sum+a
    Next  
     RandomSeed(1) 
    For a = 1 To 100 
      RandomData(*rd,256)
      ct + sq\GetNumeric(*rd,256,1) ;get a big key using hash
    Next  
    Debug ct     ;check that ct matches sum
    Debug sum 
    
    sq\Free()   
    
    Input() 
    
  CompilerElse 
    
    OpenConsole()
    
    #TestNumeric = 1
    #TESTMAP =  0
    #Randomkeys = 1 
    
    Global lt = 1 << 22   
    
    Global gQuit,lt,a,num,memsize 
    Global keylen,avgkeylen  
    Global start = CreateSemaphore()
    sq.isquint = SquintNew()
    Global NewMap mp(lt)
    Global NUMTHREADS = CountCPUs(#PB_System_CPUs) 
    
    If NUMTHREADS < 3 
      MessageRequester("Squint thread tests", "system doesn't have enough core threads for tests") 
      NUMTHREADS = 3   
    EndIf   
    
    If MessageRequester("begin test","Num items " + FormatNumber(lt,0,".",",") + " lookups over 1 second",#PB_MessageRequester_YesNo) <> #PB_MessageRequester_Yes     
      End 
    EndIf  
    
    RandomSeed(124)
    
    For a = 0 To lt 
      num = Random(lt) 
      key = Hex(num);
      CompilerIf #TestNumeric 
        CompilerIf #TESTMAP = 0
          keylen+4 
        CompilerElse 
          keylen + StringByteLength(Str(num))
        CompilerEndIf 
        sq\SetNumeric(num,1,4) 
        mp(Str(num))=1 
      CompilerElse   
        keylen+StringByteLength(key) 
        sq\Set(0,@key,1)
        mp(key)=1 
      CompilerEndIf 
    Next  
    
    CompilerIf #TestNumeric 
      avgkeylen=4 
    CompilerElse  
      avgkeylen = keylen/lt    
    CompilerEndIf  
    
    CompilerIf #TESTMAP = 0 
      memsize = SquintSize(sq)
    CompilerElse     
      memsize = (lt*SizeOf(Integer)*2) + keylen  ;at minimum a map uses two pointer per bin value and the key              
    CompilerEndIf 
    
    Procedure _Read(*ct.integer) 
      Protected key.s,num.i,ct,x=0,cx=0  
      
      WaitSemaphore(start) 
      
      Repeat 
        
        CompilerIf #Randomkeys  
          num = Random($ffffffff,1) ;key's may not exist 
        CompilerElse   
          num = Random(lt,1) ;keys most likely exist 
        CompilerEndIf    
        
        CompilerIf #TESTMAP = 0
          CompilerIf #TestNumeric  
            x = SquintGetNumeric(sq,num,4)
            cx = (1 | x)   
          CompilerElse   
            key = Hex(num)
            x = SquintGetNode(sq,0,@key) 
            cx = (1 | x)   
          CompilerEndIf   
        CompilerElse   
          CompilerIf #TestNumeric  
            x = FindMapElement(mp(),Str(num)) & 1    ;swap comment for 5 x map speed 
            ;x = mp(Str(num)) & 1                      ;this shouldn't slow it down   
            cx = (1 | x)   
          CompilerElse   
            key = Hex(num)
            x = (FindMapElement(mp(),key) & 1)         ;swap comment for 5 x map speed 
            ;x = mp(key) & 1 
            cx = (1 | x)   
          CompilerEndIf  
        CompilerEndIf  
        *ct\i + 1
        ;Delay(0)
      Until gQuit  
      
    EndProcedure 
    
    Procedure _write(*ct.integer) 
      Protected key.s, num,ct  
      
      WaitSemaphore(start) 
      
      Repeat 
        num = Random(lt,1) 
        
        CompilerIf #TESTMAP = 0 
          
          CompilerIf #TestNumeric  
            SquintSetNumeric(sq,num,1,4)  
          CompilerElse   
            key = Hex(num) 
            SquintSetNode(sq,0,@key,1) 
          CompilerEndIf   
          
        CompilerElse 
          CompilerIf #TestNumeric  
            mp(Str(num)) = 1 
          CompilerElse 
            key = Hex(num)
            mp(key) = 1 
          CompilerEndIf 
        CompilerEndIf  
        
        *ct\i + 1 
        ;Delay(0) 
      Until gQuit  
      
    EndProcedure  
    
    Procedure _Enum(*void) 
      Protected ct1,ct,num,key.s  
      
      WaitSemaphore(start) 
      
      Repeat 
        CompilerIf #TestNumeric = 0 
          CompilerIf #TESTMAP = 0 
            num = Random(lt,1) 
            key = Hex(num)
            sq\Enum(@key,@CBSquint())  
          CompilerElse 
            num = Random(lt,1) 
            key = Hex(num)
            x = mp(key)
            PrintN(MapKey(mp()))
          CompilerEndIf  
        CompilerElse 
          CompilerIf #TESTMAP = 0  
            sq\WalkNumeric(@CBSquintWalk())   
          CompilerElse 
            While ct < 1000  
              x = mp(Str(ct1)) 
              If x <> 0 
                PrintN(Str(ct1) + " " + Str(x))
                ct+1
              EndIf   
              ct1 + 1 
            Wend     
          CompilerEndIf   
        CompilerEndIf  
        
        Delay(10) 
        
      Until gQuit   
      
    EndProcedure   
    
    Global Dim counts(NUMTHREADS) 
    Global Dim threads(NUMTHREADS) 
    
    For a = 0 To NUMTHREADS-2;
      threads(a) = CreateThread(@_read(),@counts(a)) 
    Next 
    Threads(a) = CreateThread(@_write(),@counts(a)) 
    ;a+1
    ;Threads(a) = CreateThread(@_Enum(),0) 
    
    Delay(1000) 
    
    For a = 0 To NUMTHREADS-1 
      SignalSemaphore(start)
    Next  
    
    Delay(1000) 
    
    gquit=1 
    
    For a = 0 To NUMTHREADS-1
      WaitThread(threads(a))
    Next 
    
    Global out.s, total, avg, tout.s  
    For a = 0 To NUMTHREADS-2;
      total + counts(a)  
      tout + " thread " + Str(a) + " " +  FormatNumber(counts(a),0,".",",") + #CRLF$
    Next 
    tout + " thread " + Str(a) + " " +  FormatNumber(counts(a),0,".",",") + #CRLF$
    
    avg = (total / (NUMTHREADS-1))
    
    CompilerIf  #TESTMAP
      out +  "Map lookup " + "items " + FormatNumber(total,0) + "  p/s " +  " avg per thread " + FormatNumber(avg,0) +  #CRLF$
      out +  "lookup rate " + FormatNumber(total*avgkeylen/1024/1024,2,".",",") + " mb p/s"  + #CRLF$
      out +  "lookup time " + FormatNumber((1000.0/total)*1000000 ,2,".",",") + " ns"  + #CRLF$
      out +  "map writes items " + FormatNumber(counts(NUMTHREADS-1),0)  + " p/s" + #CRLF$
      out +  "Write rate " +  FormatNumber(counts(NUMTHREADS-1)*avgkeylen/1024/1024,2,".",",") + " mb p/s"  + #CRLF$
      out +  "num items " + FormatNumber(lt,0,".",",") + " mem " + StrF(memsize/(1024*1024),2) + "mb keysize " + StrF(keylen/(1024*1024),2) + " mb"  + #CRLF$     
    CompilerElse 
      CompilerIf #TestNumeric 
        out +  "Squint Numeric lookup items " + FormatNumber(total,0) + " p/s" + " avg per thread " + FormatNumber(avg,0) +  #CRLF$
        out +  "lookup rate " + FormatNumber(total*avgkeylen/1024/1024,2,".",",") + " mb p/s"  + #CRLF$
        out +  "lookup time " + FormatNumber((1000.0/total)*1000000 ,2,".",",") + " ns"  + #CRLF$
        out +  "Squint Numeric writes items " + FormatNumber(counts(NUMTHREADS-1),0)  + #CRLF$
        out +  "Write rate " +  FormatNumber(counts(NUMTHREADS-1)*avgkeylen/1024/1024,2,".",",") + " mb p/s"  + #CRLF$
      CompilerElse   
        out +  "Squint lookup items " + FormatNumber(total,0) + " p/s" + " avg per thread " + FormatNumber(avg,0) + #CRLF$
        out +  "lookup rate " + FormatNumber(total*avgkeylen/1024/1024,2,".",",") + " mb p/s"  + #CRLF$
        out +  "lookup time " + FormatNumber((1000.0/total)*1000000 ,2,".",",") + " ns"  + #CRLF$
        out +  "Squint writes items " + FormatNumber(counts(NUMTHREADS-1),0)  + #CRLF$
        out +  "Writes rate " + FormatNumber(counts(NUMTHREADS-1)*avgkeylen/1024/1024,2,".",",") + " mb p/s"   + #CRLF$ 
      CompilerEndIf   
      out +  "num items " + FormatNumber(lt,0,".",",") + " mem " + StrF(sq\Size() / (1024*1024),2) + "mb keysize " + StrF(keylen/(1024*1024),2) + " mb"  + #CRLF$     
      
    CompilerEndIf 
    
    out + tout 
    Print(out) 
    
    SetClipboardText(out)
    MessageRequester("threads",out) 
    
  CompilerEndIf  
  
CompilerEndIf   
