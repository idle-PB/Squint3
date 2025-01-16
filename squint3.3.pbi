
Macro Comments() 
  ; SQUINT 3, Sparse Quad Union Indexed Nibble Trie
  ; Copyright Andrew Ferguson aka Idle (c) 2020 - 2024 
  ; Version 3.2.2 b5
  ; PB 5.72-6.02b 32bit/64bit asm and c backends for Windows,Mac OSX,Linux,PI,M1
  ; Thanks Wilbert for the high low insight and utf8 conversion help.
  ; Squint is a lock free concurrent compact prefix Trie indexed by nibbles into a sparse array
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
  ; Squint supports Set, Get, Enum, EnumNode , Walk, WalkNode, Merge, Delete and Prune with a flag in Delete
  ; String keys can be Unicode, Ascii or UTF8 the type must be specified 
  ; all string keys get mapped to UTF8 
  ;
  ; SquintNumeric supports, SetNumeric GetNumeric DeleteNumeric and WalkNumeric
  ; it's provided as a direct subtitute for a map, keys can be any size upto #SQUINT_MAX_KEY =1024
  ; keys are returned as pointers in walk     
  ; keys can be anything that's serial and optionaly you can hash longer keys which will be sizeof integer 
  ;
  ; Note while you can mix string and numeric keys in the same trie it's not recomended unless you only require set and get 
  ;  
  ; Eclipse Public License - v 2.0
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
    mwrite.i
    menum.i
    *merge.squint
    *root.squint_node
    sb.a[#SQUINT_MAX_KEY]
  EndStructure
  
  CompilerIf #PB_Compiler_32Bit 
    #Squint_Pmask = $fffffffe
    #Squint_Integer = 4 
  CompilerElse
    #Squint_Pmask = $fffffffffffe
    #Squint_Integer = 8 
  CompilerEndIf
  
  ;-Squint Callback prototype 
  Prototype Squint_CB(*key,*value=0,*userdata=0)
  Prototype Squint_CBFree(*mem) 
  
  Declare SquintNew()
  Declare SquintFree(*this.Squint,*pfn.Squint_CBFree=0)
  Declare SquintMerge(*this.squint,*target.squint,freesource=0,numeric=0) 
  
  Declare SquintSetNode(*this.squint,*subtrie,*key,value.i,mode=#PB_Unicode)
  Declare SquintGetNode(*this.squint,*subtrie,*key,mode=#PB_Unicode,bval=1)
  Declare SquintDeleteNode(*this.squint,*subtrie,*key,prune=0,mode=#PB_Unicode)
  Declare SquintWalkNode(*this.squint,*subtrie,*pfn.squint_CB,*userdata=0) 
  Declare SquintEnum(*this.squint,*key,*pfn.squint_CB,*userdata=0,mode=#PB_Unicode)
  Declare SquintEnumNode(*this.squint,*subtrie,*key,*pfn.squint_CB,*userdata=0,mode=#PB_Unicode)
  
  Declare SquintSetNumeric(*this.squint,key.i,value.i,size=#Squint_Integer,bhash=0)
  Declare SquintGetNumeric(*this.squint,key.i,size = #Squint_Integer,bhash=0)
  Declare SquintDeleteNumeric(*this.squint,key.i,size = #Squint_Integer,bhash=0)
  Declare SquintWalkNumeric(*this.squint,*pfn.squint_CB,size=#Squint_Integer,*userdata=0)  
  
  Declare SquintSetBinary(*this.squint,*subtrie,*key,value.i,size)
  Declare SquintGetBinary(*this.squint,*subtrie,*key,size)
  Declare SquintDeleteBinary(*this.squint,*subtrie,*key,size,prune=0)
  Declare SquintEnumBinary(*this.squint,*subtrie,*key,size,*pfn.squint_CB,*userdata=0)
  Declare SquintWalkBinary(*this.squint,*subtrie,*pfn.squint_CB,size,*userdata=0) 
  
  Declare SquintSize(*this.squint)
  Declare SquintNumKeys(*this.squint)
  
  ;-Squint Inteface iSquint  
  Interface iSquint
    Free(*pfn.Squint_CBFree=0)
    Merge(*target.squint,freesource=0,numeric=0)  
    Delete(*subtrie,*key,prune=0,mode=#PB_Unicode)
    Set(*subtrie,*key,value.i,mode=#PB_Unicode)
    Get(*subtrie,*key,mode=#PB_Unicode,bval=1)
    Enum(*key,*pfn.squint_CB,*userdata=0,mode=#PB_Unicode)
    EnumNode(*subtrie,*key,*pfn.squint_CB,*userdata=0,mode=#PB_Unicode)
    Walk(*subtrie,*pfn.squint_CB,*userdata=0)
    SetNumeric(key.i,value.i,size=#Squint_Integer,bhash=0) 
    GetNumeric(key.i,size= #Squint_Integer,bhash=0) 
    DeleteNumeric(key.i,size=#Squint_Integer,bhash=0)
    WalkNumeric(*pfn.Squint_CB,size=#Squint_Integer,*userdata=0)
    SetBinary(*subtrie,*key,value.i,size) 
    GetBinary(*subtrie,*key,size) 
    DeleteBinary(*subtrie,*key,size,prune=0) 
    EnumBinary(*subtrie,*key,size,*pfn.squint_CB,*userdata=0)
    WalkBinary(*subtrie,*pfn.squint_CB,size,*userdata=0) 
    Size()
    NumKeys()
  EndInterface
  
  DataSection: vtSquint:
    Data.i @SquintFree()
    Data.i @SquintMerge() 
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
    CompilerIf #PB_Compiler_32Bit 
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
        !lock xchg qword [rdx] , rax
      CompilerEndIf 
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
       !lfence
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
  
  Macro _SETNODE()
    
    If *node\vertex
       
      _GETNODECOUNT()
      If (offset <> 15 Or nodecount = 16)
         XCHG_(@*node,(*node\Vertex\e[offset] & #Squint_Pmask))  
      Else  
        
        *node\Vertex = bts(*node\Vertex)
                      
        offset = nodecount
        nodecount+1 
        
        *new = AllocateMemory((nodecount)*SizeOf(squint_node)) 
        *old = *node\vertex & #Squint_Pmask
        CopyMemory(*old,*new,(offset)*SizeOf(squint_node)) 
                
        CompilerIf #PB_Compiler_64Bit; 
          *new | ((nodecount) << 48)
        CompilerEndIf  
                
        XCHG_(@*node\vertex,*new) 
        
        _SETINDEX(*node\squint,idx,offset)
                        
        XCHG_(@*node,(*node\Vertex\e[offset] & #Squint_Pmask))
               
        FreeMemory(*old) 
        
        If *this\merge  
          *this\merge\size + SizeOf(squint_node) 
        Else   
          *this\size  +SizeOf(squint_node) 
        EndIf 
                
      EndIf 
      
    Else
            
      *node\vertex = AllocateMemory(SizeOf(squint_Node))
      
      *node\Vertex = bts(*node\Vertex)
      
      CompilerIf #PB_Compiler_64Bit; 
        *node\vertex | (1 << 48)
      CompilerEndIf
      *node\squint = -1
      _SETINDEX(*node\squint,idx,0)
      
      *node\Vertex = BTC(*node\Vertex)
      
      XCHG_(@*node,(*node\Vertex\e[0] & #Squint_Pmask))
      
      If *this\merge  
       *this\merge\size +SizeOf(squint_node) 
      Else   
        *this\size+SizeOf(squint_node) 
      EndIf 
           
    EndIf 
    
  EndMacro
     
  Procedure XCHG_(*ptr.Integer,v1) 
    
    CompilerIf #PB_Compiler_Backend = #PB_Backend_C 
      !__atomic_exchange_n(&p_ptr->f_i,v_v1,__ATOMIC_SEQ_CST); 
    CompilerElse 
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
        !mov ecx,[p.p_ptr]
        !mov eax,[p.v_v1]
        !xchg dword [ecx],eax
      CompilerElse 
        !mov rcx, [p.p_ptr]
        !mov rax, [p.v_v1 ] 
        !xchg qword [rcx],rax
      CompilerEndIf
    CompilerEndIf 
    
  EndProcedure 
  
  Procedure CMPXCHG_(*ptr.Integer,eq,chg) 
    
    CompilerIf #PB_Compiler_Backend = #PB_Backend_C 
      !__atomic_compare_exchange_n(&p_ptr->f_i,&v_eq,v_chg,0,__ATOMIC_SEQ_CST,__ATOMIC_RELAXED); 
    CompilerElse 
      
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
        !mov eax, dword [p.v_eq]
        !mov ecx, dword [p.v_chg]
        !mov edx, dword [p.p_ptr] 
        !lock cmpxchg dword [edx],ecx 
      CompilerElse 
        !mov rax, qword [p.v_eq]
        !mov rcx, qword [p.v_chg]
        !mov rdx, qword [p.p_ptr] 
        !lock cmpxchg qword [rdx],rcx 
      CompilerEndIf  
      
    CompilerEndIf 
  EndProcedure
      
  Procedure BTS(*node) 
    CompilerIf #PB_Compiler_Backend = #PB_Backend_C 
      !asm("lock bts %1, %0" : "+m" (p_node) : "r" (0)); 
    CompilerElseIf #PB_Compiler_Processor = #PB_Processor_x86
      !lock BTS dword [p.p_node],0 
    CompilerElse
      !lock BTS qword [p.p_node],0 
    CompilerEndIf  
         
    ProcedureReturn *node  
  EndProcedure 

 Procedure BTC(*node) 
   CompilerIf #PB_Compiler_Backend = #PB_Backend_C 
      !asm("lock btc %1, %0" : "+m" (p_node) : "r" (0)); 
    CompilerElseIf #PB_Compiler_Processor = #PB_Processor_x86
      !lock BTC dword [p.p_node],0 
    CompilerElse
      !lock BTC qword [p.p_node],0 
    CompilerEndIf  
    ProcedureReturn *node
 EndProcedure   
  
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
      *this\mwrite = CreateMutex() 
      *this\menum = CreateMutex()
      
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
    _LockMutex(*this\mwrite)
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
    _UnlockMutex(*this\mwrite) 
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
    FreeMutex(*this\mwrite)
    FreeMutex(*this\menum) 
    FreeMemory(*this\root)
    nodecount = *this\size 
    FreeMemory(*this) 
    
    ProcedureReturn  nodecount  
  EndProcedure
  
  Procedure ISquintMerge(*this.squint,*node.squint_Node,*target.squint,depth,*outkey,numeric)
    Protected a.i,offset,nodecount,*mem.Ascii,key.s,*tnode 
    
    If Not *node
      ProcedureReturn 0
    EndIf
    
    For a =0 To 15
      
      offset = (*node\squint >> (a<<2)) & $f
      If (*node\vertex And *node\squint)
        _GETNODECOUNT()
        If (offset <> 15 Or nodecount = 16)
          _POKENHL(*outkey,depth,a)
          XCHG_(@*tnode,(*node\Vertex\e[offset] & #Squint_Pmask))
          If ISquintMerge(*this,*tnode,*target,depth+1,*outkey,numeric) = 0 
            Break 
          EndIf  
        EndIf
        
      EndIf
    Next
    
    If *node\vertex=0
      
      PokeA(*outkey+((depth>>1)),0)
      If numeric = 0 
        If *node\value
          SquintSetNode(*target,0,*outkey,*node\value,#PB_UTF8)
        EndIf  
      Else 
        If *node\value
          SquintSetNumeric(*target,*outkey,*node\value)
        EndIf   
      EndIf 
    EndIf
    ProcedureReturn *node
    
  EndProcedure
  
  ;#################################################################################
  ;#    merge tries    
  ;#    *this.squint instance from SquintNew() 
  ;#    *target squint to merge into  
  ;#    freesource frees the souce 
  ;##################################################################################
  
  Procedure SquintMerge(*this.squint,*target.squint,freesource=0,numeric=0)   
    
    Protected outkey.s{#SQUINT_MAX_KEY} 
    
    *target\merge=0 
    
    ISquintMerge(*this,*this\root,*target,0,@outkey,numeric)
    
    If freesource
      
      SquintFree(*this) 
      
    EndIf   
    
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
    Protected *new.squint_node,*old.squint_node,*adr 
    Protected bmerge      
      
    
    _LockMutex(*this\mwrite)
    
    XCHG_(@bmerge,*this\merge) 
    If bmerge 
      *node = *this\merge\root & #Squint_Pmask
    Else 
      If *subtrie = 0
        *node = *this\root & #Squint_Pmask
      Else 
        *node = *subtrie & #Squint_Pmask
      EndIf
    EndIf 
      
    _CONVERTUTF8()
    
    While vchar
      
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
     ; Delay(0)
    Wend
    
    
    idx=0
    *out = *node 
    offset = *node\squint & $f
    
    _SETNODE()
   
    If bmerge 
      *this\merge\count+1 
    Else 
      *this\count +1
    EndIf 
    
    If value 
      *node\value = value
    EndIf 
    
    _UnlockMutex(*this\mwrite)
    
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
      XCHG_(@*node,(*this\root & #Squint_Pmask))
    Else 
      XCHG_(@*node,(*subtrie & #Squint_Pmask))
    EndIf 
    _CONVERTUTF8()
    
    If *node\vertex
      
      While vchar
        
        l1:
        If Not (*node & 1) 
          
          offset = (*node\squint >> ((vchar & $f0) >> 2 )) & $f
          _GETNODECOUNT()
          If offset < nodecount
            XCHG_(@*node,(*node\Vertex\e[offset] & #Squint_Pmask))
          Else
            ProcedureReturn 0
          EndIf
        Else 
          Delay(0)
          Goto l1  
        EndIf  
        
        l2:
        If Not (*node & 1) 
          
          offset = (*node\squint >> ((vchar & $0f) << 2)) & $f
          _GETNODECOUNT()
          If offset < nodecount
            XCHG_(@*node,(*node\Vertex\e[offset] & #Squint_Pmask))
          Else
            ProcedureReturn 0
          EndIf
        Else 
          Delay(0)
          Goto l2  
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
        XCHG_(@*node,(*node\Vertex\e[offset] & #Squint_Pmask)) 
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
  
  Structure stack 
    *node 
    a.i
    depth.i
  EndStructure  
  
  Procedure IEnum(*this.squint,*node.squint_Node,depth,*pfn.squint_CB,*outkey,*userdata=0)
    Protected a.i,b.i,offset,nodecount,*mem.Ascii
    
    If Not *node
      ProcedureReturn 0
    EndIf
    
    For a =0 To 15
      
      offset = (*node\squint >> (a<<2)) & $f
      If (*node\vertex And *node\squint)
        _GETNODECOUNT()
        If (offset <> 15 Or nodecount = 16)
          _POKENHL(*outkey,depth,a)
          If IEnum(*this,(*node\Vertex\e[offset] & #Squint_Pmask),depth+1,*pfn,*outkey,*userdata) = 0 
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
    Protected *old.squint,*new.squint,bnmerge
    Protected outkey.s{1024} 
    
    _LockMutex(*this\menum)
    
    *new = SquintNew()     
    XCHG_(@*this\merge,*new) 
    
    If *subtrie = 0
       *node = *this\root & #Squint_Pmask
    Else 
       *node = *subtrie & #Squint_Pmask
    EndIf 
    _CONVERTUTF8()
    
    If *node\vertex
      
      While vchar
        
        l1:
        If Not (*node & 1)
          
          offset = (*node\squint >> ((vchar & $f0) >> 2 )) & $f
          _GETNODECOUNT()
          If offset < nodecount
            *mem = @outkey+(depth>>1) 
            *mem\a = (*mem\a & $0f) | (((vchar >> 4) & $f)<<4)
            depth+1
            *node = (*node\Vertex\e[offset] & #Squint_Pmask)
          Else
            bnmerge = 1
            Break 
          EndIf
        Else 
          Delay(0)
          Goto l1  
        EndIf  
        
        l2:
        If Not (*node & 1)
         
          offset = (*node\squint >> ((vchar & $0f) << 2)) & $f
          _GETNODECOUNT()
          If offset < nodecount
            *mem = @outkey+(depth>>1) 
            *Mem\a = ((*Mem\a & $f0) | (vchar & $f))
            depth+1
            *node = (*node\Vertex\e[offset] & #Squint_Pmask)
          Else
            bnmerge = 1 
            Break 
          EndIf
        Else 
          Delay(0)
          Goto l2
        EndIf 
        
        vchar >> 8
        count+1
        If vchar = 0
          *key+2
          _MODECHECK()
        EndIf
        
      Wend
      
      If bnmerge = 0 
        
        IEnum(*this,*node,depth,*pfn,@outkey,*userdata)
        
        _LockMutex(*this\mwrite)  
        
        *old = *this\merge
        XCHG_(@*this\merge,0)               
        SquintMerge(*old,*this)
        
        _UnlockMutex(*this\mwrite)
        
        SquintFree(*old)
        
      Else 
        
        _LockMutex(*this\mwrite)  
        *old = *this\merge
        XCHG_(@*this\merge,0)    
        
        _UnlockMutex(*this\mwrite)
        SquintFree(*old)
        
      EndIf 
      
    EndIf 
    
    _UnlockMutex(*this\menum) 
    
    
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
    
    Protected *node, *old.squint,*new.squint, outkey.s{#SQUINT_MAX_KEY} 
    
    _LockMutex(*this\menum)
    
    *new = SquintNew()     
    XCHG_(@*this\merge,*new) 
    
    *node = *this\root & #Squint_Pmask
    
    IEnum(*this,*node,0,*pfn,@outkey,*userdata)
    
    _LockMutex(*this\mwrite)  
    
    *old = *this\merge
    XCHG_(@*this\merge,0)               
    SquintMerge(*old,*this) 
    
    _UnlockMutex(*this\mwrite)
    
    SquintFree(*old)
    
    _UnlockMutex(*this\menum) 
    
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
    
    Protected *node, *old.squint,*new.squint, outkey.s{#SQUINT_MAX_KEY}    
    
    _LockMutex(*this\menum)
    
    *new = SquintNew()     
    XCHG_(@*this\merge,*new) 
    
    If *subtrie = 0
      *node = *this\root & #Squint_Pmask 
    Else
      *node = *subtrie  & #Squint_Pmask 
    EndIf 
    
    IEnum(*this,*node,0,*pfn,@outkey,*userdata)
    
    _LockMutex(*this\mwrite)  
    
    *old = *this\merge
    XCHG_(@*this\merge,0)               
    SquintMerge(*old,*this) 
    
    _UnlockMutex(*this\mwrite)
    
    SquintFree(*old)
    
    _UnlockMutex(*this\menum) 
    
  EndProcedure
  
  ;-Binaryfunctions operate the same as the string functions with no utf8 conversion   
  
  ;#################################################################################
  ;#    Set a Binary key  
  ;#    a Binary key is an address to memory and it's size in bytes 
  ;#    
  ;#    *this.squint instance from SquintNew() 
  ;#    *key   address of a variable or memory pointer 
  ;#    value.i non zero value or address of something  
  ;#    size.i required size in bytes    
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
    Protected bmerge,*old,*new.squint_node,sqindex,*akey.Ascii 
     
    
    _LockMutex(*this\mwrite)
    
    XCHG_(@bmerge,*this\merge) 
    If bmerge 
      *node = *this\merge\root & #Squint_Pmask
    Else 
      If *subtrie = 0
        *node = *this\root & #Squint_Pmask
      Else 
        *node = *subtrie & #Squint_Pmask
      EndIf
    EndIf 
    
    *akey = *key 
    
    While count <= size  
      idx = (*akey\a >> 4) & $f
      offset = (*node\squint >> (idx<<2)) & $f
      _SetNODE()
      idx = (*akey\a & $f)
      offset = (*node\squint >> (idx<<2)) & $f
      _SetNODE()
      *akey+1 
      count+1
    Wend
    
    If bmerge 
      *this\merge\count+1 
    Else 
      *this\count +1
    EndIf 
    
    If value 
      *node\value = value
    EndIf 
    
    _UnlockMutex(*this\mwrite)
    
    ProcedureReturn *node 
    
  EndProcedure
  
  ;##################################################################################
  ;#    Get a Binary node     
  ;#    *key   address of a variable Or memory pointer 
  ;#    size   number of bytes used for the key      
  ;#    #returns the value         
  ;#  example  
  ;#     pt.point  
  ;#     pt\x = 100 
  ;#     pt\y = 200   
  ;#     x = squintGetBinary(sq,@pt,sizeof(point))   
  ;#     or via interface 
  ;#     x = sq\getBinary(@pt,sizeof(point))        
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
      
      l1:
      If Not (*node & 1) 
        offset = (*node\squint >> ((*akey\a & $f0) >> 2 )) & $f
        _GETNODECOUNT()
        If offset < nodecount
          *node = (*node\Vertex\e[offset] & #Squint_Pmask)
        Else
          ProcedureReturn 0
        EndIf
      Else 
        Goto l1
      EndIf  
      
      l2:
      If Not (*node & 1) 
       offset = (*node\squint >> ((*akey\a & $0f) << 2)) & $f
        _GETNODECOUNT()
        If offset < nodecount
          *node = (*node\Vertex\e[offset] & #Squint_Pmask)
        Else
          ProcedureReturn 0
        EndIf
      Else 
        Goto l2
      EndIf  
      *akey+1
      count+1
    Wend
    
    ProcedureReturn *node\value
  EndProcedure
  
  ;##################################################################################
  ;#  Delete Binary resets the keys value to 0      
  ;#    *this.squint instance from SquintNew() 
  ;#    *key   address of a variable or memory pointer 
  ;#    size   number of bytes used to store the key    
  ;#  example  
  ;#     pt.point  
  ;#     pt\x = 100 
  ;#     pt\y = 200   
  ;#     x = SquintDeleteBinary(sq,@pt,SizeOf(point))   
  ;#     or via interface 
  ;#     x = sq\DeleteBinary(@pt,SizeOf(point))      
  ;################################################################################## 
  
  Procedure SquintDeleteBinary(*this.squint,*subtrie,*key,size,prune=0)    
    
    Protected *node.squint_node,idx,*mem.Ascii,*akey.Ascii,offset,nodecount,vchar.l,vret.l,count,*out
    If *subtrie = 0
      *node = *this\root & #Squint_Pmask
    Else
      *node = *subtrie  & #Squint_Pmask 
    EndIf 
    *akey=*key 
    
    While count <= size  
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
    
    Protected *node.squint_Node,idx,*mem.Ascii,*akey.Ascii,offset,nodecount,depth,vchar.l,vret.l,count
    Protected bnmerge,*old.squint,*new.squint,outkey.s{1024} 
    
    _LockMutex(*this\menum)
    
    *new = SquintNew()     
    XCHG_(@*this\merge,*new) 
    
    If *subtrie = 0
      *node = *this\root
    Else
      *node = *subtrie  & #Squint_Pmask 
    EndIf 
    
    *akey = *key 
    
    While count < size  
      
      l1:
      If Not (*node & 1)
        
        offset = (*node\squint >> ((*akey\a & $f0) >> 2 )) & $f
        _GETNODECOUNT()
        If offset < nodecount
          *mem = @outkey+(depth>>1) 
          *mem\a = (*mem\a & $0f) | (((*akey\a >> 4) & $f)<<4)
          depth+1
          *node = (*node\Vertex\e[offset] & #Squint_Pmask)
        Else
          bnmerge=1
          Break 
        EndIf
      Else 
        Delay(0)
        Goto l1  
      EndIf  
      
      l2:
      If Not (*node & 1)
        
        offset = (*node\squint >> ((*akey\a & $0f) << 2)) & $f
        _GETNODECOUNT()
        If offset < nodecount
          *mem = @outkey+(depth>>1) 
          *Mem\a = ((*Mem\a & $f0) | (*akey\a & $f))
          depth+1
          *node = (*node\Vertex\e[offset] & #Squint_Pmask)
        Else
          bnmerge=1  
          Break
        EndIf
        
      Else 
        Delay(0)
        Goto l2  
      EndIf  
      
      *akey+1
      count+1
      
    Wend
    
    If bnmerge = 0 
      
      IEnum(*this,*node,depth,*pfn,@outkey,*userdata)
      
      _LockMutex(*this\mwrite)  
      
      *old = *this\merge
      XCHG_(@*this\merge,0)               
      SquintMerge(*old,*this) 
      
      _UnlockMutex(*this\mwrite)
      
      SquintFree(*new)
      
    Else 
      
      *old = *this\merge
      XCHG_(@*this\merge,0)    
      SquintFree(*old)
      
    EndIf 
    
    _UnlockMutex(*this\menum) 
    
  EndProcedure
  
  Procedure SquintWalkBinary(*this.squint,*subtrie,*pfn.squint_CB,size,*userdata=0)    
    
    Protected *node, *old.squint,*new.squint, outkey.s{#SQUINT_MAX_KEY}    
    
    _LockMutex(*this\menum)
    
    *new = SquintNew()     
    XCHG_(@*this\merge,*new) 
    
    If *subtrie = 0
      *node = *this\root
    Else
      *node = *subtrie  & #Squint_Pmask 
    EndIf 
    
    IEnum(*this,*node,0,*pfn,@outkey,*userdata)
    
    _LockMutex(*this\mwrite)  
    
    *old = *this\merge
    XCHG_(@*this\merge,0)               
    SquintMerge(*old,*this) 
    
    _UnlockMutex(*this\mwrite)
    
    SquintFree(*old)
    
    _UnlockMutex(*this\menum) 
    
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
    Protected bmerge,*old,*new.squint_node,sqindex,*akey.Ascii 
      
    
    _LockMutex(*this\mwrite)
    
    XCHG_(@bmerge,*this\merge) 
    If bmerge 
      XCHG_(@*node,(*this\merge\root & #Squint_Pmask))
    Else 
      XCHG_(@*node,(*this\root & #Squint_Pmask))
    EndIf  
    XCHG_(@*this\write,*node) 
    
    If bhash 
      *akey=PeekI(@key)  
      hash = $D45E69F901E72147 ! bhash;
      Repeat 
        hash = $3631754B22FF2D5C * (count + *akey\a) ! (hash << 2) ! (hash >> 2);
        *akey + 1
        count+1 
      Until count > size 
      count = 0 
      size = 8
      *akey = @hash+(#Squint_Integer-1)
    Else 
      *akey = @key+(size-1)
    EndIf 
    
    While count < size  
      
      idx = (*akey\a >> 4) & $f
      offset = (*node\squint >> (idx<<2)) & $f
      _SetNODE()
      
      idx = (*akey\a & $f)
      offset = (*node\squint >> (idx<<2)) & $f
      _SetNODE()
      *akey-1 
      count+1
      ;Delay(0)
    Wend
    
    If bmerge 
      *this\merge\count+1 
    Else 
      *this\count +1
    EndIf 
    
    *node\value = value
            
    _UnlockMutex(*this\mwrite)
    
    ProcedureReturn *node
    
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
    
    XCHG_(@*node,(*this\root & #Squint_Pmask))
    
    If bhash 
      *akey=PeekI(@key)  
      hash = $D45E69F901E72147 ! bhash;
      Repeat 
        hash = $3631754B22FF2D5C * (count + *akey\a) ! (hash << 2) ! (hash >> 2);
        *akey + 1
        count+1 
      Until count > size 
      count = 0 
      size = 8
      *akey = @hash+(#Squint_Integer-1)
    Else 
      *akey = @key+(size-1)
    EndIf 
    
    While count < size  
      
      l1:
      If Not (*node & 1) 
        
        _GETNODECOUNT()
        XCHG_(@offset,*node\squint) 
        offset = (offset >> ((*akey\a & $f0) >> 2 )) & $f
        If offset < nodecount
          XCHG_(@*node,(*node\Vertex\e[offset] & #Squint_Pmask))
        Else
          ProcedureReturn 0
        EndIf
      Else 
        Delay(0)
        Goto l1  
      EndIf  
      
      l2:
      If Not (*node & 1)  
         _GETNODECOUNT()
        XCHG_(@offset,*node\squint) 
        offset = (offset >> ((*akey\a & $0f) << 2)) & $f
        If offset < nodecount
          XCHG_(@*node,(*node\Vertex\e[offset] & #Squint_Pmask)) 
        Else
          ProcedureReturn 0
        EndIf
      Else 
        Delay(0)
        Goto l2  
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
      *akey=PeekI(@key)  
      hash = $D45E69F901E72147 ! bhash;
      Repeat 
        hash = $3631754B22FF2D5C * (count + *akey\a) ! (hash << 2) ! (hash >> 2);
        *akey + 1
        count+1 
      Until count > size 
      count = 0 
      size = 8
      *akey = @hash+(#Squint_Integer-1)
    Else 
      *akey = @key+(size-1)
    EndIf 
    
    While count < size 
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
  
  Procedure IEnumNumeric(*this.squint,*node.squint_Node,depth,*pfn.squint_CB,*outkey.integer,size,*userdata=0)
    Protected a.i,offset,nodecount,*mem.Ascii,vchar.i,vret.i 
    
    If Not *node
      ProcedureReturn 0
    EndIf
    
    For a = 0 To 15 
      offset = (*node\squint >> (a<<2)) & $f
      If (*node\vertex And *node\squint)
        _GETNODECOUNT()
        If (offset <> 15 Or nodecount = 16)
            _POKENHL(*outkey,depth,a)
           If IEnumNumeric(*this,*node\Vertex\e[offset] & #Squint_Pmask,depth+1,*pfn,*outkey,size,*userdata) = 0 
            Break 
          EndIf   
        EndIf
      EndIf
    Next
        
    If *node\vertex=0
      vchar = PeekI(*outkey) 
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
      
      If *node\value
        If *pfn   
          *pfn(@vchar,*node\value,*userdata)
        EndIf
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
    
    Protected depth,*node.squint_node,*new.squint,*old.squint,out.i,outkey.s{#SQUINT_MAX_KEY}        
    
    _LockMutex(*this\menum)
    
    *new = SquintNew()     
     
    XCHG_(@*this\merge,*new) 
    
    *node = *this\root & #Squint_Pmask
       
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x64  
      If size > 8 
        IEnum(*this,*node,0,*pfn,@outkey,*userdata)
      Else 
        IEnumNumeric(*this,*node,0,*pfn,@out,size,*userdata)
      EndIf   
    CompilerElse 
      If size > 4 
        IEnum(*this,*node,0,*pfn,@outkey,*userdata)
      Else 
        IEnumNumeric(*this,*node,depth,*pfn,@out,size,*userdata)
      EndIf   
      
    CompilerEndIf  
    
    _LockMutex(*this\mwrite)  
       
    *old = *this\merge
    XCHG_(@*this\merge,0)               
    SquintMerge(*old,*this,0,1) 
    
    _UnlockMutex(*this\mwrite)
           
    SquintFree(*old)
    
    _UnlockMutex(*this\menum) 
    
  EndProcedure
  
  
EndModule 

CompilerIf #PB_Compiler_IsMainFile  
  
  UseModule Squint
  
  Procedure ErrorHandler()
    Protected ErrorMessage.s
    
    ErrorMessage = "error was detected:" + #CRLF$ 
    ErrorMessage + #CRLF$
    ErrorMessage + "Error Message:   " + ErrorMessage()      + #CRLF$
    ErrorMessage + "Error Code:      " + Str(ErrorCode())    + #CRLF$  
    ErrorMessage + "Code Address:    " + Str(ErrorAddress()) + #CRLF$
    
    If ErrorCode() = #PB_OnError_InvalidMemory   
      ErrorMessage + "Target Address:  " + Str(ErrorTargetAddress()) + #CRLF$
    EndIf
    
    If ErrorLine() = -1
      ErrorMessage + "Sourcecode line: Enable OnError lines support to get code line information." + #CRLF$
    Else
      ErrorMessage + "Sourcecode line: " + Str(ErrorLine()) + #CRLF$
      ErrorMessage + "Sourcecode file: " + ErrorFile() + #CRLF$
    EndIf
    
    ErrorMessage + #CRLF$
    ErrorMessage + "Register content:" + #CRLF$
    CompilerIf #PB_Compiler_64Bit 
      ErrorMessage + "RAX = " + Str(ErrorRegister(#PB_OnError_RAX)) + #CRLF$
      ErrorMessage + "RBX = " + Str(ErrorRegister(#PB_OnError_RBX)) + #CRLF$
      ErrorMessage + "RCX = " + Str(ErrorRegister(#PB_OnError_RCX)) + #CRLF$
      ErrorMessage + "RDX = " + Str(ErrorRegister(#PB_OnError_RDX)) + #CRLF$
      ErrorMessage + "RBP = " + Str(ErrorRegister(#PB_OnError_RBP)) + #CRLF$
      ErrorMessage + "RSI = " + Str(ErrorRegister(#PB_OnError_RSI)) + #CRLF$
      ErrorMessage + "RDI = " + Str(ErrorRegister(#PB_OnError_RDI)) + #CRLF$
      ErrorMessage + "RSP = " + Str(ErrorRegister(#PB_OnError_RSP)) + #CRLF$
    CompilerElse 
      ErrorMessage + "EAX = " + Str(ErrorRegister(#PB_OnError_EAX)) + #CRLF$
      ErrorMessage + "EBX = " + Str(ErrorRegister(#PB_OnError_EBX)) + #CRLF$
      ErrorMessage + "ECX = " + Str(ErrorRegister(#PB_OnError_ECX)) + #CRLF$
      ErrorMessage + "EDX = " + Str(ErrorRegister(#PB_OnError_EDX)) + #CRLF$
      ErrorMessage + "EBP = " + Str(ErrorRegister(#PB_OnError_EBP)) + #CRLF$
      ErrorMessage + "ESI = " + Str(ErrorRegister(#PB_OnError_ESI)) + #CRLF$
      ErrorMessage + "EDI = " + Str(ErrorRegister(#PB_OnError_EDI)) + #CRLF$
      ErrorMessage + "ESP = " + Str(ErrorRegister(#PB_OnError_ESP)) + #CRLF$
    CompilerEndIf
    
    PrintN(ErrorMessage)
    SetClipboardText(ErrorMessage) 
    Input()
    End
    
  EndProcedure
  
  OnErrorCall(@ErrorHandler())
  
  Procedure CBSquint(*key,*value,*userData)  
    Protected sout.s  
    sout = PeekS(*key,-1,#PB_UTF8)
    If *value 
      PrintN(sout + " " + Str(*userData) + " " + Str(*value))
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
    SubTrieA = sq\Set(0,@"subtrieA:",123)    ;Set it with utf8 flag it returns the root of the sub trie 
    
    key = "abc"                                
    sq\Set(SubTrieA,@key,1)          ;key evaluates as subtrieA:abc  to the sub trie  
    
    key = "abcd" 
    sq\Set(SubTrieA,@key,1)          ;key evaluates as subtrieA:abcd  to the sub trie  
    
    *key = UTF8("utf8:" + Chr($20AC) + Chr($A9))  
    sq\Set(SubTrieA,*key,2,#PB_UTF8) ;add it to the sub trie with utf8 key  
    
    key.s = "unicode:" + Chr($20AC) + Chr($A9)  
    sq\Set(SubTrieA,@key,3) ;add it to the sub trie with utf8 key 
    
    *key = Ascii("cde") 
    sq\set(SubTrieA,*key,4,#PB_Ascii) ;add to sub trie with ascii key    
    
    PrintN("value from ascii key " + Str(sq\Get(SubTrieA,*key,#PB_Ascii)))  ;get the value from the ascci key  
    
    key = "abc"                              
    PrintN("value from unicode key " + Str(sq\Get(SubTrieA,@key)))            ;get the unicode key  
    
    PrintN("the stored node aka subtrieA: = " + Str(SubTrieA))   
    PrintN(" look up subtrie node " + Str( sq\Get(0,@"subtrieA:",#PB_Unicode,0)))   
    PrintN(" look up its value  " +   Str(sq\Get(0,@"subtrieA:")))  
    
    PrintN("___ENUM from stored pointer to subtrieA")
    key = "ab"
    sq\EnumNode(SubTrieA,@key,@CBSquint())                 ;returns the root key + sub keys   
    
    key.s = "subtrie_b_"                      ;test raw access no interface   
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
    
    PrintN("-----merge----------") 
    
    Global sq1.isquint = SquintNew()
    
    key = "merge123"
    sq1\Set(0,@key,123) 
    key= "merge234" 
    sq1\Set(0,@key,234) 
    key= "merge345" 
    sq1\Set(0,@key,345) 
    
    sq1\Merge(sq) 
    
    PrintN("++++dump whole trie +++++")
    SquintWalkNode(sq,0,@CBSquint())   
    
    sq\Free()
    
     Procedure CBSquintWalkNum(*key.Integer,value,*userData)
      PrintN(Str(*key\i) + " " + Str(value))  
    EndProcedure
    
    
    
    sq.isquint = SquintNew()
    
    PrintN("-------Numeric------------") 
    
    
    sq\SetNumeric(-1,12345)                ;Add numeric keys   
    sq\SetNumeric(34567,34567)
    sq\SetNumeric(23456,23456) 
    sq\SetNumeric(12345,12345) 
    
    
    PrintN("get numeric key " + Str(sq\GetNumeric(34567)))                ;test get numeric    
    
    PrintN("-------Walk numeric ----") 
    sq\WalkNumeric(@CBSquintWalkNum())           ;walk the numeric they return in sorted order     
    
    sq\Free() 
       
    
    sq.isquint = SquintNew()
    sq\SetNumeric(1,123,4)
    sq\SetNumeric(4,456,4)
    sq\SetNumeric(8,8910,4)
    
   
    PrintN(Str(sq\GetNumeric(1,4))) 
    PrintN(Str(sq\GetNumeric(2,4))) 
    PrintN(Str(sq\GetNumeric(4,4))) 
    PrintN(Str(sq\GetNumeric(6,4))) 
    PrintN(Str(sq\GetNumeric(8,4))) 
    
    PrintN("-------Walk numeric ----") 
    sq\WalkNumeric(@CBSquintWalkNum(),4)      
    
    *rd = AllocateMemory(256) 
    RandomSeed(1) 
    For a = 1 To 100 
      RandomData(*rd,256)
      sq\SetNumeric(*rd,a,256,1) 
      sum+a
    Next  
    RandomSeed(1) 
    ct=0
    For a = 1 To 100 
      RandomData(*rd,256)
      ct + sq\GetNumeric(*rd,256,1) 
    Next  
    Debug ct 
    Debug sum 
    
    sq\Free()   
    
    Input() 
    
  CompilerElse 
    
    Global Enumkey 
    
    Procedure CBEnum(*key,*value,*userData.integer)  
      Protected sout.s  
      sout = PeekS(*key,-1,#PB_UTF8)
      *userData\i + 1 
      Enumkey + StringByteLength(sout) 
      ProcedureReturn 1 
    EndProcedure
    
    Procedure CBWalk(*key,value,*userData.Integer)
      
      *userData\i + 1 
      Enumkey + 4 
      ProcedureReturn 1 
      
    EndProcedure
        
    OpenConsole()
    
    #TestNumeric = 1
    #Randomkeys = 1
        
    Global lt = 1 ;<< 22  
    
    Global gQuit,lt,a,num,memsize 
    Global keylen,avgkeylen  
    Global start = CreateSemaphore()
    Global gcount, gnum = (1 << 24)
    Global gmask = gnum-1
    Global Dim gkeys.s(gnum) 
        
    sq.isquint = SquintNew()
    
    Global NUMTHREADS = CountCPUs(#PB_System_CPUs) 
    
    If NUMTHREADS < 6 
      MessageRequester("Squint thread tests", "system doesn't have enough core threads for tests") 
      NUMTHREADS = 6   
    EndIf   
    
    If MessageRequester("begin test","Num items " + FormatNumber(lt,0,".",",") + " lookups over 1 second",#PB_MessageRequester_YesNo) <> #PB_MessageRequester_Yes     
      End 
    EndIf  
    
   ; RandomSeed(124)
    
    For a = 1 To gnum 
      CompilerIf #Randomkeys  
        gkeys(a) = Hex(Random($ffffffff,$ffff)) ;key's may not exist 
      CompilerElse   
        gkeys(a) = Hex(Random(lt,1))            ;keys most likely exist 
      CompilerEndIf    
    Next      
    
    For gcount = 1 To lt 
      CompilerIf #Randomkeys  
        num = Random($ffffffff,$ffff) ;key's may not exist 
      CompilerElse   
        num = Random(lt,1) ;keys most likely exist 
      CompilerEndIf    
      key = gkeys(gcount);
      CompilerIf #TestNumeric 
        keylen+4 
        sq\SetNumeric(num,1,4) 
      CompilerElse   
        
        keylen+StringByteLength(key) 
        sq\Set(0,@key,Val(key))
      CompilerEndIf 
    Next  
    gcount-1
    
    Global readkey,writekey 
    
    Procedure _Read(*ct.integer) 
      Protected key.s,num.i,ct,x=0,cx=0  
      
      WaitSemaphore(start) 
      
      Repeat 
        
        CompilerIf #Randomkeys  
          num = Random($ffffffff,$ffff) ;key's may not exist 
        CompilerElse   
          num = Random(lt,1) ;keys most likely exist 
        CompilerEndIf    
        
        CompilerIf #TestNumeric  
          x = SquintGetNumeric(sq,num,4)
          cx = (1 | x)   
          readkey+4
        CompilerElse   
          key = Hex(num)
          x = SquintGetNode(sq,0,@key) 
          cx = (1 | x)   
          readkey+StringByteLength(key)
        CompilerEndIf   
        *ct\i + 1
        
      Until gQuit  
      
    EndProcedure 
    
    Procedure _write(*ct.integer) 
      Protected key.s, num,ct,len   
      num=*ct\i
      WaitSemaphore(start) 
      
      Repeat 
        
        num+2
        num & gmask      
        
        CompilerIf #TestNumeric  
          SquintSetNumeric(sq,num,*ct\i,4)  
          keylen + 4 
          writekey+ 4 
        CompilerElse   
          key = gkeys(num) 
         If SquintSetNode(sq,0,@key,Val(key))
            len = StringByteLength(key)
            keylen + len
            writekey + Len
          Else 
            PrintN("Set Error")
          EndIf   
          
        CompilerEndIf   
        
        *ct\i + 1 
        
      Until gQuit  
      
    EndProcedure  
    
    Procedure _Enum(*ct.integer) 
      Protected a,ct1,ct,num,key.s  
      
      WaitSemaphore(start) 
      
      Repeat
        CompilerIf #TestNumeric = 0 
          num = Random(gnum,1) 
          key = Left(gkeys(num),3) 
          If key <> "" 
            sq\EnumNode(0,@key,@CBEnum(),*ct)
          EndIf   
        CompilerElse 
          sq\WalkNumeric(@CBWalk(),4,*ct)
        CompilerEndIf  
        
      Until gquit  
      
    EndProcedure   
    
    Structure tdata 
      type.s
      count.l 
    EndStructure   
    
    Global Dim counts.tdata(NUMTHREADS) 
    Global Dim threads(NUMTHREADS) 
    
    For a = 0 To NUMTHREADS-5
      counts(a)\type = "Read"
      threads(a) = CreateThread(@_read(),@counts(a)\count) 
    Next 
    counts(a)\type = "Write" 
    Threads(a) = CreateThread(@_write(),@counts(a)\count) 
    a+1
    counts(a)\type = "Write" 
    counts(a)\count = 1
    Threads(a) = CreateThread(@_write(),@counts(a)\count) 
    a+1
    counts(a)\type = "Enum" 
    Threads(a) = CreateThread(@_enum(),@counts(a)\count) 
    a+1
    counts(a)\type = "Enum" 
    Threads(a) = CreateThread(@_enum(),@counts(a)\count) 
    
   If MessageRequester("begin","Num items " + FormatNumber(lt,0,".",",") + " lookups over 1 second",#PB_MessageRequester_YesNo) <> #PB_MessageRequester_Yes     
     End 
   EndIf 
    
    For a = 0 To NUMTHREADS-1 
      SignalSemaphore(start)
    Next  
    
    Delay(1000) 
    
    gquit=1 
    
    For a = 0 To NUMTHREADS-1 
      If IsThread(threads(a)) 
        WaitThread(threads(a)) 
      EndIf   
    Next 
    
    Global out.s, totalread, avgread, tout.s  
    Global totalwrite,totalenum,avgwrite,avgenum,totalkeys 
    
    For a = 0 To ArraySize(counts())-1 
      If counts(a)\type = "Read"
        totalread + counts(a)\count  
        
      ElseIf counts(a)\type = "Write" 
        totalwrite + counts(a)\count
      Else 
        totalenum + counts(a)\count 
      EndIf   
      tout + counts(a)\type + " thread " + Str(a) + " " +  FormatNumber(counts(a)\count,0,".",",") + #CRLF$
    Next 
    
    totalkeys + totalread + totalwrite + totalenum   
        
    out +  "Number of Keys " + FormatNumber(SquintNumKeys(sq),0,".",",")  + #CRLF$
    out +  "Memory " + StrF(sq\Size() / (1024*1024),2) + "mb" + #CRLF$
    out +  "Keysize " + StrF(keylen/(1024*1024),2) + " mb"  + #CRLF$
    out +  "Overhead " + StrF((sq\Size() / (1024*1024)) / (keylen/(1024*1024))) + #CRLF$
    out +  #CRLF$
    out +  "Total Keys " +  FormatNumber(totalkeys,0,"",",") + " p/s" + #CRLF$ 
    out +  "Lookup Keys " + FormatNumber(totalread,0) + " p/s" + #CRLF$
    out +  "Lookup Rate " + FormatNumber(readkey/1024/1024,2,".",",") + " mb p/s"  + #CRLF$
    out +  "Lookup Time " + FormatNumber((1.0/totalread)*1000000000 ,2,".",",") + " ns"  + #CRLF$
    out +  "Write Keys " + FormatNumber(totalwrite,0) + " p/s" + #CRLF$
    out +  "Write Rate " +  FormatNumber(writekey/1024/1024,2,".",",") + " mb p/s"  + #CRLF$
    out +  "Write Time " + FormatNumber((1.0/totalwrite)*1000000 ,2,".",",") + " " + Chr(181) + "s" + #CRLF$
    out +  "Enums Keys " +  FormatNumber(totalenum,0) + #CRLF$
    out +  "Enum Rate "  +  FormatNumber(Enumkey/1024/1024,2,".",",") + " mb p/s"  + #CRLF$ 
    out +  #CRLF$
          
    out + tout 
    Print(out) 
    SetClipboardText(out)
    
    MessageRequester("threads",out) 
    
  CompilerEndIf  
  
CompilerEndIf   
