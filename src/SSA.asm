

 %include "../EBNF/EBNFix.asm"
;------------------------------------------------------------------------------
section .bss

aBitMap0 	resq	1
aBitMap1	resq	1
aBitMap48	resq	1
aBitMap488	resq	1

aBitMapCur	resq	1
;------------------------------------------------------------------------------
section .text
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; candidates for the EBNFKernel
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

LIStore: ; Store LstIn at inline address
	; usage: LIStore(<address>)
	; uses :rax, rsi, rdi, rdx
	pop rsi
	lodsq
	mov rdi, rax
	push rsi
	mov rsi, rLastIn
	mov rdx, rLastInLen
	add rdi, rdx
	cld
LIStr1:	dec rdi
	lodsb
	mov [rdi],al
	dec rdx
	jnz LIStr1
	ret

;------------------------------------------------------------------------------
TapMsg: ; Display txt by pOut between TapMsg and MsgTap
	; Usage: TapMsg <code with pOut> MsgTap
	; Condition: code should not extend stack
	
	pop rbx
	push rOutPnt
	jmp rbx

MsgTap: pop rbx
	pop rsi
	push rbx
	mov rdx, rOutPnt
	sub rdx, rsi
	call MessageMem
	ret

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
SetBitMapCur:
	; usage: SetBitMapCur(x) where x= e.g *aBitMap0
	
	pop rsi
	mov rdi, aBitMapCur
	cld
	movsq
	jmp rsi
;------------------------------------------------------------------------------
ShowBitMap0:
	mov rdi, rOutPnt
	mov rdx, [aBitMapCur]
	mov rdx, [rdx]
	xor rcx, rcx
	cld
ShowB2:	inc rcx
	shl rdx, 1
	jnc ShowB1
	mov rax, rcx
	call Bin2Dec
	mov al, " "
	stosb
ShowB1:	cmp rcx, 64	
	jnz ShowB2
	mov rOutPnt, rdi
	inc rcx
	dec rOutPnt
	ret
;------------------------------------------------------------------------------

ShowBitMap1:
	mov rdi, rOutPnt
	mov rdx, [aBitMap1]
	xor rcx, rcx
	cld
ShwB12:	inc rcx
	shl rdx, 1
	jnc ShwB11
	mov rax, rcx
	add rax, 64
	call Bin2Dec
	mov al, " "
	stosb
ShwB11:	cmp rcx, 64
	jnz ShwB12
	mov rOutPnt, rdi
	inc rcx
	dec rOutPnt
	ret
;------------------------------------------------------------------------------
IsBit:	; usage: IsBit(n) or Call-db-statement)
	; out: rOk = nth bit of Bitmap0
	; uses rax
	; mod 64, to keep references in line with IFSF
	; above 64, be sure to have set BitMap current
	
	pop rsi
	cld
	lodsq
	and rax, 0x3ff
	mov rdx,64	
	sub rdx, rax
	mov rax, [aBitMapCur]
	mov rax, [rax]
 	xor rcx, rcx
	bt rax,rdx
	jnc IsBt1

	inc rcx
IsBt1: jmp rsi
;------------------------------------------------------------------------------
IsBit1:	; usage: IsBit(n) or Call-db-statement)
	; out: rOk = nth bit of Bitmap0
	; uses rax
	
	pop rsi
	cld
	lodsq
	sub rax, 64
	and rax, 0x3ff		; mod 64, to keep references in line with IFSF
	mov rdx,64		; above 64, be sure to have set BitMap current
	sub rdx, rax
	mov rax, [aBitMap1]
 	xor rcx, rcx
	bt rax,rdx
	jnc IsBt11
	inc rcx
IsBt11: jmp rsi

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
an:
	call cPush
	call a
	jrcxz DL0000
	jmp DLEnd0000
DL0000:	inc rcx
	call cTop
	call n
DLEnd0000:
	call cDrop
	ret

;an	= a | n;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
anp:
	call cPush
	call an
	jrcxz DL0001
	jmp DLEnd0001
DL0001:	inc rcx
	call cTop
	call pIn
	 db 0x0001, " "
DLEnd0001:
	call cDrop
	ret

;anp	= an | " ";

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ans:
	call cPush
	call an
	jrcxz DL0002
	jmp DLEnd0002
DL0002:	inc rcx
	call cTop
	call s
DLEnd0002:
	call cDrop
	ret

;ans	= an | s ;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ansb:
	call cPush
	call pInterval
	 db 0, 255
	call cDrop
	ret

;ansb	= ^0..^255;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
as:
	call cPush
	call a
	jrcxz DL0003
	jmp DLEnd0003
DL0003:	inc rcx
	call cTop
	call s
DLEnd0003:
	call cDrop
	ret

;as	= a | s;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
CCYY:
	call cPush
	mov rFactCnt, 4
	or rFactCnt, rFactCnt
	jz FacEnd0004
FacRep0004:
	call n
	dec rFactCnt
	jrcxz FacEnd0004
	jz FacEnd0004
	jmp FacRep0004
FacEnd0004:
	call cDrop
	ret

;CCYY	= 4*n;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
YY:
	call cPush
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd0005
FacRep0005:
	call n
	dec rFactCnt
	jrcxz FacEnd0005
	jz FacEnd0005
	jmp FacRep0005
FacEnd0005:
	call cDrop
	ret

;YY	= 2*n;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
DD:
	call cPush
	call cPush
	call pIn
	 db 0x0001, "0"
	or rPOk, rPOk
	jnz SD0006
	jmp SDEnd0006
SD0006:
	call pInterval
	 db "1", "9"
SDEnd0006:
	call cDrop
	jrcxz DL0007
	jmp DLEnd0007
DL0007:	inc rcx
	call cTop
	call cPush
	call pInterval
	 db "1", "2"
	or rPOk, rPOk
	jnz SD0008
	jmp SDEnd0008
SD0008:
	call pInterval
	 db "0", "9"
SDEnd0008:
	call cDrop
	jrcxz DL0009
	jmp DLEnd0007
DL0009:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "30"
	jrcxz DL000A
	jmp DLEnd0007
DL000A:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "31"
DLEnd0007:
	call cDrop
	ret

;DD	= ("0", "1".."9")|("1".."2","0".."9")|"30"|"31";

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
hh:
	call cPush
	call pInterval
	 db "0", "1"
	or rPOk, rPOk
	jnz SD000B
	jmp SDEnd000B
SD000B:
	call pInterval
	 db "0", "9"
SDEnd000B:
	jrcxz DL000C
	jmp DLEnd000C
DL000C:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "1"
	or rPOk, rPOk
	jnz SD000D
	jmp SDEnd000D
SD000D:
	call pInterval
	 db "0", "9"
SDEnd000D:
	jrcxz DL000E
	jmp DLEnd000C
DL000E:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "2"
	or rPOk, rPOk
	jnz SD000F
	jmp SDEnd000F
SD000F:
	call pInterval
	 db "0", "3"
SDEnd000F:
DLEnd000C:
	call cDrop
	ret

;hh	= "0".."1", "0".."9"|"1","0".."9"|"2","0".."3";

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
LVAR:
	call cPush
	call n
	call cDrop
	ret

;LVAR	= n;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
LLVAR:
	call cPush
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd0010
FacRep0010:
	call n
	dec rFactCnt
	jrcxz FacEnd0010
	jz FacEnd0010
	jmp FacRep0010
FacEnd0010:
	call cDrop
	ret

;LLVAR	= 2*n;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
LLLVAR:
	call cPush
	mov rFactCnt, 3
	or rFactCnt, rFactCnt
	jz FacEnd0011
FacRep0011:
	call n
	dec rFactCnt
	jrcxz FacEnd0011
	jz FacEnd0011
	jmp FacRep0011
FacEnd0011:
	call cDrop
	ret

;LLLVAR	= 3*n;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
MM:
	call cPush
	call pIn
	 db 0x0001, "0"
	or rPOk, rPOk
	jnz SD0012
	jmp SDEnd0012
SD0012:
	call pInterval
	 db "1", "9"
SDEnd0012:
	jrcxz DL0013
	jmp DLEnd0013
DL0013:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "1"
	or rPOk, rPOk
	jnz SD0014
	jmp SDEnd0014
SD0014:
	call pInterval
	 db "0", "2"
SDEnd0014:
DLEnd0013:
	call cDrop
	ret

;MM	= "0", "1".."9"|"1", "0".."2";

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
mm:
	call cPush
	call pInterval
	 db "0", "5"
	or rPOk, rPOk
	jnz SD0015
	jmp SDEnd0015
SD0015:
	call pInterval
	 db "0", "9"
SDEnd0015:
	call cDrop
	ret

;mm	= "0".."5","0".."9";
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ns:
	call cPush
	call n
	jrcxz DL0016
	jmp DLEnd0016
DL0016:	inc rcx
	call cTop
	call s
DLEnd0016:
	call cDrop
	ret

;ns	= n|s;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
p:
	call cPush
	call pIn
	 db 0x0001, " "
	call cDrop
	ret

;p	= " ";

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
s:
	call cPush
	call pInterval
	 db 10, 255
	call cDrop
	ret

;s	= ^10..^255;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
nss:
	call cPush
	call pInterval
	 db "0", "5"
	or rPOk, rPOk
	jnz SD0017
	jmp SDEnd0017
SD0017:
	call pInterval
	 db "0", "9"
SDEnd0017:
	call cDrop
	ret

;nss	= "0".."5","0".."9";

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
HexDig:
	call cPush
	call pInterval
	 db "0", "9"
	jrcxz DL0018
	jmp DLEnd0018
DL0018:	inc rcx
	call cTop
	call pInterval
	 db "A", "F"
	jrcxz DL0019
	jmp DLEnd0018
DL0019:	inc rcx
	call cTop
	call pInterval
	 db "a", "f"
DLEnd0018:
	call cDrop
	ret

;HexDig	= "0".."9"|"A".."F"|"a".."f";
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Rum:
	call cPush
	call Message
	 db 0x0A, 'Starting..'
	or rPOk, rPOk
	jnz SD001A
	jmp SDEnd001A
SD001A:
	push 1
	call sCLArg
	call F2I
	or rPOk, rPOk
	jnz SD001B
	jmp SDEnd001A
SD001B:
	call Message
	 db 0x1F, 'Loaded source..Compiled items: '
	or rPOk, rPOk
	jnz SD001C
	jmp SDEnd001A
SD001C:
	push Grammar
	call I2O
	or rPOk, rPOk
	jnz SD001D
	jmp SDEnd001A
SD001D:
	call Message
	 db 0x0C, 'Grammar OK..'
	or rPOk, rPOk
	jnz SD001E
	jmp SDEnd001A
SD001E:
	push 1
	call sCLArg
	call sPush
	 db 0x0005, '.json'
	call sConcat
	call O2F
	or rPOk, rPOk
	jnz SD001F
	jmp SDEnd001A
SD001F:
	call Message
	 db 0x16, 'Saved object.. Done !', 0x0A
SDEnd001A:
	jrcxz DL0020
	jmp DLEnd0020
DL0020:	inc rcx
	call cTop
	call ErrorMessage
	 db 0x0E, 'Aj, some error'
DLEnd0020:
	call cDrop
	ret

;Rum	 = 	Message('Starting..')	, F2I (sCLArg(1))			, Message('Loaded source..Compiled items: ')
;					, I2O (*Grammar)			, Message('Grammar OK..')
;					, O2F (sConcat(sCLArg(1),'.json'))	, Message('Saved object.. Done !', 0x0A)
;    					| ErrorMessage('Aj, some error');
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Grammar:
	call cPush
	call pOut
	 db 0x0F, '{"TrxStream":{', 0x0A
	or rPOk, rPOk
	jnz SD0021
	jmp SDEnd0021
SD0021:
	call cPush
RSRep0024:
	call cPush
	call Msg
	or rPOk, rPOk
	jnz SD0025
	jmp SDEnd0025
SD0025:
	call pOut
	 db 0x03, '},', 0x0a
SDEnd0025:
	call cDrop
	jrcxz RSEnd0024
	or rInEndFlg, rInEndFlg
	jnz RSEnd0024
	jmp RSRep0024
RSEnd0024:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD0026
	jmp SDEnd0021
SD0026:
	call cPush
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd0027
FacRep0027:
	call DropLastChar
	dec rFactCnt
	jrcxz FacEnd0027
	jz FacEnd0027
	jmp FacRep0027
FacEnd0027:
	call cDrop
	or rPOk, rPOk
	jnz SD0028
	jmp SDEnd0021
SD0028:
	call pOut
	 db 0x04, 0x0a, '}}', 0x0a
SDEnd0021:
	call cDrop
	ret

;Grammar	= 		 pOut('{"TrxStream":{', 0x0A),
;	  { Msg		,pOut('},', 0x0a) 
;		}, 
;	  (2*DropLastChar), pOut(0x0a, '}}', 0x0a);
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Msg:
	call cPush
	call cPush
	call MTI
	or rPOk, rPOk
	jnz SD0029
	jmp SDEnd0029
SD0029:
	call pOut
	 db 0x01, '{'
	or rPOk, rPOk
	jnz SD002A
	jmp SDEnd0029
SD002A:
	call Message
	 db 0x02, ": "
	or rPOk, rPOk
	jnz SD002B
	jmp SDEnd0029
SD002B:
	xor rax,rax
	mov [aBitMap0]  ,rax
	mov [aBitMap1]  ,rax
	mov [aBitMap48] ,rax
	mov [aBitMap488],rax
	or rPOk, rPOk
	jnz SD002C
	jmp SDEnd0029
SD002C:
	call BitMap0
	or rPOk, rPOk
	jnz SD002D
	jmp SDEnd0029
SD002D:
	call Fields0
SDEnd0029:
	call cDrop
	jrcxz DL002E
	jmp DLEnd002E
DL002E:	inc rcx
	call cTop
	call Message
	 db 1, ","
	call pOut
	 db 5, '"?":"'
	call cPush
	call anp
	or rPOk, rPOk
	jnz SD002F
	jmp SDEnd002F
SD002F:
	call pOutLI
SDEnd002F:
	jrcxz DL0030
	jmp DLEnd0030
DL0030:	inc rcx
	call cTop
	call b
	or rPOk, rPOk
	jnz SD0031
	jmp SDEnd0031
SD0031:
	call pOutLIHex
SDEnd0031:
DLEnd0030:
	call cDrop
	or rPOk, rPOk
	jnz SD0032
	jmp SDEnd0032
SD0032:
	call pOut
	 db 0x01, '"'
SDEnd0032:
DLEnd002E:
	call cDrop
	ret

;Msg = (	MTI, pOut ('{'), Message (": "),
;					 <.	xor rax,rax.>
;					 <.	mov [aBitMap0]  ,rax.>
;					 <.	mov [aBitMap1]  ,rax.>
;					 <.	mov [aBitMap48] ,rax.>
;					 <.	mov [aBitMap488],rax.>
;	    , BitMap0, Fields0 )| 	<<	call Message>>
;	    				<<	 db 1, ",">>
;	    				<<	call pOut>>
;	    				<<	 db 5, '"?":"'>>
;	    		 	  (anp, pOutLI| b, pOutLIHex), pOut('"') ;
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
MTI:
	call cPush
	call Message
	 db 0x01, 0x0a
	or rPOk, rPOk
	jnz SD0033
	jmp SDEnd0033
SD0033:
	call pIn
	 db 0x0004, "1100"
	or rPOk, rPOk
	jnz SD0034
	jmp SDEnd0033
SD0034:
	call pOut
	 db 0x1D, 0x0a, '"1100 AuthorizationRequest":'
	or rPOk, rPOk
	jnz SD0035
	jmp SDEnd0033
SD0035:
	call MsgLI
SDEnd0033:
	jrcxz DL0036
	jmp DLEnd0036
DL0036:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1110"
	or rPOk, rPOk
	jnz SD0037
	jmp SDEnd0037
SD0037:
	call pOut
	 db 0x1E, 0x0a, '"1110 AuthorizationResponse":'
	or rPOk, rPOk
	jnz SD0038
	jmp SDEnd0037
SD0038:
	call MsgLI
SDEnd0037:
	jrcxz DL0039
	jmp DLEnd0036
DL0039:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1200"
	or rPOk, rPOk
	jnz SD003A
	jmp SDEnd003A
SD003A:
	call pOut
	 db 0x17, 0x0a, '"1200 PaymentRequest":'
	or rPOk, rPOk
	jnz SD003B
	jmp SDEnd003A
SD003B:
	call MsgLI
SDEnd003A:
	jrcxz DL003C
	jmp DLEnd0036
DL003C:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1210"
	or rPOk, rPOk
	jnz SD003D
	jmp SDEnd003D
SD003D:
	call pOut
	 db 0x18, 0x0a, '"1210 PaymentResponse":'
	or rPOk, rPOk
	jnz SD003E
	jmp SDEnd003D
SD003E:
	call MsgLI
SDEnd003D:
	jrcxz DL003F
	jmp DLEnd0036
DL003F:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1220"
	or rPOk, rPOk
	jnz SD0040
	jmp SDEnd0040
SD0040:
	call pOut
	 db 0x1A, 0x0a, '"1220 TransactionAdvice":'
	or rPOk, rPOk
	jnz SD0041
	jmp SDEnd0040
SD0041:
	call MsgLI
SDEnd0040:
	jrcxz DL0042
	jmp DLEnd0036
DL0042:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1221"
	or rPOk, rPOk
	jnz SD0043
	jmp SDEnd0043
SD0043:
	call pOut
	 db 0x20, 0x0a, '"1221 TransactionAdviceRepeat":'
	or rPOk, rPOk
	jnz SD0044
	jmp SDEnd0043
SD0044:
	call MsgLI
SDEnd0043:
	jrcxz DL0045
	jmp DLEnd0036
DL0045:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1230"
	or rPOk, rPOk
	jnz SD0046
	jmp SDEnd0046
SD0046:
	call pOut
	 db 0x1E, 0x0a, '"1230 AuthorizationResponse":'
	or rPOk, rPOk
	jnz SD0047
	jmp SDEnd0046
SD0047:
	call MsgLI
SDEnd0046:
	jrcxz DL0048
	jmp DLEnd0036
DL0048:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1420"
	or rPOk, rPOk
	jnz SD0049
	jmp SDEnd0049
SD0049:
	call pOut
	 db 0x17, 0x0a, '"1420 ReversalAdvice":'
	or rPOk, rPOk
	jnz SD004A
	jmp SDEnd0049
SD004A:
	call MsgLI
SDEnd0049:
	jrcxz DL004B
	jmp DLEnd0036
DL004B:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1421"
	or rPOk, rPOk
	jnz SD004C
	jmp SDEnd004C
SD004C:
	call pOut
	 db 0x1D, 0x0a, '"1421 ReversalAdviceRepeat":'
	or rPOk, rPOk
	jnz SD004D
	jmp SDEnd004C
SD004D:
	call MsgLI
SDEnd004C:
	jrcxz DL004E
	jmp DLEnd0036
DL004E:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1430"
	or rPOk, rPOk
	jnz SD004F
	jmp SDEnd004F
SD004F:
	call pOut
	 db 0x1F, 0x0a, '"1430 ReversalAdviceResponse":'
	or rPOk, rPOk
	jnz SD0050
	jmp SDEnd004F
SD0050:
	call MsgLI
SDEnd004F:
	jrcxz DL0051
	jmp DLEnd0036
DL0051:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1520"
	or rPOk, rPOk
	jnz SD0052
	jmp SDEnd0052
SD0052:
	call pOut
	 db 0x1D, 0x0a, '"1520 ReconciliationAdvice":'
	or rPOk, rPOk
	jnz SD0053
	jmp SDEnd0052
SD0053:
	call MsgLI
SDEnd0052:
	jrcxz DL0054
	jmp DLEnd0036
DL0054:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1530"
	or rPOk, rPOk
	jnz SD0055
	jmp SDEnd0055
SD0055:
	call pOut
	 db 0x25, 0x0a, '"1530 ReconciliationAdviceResponse":'
	or rPOk, rPOk
	jnz SD0056
	jmp SDEnd0055
SD0056:
	call MsgLI
SDEnd0055:
	jrcxz DL0057
	jmp DLEnd0036
DL0057:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1820"
	or rPOk, rPOk
	jnz SD0058
	jmp SDEnd0058
SD0058:
	call pOut
	 db 0x20, 0x0a, '"1820 NetworkManagementAdvice":'
	or rPOk, rPOk
	jnz SD0059
	jmp SDEnd0058
SD0059:
	call MsgLI
SDEnd0058:
	jrcxz DL005A
	jmp DLEnd0036
DL005A:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1821"
	or rPOk, rPOk
	jnz SD005B
	jmp SDEnd005B
SD005B:
	call pOut
	 db 0x26, 0x0a, '"1821 NetworkManagementAdviceRepeat":'
	or rPOk, rPOk
	jnz SD005C
	jmp SDEnd005B
SD005C:
	call MsgLI
SDEnd005B:
	jrcxz DL005D
	jmp DLEnd0036
DL005D:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1830"
	or rPOk, rPOk
	jnz SD005E
	jmp SDEnd005E
SD005E:
	call pOut
	 db 0x28, 0x0a, '"1830 NetworkManagementAdviceResponse":'
	or rPOk, rPOk
	jnz SD005F
	jmp SDEnd005E
SD005F:
	call MsgLI
SDEnd005E:
	jrcxz DL0060
	jmp DLEnd0036
DL0060:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "9100"
	or rPOk, rPOk
	jnz SD0061
	jmp SDEnd0061
SD0061:
	call pOut
	 db 0x23, 0x0a, '"9100 IndoorAuthorizationRequest":'
	or rPOk, rPOk
	jnz SD0062
	jmp SDEnd0061
SD0062:
	call MsgLI
SDEnd0061:
	jrcxz DL0063
	jmp DLEnd0036
DL0063:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "9110"
	or rPOk, rPOk
	jnz SD0064
	jmp SDEnd0064
SD0064:
	call pOut
	 db 0x24, 0x0a, '"9110 IndoorAuthorizationResponse":'
	or rPOk, rPOk
	jnz SD0065
	jmp SDEnd0064
SD0065:
	call MsgLI
SDEnd0064:
DLEnd0036:
	call cDrop
	ret

;MTI = 	Message (0x0a),
;	"1100"		,pOut(0x0a, '"1100 AuthorizationRequest":') 		,MsgLI	|
;	"1110"		,pOut(0x0a, '"1110 AuthorizationResponse":')		,MsgLI	|
;	"1200"		,pOut(0x0a, '"1200 PaymentRequest":')			,MsgLI	|
;	"1210"		,pOut(0x0a, '"1210 PaymentResponse":')			,MsgLI	|
;	"1220"		,pOut(0x0a, '"1220 TransactionAdvice":')		,MsgLI	|
;	"1221"		,pOut(0x0a, '"1221 TransactionAdviceRepeat":')		,MsgLI	|
;	"1230"		,pOut(0x0a, '"1230 AuthorizationResponse":')		,MsgLI	|
;	"1420"		,pOut(0x0a, '"1420 ReversalAdvice":')			,MsgLI	|
;	"1421"		,pOut(0x0a, '"1421 ReversalAdviceRepeat":')		,MsgLI	|
;	"1430"		,pOut(0x0a, '"1430 ReversalAdviceResponse":') 		,MsgLI	|
;	"1520"		,pOut(0x0a, '"1520 ReconciliationAdvice":') 		,MsgLI	|
;	"1530"		,pOut(0x0a, '"1530 ReconciliationAdviceResponse":') 	,MsgLI	|
;	"1820"		,pOut(0x0a, '"1820 NetworkManagementAdvice":')		,MsgLI	|
;	"1821"		,pOut(0x0a, '"1821 NetworkManagementAdviceRepeat":')	,MsgLI	|
;	"1830"		,pOut(0x0a, '"1830 NetworkManagementAdviceResponse":')	,MsgLI	|
;	"9100"		,pOut(0x0a, '"9100 IndoorAuthorizationRequest":') 	,MsgLI	|
;	"9110"		,pOut(0x0a, '"9110 IndoorAuthorizationResponse":')	,MsgLI	;
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
BitMap0:
	call cPush
	call cPush
	mov rFactCnt, 8
	or rFactCnt, rFactCnt
	jz FacEnd0066
FacRep0066:
	call b
	dec rFactCnt
	jrcxz FacEnd0066
	jz FacEnd0066
	jmp FacRep0066
FacEnd0066:
	call cDrop
	or rPOk, rPOk
	jnz SD0067
	jmp SDEnd0067
SD0067:
	call LIStore
	 dq aBitMap0
	or rPOk, rPOk
	jnz SD0068
	jmp SDEnd0067
SD0068:
	call SetBitMapCur
	 dq aBitMap0
	or rPOk, rPOk
	jnz SD0069
	jmp SDEnd0067
SD0069:
	call pOut
	 db 0x0F, 0x0a, 0x09, '"BitMap0" : "'
	or rPOk, rPOk
	jnz SD006A
	jmp SDEnd0067
SD006A:
	call TapMsg
	call ShowBitMap0
	call Message
	 db 0x04, " B: "
	call MsgTap
	call pOut
	 db 0x02, '",'
SDEnd0067:
	call cDrop
	ret

;BitMap0  = (8*b)	, LIStore(*aBitMap0), SetBitMapCur(*aBitMap0)
;			, pOut(0x0a, 0x09, '"BitMap0" : "'),		TapMsg ShowBitMap0 Message(" B: ") 		MsgTap pOut('",') ;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
BitMap1:
	call cPush
	call cPush
	mov rFactCnt, 8
	or rFactCnt, rFactCnt
	jz FacEnd006B
FacRep006B:
	call b
	dec rFactCnt
	jrcxz FacEnd006B
	jz FacEnd006B
	jmp FacRep006B
FacEnd006B:
	call cDrop
	or rPOk, rPOk
	jnz SD006C
	jmp SDEnd006C
SD006C:
	call LIStore
	 dq aBitMap1
	or rPOk, rPOk
	jnz SD006D
	jmp SDEnd006C
SD006D:
	call pOut
	 db 0x0F, 0x0a, 0x09, '"BitMap1" : "'
	or rPOk, rPOk
	jnz SD006E
	jmp SDEnd006C
SD006E:
	call TapMsg
	call ShowBitMap1
	call Message
	 db 0x0B, 0x0a, "      B1: "
	call MsgTap
	call pOut
	 db 0x02, '",'
SDEnd006C:
	call cDrop
	ret

;BitMap1  = (8*b)	, LIStore(*aBitMap1)
;			, pOut(0x0a, 0x09, '"BitMap1" : "'),		TapMsg ShowBitMap1 Message(0x0a, "      B1: ")	MsgTap pOut('",') ;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
BitMap48:
	call cPush
	call cPush
	mov rFactCnt, 8
	or rFactCnt, rFactCnt
	jz FacEnd006F
FacRep006F:
	call b
	dec rFactCnt
	jrcxz FacEnd006F
	jz FacEnd006F
	jmp FacRep006F
FacEnd006F:
	call cDrop
	or rPOk, rPOk
	jnz SD0070
	jmp SDEnd0070
SD0070:
	call LIStore
	 dq aBitMap48
	or rPOk, rPOk
	jnz SD0071
	jmp SDEnd0070
SD0071:
	call SetBitMapCur
	 dq aBitMap48
	or rPOk, rPOk
	jnz SD0072
	jmp SDEnd0070
SD0072:
	call pOut
	 db 0x11, 0x0a, 0x09, 0x09, '"BitMap48" : "'
	or rPOk, rPOk
	jnz SD0073
	jmp SDEnd0070
SD0073:
	call TapMsg
	call ShowBitMap0
	call Message
	 db 0x0B, 0x0a, "     B48: "
	call MsgTap
	call pOut
	 db 0x02, '",'
SDEnd0070:
	call cDrop
	ret

;BitMap48 = (8*b)	, LIStore(*aBitMap48), SetBitMapCur(*aBitMap48) 
;			, pOut(0x0a, 0x09, 0x09, '"BitMap48" : "'),	TapMsg ShowBitMap0 Message(0x0a, "     B48: ")	MsgTap pOut('",') ;
;
;/*IFSF1997*/

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Fields0:
	call cPush
	call cPush
	call IsBit
	 dq 1
	or rPOk, rPOk
	jnz SD0074
	jmp SDEnd0074
SD0074:
	call BitMap1
SDEnd0074:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0075
	jmp SDEnd0075
SD0075:
	call cPush
	call IsBit
	 dq 2
	or rPOk, rPOk
	jnz SD0076
	jmp SDEnd0076
SD0076:
	call cPush
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep0077
	jmp FacEnd0077
FacRep0077:
	call ans
	dec rFactCnt
	jrcxz FacEnd0077
	jz FacEnd0077
	jmp FacRep0077
FacEnd0077:
	call cDrop
	or rPOk, rPOk
	jnz SD0078
	jmp SDEnd0076
SD0078:
	call pOut
	 db 0x19, 0x0a, 0x09, '"B02 PAN (manual)"		: "'
	or rPOk, rPOk
	jnz SD0079
	jmp SDEnd0076
SD0079:
	call pOutLI
	or rPOk, rPOk
	jnz SD007A
	jmp SDEnd0076
SD007A:
	call pOut
	 db 0x02, '",'
SDEnd0076:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD007B
	jmp SDEnd0075
SD007B:
	call cPush
	call IsBit
	 dq 3
	or rPOk, rPOk
	jnz SD007C
	jmp SDEnd007C
SD007C:
	call cPush
	mov rFactCnt, 6
	or rFactCnt, rFactCnt
	jz FacEnd007D
FacRep007D:
	call n
	dec rFactCnt
	jrcxz FacEnd007D
	jz FacEnd007D
	jmp FacRep007D
FacEnd007D:
	call cDrop
	or rPOk, rPOk
	jnz SD007E
	jmp SDEnd007C
SD007E:
	call pOut
	 db 0x1C, 0x0a, 0x09, '"B03 Processing code"		: {'
SDEnd007C:
	or rPOk, rPOk
	jnz AD007F
	jmp ADEnd007F
AD007F:
	call cAndProlog
	call Bit3
	call cAndEpilog
ADEnd007F:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0080
	jmp SDEnd0075
SD0080:
	call cPush
	call IsBit
	 dq 4
	or rPOk, rPOk
	jnz SD0081
	jmp SDEnd0081
SD0081:
	call cPush
	mov rFactCnt, 12
	or rFactCnt, rFactCnt
	jz FacEnd0082
FacRep0082:
	call n
	dec rFactCnt
	jrcxz FacEnd0082
	jz FacEnd0082
	jmp FacRep0082
FacEnd0082:
	call cDrop
	or rPOk, rPOk
	jnz SD0083
	jmp SDEnd0081
SD0083:
	call pOut
	 db 0x1E, 0x0a, 0x09, '"B04 Amount transaction"	: "'
	or rPOk, rPOk
	jnz SD0084
	jmp SDEnd0081
SD0084:
	call pOutLI
	or rPOk, rPOk
	jnz SD0085
	jmp SDEnd0081
SD0085:
	call pOut
	 db 0x01, "("
SDEnd0081:
	or rPOk, rPOk
	jnz AD0086
	jmp ADEnd0086
AD0086:
	call cAndProlog
	call cPush
	mov rFactCnt, 10
	or rFactCnt, rFactCnt
	jz FacEnd0087
FacRep0087:
	call n
	dec rFactCnt
	jrcxz FacEnd0087
	jz FacEnd0087
	jmp FacRep0087
FacEnd0087:
	call cDrop
	or rPOk, rPOk
	jnz SD0088
	jmp SDEnd0088
SD0088:
	call pOutLITrim
	or rPOk, rPOk
	jnz SD0089
	jmp SDEnd0088
SD0089:
	call pOut
	 db 0x01, "."
	or rPOk, rPOk
	jnz SD008A
	jmp SDEnd0088
SD008A:
	call cPush
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd008B
FacRep008B:
	call n
	dec rFactCnt
	jrcxz FacEnd008B
	jz FacEnd008B
	jmp FacRep008B
FacEnd008B:
	call cDrop
	or rPOk, rPOk
	jnz SD008C
	jmp SDEnd0088
SD008C:
	call pOutLI
	or rPOk, rPOk
	jnz SD008D
	jmp SDEnd0088
SD008D:
	call pOut
	 db 0x01, ")"
	or rPOk, rPOk
	jnz SD008E
	jmp SDEnd0088
SD008E:
	call pOut
	 db 0x02, '",'
SDEnd0088:
	call cAndEpilog
ADEnd0086:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD008F
	jmp SDEnd0075
SD008F:
	call cPush
	call IsBit
	 dq 5
	or rPOk, rPOk
	jnz SD0090
	jmp SDEnd0090
SD0090:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B05"				: "'
	or rPOk, rPOk
	jnz SD0091
	jmp SDEnd0090
SD0091:
	call pOut
	 db 0x02, '",'
SDEnd0090:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0092
	jmp SDEnd0075
SD0092:
	call cPush
	call IsBit
	 dq 6
	or rPOk, rPOk
	jnz SD0093
	jmp SDEnd0093
SD0093:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B06"				: "'
	or rPOk, rPOk
	jnz SD0094
	jmp SDEnd0093
SD0094:
	call pOut
	 db 0x02, '",'
SDEnd0093:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0095
	jmp SDEnd0075
SD0095:
	call cPush
	call IsBit
	 dq 7
	or rPOk, rPOk
	jnz SD0096
	jmp SDEnd0096
SD0096:
	call cPush
	mov rFactCnt, 10
	or rFactCnt, rFactCnt
	jz FacEnd0097
FacRep0097:
	call n
	dec rFactCnt
	jrcxz FacEnd0097
	jz FacEnd0097
	jmp FacRep0097
FacEnd0097:
	call cDrop
	or rPOk, rPOk
	jnz SD0098
	jmp SDEnd0096
SD0098:
	call pOut
	 db 0x22, 0x0a, 0x09, '"B07 Date time transmission"	: "'
SDEnd0096:
	or rPOk, rPOk
	jnz AD0099
	jmp ADEnd0099
AD0099:
	call cAndProlog
	call MM
	or rPOk, rPOk
	jnz SD009A
	jmp SDEnd009A
SD009A:
	call pOutLI
	or rPOk, rPOk
	jnz SD009B
	jmp SDEnd009A
SD009B:
	call pOut
	 db 0x01, '-'
	or rPOk, rPOk
	jnz SD009C
	jmp SDEnd009A
SD009C:
	call DD
	or rPOk, rPOk
	jnz SD009D
	jmp SDEnd009A
SD009D:
	call pOutLI
	or rPOk, rPOk
	jnz SD009E
	jmp SDEnd009A
SD009E:
	call pOut
	 db 0x01, 'T'
	or rPOk, rPOk
	jnz SD009F
	jmp SDEnd009A
SD009F:
	call hh
	or rPOk, rPOk
	jnz SD00A0
	jmp SDEnd009A
SD00A0:
	call pOutLI
	or rPOk, rPOk
	jnz SD00A1
	jmp SDEnd009A
SD00A1:
	call pOut
	 db 0x01, ':'
	or rPOk, rPOk
	jnz SD00A2
	jmp SDEnd009A
SD00A2:
	call mm
	or rPOk, rPOk
	jnz SD00A3
	jmp SDEnd009A
SD00A3:
	call pOutLI
	or rPOk, rPOk
	jnz SD00A4
	jmp SDEnd009A
SD00A4:
	call pOut
	 db 0x01, ':'
	or rPOk, rPOk
	jnz SD00A5
	jmp SDEnd009A
SD00A5:
	call nss
	or rPOk, rPOk
	jnz SD00A6
	jmp SDEnd009A
SD00A6:
	call pOutLI
	or rPOk, rPOk
	jnz SD00A7
	jmp SDEnd009A
SD00A7:
	call pOut
	 db 0x06, '.000",'
SDEnd009A:
	call cAndEpilog
ADEnd0099:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD00A8
	jmp SDEnd0075
SD00A8:
	call cPush
	call IsBit
	 dq 8
	or rPOk, rPOk
	jnz SD00A9
	jmp SDEnd00A9
SD00A9:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B08"				: "'
	or rPOk, rPOk
	jnz SD00AA
	jmp SDEnd00A9
SD00AA:
	call pOut
	 db 0x02, '",'
SDEnd00A9:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD00AB
	jmp SDEnd0075
SD00AB:
	call cPush
	call IsBit
	 dq 9
	or rPOk, rPOk
	jnz SD00AC
	jmp SDEnd00AC
SD00AC:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B09"				: "'
	or rPOk, rPOk
	jnz SD00AD
	jmp SDEnd00AC
SD00AD:
	call pOut
	 db 0x02, '",'
SDEnd00AC:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD00AE
	jmp SDEnd0075
SD00AE:
	call cPush
	call IsBit
	 dq 10
	or rPOk, rPOk
	jnz SD00AF
	jmp SDEnd00AF
SD00AF:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B10"				: "'
	or rPOk, rPOk
	jnz SD00B0
	jmp SDEnd00AF
SD00B0:
	call pOut
	 db 0x02, '",'
SDEnd00AF:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD00B1
	jmp SDEnd0075
SD00B1:
	call cPush
	call IsBit
	 dq 11
	or rPOk, rPOk
	jnz SD00B2
	jmp SDEnd00B2
SD00B2:
	call cPush
	mov rFactCnt, 6
	or rFactCnt, rFactCnt
	jz FacEnd00B3
FacRep00B3:
	call n
	dec rFactCnt
	jrcxz FacEnd00B3
	jz FacEnd00B3
	jmp FacRep00B3
FacEnd00B3:
	call cDrop
	or rPOk, rPOk
	jnz SD00B4
	jmp SDEnd00B2
SD00B4:
	call pOut
	 db 0x12, 0x0a, 0x09, '"B11 STAN"			: "'
	or rPOk, rPOk
	jnz SD00B5
	jmp SDEnd00B2
SD00B5:
	call pOutLI
	or rPOk, rPOk
	jnz SD00B6
	jmp SDEnd00B2
SD00B6:
	call pOut
	 db 0x02, '",'
SDEnd00B2:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD00B7
	jmp SDEnd0075
SD00B7:
	call cPush
	call IsBit
	 dq 12
	or rPOk, rPOk
	jnz SD00B8
	jmp SDEnd00B8
SD00B8:
	call cPush
	mov rFactCnt, 12
	or rFactCnt, rFactCnt
	jz FacEnd00B9
FacRep00B9:
	call n
	dec rFactCnt
	jrcxz FacEnd00B9
	jz FacEnd00B9
	jmp FacRep00B9
FacEnd00B9:
	call cDrop
	or rPOk, rPOk
	jnz SD00BA
	jmp SDEnd00B8
SD00BA:
	call pOut
	 db 0x23, 0x0a, 0x09, '"B12 Date time transaction"	: "20'
SDEnd00B8:
	or rPOk, rPOk
	jnz AD00BB
	jmp ADEnd00BB
AD00BB:
	call cAndProlog
	call YY
	or rPOk, rPOk
	jnz SD00BC
	jmp SDEnd00BC
SD00BC:
	call pOutLI
	or rPOk, rPOk
	jnz SD00BD
	jmp SDEnd00BC
SD00BD:
	call pOut
	 db 0x01, '-'
	or rPOk, rPOk
	jnz SD00BE
	jmp SDEnd00BC
SD00BE:
	call MM
	or rPOk, rPOk
	jnz SD00BF
	jmp SDEnd00BC
SD00BF:
	call pOutLI
	or rPOk, rPOk
	jnz SD00C0
	jmp SDEnd00BC
SD00C0:
	call pOut
	 db 0x01, '-'
	or rPOk, rPOk
	jnz SD00C1
	jmp SDEnd00BC
SD00C1:
	call DD
	or rPOk, rPOk
	jnz SD00C2
	jmp SDEnd00BC
SD00C2:
	call pOutLI
	or rPOk, rPOk
	jnz SD00C3
	jmp SDEnd00BC
SD00C3:
	call pOut
	 db 0x01, 'T'
	or rPOk, rPOk
	jnz SD00C4
	jmp SDEnd00BC
SD00C4:
	call hh
	or rPOk, rPOk
	jnz SD00C5
	jmp SDEnd00BC
SD00C5:
	call pOutLI
	or rPOk, rPOk
	jnz SD00C6
	jmp SDEnd00BC
SD00C6:
	call pOut
	 db 0x01, ':'
	or rPOk, rPOk
	jnz SD00C7
	jmp SDEnd00BC
SD00C7:
	call mm
	or rPOk, rPOk
	jnz SD00C8
	jmp SDEnd00BC
SD00C8:
	call pOutLI
	or rPOk, rPOk
	jnz SD00C9
	jmp SDEnd00BC
SD00C9:
	call pOut
	 db 0x01, ':'
	or rPOk, rPOk
	jnz SD00CA
	jmp SDEnd00BC
SD00CA:
	call nss
	or rPOk, rPOk
	jnz SD00CB
	jmp SDEnd00BC
SD00CB:
	call pOutLI
	or rPOk, rPOk
	jnz SD00CC
	jmp SDEnd00BC
SD00CC:
	call pOut
	 db 0x06, '.000",'
SDEnd00BC:
	call cAndEpilog
ADEnd00BB:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD00CD
	jmp SDEnd0075
SD00CD:
	call cPush
	call IsBit
	 dq 13
	or rPOk, rPOk
	jnz SD00CE
	jmp SDEnd00CE
SD00CE:
	call cPush
	mov rFactCnt, 4
	or rFactCnt, rFactCnt
	jz FacEnd00CF
FacRep00CF:
	call n
	dec rFactCnt
	jrcxz FacEnd00CF
	jz FacEnd00CF
	jmp FacRep00CF
FacEnd00CF:
	call cDrop
	or rPOk, rPOk
	jnz SD00D0
	jmp SDEnd00CE
SD00D0:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B13"				: "'
	or rPOk, rPOk
	jnz SD00D1
	jmp SDEnd00CE
SD00D1:
	call pOutLI
	or rPOk, rPOk
	jnz SD00D2
	jmp SDEnd00CE
SD00D2:
	call pOut
	 db 0x02, '",'
SDEnd00CE:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD00D3
	jmp SDEnd0075
SD00D3:
	call cPush
	call IsBit
	 dq 14
	or rPOk, rPOk
	jnz SD00D4
	jmp SDEnd00D4
SD00D4:
	call cPush
	mov rFactCnt, 4
	or rFactCnt, rFactCnt
	jz FacEnd00D5
FacRep00D5:
	call n
	dec rFactCnt
	jrcxz FacEnd00D5
	jz FacEnd00D5
	jmp FacRep00D5
FacEnd00D5:
	call cDrop
	or rPOk, rPOk
	jnz SD00D6
	jmp SDEnd00D4
SD00D6:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B14"				: "'
	or rPOk, rPOk
	jnz SD00D7
	jmp SDEnd00D4
SD00D7:
	call pOutLI
	or rPOk, rPOk
	jnz SD00D8
	jmp SDEnd00D4
SD00D8:
	call pOut
	 db 0x02, '",'
SDEnd00D4:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD00D9
	jmp SDEnd0075
SD00D9:
	call cPush
	call IsBit
	 dq 15
	or rPOk, rPOk
	jnz SD00DA
	jmp SDEnd00DA
SD00DA:
	call cPush
	mov rFactCnt, 6
	or rFactCnt, rFactCnt
	jz FacEnd00DB
FacRep00DB:
	call n
	dec rFactCnt
	jrcxz FacEnd00DB
	jz FacEnd00DB
	jmp FacRep00DB
FacEnd00DB:
	call cDrop
	or rPOk, rPOk
	jnz SD00DC
	jmp SDEnd00DA
SD00DC:
	call pOut
	 db 0x1C, 0x0a, 0x09, '"B15 Settlement date"		: "'
	or rPOk, rPOk
	jnz SD00DD
	jmp SDEnd00DA
SD00DD:
	call pOutLI
	or rPOk, rPOk
	jnz SD00DE
	jmp SDEnd00DA
SD00DE:
	call pOut
	 db 0x02, '",'
SDEnd00DA:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD00DF
	jmp SDEnd0075
SD00DF:
	call cPush
	call IsBit
	 dq 16
	or rPOk, rPOk
	jnz SD00E0
	jmp SDEnd00E0
SD00E0:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B16"				: "'
	or rPOk, rPOk
	jnz SD00E1
	jmp SDEnd00E0
SD00E1:
	call pOut
	 db 0x02, '",'
SDEnd00E0:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD00E2
	jmp SDEnd0075
SD00E2:
	call cPush
	call IsBit
	 dq 17
	or rPOk, rPOk
	jnz SD00E3
	jmp SDEnd00E3
SD00E3:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B17"				: "'
	or rPOk, rPOk
	jnz SD00E4
	jmp SDEnd00E3
SD00E4:
	call pOut
	 db 0x02, '",'
SDEnd00E3:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD00E5
	jmp SDEnd0075
SD00E5:
	call cPush
	call IsBit
	 dq 18
	or rPOk, rPOk
	jnz SD00E6
	jmp SDEnd00E6
SD00E6:
	call cPush
	mov rFactCnt, 4
	or rFactCnt, rFactCnt
	jz FacEnd00E7
FacRep00E7:
	call n
	dec rFactCnt
	jrcxz FacEnd00E7
	jz FacEnd00E7
	jmp FacRep00E7
FacEnd00E7:
	call cDrop
	or rPOk, rPOk
	jnz SD00E8
	jmp SDEnd00E6
SD00E8:
	call pOut
	 db 0x1C, 0x0a, 0x09, '"B18 reference number"	: "'
	or rPOk, rPOk
	jnz SD00E9
	jmp SDEnd00E6
SD00E9:
	call pOutLI
	or rPOk, rPOk
	jnz SD00EA
	jmp SDEnd00E6
SD00EA:
	call pOut
	 db 0x02, '",'
SDEnd00E6:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD00EB
	jmp SDEnd0075
SD00EB:
	call cPush
	call IsBit
	 dq 19
	or rPOk, rPOk
	jnz SD00EC
	jmp SDEnd00EC
SD00EC:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B19"				: "'
	or rPOk, rPOk
	jnz SD00ED
	jmp SDEnd00EC
SD00ED:
	call pOut
	 db 0x02, '",'
SDEnd00EC:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD00EE
	jmp SDEnd0075
SD00EE:
	call cPush
	call IsBit
	 dq 20
	or rPOk, rPOk
	jnz SD00EF
	jmp SDEnd00EF
SD00EF:
	call cPush
	mov rFactCnt, 3
	or rFactCnt, rFactCnt
	jz FacEnd00F0
FacRep00F0:
	call n
	dec rFactCnt
	jrcxz FacEnd00F0
	jz FacEnd00F0
	jmp FacRep00F0
FacEnd00F0:
	call cDrop
	or rPOk, rPOk
	jnz SD00F1
	jmp SDEnd00EF
SD00F1:
	call pOut
	 db 0x1A, 0x0a, 0x09, '"B20 Language code"		: "'
	or rPOk, rPOk
	jnz SD00F2
	jmp SDEnd00EF
SD00F2:
	call pOutLI
	or rPOk, rPOk
	jnz SD00F3
	jmp SDEnd00EF
SD00F3:
	call pOut
	 db 0x02, '",'
SDEnd00EF:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD00F4
	jmp SDEnd0075
SD00F4:
	call cPush
	call IsBit
	 dq 21
	or rPOk, rPOk
	jnz SD00F5
	jmp SDEnd00F5
SD00F5:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B21"				: "'
	or rPOk, rPOk
	jnz SD00F6
	jmp SDEnd00F5
SD00F6:
	call pOut
	 db 0x02, '",'
SDEnd00F5:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD00F7
	jmp SDEnd0075
SD00F7:
	call cPush
	call IsBit
	 dq 22
	or rPOk, rPOk
	jnz SD00F8
	jmp SDEnd00F8
SD00F8:
	call cPush
	mov rFactCnt, 12
	or rFactCnt, rFactCnt
	jz FacEnd00F9
FacRep00F9:
	call an
	dec rFactCnt
	jrcxz FacEnd00F9
	jz FacEnd00F9
	jmp FacRep00F9
FacEnd00F9:
	call cDrop
	or rPOk, rPOk
	jnz SD00FA
	jmp SDEnd00F8
SD00FA:
	call pOut
	 db 0x1B, 0x0a, 0x09, '"B22 POS data code" 		: {'
SDEnd00F8:
	or rPOk, rPOk
	jnz AD00FB
	jmp ADEnd00FB
AD00FB:
	call cAndProlog
	call Bit22
	call cAndEpilog
ADEnd00FB:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD00FC
	jmp SDEnd0075
SD00FC:
	call cPush
	call IsBit
	 dq 23
	or rPOk, rPOk
	jnz SD00FD
	jmp SDEnd00FD
SD00FD:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B23"				: "'
	or rPOk, rPOk
	jnz SD00FE
	jmp SDEnd00FD
SD00FE:
	call pOutLI
	or rPOk, rPOk
	jnz SD00FF
	jmp SDEnd00FD
SD00FF:
	call pOut
	 db 0x02, '",'
SDEnd00FD:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0100
	jmp SDEnd0075
SD0100:
	call cPush
	call IsBit
	 dq 24
	or rPOk, rPOk
	jnz SD0101
	jmp SDEnd0101
SD0101:
	call cPush
	mov rFactCnt, 3
	or rFactCnt, rFactCnt
	jz FacEnd0102
FacRep0102:
	call n
	dec rFactCnt
	jrcxz FacEnd0102
	jz FacEnd0102
	jmp FacRep0102
FacEnd0102:
	call cDrop
	or rPOk, rPOk
	jnz SD0103
	jmp SDEnd0101
SD0103:
	call pOut
	 db 0x1B, 0x0a, 0x09, '"B24 Function code" 		: "'
	or rPOk, rPOk
	jnz SD0104
	jmp SDEnd0101
SD0104:
	call pOutLI
	or rPOk, rPOk
	jnz SD0105
	jmp SDEnd0101
SD0105:
	call pOut
	 db 0x02, ' ('
SDEnd0101:
	or rPOk, rPOk
	jnz AD0106
	jmp ADEnd0106
AD0106:
	call cAndProlog
	call Bit24
	or rPOk, rPOk
	jnz SD0107
	jmp SDEnd0107
SD0107:
	call pOut
	 db 0x03, ')",'
SDEnd0107:
	call cAndEpilog
ADEnd0106:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0108
	jmp SDEnd0075
SD0108:
	call cPush
	call IsBit
	 dq 25
	or rPOk, rPOk
	jnz SD0109
	jmp SDEnd0109
SD0109:
	call cPush
	mov rFactCnt, 4
	or rFactCnt, rFactCnt
	jz FacEnd010A
FacRep010A:
	call n
	dec rFactCnt
	jrcxz FacEnd010A
	jz FacEnd010A
	jmp FacRep010A
FacEnd010A:
	call cDrop
	or rPOk, rPOk
	jnz SD010B
	jmp SDEnd0109
SD010B:
	call pOut
	 db 0x1F, 0x0a, 0x09, '"B25 Message reason code"	: "'
	or rPOk, rPOk
	jnz SD010C
	jmp SDEnd0109
SD010C:
	call pOutLI
	or rPOk, rPOk
	jnz SD010D
	jmp SDEnd0109
SD010D:
	call pOut
	 db 0x02, ' ('
SDEnd0109:
	or rPOk, rPOk
	jnz AD010E
	jmp ADEnd010E
AD010E:
	call cAndProlog
	call Bit25
	or rPOk, rPOk
	jnz SD010F
	jmp SDEnd010F
SD010F:
	call pOut
	 db 0x03, ')",'
SDEnd010F:
	call cAndEpilog
ADEnd010E:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0110
	jmp SDEnd0075
SD0110:
	call cPush
	call IsBit
	 dq 26
	or rPOk, rPOk
	jnz SD0111
	jmp SDEnd0111
SD0111:
	call cPush
	mov rFactCnt, 4
	or rFactCnt, rFactCnt
	jz FacEnd0112
FacRep0112:
	call n
	dec rFactCnt
	jrcxz FacEnd0112
	jz FacEnd0112
	jmp FacRep0112
FacEnd0112:
	call cDrop
	or rPOk, rPOk
	jnz SD0113
	jmp SDEnd0111
SD0113:
	call pOut
	 db 0x25, 0x0a, 0x09, '"B26 Card acceptor busnss code" : "'
	or rPOk, rPOk
	jnz SD0114
	jmp SDEnd0111
SD0114:
	call pOutLI
	or rPOk, rPOk
	jnz SD0115
	jmp SDEnd0111
SD0115:
	call pOut
	 db 0x02, ' ('
SDEnd0111:
	or rPOk, rPOk
	jnz AD0116
	jmp ADEnd0116
AD0116:
	call cAndProlog
	call Bit26
	or rPOk, rPOk
	jnz SD0117
	jmp SDEnd0117
SD0117:
	call pOut
	 db 0x03, ')",'
SDEnd0117:
	call cAndEpilog
ADEnd0116:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0118
	jmp SDEnd0075
SD0118:
	call cPush
	call IsBit
	 dq 27
	or rPOk, rPOk
	jnz SD0119
	jmp SDEnd0119
SD0119:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B27" 			: "'
	or rPOk, rPOk
	jnz SD011A
	jmp SDEnd0119
SD011A:
	call pOut
	 db 0x02, '",'
SDEnd0119:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD011B
	jmp SDEnd0075
SD011B:
	call cPush
	call IsBit
	 dq 28
	or rPOk, rPOk
	jnz SD011C
	jmp SDEnd011C
SD011C:
	call cPush
	mov rFactCnt, 6
	or rFactCnt, rFactCnt
	jz FacEnd011D
FacRep011D:
	call n
	dec rFactCnt
	jrcxz FacEnd011D
	jz FacEnd011D
	jmp FacRep011D
FacEnd011D:
	call cDrop
	or rPOk, rPOk
	jnz SD011E
	jmp SDEnd011C
SD011E:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B28"				: "'
	or rPOk, rPOk
	jnz SD011F
	jmp SDEnd011C
SD011F:
	call pOutLI
	or rPOk, rPOk
	jnz SD0120
	jmp SDEnd011C
SD0120:
	call pOut
	 db 0x02, '",'
SDEnd011C:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0121
	jmp SDEnd0075
SD0121:
	call cPush
	call IsBit
	 dq 29
	or rPOk, rPOk
	jnz SD0122
	jmp SDEnd0122
SD0122:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B29"				: "'
	or rPOk, rPOk
	jnz SD0123
	jmp SDEnd0122
SD0123:
	call pOut
	 db 0x02, '",'
SDEnd0122:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0124
	jmp SDEnd0075
SD0124:
	call cPush
	call IsBit
	 dq 30
	or rPOk, rPOk
	jnz SD0125
	jmp SDEnd0125
SD0125:
	call cPush
	mov rFactCnt, 24
	or rFactCnt, rFactCnt
	jz FacEnd0126
FacRep0126:
	call n
	dec rFactCnt
	jrcxz FacEnd0126
	jz FacEnd0126
	jmp FacRep0126
FacEnd0126:
	call cDrop
	or rPOk, rPOk
	jnz SD0127
	jmp SDEnd0125
SD0127:
	call pOut
	 db 0x1C, 0x0a, 0x09, '"B30 Original amount"		: "'
	or rPOk, rPOk
	jnz SD0128
	jmp SDEnd0125
SD0128:
	call pOut
	 db 0x01, "("
SDEnd0125:
	or rPOk, rPOk
	jnz AD0129
	jmp ADEnd0129
AD0129:
	call cAndProlog
	call cPush
	mov rFactCnt, 22
	or rFactCnt, rFactCnt
	jz FacEnd012A
FacRep012A:
	call n
	dec rFactCnt
	jrcxz FacEnd012A
	jz FacEnd012A
	jmp FacRep012A
FacEnd012A:
	call cDrop
	or rPOk, rPOk
	jnz SD012B
	jmp SDEnd012B
SD012B:
	call pOutLITrim
	or rPOk, rPOk
	jnz SD012C
	jmp SDEnd012B
SD012C:
	call pOut
	 db 0x01, "."
	or rPOk, rPOk
	jnz SD012D
	jmp SDEnd012B
SD012D:
	call cPush
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd012E
FacRep012E:
	call n
	dec rFactCnt
	jrcxz FacEnd012E
	jz FacEnd012E
	jmp FacRep012E
FacEnd012E:
	call cDrop
	or rPOk, rPOk
	jnz SD012F
	jmp SDEnd012B
SD012F:
	call pOutLI
	or rPOk, rPOk
	jnz SD0130
	jmp SDEnd012B
SD0130:
	call pOut
	 db 0x04, "[l])"
	or rPOk, rPOk
	jnz SD0131
	jmp SDEnd012B
SD0131:
	call pOut
	 db 0x02, '",'
SDEnd012B:
	call cAndEpilog
ADEnd0129:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0132
	jmp SDEnd0075
SD0132:
	call cPush
	call IsBit
	 dq 31
	or rPOk, rPOk
	jnz SD0133
	jmp SDEnd0133
SD0133:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B31"				: "'
	or rPOk, rPOk
	jnz SD0134
	jmp SDEnd0133
SD0134:
	call pOut
	 db 0x02, '",'
SDEnd0133:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0135
	jmp SDEnd0075
SD0135:
	call cPush
	call IsBit
	 dq 32
	or rPOk, rPOk
	jnz SD0136
	jmp SDEnd0136
SD0136:
	call pOut
	 db 0x24, 0x0a, 0x09, '"B32 Acquiring institution ID"	: "'
	or rPOk, rPOk
	jnz SD0137
	jmp SDEnd0136
SD0137:
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep0138
	jmp FacEnd0138
FacRep0138:
	call cPush
	call n
	or rPOk, rPOk
	jnz SD0139
	jmp SDEnd0139
SD0139:
	call pOutLI
SDEnd0139:
	call cDrop
	dec rFactCnt
	jrcxz FacEnd0138
	jz FacEnd0138
	jmp FacRep0138
FacEnd0138:
	or rPOk, rPOk
	jnz SD013A
	jmp SDEnd0136
SD013A:
	call pOut
	 db 0x02, '",'
SDEnd0136:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD013B
	jmp SDEnd0075
SD013B:
	call cPush
	call IsBit
	 dq 33
	or rPOk, rPOk
	jnz SD013C
	jmp SDEnd013C
SD013C:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B33"				: "'
	or rPOk, rPOk
	jnz SD013D
	jmp SDEnd013C
SD013D:
	call pOut
	 db 0x02, '",'
SDEnd013C:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD013E
	jmp SDEnd0075
SD013E:
	call cPush
	call IsBit
	 dq 34
	or rPOk, rPOk
	jnz SD013F
	jmp SDEnd013F
SD013F:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B34"				: "'
	or rPOk, rPOk
	jnz SD0140
	jmp SDEnd013F
SD0140:
	call pOut
	 db 0x02, '",'
SDEnd013F:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0141
	jmp SDEnd0075
SD0141:
	call cPush
	call IsBit
	 dq 35
	or rPOk, rPOk
	jnz SD0142
	jmp SDEnd0142
SD0142:
	call pOut
	 db 0x15, 0x0a, 0x09, '"B35 Track 2"			: "'
	or rPOk, rPOk
	jnz SD0143
	jmp SDEnd0142
SD0143:
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep0144
	jmp FacEnd0144
FacRep0144:
	call cPush
	call ans
	or rPOk, rPOk
	jnz SD0145
	jmp SDEnd0145
SD0145:
	call pOutLI
SDEnd0145:
	call cDrop
	dec rFactCnt
	jrcxz FacEnd0144
	jz FacEnd0144
	jmp FacRep0144
FacEnd0144:
	or rPOk, rPOk
	jnz SD0146
	jmp SDEnd0142
SD0146:
	call pOut
	 db 0x02, '",'
SDEnd0142:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0147
	jmp SDEnd0075
SD0147:
	call cPush
	call IsBit
	 dq 36
	or rPOk, rPOk
	jnz SD0148
	jmp SDEnd0148
SD0148:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B36"				: "'
	or rPOk, rPOk
	jnz SD0149
	jmp SDEnd0148
SD0149:
	call pOut
	 db 0x02, '",'
SDEnd0148:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD014A
	jmp SDEnd0075
SD014A:
	call cPush
	call IsBit
	 dq 37
	or rPOk, rPOk
	jnz SD014B
	jmp SDEnd014B
SD014B:
	call pOut
	 db 0x23, 0x0a, 0x09, '"B37 Retrieval reference num"	: "'
	or rPOk, rPOk
	jnz SD014C
	jmp SDEnd014B
SD014C:
	call pOutLI
	or rPOk, rPOk
	jnz SD014D
	jmp SDEnd014B
SD014D:
	call pOut
	 db 0x02, '",'
SDEnd014B:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD014E
	jmp SDEnd0075
SD014E:
	call cPush
	call IsBit
	 dq 38
	or rPOk, rPOk
	jnz SD014F
	jmp SDEnd014F
SD014F:
	call cPush
	mov rFactCnt, 6
	or rFactCnt, rFactCnt
	jz FacEnd0150
FacRep0150:
	call anp
	dec rFactCnt
	jrcxz FacEnd0150
	jz FacEnd0150
	jmp FacRep0150
FacEnd0150:
	call cDrop
	or rPOk, rPOk
	jnz SD0151
	jmp SDEnd014F
SD0151:
	call pOut
	 db 0x1E, 0x0a, 0x09, '"B38 Authorisation code"	: "'
	or rPOk, rPOk
	jnz SD0152
	jmp SDEnd014F
SD0152:
	call pOutLI
	or rPOk, rPOk
	jnz SD0153
	jmp SDEnd014F
SD0153:
	call pOut
	 db 0x02, '",'
SDEnd014F:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0154
	jmp SDEnd0075
SD0154:
	call cPush
	call IsBit
	 dq 39
	or rPOk, rPOk
	jnz SD0155
	jmp SDEnd0155
SD0155:
	call cPush
	mov rFactCnt, 3
	or rFactCnt, rFactCnt
	jz FacEnd0156
FacRep0156:
	call n
	dec rFactCnt
	jrcxz FacEnd0156
	jz FacEnd0156
	jmp FacRep0156
FacEnd0156:
	call cDrop
	or rPOk, rPOk
	jnz SD0157
	jmp SDEnd0155
SD0157:
	call pOut
	 db 0x18, 0x0a, 0x09, '"B39 Action code"		: "'
	or rPOk, rPOk
	jnz SD0158
	jmp SDEnd0155
SD0158:
	call pOutLI
	or rPOk, rPOk
	jnz SD0159
	jmp SDEnd0155
SD0159:
	call pOut
	 db 0x02, ' ('
SDEnd0155:
	or rPOk, rPOk
	jnz AD015A
	jmp ADEnd015A
AD015A:
	call cAndProlog
	call Bit39
	or rPOk, rPOk
	jnz SD015B
	jmp SDEnd015B
SD015B:
	call pOut
	 db 0x03, ')",'
SDEnd015B:
	call cAndEpilog
ADEnd015A:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD015C
	jmp SDEnd0075
SD015C:
	call cPush
	call IsBit
	 dq 40
	or rPOk, rPOk
	jnz SD015D
	jmp SDEnd015D
SD015D:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B40"				: "'
	or rPOk, rPOk
	jnz SD015E
	jmp SDEnd015D
SD015E:
	call pOut
	 db 0x02, '",'
SDEnd015D:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD015F
	jmp SDEnd0075
SD015F:
	call cPush
	call IsBit
	 dq 41
	or rPOk, rPOk
	jnz SD0160
	jmp SDEnd0160
SD0160:
	call cPush
	mov rFactCnt, 8
	or rFactCnt, rFactCnt
	jz FacEnd0161
FacRep0161:
	call ans
	dec rFactCnt
	jrcxz FacEnd0161
	jz FacEnd0161
	jmp FacRep0161
FacEnd0161:
	call cDrop
	or rPOk, rPOk
	jnz SD0162
	jmp SDEnd0160
SD0162:
	call pOut
	 db 0x18, 0x0a, 0x09, '"B41 Terminal ID"		: "'
	or rPOk, rPOk
	jnz SD0163
	jmp SDEnd0160
SD0163:
	call pOutLI
	or rPOk, rPOk
	jnz SD0164
	jmp SDEnd0160
SD0164:
	call pOut
	 db 0x02, '",'
SDEnd0160:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0165
	jmp SDEnd0075
SD0165:
	call cPush
	call IsBit
	 dq 42
	or rPOk, rPOk
	jnz SD0166
	jmp SDEnd0166
SD0166:
	call cPush
	mov rFactCnt, 15
	or rFactCnt, rFactCnt
	jz FacEnd0167
FacRep0167:
	call ans
	dec rFactCnt
	jrcxz FacEnd0167
	jz FacEnd0167
	jmp FacRep0167
FacEnd0167:
	call cDrop
	or rPOk, rPOk
	jnz SD0168
	jmp SDEnd0166
SD0168:
	call pOut
	 db 0x12, 0x0a, 0x09, '"B42 CAIC"			: "'
	or rPOk, rPOk
	jnz SD0169
	jmp SDEnd0166
SD0169:
	call pOutLI
	or rPOk, rPOk
	jnz SD016A
	jmp SDEnd0166
SD016A:
	call pOut
	 db 0x02, '",'
SDEnd0166:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD016B
	jmp SDEnd0075
SD016B:
	call cPush
	call IsBit
	 dq 43
	or rPOk, rPOk
	jnz SD016C
	jmp SDEnd016C
SD016C:
	call cPush
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep016D
	jmp FacEnd016D
FacRep016D:
	call ans
	dec rFactCnt
	jrcxz FacEnd016D
	jz FacEnd016D
	jmp FacRep016D
FacEnd016D:
	call cDrop
	or rPOk, rPOk
	jnz SD016E
	jmp SDEnd016C
SD016E:
	call pOut
	 db 0x13, 0x0a, 0x09, '"B43 CAN/L"			: "'
SDEnd016C:
	or rPOk, rPOk
	jnz AD016F
	jmp ADEnd016F
AD016F:
	call cAndProlog
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep0170
	jmp FacEnd0170
FacRep0170:
	call cPush
	call pIn
	 db 0x0001, '\'
	or rPOk, rPOk
	jnz SD0171
	jmp SDEnd0171
SD0171:
	call pOut
	 db 0x02, '\\'
SDEnd0171:
	jrcxz DL0172
	jmp DLEnd0172
DL0172:	inc rcx
	call cTop
	call pIn
	 db 1, 34
	or rPOk, rPOk
	jnz SD0173
	jmp SDEnd0173
SD0173:
	call pOut
	 db 0x02, '\"'
SDEnd0173:
	jrcxz DL0174
	jmp DLEnd0172
DL0174:	inc rcx
	call cTop
	call ans
	or rPOk, rPOk
	jnz SD0175
	jmp SDEnd0175
SD0175:
	call pOutLI
SDEnd0175:
DLEnd0172:
	call cDrop
	dec rFactCnt
	jrcxz FacEnd0170
	jz FacEnd0170
	jmp FacRep0170
FacEnd0170:
	or rPOk, rPOk
	jnz SD0176
	jmp SDEnd0176
SD0176:
	call pOut
	 db 0x02, '",'
SDEnd0176:
	call cAndEpilog
ADEnd016F:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0177
	jmp SDEnd0075
SD0177:
	call cPush
	call IsBit
	 dq 44
	or rPOk, rPOk
	jnz SD0178
	jmp SDEnd0178
SD0178:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B44" 			: "'
	or rPOk, rPOk
	jnz SD0179
	jmp SDEnd0178
SD0179:
	call pOut
	 db 0x02, '",'
SDEnd0178:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD017A
	jmp SDEnd0075
SD017A:
	call cPush
	call IsBit
	 dq 45
	or rPOk, rPOk
	jnz SD017B
	jmp SDEnd017B
SD017B:
	call pOut
	 db 0x19, 0x0a, 0x09, '"B45 Track 1 data"		: "'
	or rPOk, rPOk
	jnz SD017C
	jmp SDEnd017B
SD017C:
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep017D
	jmp FacEnd017D
FacRep017D:
	call cPush
	call ans
	or rPOk, rPOk
	jnz SD017E
	jmp SDEnd017E
SD017E:
	call pOutLI
SDEnd017E:
	call cDrop
	dec rFactCnt
	jrcxz FacEnd017D
	jz FacEnd017D
	jmp FacRep017D
FacEnd017D:
	or rPOk, rPOk
	jnz SD017F
	jmp SDEnd017B
SD017F:
	call pOut
	 db 0x02, '",'
SDEnd017B:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0180
	jmp SDEnd0075
SD0180:
	call cPush
	call IsBit
	 dq 46
	or rPOk, rPOk
	jnz SD0181
	jmp SDEnd0181
SD0181:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B46"				: "'
	or rPOk, rPOk
	jnz SD0182
	jmp SDEnd0181
SD0182:
	call pOut
	 db 0x02, '",'
SDEnd0181:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0183
	jmp SDEnd0075
SD0183:
	call cPush
	call IsBit
	 dq 47
	or rPOk, rPOk
	jnz SD0184
	jmp SDEnd0184
SD0184:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B47"				: "'
	or rPOk, rPOk
	jnz SD0185
	jmp SDEnd0184
SD0185:
	call pOut
	 db 0x02, '",'
SDEnd0184:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0186
	jmp SDEnd0075
SD0186:
	call cPush
	call IsBit
	 dq 48
	or rPOk, rPOk
	jnz SD0187
	jmp SDEnd0187
SD0187:
	call cPush
	call LLLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep0188
	jmp FacEnd0188
FacRep0188:
	call b
	dec rFactCnt
	jrcxz FacEnd0188
	jz FacEnd0188
	jmp FacRep0188
FacEnd0188:
	call cDrop
	or rPOk, rPOk
	jnz SD0189
	jmp SDEnd0187
SD0189:
	call pOut
	 db 0x22, 0x0a, 0x09, '"B48 Msg ctrl data elements"	: {'
SDEnd0187:
	or rPOk, rPOk
	jnz AD018A
	jmp ADEnd018A
AD018A:
	call cAndProlog
	call cPush
	mov rFactCnt, 3
	or rFactCnt, rFactCnt
	jz FacEnd018B
FacRep018B:
	call b
	dec rFactCnt
	jrcxz FacEnd018B
	jz FacEnd018B
	jmp FacRep018B
FacEnd018B:
	or rPOk, rPOk
	jnz SD018C
	jmp SDEnd018C
SD018C:
	call BitMap48
	or rPOk, rPOk
	jnz SD018D
	jmp SDEnd018C
SD018D:
	call Fields48
	or rPOk, rPOk
	jnz SD018E
	jmp SDEnd018C
SD018E:
	call SetBitMapCur
	 dq aBitMap0
SDEnd018C:
	call cDrop
	call cAndEpilog
ADEnd018A:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD018F
	jmp SDEnd0075
SD018F:
	call cPush
	call IsBit
	 dq 49
	or rPOk, rPOk
	jnz SD0190
	jmp SDEnd0190
SD0190:
	call cPush
	mov rFactCnt, 3
	or rFactCnt, rFactCnt
	jz FacEnd0191
FacRep0191:
	call an
	dec rFactCnt
	jrcxz FacEnd0191
	jz FacEnd0191
	jmp FacRep0191
FacEnd0191:
	call cDrop
	or rPOk, rPOk
	jnz SD0192
	jmp SDEnd0190
SD0192:
	call pOut
	 db 0x1A, 0x0a, 0x09, '"B49 Currency code"		: "'
	or rPOk, rPOk
	jnz SD0193
	jmp SDEnd0190
SD0193:
	call pOutLI
	or rPOk, rPOk
	jnz SD0194
	jmp SDEnd0190
SD0194:
	call pOut
	 db 0x02, ' ('
SDEnd0190:
	or rPOk, rPOk
	jnz AD0195
	jmp ADEnd0195
AD0195:
	call cAndProlog
	call Bit49
	or rPOk, rPOk
	jnz SD0196
	jmp SDEnd0196
SD0196:
	call pOut
	 db 0x03, ')",'
SDEnd0196:
	call cAndEpilog
ADEnd0195:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0197
	jmp SDEnd0075
SD0197:
	call cPush
	call IsBit
	 dq 50
	or rPOk, rPOk
	jnz SD0198
	jmp SDEnd0198
SD0198:
	call cPush
	mov rFactCnt, 3
	or rFactCnt, rFactCnt
	jz FacEnd0199
FacRep0199:
	call n
	dec rFactCnt
	jrcxz FacEnd0199
	jz FacEnd0199
	jmp FacRep0199
FacEnd0199:
	call cDrop
	or rPOk, rPOk
	jnz SD019A
	jmp SDEnd0198
SD019A:
	call pOut
	 db 0x23, 0x0a, 0x09, '"B50 Currency code reconcili"	: "'
	or rPOk, rPOk
	jnz SD019B
	jmp SDEnd0198
SD019B:
	call pOutLI
	or rPOk, rPOk
	jnz SD019C
	jmp SDEnd0198
SD019C:
	call pOut
	 db 0x02, '",'
SDEnd0198:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD019D
	jmp SDEnd0075
SD019D:
	call cPush
	call IsBit
	 dq 51
	or rPOk, rPOk
	jnz SD019E
	jmp SDEnd019E
SD019E:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B51"				: "'
	or rPOk, rPOk
	jnz SD019F
	jmp SDEnd019E
SD019F:
	call pOut
	 db 0x02, '",'
SDEnd019E:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01A0
	jmp SDEnd0075
SD01A0:
	call cPush
	call IsBit
	 dq 52
	or rPOk, rPOk
	jnz SD01A1
	jmp SDEnd01A1
SD01A1:
	call cPush
	mov rFactCnt, 8
	or rFactCnt, rFactCnt
	jz FacEnd01A2
FacRep01A2:
	call b
	dec rFactCnt
	jrcxz FacEnd01A2
	jz FacEnd01A2
	jmp FacRep01A2
FacEnd01A2:
	call cDrop
	or rPOk, rPOk
	jnz SD01A3
	jmp SDEnd01A1
SD01A3:
	call pOut
	 db 0x15, 0x0a, 0x09, '"B52 PIN data"		: "'
	or rPOk, rPOk
	jnz SD01A4
	jmp SDEnd01A1
SD01A4:
	call pOutLIHex
	or rPOk, rPOk
	jnz SD01A5
	jmp SDEnd01A1
SD01A5:
	call pOut
	 db 0x02, '",'
SDEnd01A1:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01A6
	jmp SDEnd0075
SD01A6:
	call cPush
	call IsBit
	 dq 53
	or rPOk, rPOk
	jnz SD01A7
	jmp SDEnd01A7
SD01A7:
	call cPush
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep01A8
	jmp FacEnd01A8
FacRep01A8:
	call b
	dec rFactCnt
	jrcxz FacEnd01A8
	jz FacEnd01A8
	jmp FacRep01A8
FacEnd01A8:
	call cDrop
	or rPOk, rPOk
	jnz SD01A9
	jmp SDEnd01A7
SD01A9:
	call pOut
	 db 0x21, 0x0a, 0x09, '"B53 Security related info"	: {'
SDEnd01A7:
	or rPOk, rPOk
	jnz AD01AA
	jmp ADEnd01AA
AD01AA:
	call cAndProlog
	call Bit53H2H
	call cAndEpilog
ADEnd01AA:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01AB
	jmp SDEnd0075
SD01AB:
	call cPush
	call IsBit
	 dq 54
	or rPOk, rPOk
	jnz SD01AC
	jmp SDEnd01AC
SD01AC:
	call cPush
	call LLLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep01AD
	jmp FacEnd01AD
FacRep01AD:
	call ans
	dec rFactCnt
	jrcxz FacEnd01AD
	jz FacEnd01AD
	jmp FacRep01AD
FacEnd01AD:
	call cDrop
	or rPOk, rPOk
	jnz SD01AE
	jmp SDEnd01AC
SD01AE:
	call pOut
	 db 0x1E, 0x0a, 0x09, '"B54 Amounts additional"	: "'
	or rPOk, rPOk
	jnz SD01AF
	jmp SDEnd01AC
SD01AF:
	call pOutLI
	or rPOk, rPOk
	jnz SD01B0
	jmp SDEnd01AC
SD01B0:
	call pOut
	 db 0x02, '",'
SDEnd01AC:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01B1
	jmp SDEnd0075
SD01B1:
	call cPush
	call IsBit
	 dq 55
	or rPOk, rPOk
	jnz SD01B2
	jmp SDEnd01B2
SD01B2:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B55"				: "'
	or rPOk, rPOk
	jnz SD01B3
	jmp SDEnd01B2
SD01B3:
	call pOut
	 db 0x02, '",'
SDEnd01B2:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01B4
	jmp SDEnd0075
SD01B4:
	call cPush
	call IsBit
	 dq 56
	or rPOk, rPOk
	jnz SD01B5
	jmp SDEnd01B5
SD01B5:
	call pOut
	 db 0x22, 0x0a, 0x09, '"B56 Original data elements"	: "'
	or rPOk, rPOk
	jnz SD01B6
	jmp SDEnd01B5
SD01B6:
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep01B7
	jmp FacEnd01B7
FacRep01B7:
	call cPush
	call n
	or rPOk, rPOk
	jnz SD01B8
	jmp SDEnd01B8
SD01B8:
	call pOutLI
SDEnd01B8:
	call cDrop
	dec rFactCnt
	jrcxz FacEnd01B7
	jz FacEnd01B7
	jmp FacRep01B7
FacEnd01B7:
	or rPOk, rPOk
	jnz SD01B9
	jmp SDEnd01B5
SD01B9:
	call pOut
	 db 0x02, '",'
SDEnd01B5:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01BA
	jmp SDEnd0075
SD01BA:
	call cPush
	call IsBit
	 dq 57
	or rPOk, rPOk
	jnz SD01BB
	jmp SDEnd01BB
SD01BB:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B57"				: "'
	or rPOk, rPOk
	jnz SD01BC
	jmp SDEnd01BB
SD01BC:
	call pOut
	 db 0x02, '",'
SDEnd01BB:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01BD
	jmp SDEnd0075
SD01BD:
	call cPush
	call IsBit
	 dq 58
	or rPOk, rPOk
	jnz SD01BE
	jmp SDEnd01BE
SD01BE:
	call pOut
	 db 0x0E, 0x0a, 0x09, '"B58"				: "'
	or rPOk, rPOk
	jnz SD01BF
	jmp SDEnd01BE
SD01BF:
	call pOut
	 db 0x02, '",'
SDEnd01BE:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01C0
	jmp SDEnd0075
SD01C0:
	call cPush
	call IsBit
	 dq 59
	or rPOk, rPOk
	jnz SD01C1
	jmp SDEnd01C1
SD01C1:
	call pOut
	 db 0x1B, 0x0a, 0x09, '"B59 Transport data"		: "'
	or rPOk, rPOk
	jnz SD01C2
	jmp SDEnd01C1
SD01C2:
	call LLLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep01C3
	jmp FacEnd01C3
FacRep01C3:
	call cPush
	call ans
	or rPOk, rPOk
	jnz SD01C4
	jmp SDEnd01C4
SD01C4:
	call pOutLI
SDEnd01C4:
	call cDrop
	dec rFactCnt
	jrcxz FacEnd01C3
	jz FacEnd01C3
	jmp FacRep01C3
FacEnd01C3:
	or rPOk, rPOk
	jnz SD01C5
	jmp SDEnd01C1
SD01C5:
	call pOut
	 db 0x02, '",'
SDEnd01C1:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01C6
	jmp SDEnd0075
SD01C6:
	call cPush
	call IsBit
	 dq 60
	or rPOk, rPOk
	jnz SD01C7
	jmp SDEnd01C7
SD01C7:
	call LLLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep01C8
	jmp FacEnd01C8
FacRep01C8:
	call ans
	dec rFactCnt
	jrcxz FacEnd01C8
	jz FacEnd01C8
	jmp FacRep01C8
FacEnd01C8:
	or rPOk, rPOk
	jnz SD01C9
	jmp SDEnd01C7
SD01C9:
	call pOut
	 db 0x1E, 0x0a, 0x09, '"B60 Entered PIN Digits"	: "'
	or rPOk, rPOk
	jnz SD01CA
	jmp SDEnd01C7
SD01CA:
	call pOutLI
	or rPOk, rPOk
	jnz SD01CB
	jmp SDEnd01C7
SD01CB:
	call pOut
	 db 0x02, '",'
SDEnd01C7:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01CC
	jmp SDEnd0075
SD01CC:
	call cPush
	call IsBit
	 dq 61
	or rPOk, rPOk
	jnz SD01CD
	jmp SDEnd01CD
SD01CD:
	call LLLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep01CE
	jmp FacEnd01CE
FacRep01CE:
	call ans
	dec rFactCnt
	jrcxz FacEnd01CE
	jz FacEnd01CE
	jmp FacRep01CE
FacEnd01CE:
	or rPOk, rPOk
	jnz SD01CF
	jmp SDEnd01CD
SD01CF:
	call pOut
	 db 0x1F, 0x0a, 0x09, '"B61 Failed PIN attempts"	: "'
	or rPOk, rPOk
	jnz SD01D0
	jmp SDEnd01CD
SD01D0:
	call pOutLI
	or rPOk, rPOk
	jnz SD01D1
	jmp SDEnd01CD
SD01D1:
	call pOut
	 db 0x02, '",'
SDEnd01CD:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01D2
	jmp SDEnd0075
SD01D2:
	call cPush
	call IsBit
	 dq 62
	or rPOk, rPOk
	jnz SD01D3
	jmp SDEnd01D3
SD01D3:
	call cPush
	call LLLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep01D4
	jmp FacEnd01D4
FacRep01D4:
	call ans
	dec rFactCnt
	jrcxz FacEnd01D4
	jz FacEnd01D4
	jmp FacRep01D4
FacEnd01D4:
	call cDrop
	or rPOk, rPOk
	jnz SD01D5
	jmp SDEnd01D3
SD01D5:
	call pOut
	 db 0x19, 0x0a, 0x09, '"B62 Product sets"		: {'
SDEnd01D3:
	or rPOk, rPOk
	jnz AD01D6
	jmp ADEnd01D6
AD01D6:
	call cAndProlog
	call Bit62
	call cAndEpilog
ADEnd01D6:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01D7
	jmp SDEnd0075
SD01D7:
	call cPush
	call IsBit
	 dq 63
	or rPOk, rPOk
	jnz SD01D8
	jmp SDEnd01D8
SD01D8:
	call cPush
	call LLLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep01D9
	jmp FacEnd01D9
FacRep01D9:
	call ans
	dec rFactCnt
	jrcxz FacEnd01D9
	jz FacEnd01D9
	jmp FacRep01D9
FacEnd01D9:
	call cDrop
	or rPOk, rPOk
	jnz SD01DA
	jmp SDEnd01D8
SD01DA:
	call pOut
	 db 0x19, 0x0a, 0x09, '"B63 Product data"		: {'
SDEnd01D8:
	or rPOk, rPOk
	jnz AD01DB
	jmp ADEnd01DB
AD01DB:
	call cAndProlog
	call cPush
	call Bit63
	jrcxz DL01DC
	jmp DLEnd01DC
DL01DC:	inc rcx
	call cTop
	call LLLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep01DD
	jmp FacEnd01DD
FacRep01DD:
	call ans
	dec rFactCnt
	jrcxz FacEnd01DD
	jz FacEnd01DD
	jmp FacRep01DD
FacEnd01DD:
	or rPOk, rPOk
	jnz SD01DE
	jmp SDEnd01DE
SD01DE:
	call pOut
	 db 0x16, '"Warning format error"'
SDEnd01DE:
DLEnd01DC:
	call cDrop
	call cAndEpilog
ADEnd01DB:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01DF
	jmp SDEnd0075
SD01DF:
	call cPush
	call IsBit
	 dq 64
	or rPOk, rPOk
	jnz SD01E0
	jmp SDEnd01E0
SD01E0:
	call cPush
	mov rFactCnt, 8
	or rFactCnt, rFactCnt
	jz FacEnd01E1
FacRep01E1:
	call b
	dec rFactCnt
	jrcxz FacEnd01E1
	jz FacEnd01E1
	jmp FacRep01E1
FacEnd01E1:
	call cDrop
	or rPOk, rPOk
	jnz SD01E2
	jmp SDEnd01E0
SD01E2:
	call pOut
	 db 0x11, 0x0a, 0x09, '"B64 MAC"			: "'
	or rPOk, rPOk
	jnz SD01E3
	jmp SDEnd01E0
SD01E3:
	call pOutLIHex
	or rPOk, rPOk
	jnz SD01E4
	jmp SDEnd01E0
SD01E4:
	call pOut
	 db 0x02, '",'
SDEnd01E0:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01E5
	jmp SDEnd0075
SD01E5:
	call cPush
	call IsBit1
	 dq 74
	or rPOk, rPOk
	jnz SD01E6
	jmp SDEnd01E6
SD01E6:
	call cPush
	mov rFactCnt, 10
	or rFactCnt, rFactCnt
	jz FacEnd01E7
FacRep01E7:
	call n
	dec rFactCnt
	jrcxz FacEnd01E7
	jz FacEnd01E7
	jmp FacRep01E7
FacEnd01E7:
	call cDrop
	or rPOk, rPOk
	jnz SD01E8
	jmp SDEnd01E6
SD01E8:
	call pOut
	 db 0x1B, 0x0a, 0x09, '"B74 Credits number"		: "'
	or rPOk, rPOk
	jnz SD01E9
	jmp SDEnd01E6
SD01E9:
	call pOutLI
	or rPOk, rPOk
	jnz SD01EA
	jmp SDEnd01E6
SD01EA:
	call pOut
	 db 0x02, '",'
SDEnd01E6:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01EB
	jmp SDEnd0075
SD01EB:
	call cPush
	call IsBit1
	 dq 75
	or rPOk, rPOk
	jnz SD01EC
	jmp SDEnd01EC
SD01EC:
	call cPush
	mov rFactCnt, 10
	or rFactCnt, rFactCnt
	jz FacEnd01ED
FacRep01ED:
	call n
	dec rFactCnt
	jrcxz FacEnd01ED
	jz FacEnd01ED
	jmp FacRep01ED
FacEnd01ED:
	call cDrop
	or rPOk, rPOk
	jnz SD01EE
	jmp SDEnd01EC
SD01EE:
	call pOut
	 db 0x23, 0x0a, 0x09, '"B75 Credits reversal number"	: "'
	or rPOk, rPOk
	jnz SD01EF
	jmp SDEnd01EC
SD01EF:
	call pOutLI
	or rPOk, rPOk
	jnz SD01F0
	jmp SDEnd01EC
SD01F0:
	call pOut
	 db 0x02, '",'
SDEnd01EC:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01F1
	jmp SDEnd0075
SD01F1:
	call cPush
	call IsBit1
	 dq 76
	or rPOk, rPOk
	jnz SD01F2
	jmp SDEnd01F2
SD01F2:
	call cPush
	mov rFactCnt, 10
	or rFactCnt, rFactCnt
	jz FacEnd01F3
FacRep01F3:
	call n
	dec rFactCnt
	jrcxz FacEnd01F3
	jz FacEnd01F3
	jmp FacRep01F3
FacEnd01F3:
	call cDrop
	or rPOk, rPOk
	jnz SD01F4
	jmp SDEnd01F2
SD01F4:
	call pOut
	 db 0x1A, 0x0a, 0x09, '"B76 Debits number"		: "'
	or rPOk, rPOk
	jnz SD01F5
	jmp SDEnd01F2
SD01F5:
	call pOutLI
	or rPOk, rPOk
	jnz SD01F6
	jmp SDEnd01F2
SD01F6:
	call pOut
	 db 0x02, '",'
SDEnd01F2:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01F7
	jmp SDEnd0075
SD01F7:
	call cPush
	call IsBit1
	 dq 77
	or rPOk, rPOk
	jnz SD01F8
	jmp SDEnd01F8
SD01F8:
	call cPush
	mov rFactCnt, 10
	or rFactCnt, rFactCnt
	jz FacEnd01F9
FacRep01F9:
	call n
	dec rFactCnt
	jrcxz FacEnd01F9
	jz FacEnd01F9
	jmp FacRep01F9
FacEnd01F9:
	call cDrop
	or rPOk, rPOk
	jnz SD01FA
	jmp SDEnd01F8
SD01FA:
	call pOut
	 db 0x22, 0x0a, 0x09, '"B77 Debits reversal number"	: "'
	or rPOk, rPOk
	jnz SD01FB
	jmp SDEnd01F8
SD01FB:
	call pOutLI
	or rPOk, rPOk
	jnz SD01FC
	jmp SDEnd01F8
SD01FC:
	call pOut
	 db 0x02, '",'
SDEnd01F8:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01FD
	jmp SDEnd0075
SD01FD:
	call cPush
	call IsBit1
	 dq 86
	or rPOk, rPOk
	jnz SD01FE
	jmp SDEnd01FE
SD01FE:
	call cPush
	mov rFactCnt, 16
	or rFactCnt, rFactCnt
	jz FacEnd01FF
FacRep01FF:
	call n
	dec rFactCnt
	jrcxz FacEnd01FF
	jz FacEnd01FF
	jmp FacRep01FF
FacEnd01FF:
	call cDrop
	or rPOk, rPOk
	jnz SD0200
	jmp SDEnd01FE
SD0200:
	call pOut
	 db 0x1B, 0x0a, 0x09, '"B86 Credits amount"		: "'
	or rPOk, rPOk
	jnz SD0201
	jmp SDEnd01FE
SD0201:
	call pOut
	 db 0x01, "("
SDEnd01FE:
	or rPOk, rPOk
	jnz AD0202
	jmp ADEnd0202
AD0202:
	call cAndProlog
	call cPush
	mov rFactCnt, 14
	or rFactCnt, rFactCnt
	jz FacEnd0203
FacRep0203:
	call n
	dec rFactCnt
	jrcxz FacEnd0203
	jz FacEnd0203
	jmp FacRep0203
FacEnd0203:
	call cDrop
	or rPOk, rPOk
	jnz SD0204
	jmp SDEnd0204
SD0204:
	call pOutLITrim
	or rPOk, rPOk
	jnz SD0205
	jmp SDEnd0204
SD0205:
	call pOut
	 db 0x01, "."
	or rPOk, rPOk
	jnz SD0206
	jmp SDEnd0204
SD0206:
	call cPush
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd0207
FacRep0207:
	call n
	dec rFactCnt
	jrcxz FacEnd0207
	jz FacEnd0207
	jmp FacRep0207
FacEnd0207:
	call cDrop
	or rPOk, rPOk
	jnz SD0208
	jmp SDEnd0204
SD0208:
	call pOutLI
	or rPOk, rPOk
	jnz SD0209
	jmp SDEnd0204
SD0209:
	call pOut
	 db 0x04, "[l])"
	or rPOk, rPOk
	jnz SD020A
	jmp SDEnd0204
SD020A:
	call pOut
	 db 0x02, '",'
SDEnd0204:
	call cAndEpilog
ADEnd0202:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD020B
	jmp SDEnd0075
SD020B:
	call cPush
	call IsBit1
	 dq 87
	or rPOk, rPOk
	jnz SD020C
	jmp SDEnd020C
SD020C:
	call cPush
	mov rFactCnt, 16
	or rFactCnt, rFactCnt
	jz FacEnd020D
FacRep020D:
	call n
	dec rFactCnt
	jrcxz FacEnd020D
	jz FacEnd020D
	jmp FacRep020D
FacEnd020D:
	call cDrop
	or rPOk, rPOk
	jnz SD020E
	jmp SDEnd020C
SD020E:
	call pOut
	 db 0x23, 0x0a, 0x09, '"B87 Credits reversal amount"	: "'
	or rPOk, rPOk
	jnz SD020F
	jmp SDEnd020C
SD020F:
	call pOut
	 db 0x01, "("
SDEnd020C:
	or rPOk, rPOk
	jnz AD0210
	jmp ADEnd0210
AD0210:
	call cAndProlog
	call cPush
	mov rFactCnt, 14
	or rFactCnt, rFactCnt
	jz FacEnd0211
FacRep0211:
	call n
	dec rFactCnt
	jrcxz FacEnd0211
	jz FacEnd0211
	jmp FacRep0211
FacEnd0211:
	call cDrop
	or rPOk, rPOk
	jnz SD0212
	jmp SDEnd0212
SD0212:
	call pOutLITrim
	or rPOk, rPOk
	jnz SD0213
	jmp SDEnd0212
SD0213:
	call pOut
	 db 0x01, "."
	or rPOk, rPOk
	jnz SD0214
	jmp SDEnd0212
SD0214:
	call cPush
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd0215
FacRep0215:
	call n
	dec rFactCnt
	jrcxz FacEnd0215
	jz FacEnd0215
	jmp FacRep0215
FacEnd0215:
	call cDrop
	or rPOk, rPOk
	jnz SD0216
	jmp SDEnd0212
SD0216:
	call pOutLI
	or rPOk, rPOk
	jnz SD0217
	jmp SDEnd0212
SD0217:
	call pOut
	 db 0x04, "[l])"
	or rPOk, rPOk
	jnz SD0218
	jmp SDEnd0212
SD0218:
	call pOut
	 db 0x02, '",'
SDEnd0212:
	call cAndEpilog
ADEnd0210:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0219
	jmp SDEnd0075
SD0219:
	call cPush
	call IsBit1
	 dq 88
	or rPOk, rPOk
	jnz SD021A
	jmp SDEnd021A
SD021A:
	call cPush
	mov rFactCnt, 16
	or rFactCnt, rFactCnt
	jz FacEnd021B
FacRep021B:
	call n
	dec rFactCnt
	jrcxz FacEnd021B
	jz FacEnd021B
	jmp FacRep021B
FacEnd021B:
	call cDrop
	or rPOk, rPOk
	jnz SD021C
	jmp SDEnd021A
SD021C:
	call pOut
	 db 0x1A, 0x0a, 0x09, '"B88 Debits amount"		: "'
	or rPOk, rPOk
	jnz SD021D
	jmp SDEnd021A
SD021D:
	call pOut
	 db 0x01, "("
SDEnd021A:
	or rPOk, rPOk
	jnz AD021E
	jmp ADEnd021E
AD021E:
	call cAndProlog
	call cPush
	mov rFactCnt, 14
	or rFactCnt, rFactCnt
	jz FacEnd021F
FacRep021F:
	call n
	dec rFactCnt
	jrcxz FacEnd021F
	jz FacEnd021F
	jmp FacRep021F
FacEnd021F:
	call cDrop
	or rPOk, rPOk
	jnz SD0220
	jmp SDEnd0220
SD0220:
	call pOutLITrim
	or rPOk, rPOk
	jnz SD0221
	jmp SDEnd0220
SD0221:
	call pOut
	 db 0x01, "."
	or rPOk, rPOk
	jnz SD0222
	jmp SDEnd0220
SD0222:
	call cPush
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd0223
FacRep0223:
	call n
	dec rFactCnt
	jrcxz FacEnd0223
	jz FacEnd0223
	jmp FacRep0223
FacEnd0223:
	call cDrop
	or rPOk, rPOk
	jnz SD0224
	jmp SDEnd0220
SD0224:
	call pOutLI
	or rPOk, rPOk
	jnz SD0225
	jmp SDEnd0220
SD0225:
	call pOut
	 db 0x04, "[l])"
	or rPOk, rPOk
	jnz SD0226
	jmp SDEnd0220
SD0226:
	call pOut
	 db 0x02, '",'
SDEnd0220:
	call cAndEpilog
ADEnd021E:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0227
	jmp SDEnd0075
SD0227:
	call cPush
	call IsBit1
	 dq 89
	or rPOk, rPOk
	jnz SD0228
	jmp SDEnd0228
SD0228:
	call cPush
	mov rFactCnt, 16
	or rFactCnt, rFactCnt
	jz FacEnd0229
FacRep0229:
	call n
	dec rFactCnt
	jrcxz FacEnd0229
	jz FacEnd0229
	jmp FacRep0229
FacEnd0229:
	call cDrop
	or rPOk, rPOk
	jnz SD022A
	jmp SDEnd0228
SD022A:
	call pOut
	 db 0x22, 0x0a, 0x09, '"B89 Debits reversal amount"	: "'
	or rPOk, rPOk
	jnz SD022B
	jmp SDEnd0228
SD022B:
	call pOut
	 db 0x01, "("
SDEnd0228:
	or rPOk, rPOk
	jnz AD022C
	jmp ADEnd022C
AD022C:
	call cAndProlog
	call cPush
	mov rFactCnt, 14
	or rFactCnt, rFactCnt
	jz FacEnd022D
FacRep022D:
	call n
	dec rFactCnt
	jrcxz FacEnd022D
	jz FacEnd022D
	jmp FacRep022D
FacEnd022D:
	call cDrop
	or rPOk, rPOk
	jnz SD022E
	jmp SDEnd022E
SD022E:
	call pOutLITrim
	or rPOk, rPOk
	jnz SD022F
	jmp SDEnd022E
SD022F:
	call pOut
	 db 0x01, "."
	or rPOk, rPOk
	jnz SD0230
	jmp SDEnd022E
SD0230:
	call cPush
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd0231
FacRep0231:
	call n
	dec rFactCnt
	jrcxz FacEnd0231
	jz FacEnd0231
	jmp FacRep0231
FacEnd0231:
	call cDrop
	or rPOk, rPOk
	jnz SD0232
	jmp SDEnd022E
SD0232:
	call pOutLI
	or rPOk, rPOk
	jnz SD0233
	jmp SDEnd022E
SD0233:
	call pOut
	 db 0x04, "[l])"
	or rPOk, rPOk
	jnz SD0234
	jmp SDEnd022E
SD0234:
	call pOut
	 db 0x02, '",'
SDEnd022E:
	call cAndEpilog
ADEnd022C:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0235
	jmp SDEnd0075
SD0235:
	call cPush
	call IsBit1
	 dq 97
	or rPOk, rPOk
	jnz SD0236
	jmp SDEnd0236
SD0236:
	call cPush
	call cPush
	call pIn
	 db 0x0001, "C"
	jrcxz DL0237
	jmp DLEnd0237
DL0237:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "D"
DLEnd0237:
	call cDrop
	or rPOk, rPOk
	jnz SD0238
	jmp SDEnd0238
SD0238:
	mov rFactCnt, 16
	or rFactCnt, rFactCnt
	jz FacEnd0239
FacRep0239:
	call n
	dec rFactCnt
	jrcxz FacEnd0239
	jz FacEnd0239
	jmp FacRep0239
FacEnd0239:
SDEnd0238:
	call cDrop
	or rPOk, rPOk
	jnz SD023A
	jmp SDEnd0236
SD023A:
	call pOut
	 db 0x1E, 0x0a, 0x09, '"B97 Net reconciliation"	: "'
	or rPOk, rPOk
	jnz SD023B
	jmp SDEnd0236
SD023B:
	call pOutLI
	or rPOk, rPOk
	jnz SD023C
	jmp SDEnd0236
SD023C:
	call pOut
	 db 0x02, '",'
SDEnd0236:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD023D
	jmp SDEnd0075
SD023D:
	call cPush
	call IsBit1
	 dq 123
	or rPOk, rPOk
	jnz SD023E
	jmp SDEnd023E
SD023E:
	call cPush
	call LLLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep023F
	jmp FacEnd023F
FacRep023F:
	call ans
	dec rFactCnt
	jrcxz FacEnd023F
	jz FacEnd023F
	jmp FacRep023F
FacEnd023F:
	call cDrop
	or rPOk, rPOk
	jnz SD0240
	jmp SDEnd023E
SD0240:
	call pOut
	 db 0x1F, 0x0a, 0x09, '"B123 Proprietary totals"	: "'
	or rPOk, rPOk
	jnz SD0241
	jmp SDEnd023E
SD0241:
	call pOutLI
	or rPOk, rPOk
	jnz SD0242
	jmp SDEnd023E
SD0242:
	call pOut
	 db 0x02, '",'
SDEnd023E:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0243
	jmp SDEnd0075
SD0243:
	call cPush
	call IsBit1
	 dq 128
	or rPOk, rPOk
	jnz SD0244
	jmp SDEnd0244
SD0244:
	call cPush
	mov rFactCnt, 8
	or rFactCnt, rFactCnt
	jz FacEnd0245
FacRep0245:
	call b
	dec rFactCnt
	jrcxz FacEnd0245
	jz FacEnd0245
	jmp FacRep0245
FacEnd0245:
	call cDrop
	or rPOk, rPOk
	jnz SD0246
	jmp SDEnd0244
SD0246:
	call pOut
	 db 0x28, 0x0a, 0x09, '"B128 Message authentication code"	: "'
	or rPOk, rPOk
	jnz SD0247
	jmp SDEnd0244
SD0247:
	call pOutLI
	or rPOk, rPOk
	jnz SD0248
	jmp SDEnd0244
SD0248:
	call pOut
	 db 0x02, '",'
SDEnd0244:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0249
	jmp SDEnd0075
SD0249:
	call DropLastChar
SDEnd0075:
	call cDrop
	ret

;Fields0=
;	[IsBit(1), 			BitMap1],	
;	[IsBit(2), (LLVAR *ans),	pOut(0x0a, 0x09, '"B02 PAN (manual)"		: "'), pOutLI,	pOut('",')],
;	[IsBit(3), (6*n),		pOut(0x0a, 0x09, '"B03 Processing code"		: {') + Bit3 ],
;	[IsBit(4), (12*n),		pOut(0x0a, 0x09, '"B04 Amount transaction"	: "'), pOutLI, pOut("(")
;					+ (10*n), pOutLITrim, pOut("."), (2*n), pOutLI, pOut(")"),	pOut('",')],
;	[IsBit(5), 			pOut(0x0a, 0x09, '"B05"				: "'), 		pOut('",')],
;	[IsBit(6),			pOut(0x0a, 0x09, '"B06"				: "'), 		pOut('",')],
;	[IsBit(7), (10*n), 		pOut(0x0a, 0x09, '"B07 Date time transmission"	: "')
;											+ MM, pOutLI,	pOut('-'),
;											  DD, pOutLI,	pOut('T'), 
;											  hh, pOutLI,	pOut(':'), 
;											  mm, pOutLI,	pOut(':'),
;									 		 nss, pOutLI,	pOut('.000",')],
;	[IsBit(8), 			pOut(0x0a, 0x09, '"B08"				: "'), 		pOut('",')],
;	[IsBit(9), 			pOut(0x0a, 0x09, '"B09"				: "'),		pOut('",')],
;	[IsBit(10), 			pOut(0x0a, 0x09, '"B10"				: "'),		pOut('",')],
;	[IsBit(11), (6*n), 		pOut(0x0a, 0x09, '"B11 STAN"			: "'), pOutLI,	pOut('",')],	/*IFSF2003 12*n*/
;	[IsBit(12), (12*n),		pOut(0x0a, 0x09, '"B12 Date time transaction"	: "20')
;											+ YY, pOutLI, pOut('-'),	/*ISO8601*/
;											  MM, pOutLI, pOut('-'),
;											  DD, pOutLI, pOut('T'), 
;											  hh, pOutLI, pOut(':'), 
;											  mm, pOutLI, pOut(':'),
;											  nss,pOutLI, pOut('.000",')],
;	[IsBit(13), (4*n),		pOut(0x0a, 0x09, '"B13"				: "'), pOutLI,	pOut('",')],
;	[IsBit(14), (4*n),		pOut(0x0a, 0x09, '"B14"				: "'), pOutLI,	pOut('",')],
;	[IsBit(15), (6*n),		pOut(0x0a, 0x09, '"B15 Settlement date"		: "'), pOutLI,	pOut('",')],
;	[IsBit(16),			pOut(0x0a, 0x09, '"B16"				: "'),		pOut('",')],
;	[IsBit(17),			pOut(0x0a, 0x09, '"B17"				: "'),		pOut('",')],
;	[IsBit(18), (4*n),		pOut(0x0a, 0x09, '"B18 reference number"	: "'), pOutLI,	pOut('",')],
;	[IsBit(19),			pOut(0x0a, 0x09, '"B19"				: "'),		pOut('",')],
;	[IsBit(20), (3*n),		pOut(0x0a, 0x09, '"B20 Language code"		: "'), pOutLI,	pOut('",')],
;	[IsBit(21),			pOut(0x0a, 0x09, '"B21"				: "'),		pOut('",')],
;	
;	[IsBit(22), (12*an),		pOut(0x0a, 0x09, '"B22 POS data code" 		: {') + Bit22 ],
;											
;	[IsBit(23), 			pOut(0x0a, 0x09, '"B23"				: "'), pOutLI,	pOut('",')],
;	[IsBit(24), (3*n),		pOut(0x0a, 0x09, '"B24 Function code" 		: "'), pOutLI,	pOut(' (')
;											+ Bit24,	pOut(')",')],
;											
;	[IsBit(25), (4*n),		pOut(0x0a, 0x09, '"B25 Message reason code"	: "'), pOutLI,	pOut(' (')
;											+ Bit25,	pOut(')",')],
;	
;	[IsBit(26), (4*n),		pOut(0x0a, 0x09, '"B26 Card acceptor busnss code" : "'), pOutLI, pOut(' (')
;											+ Bit26,	pOut(')",')],
;	
;	[IsBit(27),			pOut(0x0a, 0x09, '"B27" 			: "'),		pOut('",')], 
;	[IsBit(28), (6*n),		pOut(0x0a, 0x09, '"B28"				: "'), pOutLI,	pOut('",')],
;	[IsBit(29),			pOut(0x0a, 0x09, '"B29"				: "'),		pOut('",')],
;	[IsBit(30), (24*n),		pOut(0x0a, 0x09, '"B30 Original amount"		: "'), 		pOut("(")
;					+ (22*n), pOutLITrim, pOut("."), (2*n), pOutLI, pOut("[l])"),	pOut('",')],
;	[IsBit(31),			pOut(0x0a, 0x09, '"B31"				: "'), 		pOut('",')],
;
;	[IsBit(32), 			pOut(0x0a, 0x09, '"B32 Acquiring institution ID"	: "'),
;		    LLVAR * (n,	pOutLI),								pOut('",')],
;	[IsBit(33),			pOut(0x0a, 0x09, '"B33"				: "'), 		pOut('",')],
;	[IsBit(34),			pOut(0x0a, 0x09, '"B34"				: "'), 		pOut('",')],
;	[IsBit(35), 			pOut(0x0a, 0x09, '"B35 Track 2"			: "'), 
;		    LLVAR * (ans, pOutLI),								pOut('",')],
;	[IsBit(36),			pOut(0x0a, 0x09, '"B36"				: "'),		pOut('",')],
;	[IsBit(37),			pOut(0x0a, 0x09, '"B37 Retrieval reference num"	: "'), pOutLI,	pOut('",')],
;	[IsBit(38), (6*anp),		pOut(0x0a, 0x09, '"B38 Authorisation code"	: "'), pOutLI,	pOut('",')],
;	
;	[IsBit(39), (3*n),		pOut(0x0a, 0x09, '"B39 Action code"		: "'), pOutLI,	pOut(' (')
;											+ Bit39,	pOut(')",')],
;											
;	[IsBit(40), 			pOut(0x0a, 0x09, '"B40"				: "'), 		pOut('",')],
;	[IsBit(41), (8*ans),		pOut(0x0a, 0x09, '"B41 Terminal ID"		: "'), pOutLI,	pOut('",')],
;	[IsBit(42), (15*ans),		pOut(0x0a, 0x09, '"B42 CAIC"			: "'), pOutLI,	pOut('",')],
;	[IsBit(43), (LLVAR * ans),	pOut(0x0a, 0x09, '"B43 CAN/L"			: "') + LLVAR * ( '\', pOut('\\')
;													  | '"', pOut('\"')
;													  | ans, pOutLI)   
;											     ,  	pOut('",')],
;	[IsBit(44), 			pOut(0x0a, 0x09, '"B44" 			: "'), 		pOut('",')],
;	[IsBit(45),			pOut(0x0a, 0x09, '"B45 Track 1 data"		: "'),
;		    LLVAR * (ans, pOutLI),							pOut('",')],
;	[IsBit(46), 			pOut(0x0a, 0x09, '"B46"				: "'), 		pOut('",')],
;	[IsBit(47), 			pOut(0x0a, 0x09, '"B47"				: "'), 		pOut('",')],
;	[IsBit(48), (LLLVAR * b),	pOut(0x0a, 0x09, '"B48 Msg ctrl data elements"	: {') + (3*b, BitMap48, Fields48, SetBitMapCur(*aBitMap0) )],
;	[IsBit(49), (3*an),		pOut(0x0a, 0x09, '"B49 Currency code"		: "'), pOutLI,	pOut(' (')
;											+ Bit49,	pOut(')",')],
;
;	[IsBit(50), (3*n),		pOut(0x0a, 0x09, '"B50 Currency code reconcili"	: "'), pOutLI,	pOut('",')],
;	[IsBit(51),			pOut(0x0a, 0x09, '"B51"				: "'), 		pOut('",')],
;	[IsBit(52), (8*b),		pOut(0x0a, 0x09, '"B52 PIN data"		: "'),pOutLIHex,pOut('",')],
;	[IsBit(53), (LLVAR * b), 	pOut(0x0a, 0x09, '"B53 Security related info"	: {') + Bit53H2H ],
;	[IsBit(54), (LLLVAR*ans),	pOut(0x0a, 0x09, '"B54 Amounts additional"	: "'), pOutLI,	pOut('",')],
;	[IsBit(55),			pOut(0x0a, 0x09, '"B55"				: "'), 		pOut('",')],
;	[IsBit(56), 			pOut(0x0a, 0x09, '"B56 Original data elements"	: "'),
;		    LLVAR * (n, pOutLI),								pOut('",')],
;	[IsBit(57),			pOut(0x0a, 0x09, '"B57"				: "'), 		pOut('",')],
;	[IsBit(58),			pOut(0x0a, 0x09, '"B58"				: "'), 		pOut('",')],
;	[IsBit(59),			pOut(0x0a, 0x09, '"B59 Transport data"		: "'),
;		    LLLVAR * (ans, pOutLI),								pOut('",')],
;	[IsBit(60), LLLVAR * ans,	pOut(0x0a, 0x09, '"B60 Entered PIN Digits"	: "'), pOutLI,	pOut('",')],
;	[IsBit(61), LLLVAR * ans, 	pOut(0x0a, 0x09, '"B61 Failed PIN attempts"	: "'), pOutLI,	pOut('",')],
;	[IsBit(62), (LLLVAR*ans),	pOut(0x0a, 0x09, '"B62 Product sets"		: {') + Bit62 ],
;	[IsBit(63), (LLLVAR*ans),	pOut(0x0a, 0x09, '"B63 Product data"		: {') + (Bit63| LLLVAR*ans, pOut('"Warning format error"'))],
;	[IsBit(64), (8*b),		pOut(0x0a, 0x09, '"B64 MAC"			: "'), pOutLIHex, pOut('",')],		/* no spec in CGI spec. */
;	[IsBit1(74), (10*n),		pOut(0x0a, 0x09, '"B74 Credits number"		: "'), pOutLI,	pOut('",')],
;	[IsBit1(75), (10*n),		pOut(0x0a, 0x09, '"B75 Credits reversal number"	: "'), pOutLI,	pOut('",')],
;	[IsBit1(76), (10*n),		pOut(0x0a, 0x09, '"B76 Debits number"		: "'), pOutLI,	pOut('",')],
;	[IsBit1(77), (10*n),		pOut(0x0a, 0x09, '"B77 Debits reversal number"	: "'), pOutLI,	pOut('",')],
;	[IsBit1(86), (16*n),		pOut(0x0a, 0x09, '"B86 Credits amount"		: "'), 		pOut("(")
;					+ (14*n), pOutLITrim, pOut("."), (2*n), pOutLI, pOut("[l])"),	pOut('",')],
;	[IsBit1(87), (16*n),		pOut(0x0a, 0x09, '"B87 Credits reversal amount"	: "'), 	 	pOut("(")
;					+ (14*n), pOutLITrim, pOut("."), (2*n), pOutLI, pOut("[l])"),	pOut('",')],
;	[IsBit1(88), (16*n),		pOut(0x0a, 0x09, '"B88 Debits amount"		: "'), 	 	pOut("(")
;					+ (14*n), pOutLITrim, pOut("."), (2*n), pOutLI, pOut("[l])"),	pOut('",')],
;	[IsBit1(89), (16*n),		pOut(0x0a, 0x09, '"B89 Debits reversal amount"	: "'), 		pOut("(")
;					+ (14*n), pOutLITrim, pOut("."), (2*n), pOutLI, pOut("[l])"),	pOut('",')],
;	[IsBit1(97), (("C"|"D"),16*n),	pOut(0x0a, 0x09, '"B97 Net reconciliation"	: "'), pOutLI,	pOut('",')],
;	[IsBit1(123), (LLLVAR*ans),	pOut(0x0a, 0x09, '"B123 Proprietary totals"	: "'), pOutLI,	pOut('",')],
;	[IsBit1(128), (8*b),		pOut(0x0a, 0x09, '"B128 Message authentication code"	: "'), pOutLI,	pOut('",')],
;	DropLastChar ;
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Fields48:
	call cPush
	call cPush
	call IsBit
	 dq 2
	or rPOk, rPOk
	jnz SD024A
	jmp SDEnd024A
SD024A:
	call cPush
	mov rFactCnt, 20
	or rFactCnt, rFactCnt
	jz FacEnd024B
FacRep024B:
	call an
	dec rFactCnt
	jrcxz FacEnd024B
	jz FacEnd024B
	jmp FacRep024B
FacEnd024B:
	call cDrop
	or rPOk, rPOk
	jnz SD024C
	jmp SDEnd024A
SD024C:
	call pOut
	 db 0x23, 0x0a, 0x09, 0x09, '"B02 Hard-/Software config."	: "'
	or rPOk, rPOk
	jnz SD024D
	jmp SDEnd024A
SD024D:
	call pOutLI
	or rPOk, rPOk
	jnz SD024E
	jmp SDEnd024A
SD024E:
	call pOut
	 db 0x02, '",'
SDEnd024A:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD024F
	jmp SDEnd024F
SD024F:
	call cPush
	call IsBit
	 dq 3
	or rPOk, rPOk
	jnz SD0250
	jmp SDEnd0250
SD0250:
	call cPush
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd0251
FacRep0251:
	call a
	dec rFactCnt
	jrcxz FacEnd0251
	jz FacEnd0251
	jmp FacRep0251
FacEnd0251:
	call cDrop
	or rPOk, rPOk
	jnz SD0252
	jmp SDEnd0250
SD0252:
	call pOut
	 db 0x1B, 0x0a, 0x09, 0x09, '"B03 Language code"		: "'
	or rPOk, rPOk
	jnz SD0253
	jmp SDEnd0250
SD0253:
	call pOutLI
	or rPOk, rPOk
	jnz SD0254
	jmp SDEnd0250
SD0254:
	call pOut
	 db 0x02, '",'
SDEnd0250:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0255
	jmp SDEnd024F
SD0255:
	call cPush
	call IsBit
	 dq 4
	or rPOk, rPOk
	jnz SD0256
	jmp SDEnd0256
SD0256:
	call cPush
	mov rFactCnt, 10
	or rFactCnt, rFactCnt
	jz FacEnd0257
FacRep0257:
	call n
	dec rFactCnt
	jrcxz FacEnd0257
	jz FacEnd0257
	jmp FacRep0257
FacEnd0257:
	call cDrop
	or rPOk, rPOk
	jnz SD0258
	jmp SDEnd0256
SD0258:
	call pOut
	 db 0x22, 0x0a, 0x09, 0x09, '"B04 Batch/sequence number"	: "'
	or rPOk, rPOk
	jnz SD0259
	jmp SDEnd0256
SD0259:
	call pOutLI
	or rPOk, rPOk
	jnz SD025A
	jmp SDEnd0256
SD025A:
	call pOut
	 db 0x02, '",'
SDEnd0256:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD025B
	jmp SDEnd024F
SD025B:
	call cPush
	call IsBit
	 dq 5
	or rPOk, rPOk
	jnz SD025C
	jmp SDEnd025C
SD025C:
	call cPush
	mov rFactCnt, 3
	or rFactCnt, rFactCnt
	jz FacEnd025D
FacRep025D:
	call n
	dec rFactCnt
	jrcxz FacEnd025D
	jz FacEnd025D
	jmp FacRep025D
FacEnd025D:
	call cDrop
	or rPOk, rPOk
	jnz SD025E
	jmp SDEnd025C
SD025E:
	call pOut
	 db 0x1A, 0x0a, 0x09, 0x09, '"B05 Shift number"		: "'
	or rPOk, rPOk
	jnz SD025F
	jmp SDEnd025C
SD025F:
	call pOutLI
	or rPOk, rPOk
	jnz SD0260
	jmp SDEnd025C
SD0260:
	call pOut
	 db 0x02, '",'
SDEnd025C:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0261
	jmp SDEnd024F
SD0261:
	call cPush
	call IsBit
	 dq 6
	or rPOk, rPOk
	jnz SD0262
	jmp SDEnd0262
SD0262:
	call cPush
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep0263
	jmp FacEnd0263
FacRep0263:
	call n
	dec rFactCnt
	jrcxz FacEnd0263
	jz FacEnd0263
	jmp FacRep0263
FacEnd0263:
	call cDrop
	or rPOk, rPOk
	jnz SD0264
	jmp SDEnd0262
SD0264:
	call pOut
	 db 0x17, 0x0a, 0x09, 0x09, '"B06 Clerk ID"			: "'
	or rPOk, rPOk
	jnz SD0265
	jmp SDEnd0262
SD0265:
	call pOutLI
	or rPOk, rPOk
	jnz SD0266
	jmp SDEnd0262
SD0266:
	call pOut
	 db 0x02, '",'
SDEnd0262:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0267
	jmp SDEnd024F
SD0267:
	call cPush
	call IsBit
	 dq 8
	or rPOk, rPOk
	jnz SD0268
	jmp SDEnd0268
SD0268:
	call cPush
	call LLLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep0269
	jmp FacEnd0269
FacRep0269:
	call ans
	dec rFactCnt
	jrcxz FacEnd0269
	jz FacEnd0269
	jmp FacRep0269
FacEnd0269:
	or rPOk, rPOk
	jnz SD026A
	jmp SDEnd026A
SD026A:
	call pOut
	 db 0x1B, 0x0a, 0x09, 0x09, '"B08 Customer data"		: "'
SDEnd026A:
	call cDrop
SDEnd0268:
	or rPOk, rPOk
	jnz AD026B
	jmp ADEnd026B
AD026B:
	call cAndProlog
	call LLLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep026C
	jmp FacEnd026C
FacRep026C:
	call cPush
	call pIn
	 db 0x0001, '\'
	or rPOk, rPOk
	jnz SD026D
	jmp SDEnd026D
SD026D:
	call pOut
	 db 0x02, '\\'
SDEnd026D:
	jrcxz DL026E
	jmp DLEnd026E
DL026E:	inc rcx
	call cTop
	call pIn
	 db 1, 34
	or rPOk, rPOk
	jnz SD026F
	jmp SDEnd026F
SD026F:
	call pOut
	 db 0x02, '\"'
SDEnd026F:
	jrcxz DL0270
	jmp DLEnd026E
DL0270:	inc rcx
	call cTop
	call ans
	or rPOk, rPOk
	jnz SD0271
	jmp SDEnd0271
SD0271:
	call pOutLI
SDEnd0271:
DLEnd026E:
	call cDrop
	dec rFactCnt
	jrcxz FacEnd026C
	jz FacEnd026C
	jmp FacRep026C
FacEnd026C:
	or rPOk, rPOk
	jnz SD0272
	jmp SDEnd0272
SD0272:
	call pOut
	 db 0x02, '",'
SDEnd0272:
	call cAndEpilog
ADEnd026B:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0273
	jmp SDEnd024F
SD0273:
	call cPush
	call IsBit
	 dq 9
	or rPOk, rPOk
	jnz SD0274
	jmp SDEnd0274
SD0274:
	call cPush
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep0275
	jmp FacEnd0275
FacRep0275:
	call ns
	dec rFactCnt
	jrcxz FacEnd0275
	jz FacEnd0275
	jmp FacRep0275
FacEnd0275:
	call cDrop
	or rPOk, rPOk
	jnz SD0276
	jmp SDEnd0274
SD0276:
	call pOut
	 db 0x1D, 0x0a, 0x09, 0x09, '"B09 Track2 2nd card"		: "'
	or rPOk, rPOk
	jnz SD0277
	jmp SDEnd0274
SD0277:
	call pOutLI
	or rPOk, rPOk
	jnz SD0278
	jmp SDEnd0274
SD0278:
	call pOut
	 db 0x02, '",'
SDEnd0274:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0279
	jmp SDEnd024F
SD0279:
	call cPush
	call IsBit
	 dq 10
	or rPOk, rPOk
	jnz SD027A
	jmp SDEnd027A
SD027A:
	call cPush
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep027B
	jmp FacEnd027B
FacRep027B:
	call ns
	dec rFactCnt
	jrcxz FacEnd027B
	jz FacEnd027B
	jmp FacRep027B
FacEnd027B:
	call cDrop
	or rPOk, rPOk
	jnz SD027C
	jmp SDEnd027A
SD027C:
	call pOut
	 db 0x1D, 0x0a, 0x09, 0x09, '"B10 Track1 2nd card"		: "'
	or rPOk, rPOk
	jnz SD027D
	jmp SDEnd027A
SD027D:
	call pOutLI
	or rPOk, rPOk
	jnz SD027E
	jmp SDEnd027A
SD027E:
	call pOut
	 db 0x02, '",'
SDEnd027A:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD027F
	jmp SDEnd024F
SD027F:
	call cPush
	call IsBit
	 dq 13
	or rPOk, rPOk
	jnz SD0280
	jmp SDEnd0280
SD0280:
	call cPush
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep0281
	jmp FacEnd0281
FacRep0281:
	call ans
	dec rFactCnt
	jrcxz FacEnd0281
	jz FacEnd0281
	jmp FacRep0281
FacEnd0281:
	call cDrop
	or rPOk, rPOk
	jnz SD0282
	jmp SDEnd0280
SD0282:
	call pOut
	 db 0x18, 0x0a, 0x09, 0x09, '"B13 RFID data"			: "'
	or rPOk, rPOk
	jnz SD0283
	jmp SDEnd0280
SD0283:
	call pOutLI
	or rPOk, rPOk
	jnz SD0284
	jmp SDEnd0280
SD0284:
	call pOut
	 db 0x02, '",'
SDEnd0280:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0285
	jmp SDEnd024F
SD0285:
	call cPush
	call IsBit
	 dq 14
	or rPOk, rPOk
	jnz SD0286
	jmp SDEnd0286
SD0286:
	call cPush
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd0287
FacRep0287:
	call ans
	dec rFactCnt
	jrcxz FacEnd0287
	jz FacEnd0287
	jmp FacRep0287
FacEnd0287:
	call cDrop
	or rPOk, rPOk
	jnz SD0288
	jmp SDEnd0286
SD0288:
	call pOut
	 db 0x22, 0x0a, 0x09, 0x09, '"B14 PIN encryption method"	: "'
	or rPOk, rPOk
	jnz SD0289
	jmp SDEnd0286
SD0289:
	call pOutLI
	or rPOk, rPOk
	jnz SD028A
	jmp SDEnd0286
SD028A:
	call pOut
	 db 0x02, '",'
SDEnd0286:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD028B
	jmp SDEnd024F
SD028B:
	call cPush
	call IsBit
	 dq 15
	or rPOk, rPOk
	jnz SD028C
	jmp SDEnd028C
SD028C:
	call cPush
	mov rFactCnt, 8
	or rFactCnt, rFactCnt
	jz FacEnd028D
FacRep028D:
	call n
	dec rFactCnt
	jrcxz FacEnd028D
	jz FacEnd028D
	jmp FacRep028D
FacEnd028D:
	call cDrop
	or rPOk, rPOk
	jnz SD028E
	jmp SDEnd028C
SD028E:
	call pOut
	 db 0x1F, 0x0a, 0x09, 0x09, '"B15 Settlement period"		: "'
	or rPOk, rPOk
	jnz SD028F
	jmp SDEnd028C
SD028F:
	call pOutLI
	or rPOk, rPOk
	jnz SD0290
	jmp SDEnd028C
SD0290:
	call pOut
	 db 0x02, '",'
SDEnd028C:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0291
	jmp SDEnd024F
SD0291:
	call cPush
	call IsBit
	 dq 16
	or rPOk, rPOk
	jnz SD0292
	jmp SDEnd0292
SD0292:
	call cPush
	mov rFactCnt, 14
	or rFactCnt, rFactCnt
	jz FacEnd0293
FacRep0293:
	call n
	dec rFactCnt
	jrcxz FacEnd0293
	jz FacEnd0293
	jmp FacRep0293
FacEnd0293:
	call cDrop
	or rPOk, rPOk
	jnz SD0294
	jmp SDEnd0292
SD0294:
	call pOut
	 db 0x19, 0x0a, 0x09, 0x09, '"B16 Online time"		: "'
	or rPOk, rPOk
	jnz SD0295
	jmp SDEnd0292
SD0295:
	call pOutLI
	or rPOk, rPOk
	jnz SD0296
	jmp SDEnd0292
SD0296:
	call pOut
	 db 0x02, '",'
SDEnd0292:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0297
	jmp SDEnd024F
SD0297:
	call cPush
	call IsBit
	 dq 37
	or rPOk, rPOk
	jnz SD0298
	jmp SDEnd0298
SD0298:
	call ans
	or rPOk, rPOk
	jnz SD0299
	jmp SDEnd0298
SD0299:
	call pOut
	 db 0x22, 0x0a, 0x09, 0x09, '"B37 Vehicle ID entry mode"	: "'
	or rPOk, rPOk
	jnz SD029A
	jmp SDEnd0298
SD029A:
	call pOutLI
	or rPOk, rPOk
	jnz SD029B
	jmp SDEnd0298
SD029B:
	call pOut
	 db 0x02, '",'
SDEnd0298:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD029C
	jmp SDEnd024F
SD029C:
	call cPush
	call IsBit
	 dq 38
	or rPOk, rPOk
	jnz SD029D
	jmp SDEnd029D
SD029D:
	call ans
	or rPOk, rPOk
	jnz SD029E
	jmp SDEnd029D
SD029E:
	call pOut
	 db 0x22, 0x0a, 0x09, 0x09, '"B38 Pump linked indicator"	: "'
	or rPOk, rPOk
	jnz SD029F
	jmp SDEnd029D
SD029F:
	call pOutLI
	or rPOk, rPOk
	jnz SD02A0
	jmp SDEnd029D
SD02A0:
	call pOut
	 db 0x02, '",'
SDEnd029D:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD02A1
	jmp SDEnd024F
SD02A1:
	call cPush
	call IsBit
	 dq 39
	or rPOk, rPOk
	jnz SD02A2
	jmp SDEnd02A2
SD02A2:
	call cPush
	mov rFactCnt, 10
	or rFactCnt, rFactCnt
	jz FacEnd02A3
FacRep02A3:
	call n
	dec rFactCnt
	jrcxz FacEnd02A3
	jz FacEnd02A3
	jmp FacRep02A3
FacEnd02A3:
	call cDrop
	or rPOk, rPOk
	jnz SD02A4
	jmp SDEnd02A2
SD02A4:
	call pOut
	 db 0x21, 0x0a, 0x09, 0x09, '"B39 Delivery note number"	: "'
	or rPOk, rPOk
	jnz SD02A5
	jmp SDEnd02A2
SD02A5:
	call pOutLI
	or rPOk, rPOk
	jnz SD02A6
	jmp SDEnd02A2
SD02A6:
	call pOut
	 db 0x02, '",'
SDEnd02A2:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD02A7
	jmp SDEnd024F
SD02A7:
	call cPush
	call IsBit
	 dq 41
	or rPOk, rPOk
	jnz SD02A8
	jmp SDEnd02A8
SD02A8:
	call cPush
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep02A9
	jmp FacEnd02A9
FacRep02A9:
	call ans
	dec rFactCnt
	jrcxz FacEnd02A9
	jz FacEnd02A9
	jmp FacRep02A9
FacEnd02A9:
	call cDrop
	or rPOk, rPOk
	jnz SD02AA
	jmp SDEnd02A8
SD02AA:
	call pOut
	 db 0x1B, 0x0a, 0x09, 0x09, '"B41 Propriety use"		: "'
	or rPOk, rPOk
	jnz SD02AB
	jmp SDEnd02A8
SD02AB:
	call pOutLI
	or rPOk, rPOk
	jnz SD02AC
	jmp SDEnd02A8
SD02AC:
	call pOut
	 db 0x02, '",'
SDEnd02A8:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD02AD
	jmp SDEnd024F
SD02AD:
	call cPush
	call IsBit
	 dq 43
	or rPOk, rPOk
	jnz SD02AE
	jmp SDEnd02AE
SD02AE:
	call n
	or rPOk, rPOk
	jnz SD02AF
	jmp SDEnd02AE
SD02AF:
	call pOut
	 db 0x20, 0x0a, 0x09, 0x09, '"B43 Solution identifier"	: "'
	or rPOk, rPOk
	jnz SD02B0
	jmp SDEnd02AE
SD02B0:
	call pOutLI
	or rPOk, rPOk
	jnz SD02B1
	jmp SDEnd02AE
SD02B1:
	call pOut
	 db 0x02, '",'
SDEnd02AE:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD02B2
	jmp SDEnd024F
SD02B2:
	call cPush
	call IsBit
	 dq 44
	or rPOk, rPOk
	jnz SD02B3
	jmp SDEnd02B3
SD02B3:
	mov rFactCnt, 6
	or rFactCnt, rFactCnt
	jz FacEnd02B4
FacRep02B4:
	call n
	dec rFactCnt
	jrcxz FacEnd02B4
	jz FacEnd02B4
	jmp FacRep02B4
FacEnd02B4:
	or rPOk, rPOk
	jnz SD02B5
	jmp SDEnd02B3
SD02B5:
	call pOut
	 db 0x1D, 0x0a, 0x09, 0x09, '"B44 Truck/Driver ID"		: "'
	or rPOk, rPOk
	jnz SD02B6
	jmp SDEnd02B3
SD02B6:
	call pOutLI
	or rPOk, rPOk
	jnz SD02B7
	jmp SDEnd02B3
SD02B7:
	call pOut
	 db 0x02, '",'
SDEnd02B3:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD02B8
	jmp SDEnd024F
SD02B8:
	call cPush
	call IsBit
	 dq 45
	or rPOk, rPOk
	jnz SD02B9
	jmp SDEnd02B9
SD02B9:
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep02BA
	jmp FacEnd02BA
FacRep02BA:
	call n
	dec rFactCnt
	jrcxz FacEnd02BA
	jz FacEnd02BA
	jmp FacRep02BA
FacEnd02BA:
	or rPOk, rPOk
	jnz SD02BB
	jmp SDEnd02B9
SD02BB:
	call pOut
	 db 0x1F, 0x0a, 0x09, 0x09, '"B45 VIB box identifier"	: "'
	or rPOk, rPOk
	jnz SD02BC
	jmp SDEnd02B9
SD02BC:
	call pOutLI
	or rPOk, rPOk
	jnz SD02BD
	jmp SDEnd02B9
SD02BD:
	call pOut
	 db 0x02, '",'
SDEnd02B9:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD02BE
	jmp SDEnd024F
SD02BE:
	call cPush
	call IsBit
	 dq 46
	or rPOk, rPOk
	jnz SD02BF
	jmp SDEnd02BF
SD02BF:
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep02C0
	jmp FacEnd02C0
FacRep02C0:
	call an
	dec rFactCnt
	jrcxz FacEnd02C0
	jz FacEnd02C0
	jmp FacRep02C0
FacEnd02C0:
	or rPOk, rPOk
	jnz SD02C1
	jmp SDEnd02BF
SD02C1:
	call pOut
	 db 0x18, 0x0a, 0x09, 0x09, '"B46 Truck VIN"			: "'
	or rPOk, rPOk
	jnz SD02C2
	jmp SDEnd02BF
SD02C2:
	call pOutLI
	or rPOk, rPOk
	jnz SD02C3
	jmp SDEnd02BF
SD02C3:
	call pOut
	 db 0x02, '",'
SDEnd02BF:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD02C4
	jmp SDEnd024F
SD02C4:
	call cPush
	call IsBit
	 dq 47
	or rPOk, rPOk
	jnz SD02C5
	jmp SDEnd02C5
SD02C5:
	call LVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep02C6
	jmp FacEnd02C6
FacRep02C6:
	call n
	dec rFactCnt
	jrcxz FacEnd02C6
	jz FacEnd02C6
	jmp FacRep02C6
FacEnd02C6:
	or rPOk, rPOk
	jnz SD02C7
	jmp SDEnd02C5
SD02C7:
	call pOut
	 db 0x16, 0x0a, 0x09, 0x09, '"B47 Mileage"			: "'
	or rPOk, rPOk
	jnz SD02C8
	jmp SDEnd02C5
SD02C8:
	call pOutLI
	or rPOk, rPOk
	jnz SD02C9
	jmp SDEnd02C5
SD02C9:
	call pOut
	 db 0x02, '",'
SDEnd02C5:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD02CA
	jmp SDEnd024F
SD02CA:
	call cPush
	call IsBit
	 dq 48
	or rPOk, rPOk
	jnz SD02CB
	jmp SDEnd02CB
SD02CB:
	mov rFactCnt, 14
	or rFactCnt, rFactCnt
	jz FacEnd02CC
FacRep02CC:
	call n
	dec rFactCnt
	jrcxz FacEnd02CC
	jz FacEnd02CC
	jmp FacRep02CC
FacEnd02CC:
	or rPOk, rPOk
	jnz SD02CD
	jmp SDEnd02CB
SD02CD:
	call pOut
	 db 0x18, 0x0a, 0x09, 0x09, '"B48 Timestamp"			: "'
	or rPOk, rPOk
	jnz SD02CE
	jmp SDEnd02CB
SD02CE:
	call pOutLI
	or rPOk, rPOk
	jnz SD02CF
	jmp SDEnd02CB
SD02CF:
	call pOut
	 db 0x02, '",'
SDEnd02CB:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD02D0
	jmp SDEnd024F
SD02D0:
	call cPush
	call IsBit
	 dq 49
	or rPOk, rPOk
	jnz SD02D1
	jmp SDEnd02D1
SD02D1:
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep02D2
	jmp FacEnd02D2
FacRep02D2:
	call b
	dec rFactCnt
	jrcxz FacEnd02D2
	jz FacEnd02D2
	jmp FacRep02D2
FacEnd02D2:
	or rPOk, rPOk
	jnz SD02D3
	jmp SDEnd02D1
SD02D3:
	call pOut
	 db 0x20, 0x0a, 0x09, 0x09, '"B49 VIB additional data"	: "'
	or rPOk, rPOk
	jnz SD02D4
	jmp SDEnd02D1
SD02D4:
	call pOutLI
	or rPOk, rPOk
	jnz SD02D5
	jmp SDEnd02D1
SD02D5:
	call pOut
	 db 0x02, '",'
SDEnd02D1:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD02D6
	jmp SDEnd024F
SD02D6:
	call cPush
	call IsBit
	 dq 50
	or rPOk, rPOk
	jnz SD02D7
	jmp SDEnd02D7
SD02D7:
	call cPush
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd02D8
FacRep02D8:
	call n
	dec rFactCnt
	jrcxz FacEnd02D8
	jz FacEnd02D8
	jmp FacRep02D8
FacEnd02D8:
	call cDrop
	or rPOk, rPOk
	jnz SD02D9
	jmp SDEnd02D7
SD02D9:
	call pOut
	 db 0x13, 0x0a, 0x09, 0x09, '"B50 Pump"			: "'
	or rPOk, rPOk
	jnz SD02DA
	jmp SDEnd02D7
SD02DA:
	call pOutLI
	or rPOk, rPOk
	jnz SD02DB
	jmp SDEnd02D7
SD02DB:
	call pOut
	 db 0x02, '",'
SDEnd02D7:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD02DC
	jmp SDEnd024F
SD02DC:
	call cPush
	call IsBit
	 dq 51
	or rPOk, rPOk
	jnz SD02DD
	jmp SDEnd02DD
SD02DD:
	call cPush
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd02DE
FacRep02DE:
	call n
	dec rFactCnt
	jrcxz FacEnd02DE
	jz FacEnd02DE
	jmp FacRep02DE
FacEnd02DE:
	call cDrop
	or rPOk, rPOk
	jnz SD02DF
	jmp SDEnd02DD
SD02DF:
	call pOut
	 db 0x15, 0x0a, 0x09, 0x09, '"B51 Nozzle"			: "'
	or rPOk, rPOk
	jnz SD02E0
	jmp SDEnd02DD
SD02E0:
	call pOutLI
	or rPOk, rPOk
	jnz SD02E1
	jmp SDEnd02DD
SD02E1:
	call pOut
	 db 0x02, '",'
SDEnd02DD:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD02E2
	jmp SDEnd024F
SD02E2:
	call cPush
	call IsBit
	 dq 52
	or rPOk, rPOk
	jnz SD02E3
	jmp SDEnd02E3
SD02E3:
	mov rFactCnt, 7
	or rFactCnt, rFactCnt
	jz FacEnd02E4
FacRep02E4:
	call b
	dec rFactCnt
	jrcxz FacEnd02E4
	jz FacEnd02E4
	jmp FacRep02E4
FacEnd02E4:
	or rPOk, rPOk
	jnz SD02E5
	jmp SDEnd02E3
SD02E5:
	call pOut
	 db 0x1A, 0x0a, 0x09, 0x09, '"B52 IDS specific"		: "'
	or rPOk, rPOk
	jnz SD02E6
	jmp SDEnd02E3
SD02E6:
	call pOutLI
	or rPOk, rPOk
	jnz SD02E7
	jmp SDEnd02E3
SD02E7:
	call pOut
	 db 0x02, '",'
SDEnd02E3:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD02E8
	jmp SDEnd024F
SD02E8:
	call cPush
	call IsBit
	 dq 53
	or rPOk, rPOk
	jnz SD02E9
	jmp SDEnd02E9
SD02E9:
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep02EA
	jmp FacEnd02EA
FacRep02EA:
	call b
	dec rFactCnt
	jrcxz FacEnd02EA
	jz FacEnd02EA
	jmp FacRep02EA
FacEnd02EA:
	or rPOk, rPOk
	jnz SD02EB
	jmp SDEnd02E9
SD02EB:
	call pOut
	 db 0x1A, 0x0a, 0x09, 0x09, '"B53 IDS specific"		: "'
	or rPOk, rPOk
	jnz SD02EC
	jmp SDEnd02E9
SD02EC:
	call pOutLI
	or rPOk, rPOk
	jnz SD02ED
	jmp SDEnd02E9
SD02ED:
	call pOut
	 db 0x02, '",'
SDEnd02E9:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD02EE
	jmp SDEnd024F
SD02EE:
	call DropLastChar
	or rPOk, rPOk
	jnz SD02EF
	jmp SDEnd024F
SD02EF:
	call pOut
	 db 0x02, '},'
SDEnd024F:
	call cDrop
	ret

;Fields48=
;	[IsBit(2), (20*an),		pOut(0x0a, 0x09, 0x09, '"B02 Hard-/Software config."	: "'), pOutLI,	pOut('",')],
;	[IsBit(3), (2*a),		pOut(0x0a, 0x09, 0x09, '"B03 Language code"		: "'), pOutLI,	pOut('",')],
;	[IsBit(4), (10*n),		pOut(0x0a, 0x09, 0x09, '"B04 Batch/sequence number"	: "'), pOutLI,	pOut('",')],
;	[IsBit(5), (3*n),		pOut(0x0a, 0x09, 0x09, '"B05 Shift number"		: "'), pOutLI,	pOut('",')],
;	[IsBit(6), (LLVAR*n),		pOut(0x0a, 0x09, 0x09, '"B06 Clerk ID"			: "'), pOutLI,	pOut('",')],
;	[IsBit(8), (LLLVAR * ans,	pOut(0x0a, 0x09, 0x09, '"B08 Customer data"		: "')) + LLLVAR * ( '\', pOut('\\')
;														  | '"', pOut('\"')
;														  | ans, pOutLI)
;											    	     ,		pOut('",')],
;	[IsBit(9),  (LLVAR * ns),	pOut(0x0a, 0x09, 0x09, '"B09 Track2 2nd card"		: "'), pOutLI,	pOut('",')],
;	[IsBit(10), (LLVAR * ns),	pOut(0x0a, 0x09, 0x09, '"B10 Track1 2nd card"		: "'), pOutLI,	pOut('",')],
;	[IsBit(13), (LLVAR * ans),	pOut(0x0a, 0x09, 0x09, '"B13 RFID data"			: "'), pOutLI,	pOut('",')],
;	[IsBit(14), (2*ans), 		pOut(0x0a, 0x09, 0x09, '"B14 PIN encryption method"	: "'), pOutLI,	pOut('",')],
;	[IsBit(15), (8*n), 		pOut(0x0a, 0x09, 0x09, '"B15 Settlement period"		: "'), pOutLI,	pOut('",')],
;	[IsBit(16), (14*n), 		pOut(0x0a, 0x09, 0x09, '"B16 Online time"		: "'), pOutLI,	pOut('",')],
;	[IsBit(37), ans, 		pOut(0x0a, 0x09, 0x09, '"B37 Vehicle ID entry mode"	: "'), pOutLI,	pOut('",')],
;	[IsBit(38), ans, 		pOut(0x0a, 0x09, 0x09, '"B38 Pump linked indicator"	: "'), pOutLI,	pOut('",')],
;	[IsBit(39), (10*n), 		pOut(0x0a, 0x09, 0x09, '"B39 Delivery note number"	: "'), pOutLI,	pOut('",')],
;	[IsBit(41), (LLVAR*ans), 	pOut(0x0a, 0x09, 0x09, '"B41 Propriety use"		: "'), pOutLI,	pOut('",')],
;	[IsBit(43), n, 			pOut(0x0a, 0x09, 0x09, '"B43 Solution identifier"	: "'), pOutLI,	pOut('",')],
;	[IsBit(44), 6*n, 		pOut(0x0a, 0x09, 0x09, '"B44 Truck/Driver ID"		: "'), pOutLI,	pOut('",')],
;	[IsBit(45), LLVAR*n, 		pOut(0x0a, 0x09, 0x09, '"B45 VIB box identifier"	: "'), pOutLI,	pOut('",')],
;	[IsBit(46), LLVAR*an, 		pOut(0x0a, 0x09, 0x09, '"B46 Truck VIN"			: "'), pOutLI,	pOut('",')],
;	[IsBit(47), LVAR*n, 		pOut(0x0a, 0x09, 0x09, '"B47 Mileage"			: "'), pOutLI,	pOut('",')],
;	[IsBit(48), 14*n, 		pOut(0x0a, 0x09, 0x09, '"B48 Timestamp"			: "'), pOutLI,	pOut('",')],
;	[IsBit(49), LLVAR*b, 		pOut(0x0a, 0x09, 0x09, '"B49 VIB additional data"	: "'), pOutLI,	pOut('",')],
;	[IsBit(50), (2*n), 		pOut(0x0a, 0x09, 0x09, '"B50 Pump"			: "'), pOutLI,	pOut('",')],
;	[IsBit(51), (2*n), 		pOut(0x0a, 0x09, 0x09, '"B51 Nozzle"			: "'), pOutLI,	pOut('",')],
;	
;	[IsBit(52), 7*b, 		pOut(0x0a, 0x09, 0x09, '"B52 IDS specific"		: "'), pOutLI,	pOut('",')],
;	[IsBit(53), LLVAR*b, 		pOut(0x0a, 0x09, 0x09, '"B53 IDS specific"		: "'), pOutLI,	pOut('",')],	/* LLVAR missed in CGI spec. */
;	DropLastChar,
;	pOut('},');
;
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Bit3:
	call cPush
	call pOut
	 db 0x0C, 0x0a, 0x09, 0x09, '"P12" : "'
	or rPOk, rPOk
	jnz SD02F0
	jmp SDEnd02F0
SD02F0:
	call cPush
	call pIn
	 db 0x0002, "00"
	or rPOk, rPOk
	jnz SD02F1
	jmp SDEnd02F1
SD02F1:
	call pOut
	 db 0x26, '00 Debits Payment/Goods and services",'
SDEnd02F1:
	jrcxz DL02F2
	jmp DLEnd02F2
DL02F2:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "01"
	or rPOk, rPOk
	jnz SD02F3
	jmp SDEnd02F3
SD02F3:
	call pOut
	 db 0x1B, '01 Debits Cash withdrawal",'
SDEnd02F3:
	jrcxz DL02F4
	jmp DLEnd02F2
DL02F4:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "09"
	or rPOk, rPOk
	jnz SD02F5
	jmp SDEnd02F5
SD02F5:
	call pOut
	 db 0x35, '09 Debits Goods and services with cash disbursement",'
SDEnd02F5:
	jrcxz DL02F6
	jmp DLEnd02F2
DL02F6:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "17"
	or rPOk, rPOk
	jnz SD02F7
	jmp SDEnd02F7
SD02F7:
	call pOut
	 db 0x52, '17 Debits Cash Advance/Cash Sale (private value) Used to register loyalty points",'
SDEnd02F7:
	jrcxz DL02F8
	jmp DLEnd02F2
DL02F8:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "18"
	or rPOk, rPOk
	jnz SD02F9
	jmp SDEnd02F9
SD02F9:
	call pOut
	 db 0x1D, '18 Debits Pre-Authorisation",'
SDEnd02F9:
	jrcxz DL02FA
	jmp DLEnd02F2
DL02FA:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "19"
	or rPOk, rPOk
	jnz SD02FB
	jmp SDEnd02FB
SD02FB:
	call pOut
	 db 0x1E, '19 Debits Payment Completion",'
SDEnd02FB:
	jrcxz DL02FC
	jmp DLEnd02F2
DL02FC:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "20"
	or rPOk, rPOk
	jnz SD02FD
	jmp SDEnd02FD
SD02FD:
	call pOut
	 db 0x1B, '20 Credits Returns/Refund",'
SDEnd02FD:
	jrcxz DL02FE
	jmp DLEnd02F2
DL02FE:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "21"
	or rPOk, rPOk
	jnz SD02FF
	jmp SDEnd02FF
SD02FF:
	call pOut
	 db 0x15, '21 Credits Deposits",'
SDEnd02FF:
	jrcxz DL0300
	jmp DLEnd02F2
DL0300:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "28"
	or rPOk, rPOk
	jnz SD0301
	jmp SDEnd0301
SD0301:
	call pOut
	 db 0x40, '28 Credits Return (private sale) Used to return loyalty points",'
SDEnd0301:
	jrcxz DL0302
	jmp DLEnd02F2
DL0302:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "30"
	or rPOk, rPOk
	jnz SD0303
	jmp SDEnd0303
SD0303:
	call pOut
	 db 0x1C, '30 Inquiry Available funds",'
SDEnd0303:
	jrcxz DL0304
	jmp DLEnd02F2
DL0304:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "31"
	or rPOk, rPOk
	jnz SD0305
	jmp SDEnd0305
SD0305:
	call pOut
	 db 0x14, '31 Inquiry Balance",'
SDEnd0305:
	jrcxz DL0306
	jmp DLEnd02F2
DL0306:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "38"
	or rPOk, rPOk
	jnz SD0307
	jmp SDEnd0307
SD0307:
	call pOut
	 db 0x1A, '38 Inquiry Bonus Balance",'
SDEnd0307:
	jrcxz DL0308
	jmp DLEnd02F2
DL0308:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "39"
	or rPOk, rPOk
	jnz SD0309
	jmp SDEnd0309
SD0309:
	call pOut
	 db 0x10, '39 Inquiry DCC",'
SDEnd0309:
	jrcxz DL030A
	jmp DLEnd02F2
DL030A:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "60"
	or rPOk, rPOk
	jnz SD030B
	jmp SDEnd030B
SD030B:
	call pOut
	 db 0x17, '60 Control Load value",'
SDEnd030B:
	jrcxz DL030C
	jmp DLEnd02F2
DL030C:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "61"
	or rPOk, rPOk
	jnz SD030D
	jmp SDEnd030D
SD030D:
	call pOut
	 db 0x19, '61 Control Unload value",'
SDEnd030D:
	jrcxz DL030E
	jmp DLEnd02F2
DL030E:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "90"
	or rPOk, rPOk
	jnz SD030F
	jmp SDEnd030F
SD030F:
	call pOut
	 db 0x1A, '90 Control Activate card",'
SDEnd030F:
	jrcxz DL0310
	jmp DLEnd02F2
DL0310:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "91"
	or rPOk, rPOk
	jnz SD0311
	jmp SDEnd0311
SD0311:
	call pOut
	 db 0x1C, '91 Control Deactivate card",'
SDEnd0311:
DLEnd02F2:
	call cDrop
	or rPOk, rPOk
	jnz SD0312
	jmp SDEnd02F0
SD0312:
	call pOut
	 db 0x0C, 0x0a, 0x09, 0x09, '"P34" : "'
	or rPOk, rPOk
	jnz SD0313
	jmp SDEnd02F0
SD0313:
	call cPush
	call pIn
	 db 0x0002, "00"
	or rPOk, rPOk
	jnz SD0314
	jmp SDEnd0314
SD0314:
	call pOut
	 db 0x18, '00 Unspecified account",'
SDEnd0314:
	jrcxz DL0315
	jmp DLEnd0315
DL0315:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "10"
	or rPOk, rPOk
	jnz SD0316
	jmp SDEnd0316
SD0316:
	call pOut
	 db 0x14, '10 Savings account",'
SDEnd0316:
	jrcxz DL0317
	jmp DLEnd0315
DL0317:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "20"
	or rPOk, rPOk
	jnz SD0318
	jmp SDEnd0318
SD0318:
	call pOut
	 db 0x37, '20 Checking account - default  Debit card transaction",'
SDEnd0318:
	jrcxz DL0319
	jmp DLEnd0315
DL0319:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "30"
	or rPOk, rPOk
	jnz SD031A
	jmp SDEnd031A
SD031A:
	call pOut
	 db 0x37, '30 Credit facility - default  Credit card transaction",'
SDEnd031A:
	jrcxz DL031B
	jmp DLEnd0315
DL031B:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "60"
	or rPOk, rPOk
	jnz SD031C
	jmp SDEnd031C
SD031C:
	call pOut
	 db 0x16, '60 Cash card account",'
SDEnd031C:
	jrcxz DL031D
	jmp DLEnd0315
DL031D:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "65"
	or rPOk, rPOk
	jnz SD031E
	jmp SDEnd031E
SD031E:
	call pOut
	 db 0x29, '65 Cash card - reserved for private use",'
SDEnd031E:
	jrcxz DL031F
	jmp DLEnd0315
DL031F:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "66"
	or rPOk, rPOk
	jnz SD0320
	jmp SDEnd0320
SD0320:
	call pOut
	 db 0x29, '66 Cash card - reserved for private use",'
SDEnd0320:
DLEnd0315:
	call cDrop
	or rPOk, rPOk
	jnz SD0321
	jmp SDEnd02F0
SD0321:
	call pOut
	 db 0x0C, 0x0a, 0x09, 0x09, '"P45" : "'
	or rPOk, rPOk
	jnz SD0322
	jmp SDEnd02F0
SD0322:
	call cPush
	call pIn
	 db 0x0002, "00"
	or rPOk, rPOk
	jnz SD0323
	jmp SDEnd0323
SD0323:
	call pOut
	 db 0x18, '00 Unspecified account",'
SDEnd0323:
	jrcxz DL0324
	jmp DLEnd0324
DL0324:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "10"
	or rPOk, rPOk
	jnz SD0325
	jmp SDEnd0325
SD0325:
	call pOut
	 db 0x14, '10 Savings account",'
SDEnd0325:
	jrcxz DL0326
	jmp DLEnd0324
DL0326:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "20"
	or rPOk, rPOk
	jnz SD0327
	jmp SDEnd0327
SD0327:
	call pOut
	 db 0x37, '20 Checking account - default  Debit card transaction",'
SDEnd0327:
	jrcxz DL0328
	jmp DLEnd0324
DL0328:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "30"
	or rPOk, rPOk
	jnz SD0329
	jmp SDEnd0329
SD0329:
	call pOut
	 db 0x37, '30 Credit facility - default  Credit card transaction",'
SDEnd0329:
	jrcxz DL032A
	jmp DLEnd0324
DL032A:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "60"
	or rPOk, rPOk
	jnz SD032B
	jmp SDEnd032B
SD032B:
	call pOut
	 db 0x16, '60 Cash card account",'
SDEnd032B:
	jrcxz DL032C
	jmp DLEnd0324
DL032C:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "65"
	or rPOk, rPOk
	jnz SD032D
	jmp SDEnd032D
SD032D:
	call pOut
	 db 0x29, '65 Cash card - reserved for private use",'
SDEnd032D:
	jrcxz DL032E
	jmp DLEnd0324
DL032E:	inc rcx
	call cTop
	call pIn
	 db 0x0002, "66"
	or rPOk, rPOk
	jnz SD032F
	jmp SDEnd032F
SD032F:
	call pOut
	 db 0x29, '66 Cash card - reserved for private use",'
SDEnd032F:
DLEnd0324:
	call cDrop
	or rPOk, rPOk
	jnz SD0330
	jmp SDEnd02F0
SD0330:
	call DropLastChar
	or rPOk, rPOk
	jnz SD0331
	jmp SDEnd02F0
SD0331:
	call pOut
	 db 0x02, '},'
SDEnd02F0:
	call cDrop
	ret

;Bit3	=    /*Processing code, Positions 1 & 2*/
;	 pOut(0x0a, 0x09, 0x09, '"P12" : "'),
;	 (	"00", pOut('00 Debits Payment/Goods and services",')|
;		"01", pOut('01 Debits Cash withdrawal",')|
;		"09", pOut('09 Debits Goods and services with cash disbursement",')|
;		"17", pOut('17 Debits Cash Advance/Cash Sale (private value) Used to register loyalty points",')|
;		"18", pOut('18 Debits Pre-Authorisation",')|
;		"19", pOut('19 Debits Payment Completion",')|
;		"20", pOut('20 Credits Returns/Refund",')|
;		"21", pOut('21 Credits Deposits",')|
;		"28", pOut('28 Credits Return (private sale) Used to return loyalty points",')|
;		"30", pOut('30 Inquiry Available funds",')|
;		"31", pOut('31 Inquiry Balance",')|
;		"38", pOut('38 Inquiry Bonus Balance",')|
;		"39", pOut('39 Inquiry DCC",')|
;		"60", pOut('60 Control Load value",')|
;		"61", pOut('61 Control Unload value",')|
;		"90", pOut('90 Control Activate card",')|
;		"91", pOut('91 Control Deactivate card",')),
;	pOut(0x0a, 0x09, 0x09, '"P34" : "'),
;	(	"00", pOut('00 Unspecified account",')|
;		"10", pOut('10 Savings account",')|
;		"20", pOut('20 Checking account - default  Debit card transaction",')|
;		"30", pOut('30 Credit facility - default  Credit card transaction",')|
;		"60", pOut('60 Cash card account",')|
;		"65", pOut('65 Cash card - reserved for private use",')|
;		"66", pOut('66 Cash card - reserved for private use",')),
;	pOut(0x0a, 0x09, 0x09, '"P45" : "'),
;	(	"00", pOut('00 Unspecified account",')|
;		"10", pOut('10 Savings account",')|
;		"20", pOut('20 Checking account - default  Debit card transaction",')|
;		"30", pOut('30 Credit facility - default  Credit card transaction",')|
;		"60", pOut('60 Cash card account",')|
;		"65", pOut('65 Cash card - reserved for private use",')|
;		"66", pOut('66 Cash card - reserved for private use",')),	
;	DropLastChar,
;	pOut('},');
;		

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Bit22:
	call cPush
	call pOut
	 db 0x24, 0x0a, 0x09, 0x09, '"P1  Technical ability"       : "'
	or rPOk, rPOk
	jnz SD0332
	jmp SDEnd0332
SD0332:
	call cPush
	call pIn
	 db 0x0001, "2"
	or rPOk, rPOk
	jnz SD0333
	jmp SDEnd0333
SD0333:
	call pOut
	 db 0x13, '2 Magnetic stripe",'
SDEnd0333:
	jrcxz DL0334
	jmp DLEnd0334
DL0334:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "3"
	or rPOk, rPOk
	jnz SD0335
	jmp SDEnd0335
SD0335:
	call pOut
	 db 0x0C, '3 Bar code",'
SDEnd0335:
	jrcxz DL0336
	jmp DLEnd0334
DL0336:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "5"
	or rPOk, rPOk
	jnz SD0337
	jmp SDEnd0337
SD0337:
	call pOut
	 db 0x08, '5 Chip",'
SDEnd0337:
	jrcxz DL0338
	jmp DLEnd0334
DL0338:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "6"
	or rPOk, rPOk
	jnz SD0339
	jmp SDEnd0339
SD0339:
	call pOut
	 db 0x0D, '6 Key entry",'
SDEnd0339:
	jrcxz DL033A
	jmp DLEnd0334
DL033A:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "A"
	or rPOk, rPOk
	jnz SD033B
	jmp SDEnd033B
SD033B:
	call pOut
	 db 0x08, 'A RFID",'
SDEnd033B:
	jrcxz DL033C
	jmp DLEnd0334
DL033C:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "B"
	or rPOk, rPOk
	jnz SD033D
	jmp SDEnd033D
SD033D:
	call pOut
	 db 0x14, 'B Magn & Key entry",'
SDEnd033D:
	jrcxz DL033E
	jmp DLEnd0334
DL033E:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "C"
	or rPOk, rPOk
	jnz SD033F
	jmp SDEnd033F
SD033F:
	call pOut
	 db 0x19, 'C Magn, Chip, Key entry",'
SDEnd033F:
	jrcxz DL0340
	jmp DLEnd0334
DL0340:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "D"
	or rPOk, rPOk
	jnz SD0341
	jmp SDEnd0341
SD0341:
	call pOut
	 db 0x0F, 'D Magn & Chip",'
SDEnd0341:
	jrcxz DL0342
	jmp DLEnd0334
DL0342:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "E"
	or rPOk, rPOk
	jnz SD0343
	jmp SDEnd0343
SD0343:
	call pOut
	 db 0x14, 'E Chip & Key entry",'
SDEnd0343:
	jrcxz DL0344
	jmp DLEnd0334
DL0344:	inc rcx
	call cTop
	call b
	or rPOk, rPOk
	jnz SD0345
	jmp SDEnd0345
SD0345:
	call pOutLI
	or rPOk, rPOk
	jnz SD0346
	jmp SDEnd0345
SD0346:
	call pOut
	 db 0x0F, '=Illegal code",'
SDEnd0345:
DLEnd0334:
	call cDrop
	or rPOk, rPOk
	jnz SD0347
	jmp SDEnd0332
SD0347:
	call pOut
	 db 0x24, 0x0a, 0x09, 0x09, '"P2  Authentication ability"  : "'
	or rPOk, rPOk
	jnz SD0348
	jmp SDEnd0332
SD0348:
	call cPush
	call pIn
	 db 0x0001, "0"
	or rPOk, rPOk
	jnz SD0349
	jmp SDEnd0349
SD0349:
	call pOut
	 db 0x08, '0 None",'
SDEnd0349:
	jrcxz DL034A
	jmp DLEnd034A
DL034A:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "1"
	or rPOk, rPOk
	jnz SD034B
	jmp SDEnd034B
SD034B:
	call pOut
	 db 0x07, '1 PIN",'
SDEnd034B:
	jrcxz DL034C
	jmp DLEnd034A
DL034C:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "6"
	or rPOk, rPOk
	jnz SD034D
	jmp SDEnd034D
SD034D:
	call pOut
	 db 0x0B, '6 Unknown",'
SDEnd034D:
	jrcxz DL034E
	jmp DLEnd034A
DL034E:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "9"
	or rPOk, rPOk
	jnz SD034F
	jmp SDEnd034F
SD034F:
	call pOut
	 db 0x07, '9 EMV",'
SDEnd034F:
	jrcxz DL0350
	jmp DLEnd034A
DL0350:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "S"
	or rPOk, rPOk
	jnz SD0351
	jmp SDEnd0351
SD0351:
	call pOut
	 db 0x0D, 'S Signature",'
SDEnd0351:
	jrcxz DL0352
	jmp DLEnd034A
DL0352:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "T"
	or rPOk, rPOk
	jnz SD0353
	jmp SDEnd0353
SD0353:
	call pOut
	 db 0x13, 'T EMV offline PIN",'
SDEnd0353:
	jrcxz DL0354
	jmp DLEnd034A
DL0354:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "U"
	or rPOk, rPOk
	jnz SD0355
	jmp SDEnd0355
SD0355:
	call pOut
	 db 0x12, 'U EMV online PIN",'
SDEnd0355:
	jrcxz DL0356
	jmp DLEnd034A
DL0356:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "V"
	or rPOk, rPOk
	jnz SD0357
	jmp SDEnd0357
SD0357:
	call pOut
	 db 0x1A, 'V Sign & EMV offline PIN",'
SDEnd0357:
	jrcxz DL0358
	jmp DLEnd034A
DL0358:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "X"
	or rPOk, rPOk
	jnz SD0359
	jmp SDEnd0359
SD0359:
	call pOut
	 db 0x19, 'X Sign & EMV online PIN",'
SDEnd0359:
	jrcxz DL035A
	jmp DLEnd034A
DL035A:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "Y"
	or rPOk, rPOk
	jnz SD035B
	jmp SDEnd035B
SD035B:
	call pOut
	 db 0x1E, 'Y Sign & EMV on/offfline PIN",'
SDEnd035B:
	jrcxz DL035C
	jmp DLEnd034A
DL035C:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "Z"
	or rPOk, rPOk
	jnz SD035D
	jmp SDEnd035D
SD035D:
	call pOut
	 db 0x16, 'Z EMV on/offline PIN",'
SDEnd035D:
	jrcxz DL035E
	jmp DLEnd034A
DL035E:	inc rcx
	call cTop
	call b
	or rPOk, rPOk
	jnz SD035F
	jmp SDEnd035F
SD035F:
	call pOutLI
	or rPOk, rPOk
	jnz SD0360
	jmp SDEnd035F
SD0360:
	call pOut
	 db 0x0F, '=Illegal code",'
SDEnd035F:
DLEnd034A:
	call cDrop
	or rPOk, rPOk
	jnz SD0361
	jmp SDEnd0332
SD0361:
	call pOut
	 db 0x24, 0x0a, 0x09, 0x09, '"P3  Card capture ability"    : "'
	or rPOk, rPOk
	jnz SD0362
	jmp SDEnd0332
SD0362:
	call cPush
	call pIn
	 db 0x0001, "0"
	or rPOk, rPOk
	jnz SD0363
	jmp SDEnd0363
SD0363:
	call pOut
	 db 0x08, '0 None",'
SDEnd0363:
	jrcxz DL0364
	jmp DLEnd0364
DL0364:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "1"
	or rPOk, rPOk
	jnz SD0365
	jmp SDEnd0365
SD0365:
	call pOut
	 db 0x08, '1 Card",'
SDEnd0365:
	jrcxz DL0366
	jmp DLEnd0364
DL0366:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "T"
	or rPOk, rPOk
	jnz SD0367
	jmp SDEnd0367
SD0367:
	call pOut
	 db 0x1A, 'T None & EMV Sda/Dda/Cda",'
SDEnd0367:
	jrcxz DL0368
	jmp DLEnd0364
DL0368:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "U"
	or rPOk, rPOk
	jnz SD0369
	jmp SDEnd0369
SD0369:
	call pOut
	 db 0x13, 'U EMV Sda/Dda/Cda",'
SDEnd0369:
	jrcxz DL036A
	jmp DLEnd0364
DL036A:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "V"
	or rPOk, rPOk
	jnz SD036B
	jmp SDEnd036B
SD036B:
	call pOut
	 db 0x16, 'V None & EMV Sda/Dda",'
SDEnd036B:
	jrcxz DL036C
	jmp DLEnd0364
DL036C:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "W"
	or rPOk, rPOk
	jnz SD036D
	jmp SDEnd036D
SD036D:
	call pOut
	 db 0x0F, 'W EMV Sda/Dda",'
SDEnd036D:
	jrcxz DL036E
	jmp DLEnd0364
DL036E:	inc rcx
	call cTop
	call b
	or rPOk, rPOk
	jnz SD036F
	jmp SDEnd036F
SD036F:
	call pOutLI
	or rPOk, rPOk
	jnz SD0370
	jmp SDEnd036F
SD0370:
	call pOut
	 db 0x0F, '=Illegal code",'
SDEnd036F:
DLEnd0364:
	call cDrop
	or rPOk, rPOk
	jnz SD0371
	jmp SDEnd0332
SD0371:
	call pOut
	 db 0x24, 0x0a, 0x09, 0x09, '"P4  Operating Environment"   : "'
	or rPOk, rPOk
	jnz SD0372
	jmp SDEnd0332
SD0372:
	call cPush
	call pIn
	 db 0x0001, "1"
	or rPOk, rPOk
	jnz SD0373
	jmp SDEnd0373
SD0373:
	call pOut
	 db 0x07, '1 IPT",'
SDEnd0373:
	jrcxz DL0374
	jmp DLEnd0374
DL0374:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "2"
	or rPOk, rPOk
	jnz SD0375
	jmp SDEnd0375
SD0375:
	call pOut
	 db 0x07, '2 OPT",'
SDEnd0375:
	jrcxz DL0376
	jmp DLEnd0374
DL0376:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "3"
	or rPOk, rPOk
	jnz SD0377
	jmp SDEnd0377
SD0377:
	call pOut
	 db 0x0E, '3 Dealer IPT",'
SDEnd0377:
	jrcxz DL0378
	jmp DLEnd0374
DL0378:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "4"
	or rPOk, rPOk
	jnz SD0379
	jmp SDEnd0379
SD0379:
	call pOut
	 db 0x0E, '4 Dealer OPT",'
SDEnd0379:
	jrcxz DL037A
	jmp DLEnd0374
DL037A:	inc rcx
	call cTop
	call b
	or rPOk, rPOk
	jnz SD037B
	jmp SDEnd037B
SD037B:
	call pOutLI
	or rPOk, rPOk
	jnz SD037C
	jmp SDEnd037B
SD037C:
	call pOut
	 db 0x0F, '=Illegal code",'
SDEnd037B:
DLEnd0374:
	call cDrop
	or rPOk, rPOk
	jnz SD037D
	jmp SDEnd0332
SD037D:
	call pOut
	 db 0x24, 0x0a, 0x09, 0x09, '"P5  Card holder presence"    : "'
	or rPOk, rPOk
	jnz SD037E
	jmp SDEnd0332
SD037E:
	call cPush
	call pIn
	 db 0x0001, "0"
	or rPOk, rPOk
	jnz SD037F
	jmp SDEnd037F
SD037F:
	call pOut
	 db 0x17, '0 Card holder present",'
SDEnd037F:
	jrcxz DL0380
	jmp DLEnd0380
DL0380:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "1"
	or rPOk, rPOk
	jnz SD0381
	jmp SDEnd0381
SD0381:
	call pOut
	 db 0x1B, '1 Card holder not present",'
SDEnd0381:
	jrcxz DL0382
	jmp DLEnd0380
DL0382:	inc rcx
	call cTop
	call b
	or rPOk, rPOk
	jnz SD0383
	jmp SDEnd0383
SD0383:
	call pOutLI
	or rPOk, rPOk
	jnz SD0384
	jmp SDEnd0383
SD0384:
	call pOut
	 db 0x0F, '=Illegal code",'
SDEnd0383:
DLEnd0380:
	call cDrop
	or rPOk, rPOk
	jnz SD0385
	jmp SDEnd0332
SD0385:
	call pOut
	 db 0x24, 0x0a, 0x09, 0x09, '"P6  Card presence"           : "'
	or rPOk, rPOk
	jnz SD0386
	jmp SDEnd0332
SD0386:
	call cPush
	call pIn
	 db 0x0001, "0"
	or rPOk, rPOk
	jnz SD0387
	jmp SDEnd0387
SD0387:
	call pOut
	 db 0x14, '0 Card not present",'
SDEnd0387:
	jrcxz DL0388
	jmp DLEnd0388
DL0388:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "1"
	or rPOk, rPOk
	jnz SD0389
	jmp SDEnd0389
SD0389:
	call pOut
	 db 0x10, '1 Card present",'
SDEnd0389:
	jrcxz DL038A
	jmp DLEnd0388
DL038A:	inc rcx
	call cTop
	call b
	or rPOk, rPOk
	jnz SD038B
	jmp SDEnd038B
SD038B:
	call pOutLI
	or rPOk, rPOk
	jnz SD038C
	jmp SDEnd038B
SD038C:
	call pOut
	 db 0x0F, '=Illegal code",'
SDEnd038B:
DLEnd0388:
	call cDrop
	or rPOk, rPOk
	jnz SD038D
	jmp SDEnd0332
SD038D:
	call pOut
	 db 0x24, 0x0a, 0x09, 0x09, '"P7  Card data input mode"    : "'
	or rPOk, rPOk
	jnz SD038E
	jmp SDEnd0332
SD038E:
	call cPush
	call pIn
	 db 0x0001, "2"
	or rPOk, rPOk
	jnz SD038F
	jmp SDEnd038F
SD038F:
	call pOut
	 db 0x0D, '2 Magn used",'
SDEnd038F:
	jrcxz DL0390
	jmp DLEnd0390
DL0390:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "3"
	or rPOk, rPOk
	jnz SD0391
	jmp SDEnd0391
SD0391:
	call pOut
	 db 0x11, '3 Bar code used",'
SDEnd0391:
	jrcxz DL0392
	jmp DLEnd0390
DL0392:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "5"
	or rPOk, rPOk
	jnz SD0393
	jmp SDEnd0393
SD0393:
	call pOut
	 db 0x0D, '5 Chip used",'
SDEnd0393:
	jrcxz DL0394
	jmp DLEnd0390
DL0394:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "6"
	or rPOk, rPOk
	jnz SD0395
	jmp SDEnd0395
SD0395:
	call pOut
	 db 0x0F, '6 Manual done",'
SDEnd0395:
	jrcxz DL0396
	jmp DLEnd0390
DL0396:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "A"
	or rPOk, rPOk
	jnz SD0397
	jmp SDEnd0397
SD0397:
	call pOut
	 db 0x0D, 'A RFID used",'
SDEnd0397:
	jrcxz DL0398
	jmp DLEnd0390
DL0398:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "B"
	or rPOk, rPOk
	jnz SD0399
	jmp SDEnd0399
SD0399:
	call pOut
	 db 0x0D, 'B Magn used",'
SDEnd0399:
	jrcxz DL039A
	jmp DLEnd0390
DL039A:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "C"
	or rPOk, rPOk
	jnz SD039B
	jmp SDEnd039B
SD039B:
	call pOut
	 db 0x0D, 'C Chip used",'
SDEnd039B:
	jrcxz DL039C
	jmp DLEnd0390
DL039C:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "D"
	or rPOk, rPOk
	jnz SD039D
	jmp SDEnd039D
SD039D:
	call pOut
	 db 0x17, 'D Fall back magn used",'
SDEnd039D:
	jrcxz DL039E
	jmp DLEnd0390
DL039E:	inc rcx
	call cTop
	call b
	or rPOk, rPOk
	jnz SD039F
	jmp SDEnd039F
SD039F:
	call pOutLI
	or rPOk, rPOk
	jnz SD03A0
	jmp SDEnd039F
SD03A0:
	call pOut
	 db 0x0E, 'Illegal code",'
SDEnd039F:
DLEnd0390:
	call cDrop
	or rPOk, rPOk
	jnz SD03A1
	jmp SDEnd0332
SD03A1:
	call pOut
	 db 0x24, 0x0a, 0x09, 0x09, '"P8  Card holder auth method" : "'
	or rPOk, rPOk
	jnz SD03A2
	jmp SDEnd0332
SD03A2:
	call cPush
	call pIn
	 db 0x0001, "0"
	or rPOk, rPOk
	jnz SD03A3
	jmp SDEnd03A3
SD03A3:
	call pOut
	 db 0x1E, '0 CardHolderNotAuthenticated",'
SDEnd03A3:
	jrcxz DL03A4
	jmp DLEnd03A4
DL03A4:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "1"
	or rPOk, rPOk
	jnz SD03A5
	jmp SDEnd03A5
SD03A5:
	call pOut
	 db 0x0C, '1 PIN used",'
SDEnd03A5:
	jrcxz DL03A6
	jmp DLEnd03A4
DL03A6:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "5"
	or rPOk, rPOk
	jnz SD03A7
	jmp SDEnd03A7
SD03A7:
	call pOut
	 db 0x12, '5 Signature used",'
SDEnd03A7:
	jrcxz DL03A8
	jmp DLEnd03A4
DL03A8:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "6"
	or rPOk, rPOk
	jnz SD03A9
	jmp SDEnd03A9
SD03A9:
	call pOut
	 db 0x16, '6 DriverLicense used",'
SDEnd03A9:
	jrcxz DL03AA
	jmp DLEnd03A4
DL03AA:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "9"
	or rPOk, rPOk
	jnz SD03AB
	jmp SDEnd03AB
SD03AB:
	call pOut
	 db 0x18, '9 EMV Pin for 2nd card",'
SDEnd03AB:
	jrcxz DL03AC
	jmp DLEnd03A4
DL03AC:	inc rcx
	call cTop
	call b
	or rPOk, rPOk
	jnz SD03AD
	jmp SDEnd03AD
SD03AD:
	call pOutLI
	or rPOk, rPOk
	jnz SD03AE
	jmp SDEnd03AD
SD03AE:
	call pOut
	 db 0x0E, 'Illegal code",'
SDEnd03AD:
DLEnd03A4:
	call cDrop
	or rPOk, rPOk
	jnz SD03AF
	jmp SDEnd0332
SD03AF:
	call pOut
	 db 0x24, 0x0a, 0x09, 0x09, '"P9  Card holder auth entity" : "'
	or rPOk, rPOk
	jnz SD03B0
	jmp SDEnd0332
SD03B0:
	call cPush
	call pIn
	 db 0x0001, "0"
	or rPOk, rPOk
	jnz SD03B1
	jmp SDEnd03B1
SD03B1:
	call pOut
	 db 0x21, '0 Card holder not authenticated",'
SDEnd03B1:
	jrcxz DL03B2
	jmp DLEnd03B2
DL03B2:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "1"
	or rPOk, rPOk
	jnz SD03B3
	jmp SDEnd03B3
SD03B3:
	call pOut
	 db 0x1E, '1 Chip authorized Cardholder",'
SDEnd03B3:
	jrcxz DL03B4
	jmp DLEnd03B2
DL03B4:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "2"
	or rPOk, rPOk
	jnz SD03B5
	jmp SDEnd03B5
SD03B5:
	call pOut
	 db 0x17, '2 Terminal authorized",'
SDEnd03B5:
	jrcxz DL03B6
	jmp DLEnd03B2
DL03B6:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "3"
	or rPOk, rPOk
	jnz SD03B7
	jmp SDEnd03B7
SD03B7:
	call pOut
	 db 0x1A, '3 Authorising agent used",'
SDEnd03B7:
	jrcxz DL03B8
	jmp DLEnd03B2
DL03B8:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "4"
	or rPOk, rPOk
	jnz SD03B9
	jmp SDEnd03B9
SD03B9:
	call pOut
	 db 0x15, '4 Merchant did auth",'
SDEnd03B9:
	jrcxz DL03BA
	jmp DLEnd03B2
DL03BA:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "5"
	or rPOk, rPOk
	jnz SD03BB
	jmp SDEnd03BB
SD03BB:
	call pOut
	 db 0x0E, '5 Other auth",'
SDEnd03BB:
	jrcxz DL03BC
	jmp DLEnd03B2
DL03BC:	inc rcx
	call cTop
	call b
	or rPOk, rPOk
	jnz SD03BD
	jmp SDEnd03BD
SD03BD:
	call pOutLI
	or rPOk, rPOk
	jnz SD03BE
	jmp SDEnd03BD
SD03BE:
	call pOut
	 db 0x0F, '=Illegal code",'
SDEnd03BD:
DLEnd03B2:
	call cDrop
	or rPOk, rPOk
	jnz SD03BF
	jmp SDEnd0332
SD03BF:
	call pOut
	 db 0x24, 0x0a, 0x09, 0x09, '"P10 CAD can update card"     : "'
	or rPOk, rPOk
	jnz SD03C0
	jmp SDEnd0332
SD03C0:
	call cPush
	call pIn
	 db 0x0001, "0"
	or rPOk, rPOk
	jnz SD03C1
	jmp SDEnd03C1
SD03C1:
	call pOut
	 db 0x0B, '0 Unknown",'
SDEnd03C1:
	jrcxz DL03C2
	jmp DLEnd03C2
DL03C2:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "1"
	or rPOk, rPOk
	jnz SD03C3
	jmp SDEnd03C3
SD03C3:
	call pOut
	 db 0x1A, '1 CAD cannot update card",'
SDEnd03C3:
	jrcxz DL03C4
	jmp DLEnd03C2
DL03C4:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "2"
	or rPOk, rPOk
	jnz SD03C5
	jmp SDEnd03C5
SD03C5:
	call pOut
	 db 0x1C, '2 CAD can update magstripe",'
SDEnd03C5:
	jrcxz DL03C6
	jmp DLEnd03C2
DL03C6:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "3"
	or rPOk, rPOk
	jnz SD03C7
	jmp SDEnd03C7
SD03C7:
	call pOut
	 db 0x17, '3 CAD can update chip",'
SDEnd03C7:
	jrcxz DL03C8
	jmp DLEnd03C2
DL03C8:	inc rcx
	call cTop
	call b
	or rPOk, rPOk
	jnz SD03C9
	jmp SDEnd03C9
SD03C9:
	call pOutLI
	or rPOk, rPOk
	jnz SD03CA
	jmp SDEnd03C9
SD03CA:
	call pOut
	 db 0x0F, '=Illegal code",'
SDEnd03C9:
DLEnd03C2:
	call cDrop
	or rPOk, rPOk
	jnz SD03CB
	jmp SDEnd0332
SD03CB:
	call pOut
	 db 0x24, 0x0a, 0x09, 0x09, '"P11 POI output ability"      : "'
	or rPOk, rPOk
	jnz SD03CC
	jmp SDEnd0332
SD03CC:
	call cPush
	call pIn
	 db 0x0001, "0"
	or rPOk, rPOk
	jnz SD03CD
	jmp SDEnd03CD
SD03CD:
	call pOut
	 db 0x0B, '0 Unknown",'
SDEnd03CD:
	jrcxz DL03CE
	jmp DLEnd03CE
DL03CE:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "1"
	or rPOk, rPOk
	jnz SD03CF
	jmp SDEnd03CF
SD03CF:
	call pOut
	 db 0x08, '1 None",'
SDEnd03CF:
	jrcxz DL03D0
	jmp DLEnd03CE
DL03D0:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "2"
	or rPOk, rPOk
	jnz SD03D1
	jmp SDEnd03D1
SD03D1:
	call pOut
	 db 0x09, '2 Print",'
SDEnd03D1:
	jrcxz DL03D2
	jmp DLEnd03CE
DL03D2:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "3"
	or rPOk, rPOk
	jnz SD03D3
	jmp SDEnd03D3
SD03D3:
	call pOut
	 db 0x0B, '3 Display",'
SDEnd03D3:
	jrcxz DL03D4
	jmp DLEnd03CE
DL03D4:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "4"
	or rPOk, rPOk
	jnz SD03D5
	jmp SDEnd03D5
SD03D5:
	call pOut
	 db 0x15, '4 Print and display",'
SDEnd03D5:
	jrcxz DL03D6
	jmp DLEnd03CE
DL03D6:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "5"
	or rPOk, rPOk
	jnz SD03D7
	jmp SDEnd03D7
SD03D7:
	call pOut
	 db 0x0B, '5 Special",'
SDEnd03D7:
	jrcxz DL03D8
	jmp DLEnd03CE
DL03D8:	inc rcx
	call cTop
	call b
	or rPOk, rPOk
	jnz SD03D9
	jmp SDEnd03D9
SD03D9:
	call pOutLI
	or rPOk, rPOk
	jnz SD03DA
	jmp SDEnd03D9
SD03DA:
	call pOut
	 db 0x0F, '=Illegal code",'
SDEnd03D9:
DLEnd03CE:
	call cDrop
	or rPOk, rPOk
	jnz SD03DB
	jmp SDEnd0332
SD03DB:
	call pOut
	 db 0x24, 0x0a, 0x09, 0x09, '"P12 PIN capture capability"  : "'
	or rPOk, rPOk
	jnz SD03DC
	jmp SDEnd0332
SD03DC:
	call cPush
	call pIn
	 db 0x0001, "0"
	or rPOk, rPOk
	jnz SD03DD
	jmp SDEnd03DD
SD03DD:
	call pOut
	 db 0x06, 'None",'
SDEnd03DD:
	jrcxz DL03DE
	jmp DLEnd03DE
DL03DE:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "1"
	or rPOk, rPOk
	jnz SD03DF
	jmp SDEnd03DF
SD03DF:
	call pOut
	 db 0x09, 'Unknown",'
SDEnd03DF:
	jrcxz DL03E0
	jmp DLEnd03DE
DL03E0:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "4"
	or rPOk, rPOk
	jnz SD03E1
	jmp SDEnd03E1
SD03E1:
	call pOut
	 db 0x09, '4 digit",'
SDEnd03E1:
	jrcxz DL03E2
	jmp DLEnd03DE
DL03E2:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "5"
	or rPOk, rPOk
	jnz SD03E3
	jmp SDEnd03E3
SD03E3:
	call pOut
	 db 0x09, '5 digit",'
SDEnd03E3:
	jrcxz DL03E4
	jmp DLEnd03DE
DL03E4:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "6"
	or rPOk, rPOk
	jnz SD03E5
	jmp SDEnd03E5
SD03E5:
	call pOut
	 db 0x09, '6 digit",'
SDEnd03E5:
	jrcxz DL03E6
	jmp DLEnd03DE
DL03E6:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "7"
	or rPOk, rPOk
	jnz SD03E7
	jmp SDEnd03E7
SD03E7:
	call pOut
	 db 0x09, '7 digit",'
SDEnd03E7:
	jrcxz DL03E8
	jmp DLEnd03DE
DL03E8:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "8"
	or rPOk, rPOk
	jnz SD03E9
	jmp SDEnd03E9
SD03E9:
	call pOut
	 db 0x09, '8 digit",'
SDEnd03E9:
	jrcxz DL03EA
	jmp DLEnd03DE
DL03EA:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "9"
	or rPOk, rPOk
	jnz SD03EB
	jmp SDEnd03EB
SD03EB:
	call pOut
	 db 0x09, '9 digit",'
SDEnd03EB:
	jrcxz DL03EC
	jmp DLEnd03DE
DL03EC:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "A"
	or rPOk, rPOk
	jnz SD03ED
	jmp SDEnd03ED
SD03ED:
	call pOut
	 db 0x0A, '10 digit",'
SDEnd03ED:
	jrcxz DL03EE
	jmp DLEnd03DE
DL03EE:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "B"
	or rPOk, rPOk
	jnz SD03EF
	jmp SDEnd03EF
SD03EF:
	call pOut
	 db 0x0A, '11 digit",'
SDEnd03EF:
	jrcxz DL03F0
	jmp DLEnd03DE
DL03F0:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "C"
	or rPOk, rPOk
	jnz SD03F1
	jmp SDEnd03F1
SD03F1:
	call pOut
	 db 0x0A, '12 digit",'
SDEnd03F1:
	jrcxz DL03F2
	jmp DLEnd03DE
DL03F2:	inc rcx
	call cTop
	call b
	or rPOk, rPOk
	jnz SD03F3
	jmp SDEnd03F3
SD03F3:
	call pOutLI
	or rPOk, rPOk
	jnz SD03F4
	jmp SDEnd03F3
SD03F4:
	call pOut
	 db 0x0E, 'Illegal code",'
SDEnd03F3:
DLEnd03DE:
	call cDrop
	or rPOk, rPOk
	jnz SD03F5
	jmp SDEnd0332
SD03F5:
	call DropLastChar
	or rPOk, rPOk
	jnz SD03F6
	jmp SDEnd0332
SD03F6:
	call pOut
	 db 0x02, '},'
SDEnd0332:
	call cDrop
	ret

;Bit22	=	/*POS code 12*an*/
;	 pOut(0x0a, 0x09, 0x09, '"P1  Technical ability"       : "'),
;	(	"2", pOut('2 Magnetic stripe",')|
;		"3", pOut('3 Bar code",')|
;		"5", pOut('5 Chip",')|
;		"6", pOut('6 Key entry",')|
;		"A", pOut('A RFID",')|
;		"B", pOut('B Magn & Key entry",')|
;		"C", pOut('C Magn, Chip, Key entry",')|
;		"D", pOut('D Magn & Chip",')|
;		"E", pOut('E Chip & Key entry",')|
;		b, pOutLI, pOut('=Illegal code",')),
;
;	 pOut(0x0a, 0x09, 0x09, '"P2  Authentication ability"  : "'),
;	(	"0", pOut('0 None",')|
;		"1", pOut('1 PIN",')|
;		"6", pOut('6 Unknown",')|
;		"9", pOut('9 EMV",')|
;		"S", pOut('S Signature",')|
;		"T", pOut('T EMV offline PIN",')|
;		"U", pOut('U EMV online PIN",')|
;		"V", pOut('V Sign & EMV offline PIN",')|
;		"X", pOut('X Sign & EMV online PIN",')|
;		"Y", pOut('Y Sign & EMV on/offfline PIN",')|
;		"Z", pOut('Z EMV on/offline PIN",')|
;		b, pOutLI, pOut('=Illegal code",')),
;
;	 pOut(0x0a, 0x09, 0x09, '"P3  Card capture ability"    : "'),
;	(	"0", pOut('0 None",')|
;		"1", pOut('1 Card",')|
;		"T", pOut('T None & EMV Sda/Dda/Cda",')|
;		"U", pOut('U EMV Sda/Dda/Cda",')|
;		"V", pOut('V None & EMV Sda/Dda",')|
;		"W", pOut('W EMV Sda/Dda",')|
;		b, pOutLI, pOut('=Illegal code",')),
;
;	 pOut(0x0a, 0x09, 0x09, '"P4  Operating Environment"   : "'),
;	(	"1", pOut('1 IPT",')|
;		"2", pOut('2 OPT",')|
;		"3", pOut('3 Dealer IPT",')|
;		"4", pOut('4 Dealer OPT",')|
;		b, pOutLI, pOut('=Illegal code",')),
;
;	 pOut(0x0a, 0x09, 0x09, '"P5  Card holder presence"    : "'),		
;	(	"0", pOut('0 Card holder present",')|
;		"1", pOut('1 Card holder not present",')|
;		b, pOutLI, pOut('=Illegal code",')),
;
;	 pOut(0x0a, 0x09, 0x09, '"P6  Card presence"           : "'),
;	(	"0", pOut('0 Card not present",')|
;		"1", pOut('1 Card present",')|
;		b, pOutLI, pOut('=Illegal code",')),
;
;	 pOut(0x0a, 0x09, 0x09, '"P7  Card data input mode"    : "'),
;	(	"2", pOut('2 Magn used",')|
;		"3", pOut('3 Bar code used",')|
;		"5", pOut('5 Chip used",')|
;		"6", pOut('6 Manual done",')|
;		"A", pOut('A RFID used",')|
;		"B", pOut('B Magn used",')|
;		"C", pOut('C Chip used",')|
;		"D", pOut('D Fall back magn used",')|
;		b, pOutLI, pOut('Illegal code",')),
;
;	 pOut(0x0a, 0x09, 0x09, '"P8  Card holder auth method" : "'),		
;	(	"0", pOut('0 CardHolderNotAuthenticated",')|
;		"1", pOut('1 PIN used",')|
;		"5", pOut('5 Signature used",')|
;		"6", pOut('6 DriverLicense used",')|
;		"9", pOut('9 EMV Pin for 2nd card",')|
;		b, pOutLI, pOut('Illegal code",')),	
;
;	 pOut(0x0a, 0x09, 0x09, '"P9  Card holder auth entity" : "'),		
;	(	"0", pOut('0 Card holder not authenticated",')|
;		"1", pOut('1 Chip authorized Cardholder",')|
;		"2", pOut('2 Terminal authorized",')|
;		"3", pOut('3 Authorising agent used",')|
;		"4", pOut('4 Merchant did auth",')|
;		"5", pOut('5 Other auth",')|
;		b, pOutLI, pOut('=Illegal code",')),
;
;	 pOut(0x0a, 0x09, 0x09, '"P10 CAD can update card"     : "'),		
;	(	"0", pOut('0 Unknown",')|
;		"1", pOut('1 CAD cannot update card",')|
;		"2", pOut('2 CAD can update magstripe",')|
;		"3", pOut('3 CAD can update chip",')|
;		b, pOutLI, pOut('=Illegal code",')),
;
;	 pOut(0x0a, 0x09, 0x09, '"P11 POI output ability"      : "'),
;	(	"0", pOut('0 Unknown",')|
;		"1", pOut('1 None",')|
;		"2", pOut('2 Print",')|
;		"3", pOut('3 Display",')|
;		"4", pOut('4 Print and display",')|
;		"5", pOut('5 Special",')|
;		b, pOutLI, pOut('=Illegal code",')),
;
;	 pOut(0x0a, 0x09, 0x09, '"P12 PIN capture capability"  : "'),		
;	(	"0", pOut('None",')|
;		"1", pOut('Unknown",')|
;		"4", pOut('4 digit",')|
;		"5", pOut('5 digit",')|
;		"6", pOut('6 digit",')|
;		"7", pOut('7 digit",')|
;		"8", pOut('8 digit",')|
;		"9", pOut('9 digit",')|
;		"A", pOut('10 digit",')|
;		"B", pOut('11 digit",')|
;		"C", pOut('12 digit",')|
;		b, pOutLI, pOut('Illegal code",')),	
;	DropLastChar,
;	pOut('},');
;		

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Bit24:
	call cPush
	call pIn
	 db 0x0003, "101"
	or rPOk, rPOk
	jnz SD03F7
	jmp SDEnd03F7
SD03F7:
	call pOut
	 db 0x2B, "Original authorization – amount estimated"
SDEnd03F7:
	jrcxz DL03F8
	jmp DLEnd03F8
DL03F8:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "108"
	or rPOk, rPOk
	jnz SD03F9
	jmp SDEnd03F9
SD03F9:
	call pOut
	 db 0x07, "Inquiry"
SDEnd03F9:
	jrcxz DL03FA
	jmp DLEnd03F8
DL03FA:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "181"
	or rPOk, rPOk
	jnz SD03FB
	jmp SDEnd03FB
SD03FB:
	call pOut
	 db 0x3A, "Original authorization – amount estimated, 9100 from IPT"
SDEnd03FB:
	jrcxz DL03FC
	jmp DLEnd03F8
DL03FC:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "182"
	or rPOk, rPOk
	jnz SD03FD
	jmp SDEnd03FD
SD03FD:
	call pOut
	 db 0x3A, "Original authorization – amount known, 9100 from Oil FEP"
SDEnd03FD:
	jrcxz DL03FE
	jmp DLEnd03F8
DL03FE:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "200"
	or rPOk, rPOk
	jnz SD03FF
	jmp SDEnd03FF
SD03FF:
	call pOut
	 db 0x5E, "Original financial request/advice  1200 original request, 1220 standing-in for the Card Issuer"
SDEnd03FF:
	jrcxz DL0400
	jmp DLEnd03F8
DL0400:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "201"
	or rPOk, rPOk
	jnz SD0401
	jmp SDEnd0401
SD0401:
	call pOut
	 db 0x5C, "Previously approved authorization – amount the same (1220 previously authorised with 1100)"
SDEnd0401:
	jrcxz DL0402
	jmp DLEnd03F8
DL0402:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "202"
	or rPOk, rPOk
	jnz SD0403
	jmp SDEnd0403
SD0403:
	call pOut
	 db 0x5B, "Previously approved authorization – amount differs (1220 previously authorised with 1100)"
SDEnd0403:
	jrcxz DL0404
	jmp DLEnd03F8
DL0404:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "281"
	or rPOk, rPOk
	jnz SD0405
	jmp SDEnd0405
SD0405:
	call pOut
	 db 0x45, "Previously approved authorization – amount the same (1220 from IPT)"
SDEnd0405:
	jrcxz DL0406
	jmp DLEnd03F8
DL0406:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "282"
	or rPOk, rPOk
	jnz SD0407
	jmp SDEnd0407
SD0407:
	call pOut
	 db 0x44, "Previously approved authorization – amount differs (1220 from IPT)"
SDEnd0407:
	jrcxz DL0408
	jmp DLEnd03F8
DL0408:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "301"
	or rPOk, rPOk
	jnz SD0409
	jmp SDEnd0409
SD0409:
	call pOut
	 db 0x2C, "Add record (Loyalty card link/wrong PIN used"
SDEnd0409:
	jrcxz DL040A
	jmp DLEnd03F8
DL040A:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "302"
	or rPOk, rPOk
	jnz SD040B
	jmp SDEnd040B
SD040B:
	call pOut
	 db 0x1A, "Change record (PIN change)"
SDEnd040B:
	jrcxz DL040C
	jmp DLEnd03F8
DL040C:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "400"
	or rPOk, rPOk
	jnz SD040D
	jmp SDEnd040D
SD040D:
	call pOut
	 db 0x37, "Full reversal, transaction did not complete as approved"
SDEnd040D:
	jrcxz DL040E
	jmp DLEnd03F8
DL040E:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "500"
	or rPOk, rPOk
	jnz SD040F
	jmp SDEnd040F
SD040F:
	call pOut
	 db 0x14, "Final reconciliation"
SDEnd040F:
	jrcxz DL0410
	jmp DLEnd03F8
DL0410:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "501"
	or rPOk, rPOk
	jnz SD0411
	jmp SDEnd0411
SD0411:
	call pOut
	 db 0x18, "Checkpoint reconciiation"
SDEnd0411:
	jrcxz DL0412
	jmp DLEnd03F8
DL0412:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "502"
	or rPOk, rPOk
	jnz SD0413
	jmp SDEnd0413
SD0413:
	call pOut
	 db 0x2B, "Final reconciliation in a specific currency"
SDEnd0413:
	jrcxz DL0414
	jmp DLEnd03F8
DL0414:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "503"
	or rPOk, rPOk
	jnz SD0415
	jmp SDEnd0415
SD0415:
	call pOut
	 db 0x30, "Checkpoint deconciliation in a specific currency"
SDEnd0415:
	jrcxz DL0416
	jmp DLEnd03F8
DL0416:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "801"
	or rPOk, rPOk
	jnz SD0417
	jmp SDEnd0417
SD0417:
	call pOut
	 db 0x18, "System condition/sign-on"
SDEnd0417:
	jrcxz DL0418
	jmp DLEnd03F8
DL0418:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "802"
	or rPOk, rPOk
	jnz SD0419
	jmp SDEnd0419
SD0419:
	call pOut
	 db 0x19, "System condition/sign-off"
SDEnd0419:
	jrcxz DL041A
	jmp DLEnd03F8
DL041A:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "811"
	or rPOk, rPOk
	jnz SD041B
	jmp SDEnd041B
SD041B:
	call pOut
	 db 0x1A, "System security/key change"
SDEnd041B:
	jrcxz DL041C
	jmp DLEnd03F8
DL041C:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "814"
	or rPOk, rPOk
	jnz SD041D
	jmp SDEnd041D
SD041D:
	call pOut
	 db 0x3C, "System security/device authentication PIN Pad initialisation"
SDEnd041D:
	jrcxz DL041E
	jmp DLEnd03F8
DL041E:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "831"
	or rPOk, rPOk
	jnz SD041F
	jmp SDEnd041F
SD041F:
	call pOut
	 db 0x1E, "System audit control/echo test"
SDEnd041F:
	jrcxz DL0420
	jmp DLEnd03F8
DL0420:	inc rcx
	call cTop
	call cPush
	mov rFactCnt, 3
	or rFactCnt, rFactCnt
	jz FacEnd0421
FacRep0421:
	call b
	dec rFactCnt
	jrcxz FacEnd0421
	jz FacEnd0421
	jmp FacRep0421
FacEnd0421:
	call cDrop
	or rPOk, rPOk
	jnz SD0422
	jmp SDEnd0422
SD0422:
	call pOut
	 db 0x12, "Unknown IFSF code!"
SDEnd0422:
DLEnd03F8:
	call cDrop
	ret

;Bit24	=	/* Function code*/
;		"101", pOut("Original authorization – amount estimated")|
;		"108", pOut("Inquiry")|
;		"181", pOut("Original authorization – amount estimated, 9100 from IPT")|
;		"182", pOut("Original authorization – amount known, 9100 from Oil FEP")|
;		"200", pOut("Original financial request/advice  1200 original request, 1220 standing-in for the Card Issuer")|
;		"201", pOut("Previously approved authorization – amount the same (1220 previously authorised with 1100)")|
;		"202", pOut("Previously approved authorization – amount differs (1220 previously authorised with 1100)")|
;		"281", pOut("Previously approved authorization – amount the same (1220 from IPT)")|
;		"282", pOut("Previously approved authorization – amount differs (1220 from IPT)")|
;		"301", pOut("Add record (Loyalty card link/wrong PIN used")|
;		"302", pOut("Change record (PIN change)")|
;		"400", pOut("Full reversal, transaction did not complete as approved")|
;		"500", pOut("Final reconciliation")|
;		"501", pOut("Checkpoint reconciiation")|
;		"502", pOut("Final reconciliation in a specific currency")|
;		"503", pOut("Checkpoint deconciliation in a specific currency")|
;		"801", pOut("System condition/sign-on")|
;		"802", pOut("System condition/sign-off")|
;		"811", pOut("System security/key change")|
;		"814", pOut("System security/device authentication PIN Pad initialisation")|
;		"831", pOut("System audit control/echo test")|
;		(3*b), pOut("Unknown IFSF code!");
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Bit25:
	call cPush
	call pIn
	 db 0x0004, "1003"
	or rPOk, rPOk
	jnz SD0423
	jmp SDEnd0423
SD0423:
	call pOut
	 db 0x31, "Card Issuer unavailable (Use for FEP unavailable)"
SDEnd0423:
	jrcxz DL0424
	jmp DLEnd0424
DL0424:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1004"
	or rPOk, rPOk
	jnz SD0425
	jmp SDEnd0425
SD0425:
	call pOut
	 db 0x12, "Terminal Processed"
SDEnd0425:
	jrcxz DL0426
	jmp DLEnd0424
DL0426:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1005"
	or rPOk, rPOk
	jnz SD0427
	jmp SDEnd0427
SD0427:
	call pOut
	 db 0x0D, "ICC Processed"
SDEnd0427:
	jrcxz DL0428
	jmp DLEnd0424
DL0428:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1006"
	or rPOk, rPOk
	jnz SD0429
	jmp SDEnd0429
SD0429:
	call pOut
	 db 0x11, "Under floor limit"
SDEnd0429:
	jrcxz DL042A
	jmp DLEnd0424
DL042A:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1007"
	or rPOk, rPOk
	jnz SD042B
	jmp SDEnd042B
SD042B:
	call pOut
	 db 0x2C, "Stand-in processing at the acquirer's option"
SDEnd042B:
	jrcxz DL042C
	jmp DLEnd0424
DL042C:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1376"
	or rPOk, rPOk
	jnz SD042D
	jmp SDEnd042D
SD042D:
	call pOut
	 db 0x5B, "Reversal from previous batch (Sent as refund because reversal from previous batch rejected)"
SDEnd042D:
	jrcxz DL042E
	jmp DLEnd0424
DL042E:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1377"
	or rPOk, rPOk
	jnz SD042F
	jmp SDEnd042F
SD042F:
	call pOut
	 db 0x27, "Manual voucher processed (Punch bureau)"
SDEnd042F:
	jrcxz DL0430
	jmp DLEnd0424
DL0430:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "3700"
	or rPOk, rPOk
	jnz SD0431
	jmp SDEnd0431
SD0431:
	call pOut
	 db 0x27, "Customer PIN Change  Private use in [1]"
SDEnd0431:
	jrcxz DL0432
	jmp DLEnd0424
DL0432:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "3701"
	or rPOk, rPOk
	jnz SD0433
	jmp SDEnd0433
SD0433:
	call pOut
	 db 0x20, "Loyalty Link  Private use in [1]"
SDEnd0433:
	jrcxz DL0434
	jmp DLEnd0424
DL0434:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "3702"
	or rPOk, rPOk
	jnz SD0435
	jmp SDEnd0435
SD0435:
	call pOut
	 db 0x2E, "Advice of invalid PIN used  Private use in [1]"
SDEnd0435:
	jrcxz DL0436
	jmp DLEnd0424
DL0436:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1500"
	or rPOk, rPOk
	jnz SD0437
	jmp SDEnd0437
SD0437:
	call pOut
	 db 0x32, "ICC application,common data file unable to process"
SDEnd0437:
	jrcxz DL0438
	jmp DLEnd0424
DL0438:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1501"
	or rPOk, rPOk
	jnz SD0439
	jmp SDEnd0439
SD0439:
	call pOut
	 db 0x37, "ICC application,application data file unable to process"
SDEnd0439:
	jrcxz DL043A
	jmp DLEnd0424
DL043A:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1502"
	or rPOk, rPOk
	jnz SD043B
	jmp SDEnd043B
SD043B:
	call pOut
	 db 0x14, "ICC random selection"
SDEnd043B:
	jrcxz DL043C
	jmp DLEnd0424
DL043C:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1503"
	or rPOk, rPOk
	jnz SD043D
	jmp SDEnd043D
SD043D:
	call pOut
	 db 0x19, "Terminal random selection"
SDEnd043D:
	jrcxz DL043E
	jmp DLEnd0424
DL043E:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1504"
	or rPOk, rPOk
	jnz SD043F
	jmp SDEnd043F
SD043F:
	call pOut
	 db 0x1E, "Terminal unable to process ICC"
SDEnd043F:
	jrcxz DL0440
	jmp DLEnd0424
DL0440:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1505"
	or rPOk, rPOk
	jnz SD0441
	jmp SDEnd0441
SD0441:
	call pOut
	 db 0x15, "On-line forced by ICC"
SDEnd0441:
	jrcxz DL0442
	jmp DLEnd0424
DL0442:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1506"
	or rPOk, rPOk
	jnz SD0443
	jmp SDEnd0443
SD0443:
	call pOut
	 db 0x1D, "Online forced by card aceptor"
SDEnd0443:
	jrcxz DL0444
	jmp DLEnd0424
DL0444:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1507"
	or rPOk, rPOk
	jnz SD0445
	jmp SDEnd0445
SD0445:
	call pOut
	 db 0x22, "Online forced by CAD to be updated"
SDEnd0445:
	jrcxz DL0446
	jmp DLEnd0424
DL0446:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1508"
	or rPOk, rPOk
	jnz SD0447
	jmp SDEnd0447
SD0447:
	call pOut
	 db 0x1A, "On-line forced by terminal"
SDEnd0447:
	jrcxz DL0448
	jmp DLEnd0424
DL0448:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1509"
	or rPOk, rPOk
	jnz SD0449
	jmp SDEnd0449
SD0449:
	call pOut
	 db 0x1C, "Online forced by card issuer"
SDEnd0449:
	jrcxz DL044A
	jmp DLEnd0424
DL044A:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1510"
	or rPOk, rPOk
	jnz SD044B
	jmp SDEnd044B
SD044B:
	call pOut
	 db 0x10, "Over floor limit"
SDEnd044B:
	jrcxz DL044C
	jmp DLEnd0424
DL044C:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1511"
	or rPOk, rPOk
	jnz SD044D
	jmp SDEnd044D
SD044D:
	call pOut
	 db 0x13, "Merchant suspicious"
SDEnd044D:
	jrcxz DL044E
	jmp DLEnd0424
DL044E:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "1776"
	or rPOk, rPOk
	jnz SD044F
	jmp SDEnd044F
SD044F:
	call pOut
	 db 0x90, "POS offline voice auth  Indicates request comes from Oil FEP and resulting approval codes will be used in separate 1220 transaction from the POS"
SDEnd044F:
	jrcxz DL0450
	jmp DLEnd0424
DL0450:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "3700"
	or rPOk, rPOk
	jnz SD0451
	jmp SDEnd0451
SD0451:
	call pOut
	 db 0x27, "Customer PIN Change  Private use in [1]"
SDEnd0451:
	jrcxz DL0452
	jmp DLEnd0424
DL0452:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "3701"
	or rPOk, rPOk
	jnz SD0453
	jmp SDEnd0453
SD0453:
	call pOut
	 db 0x20, "Loyalty Link  Private use in [1]"
SDEnd0453:
	jrcxz DL0454
	jmp DLEnd0424
DL0454:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "3702"
	or rPOk, rPOk
	jnz SD0455
	jmp SDEnd0455
SD0455:
	call pOut
	 db 0x2E, "Advice of invalid PIN used  Private use in [1]"
SDEnd0455:
	jrcxz DL0456
	jmp DLEnd0424
DL0456:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "4000"
	or rPOk, rPOk
	jnz SD0457
	jmp SDEnd0457
SD0457:
	call pOut
	 db 0x15, "Customer Cancellation"
SDEnd0457:
	jrcxz DL0458
	jmp DLEnd0424
DL0458:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "4020"
	or rPOk, rPOk
	jnz SD0459
	jmp SDEnd0459
SD0459:
	call pOut
	 db 0x47, "Invalid Response, No action taken  Problem with the MAC on the response"
SDEnd0459:
	jrcxz DL045A
	jmp DLEnd0424
DL045A:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "4021"
	or rPOk, rPOk
	jnz SD045B
	jmp SDEnd045B
SD045B:
	call pOut
	 db 0x1C, "Timeout Waiting for response"
SDEnd045B:
	jrcxz DL045C
	jmp DLEnd0424
DL045C:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "4351"
	or rPOk, rPOk
	jnz SD045D
	jmp SDEnd045D
SD045D:
	call pOut
	 db 0x38, "Cancellation – unmatched signature  Private use in [1]"
SDEnd045D:
	jrcxz DL045E
	jmp DLEnd0424
DL045E:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "4352"
	or rPOk, rPOk
	jnz SD045F
	jmp SDEnd045F
SD045F:
	call pOut
	 db 0x2D, "Card declined transaction  Private use in [1]"
SDEnd045F:
	jrcxz DL0460
	jmp DLEnd0424
DL0460:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "4353"
	or rPOk, rPOk
	jnz SD0461
	jmp SDEnd0461
SD0461:
	call pOut
	 db 0x18, "Error in chip processing"
SDEnd0461:
	jrcxz DL0462
	jmp DLEnd0424
DL0462:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "4354"
	or rPOk, rPOk
	jnz SD0463
	jmp SDEnd0463
SD0463:
	call pOut
	 db 0x0C, "System error"
SDEnd0463:
	jrcxz DL0464
	jmp DLEnd0424
DL0464:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "8601"
	or rPOk, rPOk
	jnz SD0465
	jmp SDEnd0465
SD0465:
	call pOut
	 db 0x27, "Communications Test  Private use in [1]"
SDEnd0465:
	jrcxz DL0466
	jmp DLEnd0424
DL0466:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "8602"
	or rPOk, rPOk
	jnz SD0467
	jmp SDEnd0467
SD0467:
	call pOut
	 db 0x20, "Key Exchange  Private use in [1]"
SDEnd0467:
	jrcxz DL0468
	jmp DLEnd0424
DL0468:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "8603"
	or rPOk, rPOk
	jnz SD0469
	jmp SDEnd0469
SD0469:
	call pOut
	 db 0x1A, "Log on  Private use in [1]"
SDEnd0469:
	jrcxz DL046A
	jmp DLEnd0424
DL046A:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "8604"
	or rPOk, rPOk
	jnz SD046B
	jmp SDEnd046B
SD046B:
	call pOut
	 db 0x1B, "Log off  Private use in [1]"
SDEnd046B:
	jrcxz DL046C
	jmp DLEnd0424
DL046C:	inc rcx
	call cTop
	call cPush
	mov rFactCnt, 4
	or rFactCnt, rFactCnt
	jz FacEnd046D
FacRep046D:
	call b
	dec rFactCnt
	jrcxz FacEnd046D
	jz FacEnd046D
	jmp FacRep046D
FacEnd046D:
	call cDrop
	or rPOk, rPOk
	jnz SD046E
	jmp SDEnd046E
SD046E:
	call pOut
	 db 0x12, "Unknown IFSF code!"
SDEnd046E:
DLEnd0424:
	call cDrop
	ret

;Bit25 = 	"1003", pOut("Card Issuer unavailable (Use for FEP unavailable)")|
;		"1004", pOut("Terminal Processed")|
;		"1005", pOut("ICC Processed")|
;		"1006", pOut("Under floor limit")|
;		"1007", pOut("Stand-in processing at the acquirer's option")|
;		"1376", pOut("Reversal from previous batch (Sent as refund because reversal from previous batch rejected)")|
;		"1377", pOut("Manual voucher processed (Punch bureau)")|
;		"3700", pOut("Customer PIN Change  Private use in [1]")|
;		"3701", pOut("Loyalty Link  Private use in [1]")|
;		"3702", pOut("Advice of invalid PIN used  Private use in [1]")|
;		"1500", pOut("ICC application,common data file unable to process")|
;		"1501", pOut("ICC application,application data file unable to process")|
;		"1502", pOut("ICC random selection")|
;		"1503", pOut("Terminal random selection")|
;		"1504", pOut("Terminal unable to process ICC")|
;		"1505", pOut("On-line forced by ICC")|
;		"1506", pOut("Online forced by card aceptor")|
;		"1507", pOut("Online forced by CAD to be updated")|
;		"1508", pOut("On-line forced by terminal")|
;		"1509", pOut("Online forced by card issuer")|
;		"1510", pOut("Over floor limit")|
;		"1511", pOut("Merchant suspicious")|
;		"1776", pOut("POS offline voice auth  Indicates request comes from Oil FEP and resulting approval codes will be used in separate 1220 transaction from the POS")|
;		"3700", pOut("Customer PIN Change  Private use in [1]")|
;		"3701", pOut("Loyalty Link  Private use in [1]")|
;		"3702", pOut("Advice of invalid PIN used  Private use in [1]")|
;		"4000", pOut("Customer Cancellation")|
;		"4020", pOut("Invalid Response, No action taken  Problem with the MAC on the response")|
;		"4021", pOut("Timeout Waiting for response")|
;		"4351", pOut("Cancellation – unmatched signature  Private use in [1]")|
;		"4352", pOut("Card declined transaction  Private use in [1]")|
;		"4353", pOut("Error in chip processing")|
;		"4354", pOut("System error")|
;		"8601", pOut("Communications Test  Private use in [1]")|
;		"8602", pOut("Key Exchange  Private use in [1]")|
;		"8603", pOut("Log on  Private use in [1]")|
;		"8604", pOut("Log off  Private use in [1]")|
;		(4*b), pOut("Unknown IFSF code!");
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Bit26:
	call cPush
	call pIn
	 db 0x0004, "5143"
	or rPOk, rPOk
	jnz SD046F
	jmp SDEnd046F
SD046F:
	call pOut
	 db 0x24, "Motor vehicle supplies and new parts"
SDEnd046F:
	jrcxz DL0470
	jmp DLEnd0470
DL0470:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "5172"
	or rPOk, rPOk
	jnz SD0471
	jmp SDEnd0471
SD0471:
	call pOut
	 db 0x20, "Petroleum and petroleum products"
SDEnd0471:
	jrcxz DL0472
	jmp DLEnd0470
DL0472:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "5499"
	or rPOk, rPOk
	jnz SD0473
	jmp SDEnd0473
SD0473:
	call pOut
	 db 0x12, "Convenience stores"
SDEnd0473:
	jrcxz DL0474
	jmp DLEnd0470
DL0474:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "5541"
	or rPOk, rPOk
	jnz SD0475
	jmp SDEnd0475
SD0475:
	call pOut
	 db 0x0F, "Service station"
SDEnd0475:
	jrcxz DL0476
	jmp DLEnd0470
DL0476:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "5542"
	or rPOk, rPOk
	jnz SD0477
	jmp SDEnd0477
SD0477:
	call pOut
	 db 0x30, "Service station outdoor (Worldline WAP protocol)"
SDEnd0477:
	jrcxz DL0478
	jmp DLEnd0470
DL0478:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "4468"
	or rPOk, rPOk
	jnz SD0479
	jmp SDEnd0479
SD0479:
	call pOut
	 db 0x20, "Marinas, marine service-supplies"
SDEnd0479:
	jrcxz DL047A
	jmp DLEnd0470
DL047A:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "4582"
	or rPOk, rPOk
	jnz SD047B
	jmp SDEnd047B
SD047B:
	call pOut
	 db 0x2A, "Airports, flying fields, airport terminals"
SDEnd047B:
	jrcxz DL047C
	jmp DLEnd0470
DL047C:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "4784"
	or rPOk, rPOk
	jnz SD047D
	jmp SDEnd047D
SD047D:
	call pOut
	 db 0x12, "Tolls, bridge fees"
SDEnd047D:
	jrcxz DL047E
	jmp DLEnd0470
DL047E:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "5532"
	or rPOk, rPOk
	jnz SD047F
	jmp SDEnd047F
SD047F:
	call pOut
	 db 0x16, "Automotive tyre stores"
SDEnd047F:
	jrcxz DL0480
	jmp DLEnd0470
DL0480:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "5533"
	or rPOk, rPOk
	jnz SD0481
	jmp SDEnd0481
SD0481:
	call pOut
	 db 0x24, "Automotive parts, accessories stores"
SDEnd0481:
	jrcxz DL0482
	jmp DLEnd0470
DL0482:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "5542"
	or rPOk, rPOk
	jnz SD0483
	jmp SDEnd0483
SD0483:
	call pOut
	 db 0x1C, "Automated gasoline dispenser"
SDEnd0483:
	jrcxz DL0484
	jmp DLEnd0470
DL0484:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "5812"
	or rPOk, rPOk
	jnz SD0485
	jmp SDEnd0485
SD0485:
	call pOut
	 db 0x1A, "Eating places, restaurants"
SDEnd0485:
	jrcxz DL0486
	jmp DLEnd0470
DL0486:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "5814"
	or rPOk, rPOk
	jnz SD0487
	jmp SDEnd0487
SD0487:
	call pOut
	 db 0x15, "Fast food restaurants"
SDEnd0487:
	jrcxz DL0488
	jmp DLEnd0470
DL0488:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "5983"
	or rPOk, rPOk
	jnz SD0489
	jmp SDEnd0489
SD0489:
	call pOut
	 db 0x38, "Fuel Dealers - Coal, Fuel Oil, Liquefied Petroleum, Wood"
SDEnd0489:
	jrcxz DL048A
	jmp DLEnd0470
DL048A:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "7523"
	or rPOk, rPOk
	jnz SD048B
	jmp SDEnd048B
SD048B:
	call pOut
	 db 0x23, "Automobile parking lots and garages"
SDEnd048B:
	jrcxz DL048C
	jmp DLEnd0470
DL048C:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "7841"
	or rPOk, rPOk
	jnz SD048D
	jmp SDEnd048D
SD048D:
	call pOut
	 db 0x13, "Video rental stores"
SDEnd048D:
	jrcxz DL048E
	jmp DLEnd0470
DL048E:	inc rcx
	call cTop
	call pIn
	 db 0x0004, "7542"
	or rPOk, rPOk
	jnz SD048F
	jmp SDEnd048F
SD048F:
	call pOut
	 db 0x0A, "Car washes"
SDEnd048F:
	jrcxz DL0490
	jmp DLEnd0470
DL0490:	inc rcx
	call cTop
	call cPush
	mov rFactCnt, 4
	or rFactCnt, rFactCnt
	jz FacEnd0491
FacRep0491:
	call b
	dec rFactCnt
	jrcxz FacEnd0491
	jz FacEnd0491
	jmp FacRep0491
FacEnd0491:
	call cDrop
	or rPOk, rPOk
	jnz SD0492
	jmp SDEnd0492
SD0492:
	call pOut
	 db 0x12, "Unknown IFSF code!"
SDEnd0492:
DLEnd0470:
	call cDrop
	ret

;Bit26 = 	"5143", pOut("Motor vehicle supplies and new parts")|
;		"5172", pOut("Petroleum and petroleum products")|
;		"5499", pOut("Convenience stores")|
;		"5541", pOut("Service station")|
;		"5542", pOut("Service station outdoor (Worldline WAP protocol)")|
;		"4468", pOut("Marinas, marine service-supplies")|
;		"4582", pOut("Airports, flying fields, airport terminals")|
;		"4784", pOut("Tolls, bridge fees")|
;		"5532", pOut("Automotive tyre stores")|
;		"5533", pOut("Automotive parts, accessories stores")|
;		"5542", pOut("Automated gasoline dispenser")|
;		"5812", pOut("Eating places, restaurants")|
;		"5814", pOut("Fast food restaurants")|
;		"5983", pOut("Fuel Dealers - Coal, Fuel Oil, Liquefied Petroleum, Wood")|
;		"7523", pOut("Automobile parking lots and garages")|
;		"7841", pOut("Video rental stores")|
;		"7542", pOut("Car washes")|
;		(4*b), pOut("Unknown IFSF code!");
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Bit39:
	call cPush
	call pIn
	 db 0x0003, "000"
	or rPOk, rPOk
	jnz SD0493
	jmp SDEnd0493
SD0493:
	call pOut
	 db 0x08, "Approved"
SDEnd0493:
	jrcxz DL0494
	jmp DLEnd0494
DL0494:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "001"
	or rPOk, rPOk
	jnz SD0495
	jmp SDEnd0495
SD0495:
	call pOut
	 db 0x24, "Approved, honour with Identification"
SDEnd0495:
	jrcxz DL0496
	jmp DLEnd0494
DL0496:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "002"
	or rPOk, rPOk
	jnz SD0497
	jmp SDEnd0497
SD0497:
	call pOut
	 db 0x1C, "Approved, for partial amount"
SDEnd0497:
	jrcxz DL0498
	jmp DLEnd0494
DL0498:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "003"
	or rPOk, rPOk
	jnz SD0499
	jmp SDEnd0499
SD0499:
	call pOut
	 db 0x0D, "Approved, VIP"
SDEnd0499:
	jrcxz DL049A
	jmp DLEnd0494
DL049A:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "005"
	or rPOk, rPOk
	jnz SD049B
	jmp SDEnd049B
SD049B:
	call pOut
	 db 0x2F, "Approved, account type specified by card issuer"
SDEnd049B:
	jrcxz DL049C
	jmp DLEnd0494
DL049C:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "006"
	or rPOk, rPOk
	jnz SD049D
	jmp SDEnd049D
SD049D:
	call pOut
	 db 0x43, "Approved, for partial amount, account type specified by card issuer"
SDEnd049D:
	jrcxz DL049E
	jmp DLEnd0494
DL049E:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "007"
	or rPOk, rPOk
	jnz SD049F
	jmp SDEnd049F
SD049F:
	call pOut
	 db 0x14, "Approved, update ICC"
SDEnd049F:
	jrcxz DL04A0
	jmp DLEnd0494
DL04A0:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "080"
	or rPOk, rPOk
	jnz SD04A1
	jmp SDEnd04A1
SD04A1:
	call pOut
	 db 0x22, "Approved, (liability not accepted)"
SDEnd04A1:
	jrcxz DL04A2
	jmp DLEnd0494
DL04A2:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "081"
	or rPOk, rPOk
	jnz SD04A3
	jmp SDEnd04A3
SD04A3:
	call pOut
	 db 0x3C, "Declined, honor with Identification (liability not accepted)"
SDEnd04A3:
	jrcxz DL04A4
	jmp DLEnd0494
DL04A4:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "100"
	or rPOk, rPOk
	jnz SD04A5
	jmp SDEnd04A5
SD04A5:
	call pOut
	 db 0x17, "Declined, do not honour"
SDEnd04A5:
	jrcxz DL04A6
	jmp DLEnd0494
DL04A6:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "101"
	or rPOk, rPOk
	jnz SD04A7
	jmp SDEnd04A7
SD04A7:
	call pOut
	 db 0x16, "Declined, expired card"
SDEnd04A7:
	jrcxz DL04A8
	jmp DLEnd0494
DL04A8:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "102"
	or rPOk, rPOk
	jnz SD04A9
	jmp SDEnd04A9
SD04A9:
	call pOut
	 db 0x19, "Declined, suspected fraud"
SDEnd04A9:
	jrcxz DL04AA
	jmp DLEnd0494
DL04AA:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "103"
	or rPOk, rPOk
	jnz SD04AB
	jmp SDEnd04AB
SD04AB:
	call pOut
	 db 0x28, "Declined, card Acceptor contact acquirer"
SDEnd04AB:
	jrcxz DL04AC
	jmp DLEnd0494
DL04AC:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "104"
	or rPOk, rPOk
	jnz SD04AD
	jmp SDEnd04AD
SD04AD:
	call pOut
	 db 0x19, "Declined, restricted card"
SDEnd04AD:
	jrcxz DL04AE
	jmp DLEnd0494
DL04AE:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "106"
	or rPOk, rPOk
	jnz SD04AF
	jmp SDEnd04AF
SD04AF:
	call pOut
	 db 0x26, "Declined, allowable PIN tries exceeded"
SDEnd04AF:
	jrcxz DL04B0
	jmp DLEnd0494
DL04B0:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "107"
	or rPOk, rPOk
	jnz SD04B1
	jmp SDEnd04B1
SD04B1:
	call pOut
	 db 0x1E, "Declined, refer to Card Issuer"
SDEnd04B1:
	jrcxz DL04B2
	jmp DLEnd0494
DL04B2:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "108"
	or rPOk, rPOk
	jnz SD04B3
	jmp SDEnd04B3
SD04B3:
	call pOut
	 db 0x5F, "Declined, refer to card issuers special conditions for use May be combined with message in 62-3"
SDEnd04B3:
	jrcxz DL04B4
	jmp DLEnd0494
DL04B4:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "109"
	or rPOk, rPOk
	jnz SD04B5
	jmp SDEnd04B5
SD04B5:
	call pOut
	 db 0x1A, "Declined, invalid merchant"
SDEnd04B5:
	jrcxz DL04B6
	jmp DLEnd0494
DL04B6:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "110"
	or rPOk, rPOk
	jnz SD04B7
	jmp SDEnd04B7
SD04B7:
	call pOut
	 db 0x18, "Declined, invalid Amount"
SDEnd04B7:
	jrcxz DL04B8
	jmp DLEnd0494
DL04B8:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "111"
	or rPOk, rPOk
	jnz SD04B9
	jmp SDEnd04B9
SD04B9:
	call pOut
	 db 0x1D, "Declined, invalid Card Number"
SDEnd04B9:
	jrcxz DL04BA
	jmp DLEnd0494
DL04BA:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "112"
	or rPOk, rPOk
	jnz SD04BB
	jmp SDEnd04BB
SD04BB:
	call pOut
	 db 0x1B, "Declined, PIN data required"
SDEnd04BB:
	jrcxz DL04BC
	jmp DLEnd0494
DL04BC:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "114"
	or rPOk, rPOk
	jnz SD04BD
	jmp SDEnd04BD
SD04BD:
	call pOut
	 db 0x26, "Declined, no account of type requested"
SDEnd04BD:
	jrcxz DL04BE
	jmp DLEnd0494
DL04BE:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "115"
	or rPOk, rPOk
	jnz SD04BF
	jmp SDEnd04BF
SD04BF:
	call pOut
	 db 0x2A, "Declined, requested Function not supported"
SDEnd04BF:
	jrcxz DL04C0
	jmp DLEnd0494
DL04C0:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "116"
	or rPOk, rPOk
	jnz SD04C1
	jmp SDEnd04C1
SD04C1:
	call pOut
	 db 0x1E, "Declined, not sufficient funds"
SDEnd04C1:
	jrcxz DL04C2
	jmp DLEnd0494
DL04C2:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "117"
	or rPOk, rPOk
	jnz SD04C3
	jmp SDEnd04C3
SD04C3:
	call pOut
	 db 0x17, "Declined, incorrect PIN"
SDEnd04C3:
	jrcxz DL04C4
	jmp DLEnd0494
DL04C4:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "118"
	or rPOk, rPOk
	jnz SD04C5
	jmp SDEnd04C5
SD04C5:
	call pOut
	 db 0x18, "Declined, no card record"
SDEnd04C5:
	jrcxz DL04C6
	jmp DLEnd0494
DL04C6:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "119"
	or rPOk, rPOk
	jnz SD04C7
	jmp SDEnd04C7
SD04C7:
	call pOut
	 db 0x33, "Declined, transaction not permitted to the customer"
SDEnd04C7:
	jrcxz DL04C8
	jmp DLEnd0494
DL04C8:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "120"
	or rPOk, rPOk
	jnz SD04C9
	jmp SDEnd04C9
SD04C9:
	call pOut
	 db 0x33, "Declined, transaction not permitted to the terminal"
SDEnd04C9:
	jrcxz DL04CA
	jmp DLEnd0494
DL04CA:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "121"
	or rPOk, rPOk
	jnz SD04CB
	jmp SDEnd04CB
SD04CB:
	call pOut
	 db 0x29, "Declined, exceeds withdrawal amount limit"
SDEnd04CB:
	jrcxz DL04CC
	jmp DLEnd0494
DL04CC:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "122"
	or rPOk, rPOk
	jnz SD04CD
	jmp SDEnd04CD
SD04CD:
	call pOut
	 db 0x1C, "Declined, security violation"
SDEnd04CD:
	jrcxz DL04CE
	jmp DLEnd0494
DL04CE:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "123"
	or rPOk, rPOk
	jnz SD04CF
	jmp SDEnd04CF
SD04CF:
	call pOut
	 db 0x2C, "Declined, exceeds withdrawal frequency limit"
SDEnd04CF:
	jrcxz DL04D0
	jmp DLEnd0494
DL04D0:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "125"
	or rPOk, rPOk
	jnz SD04D1
	jmp SDEnd04D1
SD04D1:
	call pOut
	 db 0x1C, "Declined, card not effective"
SDEnd04D1:
	jrcxz DL04D2
	jmp DLEnd0494
DL04D2:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "126"
	or rPOk, rPOk
	jnz SD04D3
	jmp SDEnd04D3
SD04D3:
	call pOut
	 db 0x1B, "Declined, invalid PIN block"
SDEnd04D3:
	jrcxz DL04D4
	jmp DLEnd0494
DL04D4:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "127"
	or rPOk, rPOk
	jnz SD04D5
	jmp SDEnd04D5
SD04D5:
	call pOut
	 db 0x1A, "Declined, PIN length error"
SDEnd04D5:
	jrcxz DL04D6
	jmp DLEnd0494
DL04D6:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "128"
	or rPOk, rPOk
	jnz SD04D7
	jmp SDEnd04D7
SD04D7:
	call pOut
	 db 0x1C, "Declined, PIN key sync error"
SDEnd04D7:
	jrcxz DL04D8
	jmp DLEnd0494
DL04D8:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "180"
	or rPOk, rPOk
	jnz SD04D9
	jmp SDEnd04D9
SD04D9:
	call pOut
	 db 0x39, "Declined, redemption denied/mismatch by 2nd card mismatch"
SDEnd04D9:
	jrcxz DL04DA
	jmp DLEnd0494
DL04DA:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "181"
	or rPOk, rPOk
	jnz SD04DB
	jmp SDEnd04DB
SD04DB:
	call pOut
	 db 0x16, "Declined, card blocked"
SDEnd04DB:
	jrcxz DL04DC
	jmp DLEnd0494
DL04DC:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "182"
	or rPOk, rPOk
	jnz SD04DD
	jmp SDEnd04DD
SD04DD:
	call pOut
	 db 0x19, "Declined, account blocked"
SDEnd04DD:
	jrcxz DL04DE
	jmp DLEnd0494
DL04DE:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "183"
	or rPOk, rPOk
	jnz SD04DF
	jmp SDEnd04DF
SD04DF:
	call pOut
	 db 0x24, "Declined, incorrect odometer reading"
SDEnd04DF:
	jrcxz DL04E0
	jmp DLEnd0494
DL04E0:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "185"
	or rPOk, rPOk
	jnz SD04E1
	jmp SDEnd04E1
SD04E1:
	call pOut
	 db 0x20, "Declined, product(s) not allowed"
SDEnd04E1:
	jrcxz DL04E2
	jmp DLEnd0494
DL04E2:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "186"
	or rPOk, rPOk
	jnz SD04E3
	jmp SDEnd04E3
SD04E3:
	call pOut
	 db 0x26, "Declined, allowable PIN tries exceeded"
SDEnd04E3:
	jrcxz DL04E4
	jmp DLEnd0494
DL04E4:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "187"
	or rPOk, rPOk
	jnz SD04E5
	jmp SDEnd04E5
SD04E5:
	call pOut
	 db 0x1B, "Declined, previous PIN used"
SDEnd04E5:
	jrcxz DL04E6
	jmp DLEnd0494
DL04E6:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "188"
	or rPOk, rPOk
	jnz SD04E7
	jmp SDEnd04E7
SD04E7:
	call pOut
	 db 0x1D, "Declined, PIN change required"
SDEnd04E7:
	jrcxz DL04E8
	jmp DLEnd0494
DL04E8:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "190"
	or rPOk, rPOk
	jnz SD04E9
	jmp SDEnd04E9
SD04E9:
	call pOut
	 db 0x26, "Declined, RFID: Transponder is blocked"
SDEnd04E9:
	jrcxz DL04EA
	jmp DLEnd0494
DL04EA:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "191"
	or rPOk, rPOk
	jnz SD04EB
	jmp SDEnd04EB
SD04EB:
	call pOut
	 db 0x23, "Declined, RFID: Unknown transponder"
SDEnd04EB:
	jrcxz DL04EC
	jmp DLEnd0494
DL04EC:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "192"
	or rPOk, rPOk
	jnz SD04ED
	jmp SDEnd04ED
SD04ED:
	call pOut
	 db 0x2A, "Declined, RFID: Illegal challenge response"
SDEnd04ED:
	jrcxz DL04EE
	jmp DLEnd0494
DL04EE:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "200"
	or rPOk, rPOk
	jnz SD04EF
	jmp SDEnd04EF
SD04EF:
	call pOut
	 db 0x22, "Declined, do not honor – Capture"
SDEnd04EF:
	jrcxz DL04F0
	jmp DLEnd0494
DL04F0:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "201"
	or rPOk, rPOk
	jnz SD04F1
	jmp SDEnd04F1
SD04F1:
	call pOut
	 db 0x22, "Declined, expired card – Capture"
SDEnd04F1:
	jrcxz DL04F2
	jmp DLEnd0494
DL04F2:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "202"
	or rPOk, rPOk
	jnz SD04F3
	jmp SDEnd04F3
SD04F3:
	call pOut
	 db 0x25, "Declined, suspected fraud – Capture"
SDEnd04F3:
	jrcxz DL04F4
	jmp DLEnd0494
DL04F4:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "203"
	or rPOk, rPOk
	jnz SD04F5
	jmp SDEnd04F5
SD04F5:
	call pOut
	 db 0x34, "Declined, card acceptor contact acquirer – Capture"
SDEnd04F5:
	jrcxz DL04F6
	jmp DLEnd0494
DL04F6:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "204"
	or rPOk, rPOk
	jnz SD04F7
	jmp SDEnd04F7
SD04F7:
	call pOut
	 db 0x25, "Declined, restricted card – Capture"
SDEnd04F7:
	jrcxz DL04F8
	jmp DLEnd0494
DL04F8:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "206"
	or rPOk, rPOk
	jnz SD04F9
	jmp SDEnd04F9
SD04F9:
	call pOut
	 db 0x32, "Declined, allowable PIN tries exceeded – Capture"
SDEnd04F9:
	jrcxz DL04FA
	jmp DLEnd0494
DL04FA:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "208"
	or rPOk, rPOk
	jnz SD04FB
	jmp SDEnd04FB
SD04FB:
	call pOut
	 db 0x1F, "Declined, lost card – Capture"
SDEnd04FB:
	jrcxz DL04FC
	jmp DLEnd0494
DL04FC:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "209"
	or rPOk, rPOk
	jnz SD04FD
	jmp SDEnd04FD
SD04FD:
	call pOut
	 db 0x22, "Declined, stolen card – Capture "
SDEnd04FD:
	jrcxz DL04FE
	jmp DLEnd0494
DL04FE:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "300"
	or rPOk, rPOk
	jnz SD04FF
	jmp SDEnd04FF
SD04FF:
	call pOut
	 db 0x0A, "Successful"
SDEnd04FF:
	jrcxz DL0500
	jmp DLEnd0494
DL0500:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "302"
	or rPOk, rPOk
	jnz SD0501
	jmp SDEnd0501
SD0501:
	call pOut
	 db 0x1F, "Unable to locate record on file"
SDEnd0501:
	jrcxz DL0502
	jmp DLEnd0494
DL0502:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "306"
	or rPOk, rPOk
	jnz SD0503
	jmp SDEnd0503
SD0503:
	call pOut
	 db 0x0E, "Not successful"
SDEnd0503:
	jrcxz DL0504
	jmp DLEnd0494
DL0504:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "309"
	or rPOk, rPOk
	jnz SD0505
	jmp SDEnd0505
SD0505:
	call pOut
	 db 0x0C, "Unknown file"
SDEnd0505:
	jrcxz DL0506
	jmp DLEnd0494
DL0506:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "380"
	or rPOk, rPOk
	jnz SD0507
	jmp SDEnd0507
SD0507:
	call pOut
	 db 0x20, "Declined, Original PIN incorrect"
SDEnd0507:
	jrcxz DL0508
	jmp DLEnd0494
DL0508:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "381"
	or rPOk, rPOk
	jnz SD0509
	jmp SDEnd0509
SD0509:
	call pOut
	 db 0x26, "Declined, Allowable PIN tries exceeded"
SDEnd0509:
	jrcxz DL050A
	jmp DLEnd0494
DL050A:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "382"
	or rPOk, rPOk
	jnz SD050B
	jmp SDEnd050B
SD050B:
	call pOut
	 db 0x1B, "Declined, PIN data required"
SDEnd050B:
	jrcxz DL050C
	jmp DLEnd0494
DL050C:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "383"
	or rPOk, rPOk
	jnz SD050D
	jmp SDEnd050D
SD050D:
	call pOut
	 db 0x1B, "Declined, Invalid PIN block"
SDEnd050D:
	jrcxz DL050E
	jmp DLEnd0494
DL050E:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "384"
	or rPOk, rPOk
	jnz SD050F
	jmp SDEnd050F
SD050F:
	call pOut
	 db 0x1A, "Declined, PIN length error"
SDEnd050F:
	jrcxz DL0510
	jmp DLEnd0494
DL0510:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "385"
	or rPOk, rPOk
	jnz SD0511
	jmp SDEnd0511
SD0511:
	call pOut
	 db 0x34, "Declined, Allowable PIN retries exceeded – Capture"
SDEnd0511:
	jrcxz DL0512
	jmp DLEnd0494
DL0512:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "400"
	or rPOk, rPOk
	jnz SD0513
	jmp SDEnd0513
SD0513:
	call pOut
	 db 0x0E, "Accepted (400)"
SDEnd0513:
	jrcxz DL0514
	jmp DLEnd0494
DL0514:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "480"
	or rPOk, rPOk
	jnz SD0515
	jmp SDEnd0515
SD0515:
	call pOut
	 db 0x31, "Accepted but not matched against previous request"
SDEnd0515:
	jrcxz DL0516
	jmp DLEnd0494
DL0516:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "500"
	or rPOk, rPOk
	jnz SD0517
	jmp SDEnd0517
SD0517:
	call pOut
	 db 0x30, "Reconciled: In balance. Always return successful"
SDEnd0517:
	jrcxz DL0518
	jmp DLEnd0494
DL0518:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "501"
	or rPOk, rPOk
	jnz SD0519
	jmp SDEnd0519
SD0519:
	call pOut
	 db 0x1A, "Reconciled: Out of balance"
SDEnd0519:
	jrcxz DL051A
	jmp DLEnd0494
DL051A:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "580"
	or rPOk, rPOk
	jnz SD051B
	jmp SDEnd051B
SD051B:
	call pOut
	 db 0x38, "Reconciled; Out of balance do not attempt error recovery"
SDEnd051B:
	jrcxz DL051C
	jmp DLEnd0494
DL051C:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "800"
	or rPOk, rPOk
	jnz SD051D
	jmp SDEnd051D
SD051D:
	call pOut
	 db 0x0E, "Accepted (800)"
SDEnd051D:
	jrcxz DL051E
	jmp DLEnd0494
DL051E:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "900"
	or rPOk, rPOk
	jnz SD051F
	jmp SDEnd051F
SD051F:
	call pOut
	 db 0x67, "Advice acknowledged - no financial liability accepted  transactions, which are settled by another means"
SDEnd051F:
	jrcxz DL0520
	jmp DLEnd0494
DL0520:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "901"
	or rPOk, rPOk
	jnz SD0521
	jmp SDEnd0521
SD0521:
	call pOut
	 db 0x62, "Advice acknowledged - financial liability accepted =. OLTC transactions, which are settled on line"
SDEnd0521:
	jrcxz DL0522
	jmp DLEnd0494
DL0522:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "904"
	or rPOk, rPOk
	jnz SD0523
	jmp SDEnd0523
SD0523:
	call pOut
	 db 0x16, "Declined, format error"
SDEnd0523:
	jrcxz DL0524
	jmp DLEnd0494
DL0524:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "906"
	or rPOk, rPOk
	jnz SD0525
	jmp SDEnd0525
SD0525:
	call pOut
	 db 0x1C, "Declined, utover in progress"
SDEnd0525:
	jrcxz DL0526
	jmp DLEnd0494
DL0526:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "907"
	or rPOk, rPOk
	jnz SD0527
	jmp SDEnd0527
SD0527:
	call pOut
	 db 0x2B, "Declined, card issuer or switch inoperative"
SDEnd0527:
	jrcxz DL0528
	jmp DLEnd0494
DL0528:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "909"
	or rPOk, rPOk
	jnz SD0529
	jmp SDEnd0529
SD0529:
	call pOut
	 db 0x1C, "Declined, system malfunction"
SDEnd0529:
	jrcxz DL052A
	jmp DLEnd0494
DL052A:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "911"
	or rPOk, rPOk
	jnz SD052B
	jmp SDEnd052B
SD052B:
	call pOut
	 db 0x1F, "Declined, card issuer timed out"
SDEnd052B:
	jrcxz DL052C
	jmp DLEnd0494
DL052C:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "912"
	or rPOk, rPOk
	jnz SD052D
	jmp SDEnd052D
SD052D:
	call pOut
	 db 0x21, "Declined, card issuer unavailable"
SDEnd052D:
	jrcxz DL052E
	jmp DLEnd0494
DL052E:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "916"
	or rPOk, rPOk
	jnz SD052F
	jmp SDEnd052F
SD052F:
	call pOut
	 db 0x17, "Declined, MAC incorrect"
SDEnd052F:
	jrcxz DL0530
	jmp DLEnd0494
DL0530:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "917"
	or rPOk, rPOk
	jnz SD0531
	jmp SDEnd0531
SD0531:
	call pOut
	 db 0x1D, "Declined, MAC key synch error"
SDEnd0531:
	jrcxz DL0532
	jmp DLEnd0494
DL0532:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "921"
	or rPOk, rPOk
	jnz SD0533
	jmp SDEnd0533
SD0533:
	call pOut
	 db 0x29, "Security, soft/hardware error - no action"
SDEnd0533:
	jrcxz DL0534
	jmp DLEnd0494
DL0534:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "922"
	or rPOk, rPOk
	jnz SD0535
	jmp SDEnd0535
SD0535:
	call pOut
	 db 0x28, "Declined, message number out of sequence"
SDEnd0535:
DLEnd0494:
	call cDrop
	ret

;Bit39 =	"000", pOut("Approved")|
;	"001", pOut("Approved, honour with Identification")|
;	"002", pOut("Approved, for partial amount")|
;	"003", pOut("Approved, VIP")|
;	"005", pOut("Approved, account type specified by card issuer")|
;	"006", pOut("Approved, for partial amount, account type specified by card issuer")|
;	"007", pOut("Approved, update ICC")|
;	"080", pOut("Approved, (liability not accepted)")|
;	"081", pOut("Declined, honor with Identification (liability not accepted)")|
;	"100", pOut("Declined, do not honour")|
;	"101", pOut("Declined, expired card")|
;	"102", pOut("Declined, suspected fraud")|
;	"103", pOut("Declined, card Acceptor contact acquirer")|
;	"104", pOut("Declined, restricted card")|
;	"106", pOut("Declined, allowable PIN tries exceeded")|
;	"107", pOut("Declined, refer to Card Issuer")|
;	"108", pOut("Declined, refer to card issuers special conditions for use May be combined with message in 62-3")|
;	"109", pOut("Declined, invalid merchant")|
;	"110", pOut("Declined, invalid Amount")|
;	"111", pOut("Declined, invalid Card Number")|
;	"112", pOut("Declined, PIN data required")|
;	"114", pOut("Declined, no account of type requested")|
;	"115", pOut("Declined, requested Function not supported")|
;	"116", pOut("Declined, not sufficient funds")|
;	"117", pOut("Declined, incorrect PIN")|
;	"118", pOut("Declined, no card record")|
;	"119", pOut("Declined, transaction not permitted to the customer")|
;	"120", pOut("Declined, transaction not permitted to the terminal")|
;	"121", pOut("Declined, exceeds withdrawal amount limit")|
;	"122", pOut("Declined, security violation")|
;	"123", pOut("Declined, exceeds withdrawal frequency limit")|
;	"125", pOut("Declined, card not effective")|
;	"126", pOut("Declined, invalid PIN block")|
;	"127", pOut("Declined, PIN length error")|
;	"128", pOut("Declined, PIN key sync error")|
;	"180", pOut("Declined, redemption denied/mismatch by 2nd card mismatch")|
;	"181", pOut("Declined, card blocked")|
;	"182", pOut("Declined, account blocked")|
;	"183", pOut("Declined, incorrect odometer reading")|
;	"185", pOut("Declined, product(s) not allowed")|
;	"186", pOut("Declined, allowable PIN tries exceeded")|
;	"187", pOut("Declined, previous PIN used")|
;	"188", pOut("Declined, PIN change required")|
;	"190", pOut("Declined, RFID: Transponder is blocked")|
;	"191", pOut("Declined, RFID: Unknown transponder")|
;	"192", pOut("Declined, RFID: Illegal challenge response")|
;	"200", pOut("Declined, do not honor – Capture")|
;	"201", pOut("Declined, expired card – Capture")|
;	"202", pOut("Declined, suspected fraud – Capture")|
;	"203", pOut("Declined, card acceptor contact acquirer – Capture")|
;	"204", pOut("Declined, restricted card – Capture")|
;	"206", pOut("Declined, allowable PIN tries exceeded – Capture")|
;	"208", pOut("Declined, lost card – Capture")|
;	"209", pOut("Declined, stolen card – Capture ")|
;	"300", pOut("Successful")|
;	"302", pOut("Unable to locate record on file")|
;	"306", pOut("Not successful")|
;	"309", pOut("Unknown file")|
;  	"380", pOut("Declined, Original PIN incorrect")|   
;	"381", pOut("Declined, Allowable PIN tries exceeded")|   
;	"382", pOut("Declined, PIN data required")|   
;	"383", pOut("Declined, Invalid PIN block")|   
;	"384", pOut("Declined, PIN length error")|   
;	"385", pOut("Declined, Allowable PIN retries exceeded – Capture")| 
;	"400", pOut("Accepted (400)")|
;	"480", pOut("Accepted but not matched against previous request")|
;	"500", pOut("Reconciled: In balance. Always return successful")| 
;	"501", pOut("Reconciled: Out of balance")|
;	"580", pOut("Reconciled; Out of balance do not attempt error recovery")|
;	"800", pOut("Accepted (800)")|
;	"900", pOut("Advice acknowledged - no financial liability accepted  transactions, which are settled by another means")|
;	"901", pOut("Advice acknowledged - financial liability accepted =. OLTC transactions, which are settled on line")|
;	"904", pOut("Declined, format error")|
;	"906", pOut("Declined, utover in progress")| 
;	"907", pOut("Declined, card issuer or switch inoperative")|
;	"909", pOut("Declined, system malfunction")|
;	"911", pOut("Declined, card issuer timed out")|
;	"912", pOut("Declined, card issuer unavailable")|
;	"916", pOut("Declined, MAC incorrect")|
;	"917", pOut("Declined, MAC key synch error")|
;	"921", pOut("Security, soft/hardware error - no action")|
;	"922", pOut("Declined, message number out of sequence");
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Bit49:
	call cPush
	call pIn
	 db 0x0003, "999"
	or rPOk, rPOk
	jnz SD0536
	jmp SDEnd0536
SD0536:
	call pOut
	 db 0x09, "Liter IDS"
SDEnd0536:
	jrcxz DL0537
	jmp DLEnd0537
DL0537:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "978"
	or rPOk, rPOk
	jnz SD0538
	jmp SDEnd0538
SD0538:
	call pOut
	 db 0x08, "EUR Euro"
SDEnd0538:
	jrcxz DL0539
	jmp DLEnd0537
DL0539:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "826"
	or rPOk, rPOk
	jnz SD053A
	jmp SDEnd053A
SD053A:
	call pOut
	 db 0x12, "GBP Pound Sterling"
SDEnd053A:
	jrcxz DL053B
	jmp DLEnd0537
DL053B:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "203"
	or rPOk, rPOk
	jnz SD053C
	jmp SDEnd053C
SD053C:
	call pOut
	 db 0x10, "CZK Czech Koruna"
SDEnd053C:
	jrcxz DL053D
	jmp DLEnd0537
DL053D:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "578"
	or rPOk, rPOk
	jnz SD053E
	jmp SDEnd053E
SD053E:
	call pOut
	 db 0x13, "NOK Norwegian Krone"
SDEnd053E:
	jrcxz DL053F
	jmp DLEnd0537
DL053F:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "752"
	or rPOk, rPOk
	jnz SD0540
	jmp SDEnd0540
SD0540:
	call pOut
	 db 0x11, "SEK Swedish Krona"
SDEnd0540:
	jrcxz DL0541
	jmp DLEnd0537
DL0541:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "208"
	or rPOk, rPOk
	jnz SD0542
	jmp SDEnd0542
SD0542:
	call pOut
	 db 0x10, "DKK Danish Krone"
SDEnd0542:
	jrcxz DL0543
	jmp DLEnd0537
DL0543:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "810"
	or rPOk, rPOk
	jnz SD0544
	jmp SDEnd0544
SD0544:
	call pOut
	 db 0x11, "RUR Russian Ruble"
SDEnd0544:
	jrcxz DL0545
	jmp DLEnd0537
DL0545:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "643"
	or rPOk, rPOk
	jnz SD0546
	jmp SDEnd0546
SD0546:
	call pOut
	 db 0x11, "RUB Russian Ruble"
SDEnd0546:
	jrcxz DL0547
	jmp DLEnd0537
DL0547:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "642"
	or rPOk, rPOk
	jnz SD0548
	jmp SDEnd0548
SD0548:
	call pOut
	 db 0x07, "ROL Leu"
SDEnd0548:
	jrcxz DL0549
	jmp DLEnd0537
DL0549:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "348"
	or rPOk, rPOk
	jnz SD054A
	jmp SDEnd054A
SD054A:
	call pOut
	 db 0x0A, "HUF Forint"
SDEnd054A:
	jrcxz DL054B
	jmp DLEnd0537
DL054B:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "703"
	or rPOk, rPOk
	jnz SD054C
	jmp SDEnd054C
SD054C:
	call pOut
	 db 0x11, "SKK Slovak Koruna"
SDEnd054C:
	jrcxz DL054D
	jmp DLEnd0537
DL054D:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "792"
	or rPOk, rPOk
	jnz SD054E
	jmp SDEnd054E
SD054E:
	call pOut
	 db 0x10, "TRL Turkish Lira"
SDEnd054E:
	jrcxz DL054F
	jmp DLEnd0537
DL054F:	inc rcx
	call cTop
	call cPush
	mov rFactCnt, 3
	or rFactCnt, rFactCnt
	jz FacEnd0550
FacRep0550:
	call b
	dec rFactCnt
	jrcxz FacEnd0550
	jz FacEnd0550
	jmp FacRep0550
FacEnd0550:
	call cDrop
	or rPOk, rPOk
	jnz SD0551
	jmp SDEnd0551
SD0551:
	call pOut
	 db 0x16, "Warning unknown valuta"
SDEnd0551:
DLEnd0537:
	call cDrop
	ret

;Bit49 =	"999", pOut("Liter IDS")|
;	"978", pOut("EUR Euro")|
;	"826", pOut("GBP Pound Sterling")|
;	"203", pOut("CZK Czech Koruna")|
;	"578", pOut("NOK Norwegian Krone")|
;	"752", pOut("SEK Swedish Krona")|
;	"208", pOut("DKK Danish Krone")|
;	"810", pOut("RUR Russian Ruble")|
;	"643", pOut("RUB Russian Ruble")|
;	"642", pOut("ROL Leu")|
;	"348", pOut("HUF Forint")|
;	"703", pOut("SKK Slovak Koruna")|
;	"792", pOut("TRL Turkish Lira")|
;	(3*b), pOut("Warning unknown valuta");
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Bit53H2H:
	call cPush
	call LLVAR
	or rPOk, rPOk
	jnz SD0552
	jmp SDEnd0552
SD0552:
	call b
	or rPOk, rPOk
	jnz SD0553
	jmp SDEnd0552
SD0553:
	call pOut
	 db 0x27, 0x0a, 0x09, 0x09, '"B53.1 Key generation master key": "'
	or rPOk, rPOk
	jnz SD0554
	jmp SDEnd0552
SD0554:
	call pOutLIHex
	or rPOk, rPOk
	jnz SD0555
	jmp SDEnd0552
SD0555:
	call pOut
	 db 0x02, '",'
	or rPOk, rPOk
	jnz SD0556
	jmp SDEnd0552
SD0556:
	call b
	or rPOk, rPOk
	jnz SD0557
	jmp SDEnd0552
SD0557:
	call pOut
	 db 0x27, 0x0a, 0x09, 0x09, '"B53.2 Key version master key"   : "'
	or rPOk, rPOk
	jnz SD0558
	jmp SDEnd0552
SD0558:
	call pOutLIHex
	or rPOk, rPOk
	jnz SD0559
	jmp SDEnd0552
SD0559:
	call pOut
	 db 0x02, '",'
	or rPOk, rPOk
	jnz SD055A
	jmp SDEnd0552
SD055A:
	call cPush
	mov rFactCnt, 16
	or rFactCnt, rFactCnt
	jz FacEnd055B
FacRep055B:
	call b
	dec rFactCnt
	jrcxz FacEnd055B
	jz FacEnd055B
	jmp FacRep055B
FacEnd055B:
	call cDrop
	or rPOk, rPOk
	jnz SD055C
	jmp SDEnd0552
SD055C:
	call pOut
	 db 0x15, 0x0a, 0x09, 0x09, '"B53.3 RNDmes" : "'
	or rPOk, rPOk
	jnz SD055D
	jmp SDEnd0552
SD055D:
	call pOutLIHex
	or rPOk, rPOk
	jnz SD055E
	jmp SDEnd0552
SD055E:
	call pOut
	 db 0x02, '",'
	or rPOk, rPOk
	jnz SD055F
	jmp SDEnd0552
SD055F:
	call cPush
	mov rFactCnt, 16
	or rFactCnt, rFactCnt
	jz FacEnd0560
FacRep0560:
	call b
	dec rFactCnt
	jrcxz FacEnd0560
	jz FacEnd0560
	jmp FacRep0560
FacEnd0560:
	call cDrop
	or rPOk, rPOk
	jnz SD0561
	jmp SDEnd0552
SD0561:
	call pOut
	 db 0x15, 0x0a, 0x09, 0x09, '"B53.4 RNDpac" : "'
	or rPOk, rPOk
	jnz SD0562
	jmp SDEnd0552
SD0562:
	call pOutLIHex
	or rPOk, rPOk
	jnz SD0563
	jmp SDEnd0552
SD0563:
	call pOut
	 db 0x02, '",'
	or rPOk, rPOk
	jnz SD0564
	jmp SDEnd0552
SD0564:
	call DropLastChar
	or rPOk, rPOk
	jnz SD0565
	jmp SDEnd0552
SD0565:
	call pOut
	 db 0x02, '},'
SDEnd0552:
	call cDrop
	ret

;Bit53H2H = LLVAR,
;		b,	pOut(0x0a, 0x09, 0x09, '"B53.1 Key generation master key": "'), pOutLIHex, pOut('",'),		/* wrong spec in CGI spec. says n1 */
;		b,	pOut(0x0a, 0x09, 0x09, '"B53.2 Key version master key"   : "'), pOutLIHex, pOut('",'),		/* wrong spec in CGI spec. says n1 */
;		(16*b),	pOut(0x0a, 0x09, 0x09, '"B53.3 RNDmes" : "'), pOutLIHex, pOut('",'),
;		(16*b),	pOut(0x0a, 0x09, 0x09, '"B53.4 RNDpac" : "'), pOutLIHex, pOut('",'),
;	DropLastChar,
;	pOut('},');
;	

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Bit53P2H:
	call cPush
	call LLVAR
	or rPOk, rPOk
	jnz SD0566
	jmp SDEnd0566
SD0566:
	call cPush
	call cPush
	mov rFactCnt, 10
	or rFactCnt, rFactCnt
	jz FacEnd0567
FacRep0567:
	call HexDig
	dec rFactCnt
	jrcxz FacEnd0567
	jz FacEnd0567
	jmp FacRep0567
FacEnd0567:
	call cDrop
	or rPOk, rPOk
	jnz SD0568
	jmp SDEnd0568
SD0568:
	call pOut
	 db 0x24, 0x0a, 0x09, 0x09, '"B53.1 BDKId BDK identifier"  : "'
	or rPOk, rPOk
	jnz SD0569
	jmp SDEnd0568
SD0569:
	call pOutLI
	or rPOk, rPOk
	jnz SD056A
	jmp SDEnd0568
SD056A:
	call pOut
	 db 0x02, '",'
SDEnd0568:
	jrcxz DL056B
	jmp DLEnd056B
DL056B:	inc rcx
	call cTop
	call cPush
	mov rFactCnt, 10
	or rFactCnt, rFactCnt
	jz FacEnd056C
FacRep056C:
	call b
	dec rFactCnt
	jrcxz FacEnd056C
	jz FacEnd056C
	jmp FacRep056C
FacEnd056C:
	call cDrop
	or rPOk, rPOk
	jnz SD056D
	jmp SDEnd056D
SD056D:
	call pOut
	 db 0x35, 0x0a, 0x09, 0x09, '"B53.1 Warning BDK identifier expected in hex" : "'
	or rPOk, rPOk
	jnz SD056E
	jmp SDEnd056D
SD056E:
	call pOutLIHex
	or rPOk, rPOk
	jnz SD056F
	jmp SDEnd056D
SD056F:
	call pOut
	 db 0x02, '",'
SDEnd056D:
DLEnd056B:
	call cDrop
	or rPOk, rPOk
	jnz SD0570
	jmp SDEnd0566
SD0570:
	call cPush
	call cPush
	mov rFactCnt, 10
	or rFactCnt, rFactCnt
	jz FacEnd0571
FacRep0571:
	call HexDig
	dec rFactCnt
	jrcxz FacEnd0571
	jz FacEnd0571
	jmp FacRep0571
FacEnd0571:
	call cDrop
	or rPOk, rPOk
	jnz SD0572
	jmp SDEnd0572
SD0572:
	call pOut
	 db 0x25, 0x0a, 0x09, 0x09, '"B53.2 KSN   Key Serial Number": "'
	or rPOk, rPOk
	jnz SD0573
	jmp SDEnd0572
SD0573:
	call pOutLI
	or rPOk, rPOk
	jnz SD0574
	jmp SDEnd0572
SD0574:
	call pOut
	 db 0x02, '",'
SDEnd0572:
	jrcxz DL0575
	jmp DLEnd0575
DL0575:	inc rcx
	call cTop
	call cPush
	mov rFactCnt, 10
	or rFactCnt, rFactCnt
	jz FacEnd0576
FacRep0576:
	call b
	dec rFactCnt
	jrcxz FacEnd0576
	jz FacEnd0576
	jmp FacRep0576
FacEnd0576:
	call cDrop
	or rPOk, rPOk
	jnz SD0577
	jmp SDEnd0577
SD0577:
	call pOut
	 db 0x25, 0x0a, 0x09, 0x09, '"B53.1 KSN   Key Serial Number": "'
	or rPOk, rPOk
	jnz SD0578
	jmp SDEnd0577
SD0578:
	call pOutLIHex
	or rPOk, rPOk
	jnz SD0579
	jmp SDEnd0577
SD0579:
	call pOut
	 db 0x02, '",'
SDEnd0577:
DLEnd0575:
	call cDrop
	or rPOk, rPOk
	jnz SD057A
	jmp SDEnd0566
SD057A:
	call cPush
	mov rFactCnt, 3
	or rFactCnt, rFactCnt
	jz FacEnd057B
FacRep057B:
	call n
	dec rFactCnt
	jrcxz FacEnd057B
	jz FacEnd057B
	jmp FacRep057B
FacEnd057B:
	call cDrop
	or rPOk, rPOk
	jnz SD057C
	jmp SDEnd0566
SD057C:
	call pOut
	 db 0x24, 0x0a, 0x09, 0x09, '"B53.3 KSN   Descriptor"      : "'
	or rPOk, rPOk
	jnz SD057D
	jmp SDEnd0566
SD057D:
	call pOutLI
	or rPOk, rPOk
	jnz SD057E
	jmp SDEnd0566
SD057E:
	call pOut
	 db 0x02, '",'
	or rPOk, rPOk
	jnz SD057F
	jmp SDEnd0566
SD057F:
	call DropLastChar
	or rPOk, rPOk
	jnz SD0580
	jmp SDEnd0566
SD0580:
	call pOut
	 db 0x02, '},'
SDEnd0566:
	call cDrop
	ret

;Bit53P2H= LLVAR,
;		((10*HexDig),	pOut(0x0a, 0x09, 0x09, '"B53.1 BDKId BDK identifier"  : "'), pOutLI, pOut('",')
;		|(10*b),	pOut(0x0a, 0x09, 0x09, '"B53.1 Warning BDK identifier expected in hex" : "'), pOutLIHex, pOut('",')
;		),
;		((10*HexDig),	pOut(0x0a, 0x09, 0x09, '"B53.2 KSN   Key Serial Number": "'), pOutLI, pOut('",')	/* wrong spec in CGI spec. says n1 */
;		|(10*b),	pOut(0x0a, 0x09, 0x09, '"B53.1 KSN   Key Serial Number": "'), pOutLIHex, pOut('",')	/* this is correct */
;		),	
;		(3*n),		pOut(0x0a, 0x09, 0x09, '"B53.3 KSN   Descriptor"      : "'), pOutLI, pOut('",'),
;	DropLastChar,
;	pOut('},');
;	
;
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
IDSProduct:
	call cPush
	call pIn
	 db 0x0003, "000"
	or rPOk, rPOk
	jnz SD0581
	jmp SDEnd0581
SD0581:
	call pOut
	 db 0x0A, "000 AdBlue"
SDEnd0581:
	jrcxz DL0582
	jmp DLEnd0582
DL0582:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "001"
	or rPOk, rPOk
	jnz SD0583
	jmp SDEnd0583
SD0583:
	call pOut
	 db 0x0A, "001 Diesel"
SDEnd0583:
	jrcxz DL0584
	jmp DLEnd0582
DL0584:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "003"
	or rPOk, rPOk
	jnz SD0585
	jmp SDEnd0585
SD0585:
	call pOut
	 db 0x15, "003 Gasoil Industrial"
SDEnd0585:
	jrcxz DL0586
	jmp DLEnd0582
DL0586:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "005"
	or rPOk, rPOk
	jnz SD0587
	jmp SDEnd0587
SD0587:
	call pOut
	 db 0x1F, "005 LIC (Liquid Carbon Dioxide)"
SDEnd0587:
	jrcxz DL0588
	jmp DLEnd0582
DL0588:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "009"
	or rPOk, rPOk
	jnz SD0589
	jmp SDEnd0589
SD0589:
	call pOut
	 db 0x22, "009 LPG (Liquidfied Petroleum Gas)"
SDEnd0589:
	jrcxz DL058A
	jmp DLEnd0582
DL058A:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "010"
	or rPOk, rPOk
	jnz SD058B
	jmp SDEnd058B
SD058B:
	call pOut
	 db 0x12, "010 LNG Restricted"
SDEnd058B:
	jrcxz DL058C
	jmp DLEnd0582
DL058C:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "011"
	or rPOk, rPOk
	jnz SD058D
	jmp SDEnd058D
SD058D:
	call pOut
	 db 0x27, "011 ED95 (Green Biofuel Heavy Transport"
SDEnd058D:
	jrcxz DL058E
	jmp DLEnd0582
DL058E:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "012"
	or rPOk, rPOk
	jnz SD058F
	jmp SDEnd058F
SD058F:
	call pOut
	 db 0x24, "012 CNG/CBG (Compressed Natural Gas)"
SDEnd058F:
	jrcxz DL0590
	jmp DLEnd0582
DL0590:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "015"
	or rPOk, rPOk
	jnz SD0591
	jmp SDEnd0591
SD0591:
	call pOut
	 db 0x0E, "015 Gasoil Red"
SDEnd0591:
	jrcxz DL0592
	jmp DLEnd0582
DL0592:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "016"
	or rPOk, rPOk
	jnz SD0593
	jmp SDEnd0593
SD0593:
	call pOut
	 db 0x14, "016 Spain Red Diesel"
SDEnd0593:
	jrcxz DL0594
	jmp DLEnd0582
DL0594:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "017"
	or rPOk, rPOk
	jnz SD0595
	jmp SDEnd0595
SD0595:
	call pOut
	 db 0x0E, "017 Bio Diesel"
SDEnd0595:
	jrcxz DL0596
	jmp DLEnd0582
DL0596:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "019"
	or rPOk, rPOk
	jnz SD0597
	jmp SDEnd0597
SD0597:
	call pOut
	 db 0x07, "019 RME"
SDEnd0597:
	jrcxz DL0598
	jmp DLEnd0582
DL0598:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "020"
	or rPOk, rPOk
	jnz SD0599
	jmp SDEnd0599
SD0599:
	call pOut
	 db 0x07, "020 LNG"
SDEnd0599:
	jrcxz DL059A
	jmp DLEnd0582
DL059A:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "029"
	or rPOk, rPOk
	jnz SD059B
	jmp SDEnd059B
SD059B:
	call pOut
	 db 0x1A, "029 Super Diesel - Q8SS DK"
SDEnd059B:
	jrcxz DL059C
	jmp DLEnd0582
DL059C:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "041"
	or rPOk, rPOk
	jnz SD059D
	jmp SDEnd059D
SD059D:
	call pOut
	 db 0x13, "041 Q8 T 905 10W-40"
SDEnd059D:
	jrcxz DL059E
	jmp DLEnd0582
DL059E:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "060"
	or rPOk, rPOk
	jnz SD059F
	jmp SDEnd059F
SD059F:
	call pOut
	 db 0x10, "060 Water splash"
SDEnd059F:
	jrcxz DL05A0
	jmp DLEnd0582
DL05A0:	inc rcx
	call cTop
	call pIn
	 db 0x0003, "080"
	or rPOk, rPOk
	jnz SD05A1
	jmp SDEnd05A1
SD05A1:
	call pOut
	 db 0x0B, "080 Carwash"
SDEnd05A1:
	jrcxz DL05A2
	jmp DLEnd0582
DL05A2:	inc rcx
	call cTop
	call cPush
	mov rFactCnt, 3
	or rFactCnt, rFactCnt
	jz FacEnd05A3
FacRep05A3:
	call b
	dec rFactCnt
	jrcxz FacEnd05A3
	jz FacEnd05A3
	jmp FacRep05A3
FacEnd05A3:
	call cDrop
	or rPOk, rPOk
	jnz SD05A4
	jmp SDEnd05A4
SD05A4:
	call pOutLI
	or rPOk, rPOk
	jnz SD05A5
	jmp SDEnd05A4
SD05A5:
	call pOut
	 db 0x19, " Warning. Unknown product"
SDEnd05A4:
DLEnd0582:
	call cDrop
	ret

;IDSProduct =
;			 "000", pOut("000 AdBlue")
;			|"001", pOut("001 Diesel")
;			|"003", pOut("003 Gasoil Industrial")
;			|"005", pOut("005 LIC (Liquid Carbon Dioxide)")
;			|"009", pOut("009 LPG (Liquidfied Petroleum Gas)")
;			|"010", pOut("010 LNG Restricted")
;			|"011", pOut("011 ED95 (Green Biofuel Heavy Transport")
;			|"012", pOut("012 CNG/CBG (Compressed Natural Gas)")
;			|"015", pOut("015 Gasoil Red")
;			|"016", pOut("016 Spain Red Diesel")
;			|"017", pOut("017 Bio Diesel")
;			|"019", pOut("019 RME")
;			|"020", pOut("020 LNG")
;			|"029", pOut("029 Super Diesel - Q8SS DK")
;			|"041", pOut("041 Q8 T 905 10W-40")
;			|"060", pOut("060 Water splash")
;			|"080", pOut("080 Carwash")
;			|(3*b),	pOutLI, pOut(" Warning. Unknown product");
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Bit62IDS:
	call cPush
	call LLLVAR
	or rPOk, rPOk
	jnz SD05A6
	jmp SDEnd05A6
SD05A6:
	call cPush
	call pIn
	 db 0x0002, "00"
	or rPOk, rPOk
	jnz SD05A7
	jmp SDEnd05A7
SD05A7:
	call pOut
	 db 0x21, 0x0a, 0x09, 0x09, '"00" : "All products allowed",'
SDEnd05A7:
	jrcxz DL05A8
	jmp DLEnd05A8
DL05A8:	inc rcx
	call cTop
	call pOut
	 db 0x0E, 0x0a, 0x09, 0x09,	'"B62.1" : ['
	or rPOk, rPOk
	jnz SD05A9
	jmp SDEnd05A9
SD05A9:
	call cPush
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep05AA
	jmp FacEnd05AA
FacRep05AA:
	dec rFactCnt
	dec rFactCnt
	call cPush
	call pOut
	 db 0x05, 0x0a, 0x09, 0x09, 0x09,'"'
	or rPOk, rPOk
	jnz SD05AB
	jmp SDEnd05AB
SD05AB:
	call IDSProduct
	or rPOk, rPOk
	jnz SD05AC
	jmp SDEnd05AB
SD05AC:
	call pOut
	 db 0x02, '",'
SDEnd05AB:
	call cDrop
	dec rFactCnt
	jrcxz FacEnd05AA
	jz FacEnd05AA
	jmp FacRep05AA
FacEnd05AA:
	call cDrop
	or rPOk, rPOk
	jnz SD05AD
	jmp SDEnd05A9
SD05AD:
	call DropLastChar
	or rPOk, rPOk
	jnz SD05AE
	jmp SDEnd05A9
SD05AE:
	call pOut
	 db 0x02, "],"
SDEnd05A9:
DLEnd05A8:
	call cDrop
	or rPOk, rPOk
	jnz SD05AF
	jmp SDEnd05A6
SD05AF:
	call cPush
	call pIn
	 db 0x0001, "0"
	or rPOk, rPOk
	jnz SD05B0
	jmp SDEnd05B0
SD05B0:
	call pOut
	 db 0x27, 0x0a, 0x09, 0x09,	'"B62.2" : "0   Default device type",'
SDEnd05B0:
	jrcxz DL05B1
	jmp DLEnd05B1
DL05B1:	inc rcx
	call cTop
	call n
	or rPOk, rPOk
	jnz SD05B2
	jmp SDEnd05B2
SD05B2:
	call pOut
	 db 0x1B, 0x0a, 0x09, 0x09,	'"B62.2" : "Device type ('
	or rPOk, rPOk
	jnz SD05B3
	jmp SDEnd05B2
SD05B3:
	call pOutLI
	or rPOk, rPOk
	jnz SD05B4
	jmp SDEnd05B2
SD05B4:
	call pOut
	 db 0x02, ')"'
SDEnd05B2:
DLEnd05B1:
	call cDrop
	or rPOk, rPOk
	jnz SD05B5
	jmp SDEnd05A6
SD05B5:
	call cPush
	call LLLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep05B6
	jmp FacEnd05B6
FacRep05B6:
	call ans
	dec rFactCnt
	jrcxz FacEnd05B6
	jz FacEnd05B6
	jmp FacRep05B6
FacEnd05B6:
	call cDrop
	or rPOk, rPOk
	jnz SD05B7
	jmp SDEnd05A6
SD05B7:
	call pOut
	 db 0x0E, 0x0a, 0x09, 0x09,	'"B62.3" : "'
	or rPOk, rPOk
	jnz SD05B8
	jmp SDEnd05A6
SD05B8:
	call pOutLI
	or rPOk, rPOk
	jnz SD05B9
	jmp SDEnd05A6
SD05B9:
	call pOut
	 db 0x0A, ' Message",'
	or rPOk, rPOk
	jnz SD05BA
	jmp SDEnd05A6
SD05BA:
	call DropLastChar
	or rPOk, rPOk
	jnz SD05BB
	jmp SDEnd05A6
SD05BB:
	call pOut
	 db 0x02, '},'
SDEnd05A6:
	call cDrop
	ret

;Bit62IDS = LLLVAR, ( "00"		  ,pOut(0x0a, 0x09, 0x09, '"00" : "All products allowed",')	/* IFSF */
;		|		   pOut(0x0a, 0x09, 0x09,	'"B62.1" : ['),
;		 (LLVAR* 	 					<<	dec rFactCnt>>
;		 							<<	dec rFactCnt>> 		/* curious spec: set = 3bytes */
;		 	 (pOut(0x0a, 0x09, 0x09, 0x09,'"'), IDSProduct, pOut('",'))),
;		DropLastChar, pOut("],")		
;		),
;		("0",	pOut(0x0a, 0x09, 0x09,	'"B62.2" : "0   Default device type",')
;		|n,	pOut(0x0a, 0x09, 0x09,	'"B62.2" : "Device type ('), pOutLI, pOut(')"')
;		),
;
;		(LLLVAR*ans),	pOut(0x0a, 0x09, 0x09,	'"B62.3" : "'), pOutLI, pOut(' Message",'),
;		
;	DropLastChar,
;	pOut('},');
;	

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Bit62:
	call cPush
	call LLLVAR
	or rPOk, rPOk
	jnz SD05BC
	jmp SDEnd05BC
SD05BC:
	call cPush
	call pIn
	 db 0x0002, "00"
	or rPOk, rPOk
	jnz SD05BD
	jmp SDEnd05BD
SD05BD:
	call pOut
	 db 0x21, 0x0a, 0x09, 0x09,	'"00" : "All products allowed",'
SDEnd05BD:
	jrcxz DL05BE
	jmp DLEnd05BE
DL05BE:	inc rcx
	call cTop
	call pOut
	 db 0x0E, 0x0a, 0x09, 0x09,	'"B62.1" : ['
	or rPOk, rPOk
	jnz SD05BF
	jmp SDEnd05BF
SD05BF:
	call cPush
	call LLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep05C0
	jmp FacEnd05C0
FacRep05C0:
	dec rFactCnt
	dec rFactCnt
	call cPush
	call pOut
	 db 0x05, 0x0a, 0x09, 0x09, 0x09,'"'
	or rPOk, rPOk
	jnz SD05C1
	jmp SDEnd05C1
SD05C1:
	call IDSProduct
	or rPOk, rPOk
	jnz SD05C2
	jmp SDEnd05C1
SD05C2:
	call pOut
	 db 0x02, '",'
SDEnd05C1:
	call cDrop
	dec rFactCnt
	jrcxz FacEnd05C0
	jz FacEnd05C0
	jmp FacRep05C0
FacEnd05C0:
	call cDrop
	or rPOk, rPOk
	jnz SD05C3
	jmp SDEnd05BF
SD05C3:
	call DropLastChar
	or rPOk, rPOk
	jnz SD05C4
	jmp SDEnd05BF
SD05C4:
	call pOut
	 db 0x02, "],"
SDEnd05BF:
DLEnd05BE:
	call cDrop
	or rPOk, rPOk
	jnz SD05C5
	jmp SDEnd05BC
SD05C5:
	call cPush
	call n
	or rPOk, rPOk
	jnz SD05C6
	jmp SDEnd05C6
SD05C6:
	call pOut
	 db 0x1B, 0x0a, 0x09, 0x09,	'"B62.2" : "Device type ('
	or rPOk, rPOk
	jnz SD05C7
	jmp SDEnd05C6
SD05C7:
	call pOutLI
	or rPOk, rPOk
	jnz SD05C8
	jmp SDEnd05C6
SD05C8:
	call pOut
	 db 0x03, ')",'
SDEnd05C6:
	call cDrop
	or rPOk, rPOk
	jnz SD05C9
	jmp SDEnd05BC
SD05C9:
	call cPush
	call pIn
	 db 0x0003, "000"
	or rPOk, rPOk
	jnz SD05CA
	jmp SDEnd05CA
SD05CA:
	call pOut
	 db 0x19, 0x0a, 0x09, 0x09,	'"B62.3" : "Message ()"'
SDEnd05CA:
	jrcxz DL05CB
	jmp DLEnd05CB
DL05CB:	inc rcx
	call cTop
	call pOut
	 db 0x17, 0x0a, 0x09, 0x09,	'"B62.3" : "Message ('
	or rPOk, rPOk
	jnz SD05CC
	jmp SDEnd05CC
SD05CC:
	call cPush
	call LLLVAR
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep05CD
	jmp FacEnd05CD
FacRep05CD:
	call cPush
	call ans
	or rPOk, rPOk
	jnz SD05CE
	jmp SDEnd05CE
SD05CE:
	call pOutLI
SDEnd05CE:
	call cDrop
	dec rFactCnt
	jrcxz FacEnd05CD
	jz FacEnd05CD
	jmp FacRep05CD
FacEnd05CD:
	or rPOk, rPOk
	jnz SD05CF
	jmp SDEnd05CF
SD05CF:
	call pOut
	 db 0x02, ')"'
SDEnd05CF:
	call cDrop
SDEnd05CC:
DLEnd05CB:
	call cDrop
	or rPOk, rPOk
	jnz SD05D0
	jmp SDEnd05BC
SD05D0:
	call pOut
	 db 0x02, '},'
SDEnd05BC:
	call cDrop
	ret

;Bit62 = LLLVAR, 
;		( "00",	 pOut(0x0a, 0x09, 0x09,	'"00" : "All products allowed",')
;		|	 pOut(0x0a, 0x09, 0x09,	'"B62.1" : ['),
;		 (LLVAR* 	<<	dec rFactCnt>>
;		 		<<	dec rFactCnt>>
;		        (pOut(0x0a, 0x09, 0x09, 0x09,'"'), IDSProduct, pOut('",'))
;		 ), DropLastChar, pOut("],")	
;		),
;
;		( n, 	 pOut(0x0a, 0x09, 0x09,	'"B62.2" : "Device type ('), pOutLI, pOut(')",') ),
;		( "000", pOut(0x0a, 0x09, 0x09,	'"B62.3" : "Message ()"')
;		|	 pOut(0x0a, 0x09, 0x09,	'"B62.3" : "Message ('),
;		  (LLLVAR*(ans, pOutLI), pOut(')"'))),
;		pOut('},');
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Bit63:
	call cPush
	call cPush
	mov rFactCnt, 3
	or rFactCnt, rFactCnt
	jz FacEnd05D1
FacRep05D1:
	call n
	dec rFactCnt
	jrcxz FacEnd05D1
	jz FacEnd05D1
	jmp FacRep05D1
FacEnd05D1:
	call cDrop
	or rPOk, rPOk
	jnz SD05D2
	jmp SDEnd05D2
SD05D2:
	call pOut
	 db 0x21, 0x0a, 0x09, 0x09, '"B63-1 Service level"      : "'
	or rPOk, rPOk
	jnz SD05D3
	jmp SDEnd05D2
SD05D3:
	call cPush
	call pIn
	 db 0x0001, "S"
	or rPOk, rPOk
	jnz SD05D4
	jmp SDEnd05D4
SD05D4:
	call pOut
	 db 0x0E, 'S=Self serve",'
SDEnd05D4:
	jrcxz DL05D5
	jmp DLEnd05D5
DL05D5:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "F"
	or rPOk, rPOk
	jnz SD05D6
	jmp SDEnd05D6
SD05D6:
	call pOut
	 db 0x0E, 'F=Full serve",'
SDEnd05D6:
	jrcxz DL05D7
	jmp DLEnd05D5
DL05D7:	inc rcx
	call cTop
	call pIn
	 db 0x0001, " "
	or rPOk, rPOk
	jnz SD05D8
	jmp SDEnd05D8
SD05D8:
	call pOut
	 db 0x09, 'No info",'
SDEnd05D8:
	jrcxz DL05D9
	jmp DLEnd05D5
DL05D9:	inc rcx
	call cTop
	call b
	or rPOk, rPOk
	jnz SD05DA
	jmp SDEnd05DA
SD05DA:
	call pOut
	 db 0x1C, 'Warning, unknown IFSF code: '
	or rPOk, rPOk
	jnz SD05DB
	jmp SDEnd05DA
SD05DB:
	call pOutLI
	or rPOk, rPOk
	jnz SD05DC
	jmp SDEnd05DA
SD05DC:
	call pOut
	 db 0x02, '",'
SDEnd05DA:
DLEnd05D5:
	call cDrop
	or rPOk, rPOk
	jnz SD05DD
	jmp SDEnd05D2
SD05DD:
	call cPush
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd05DE
FacRep05DE:
	call n
	dec rFactCnt
	jrcxz FacEnd05DE
	jz FacEnd05DE
	jmp FacRep05DE
FacEnd05DE:
	call cDrop
	or rPOk, rPOk
	jnz SD05DF
	jmp SDEnd05D2
SD05DF:
	call pOut
	 db 0x21, 0x0a, 0x09, 0x09, '"B63-2 Number of products" : "'
	or rPOk, rPOk
	jnz SD05E0
	jmp SDEnd05D2
SD05E0:
	call pOutLI
	or rPOk, rPOk
	jnz SD05E1
	jmp SDEnd05D2
SD05E1:
	call pOut
	 db 0x02, '",'
SDEnd05D2:
	or rPOk, rPOk
	jnz AD05E2
	jmp ADEnd05E2
AD05E2:
	call cAndProlog
	call cPush
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd05E3
FacRep05E3:
	call n
	dec rFactCnt
	jrcxz FacEnd05E3
	jz FacEnd05E3
	jmp FacRep05E3
FacEnd05E3:
	call cDrop
	call Dec2Bin
	mov rFactCnt, rax
	or rax, rax
	jnz FacRep05E4
	jmp FacEnd05E4
FacRep05E4:
	call cPush
	call pOut
	 db 0x21, 0x0a, 0x09, 0x09, '"B63-3 Product code"       : "'
	or rPOk, rPOk
	jnz SD05E5
	jmp SDEnd05E5
SD05E5:
	call IDSProduct
	or rPOk, rPOk
	jnz SD05E6
	jmp SDEnd05E5
SD05E6:
	call pOut
	 db 0x02, '",'
	or rPOk, rPOk
	jnz SD05E7
	jmp SDEnd05E5
SD05E7:
	call pOut
	 db 0x21, 0x0a, 0x09, 0x09, '"B63-4 Unit of measure"    : "'
	or rPOk, rPOk
	jnz SD05E8
	jmp SDEnd05E5
SD05E8:
	call cPush
	call pIn
	 db 0x0001, "L"
	or rPOk, rPOk
	jnz SD05E9
	jmp SDEnd05E9
SD05E9:
	call pOut
	 db 0x07, 'Liter",'
SDEnd05E9:
	jrcxz DL05EA
	jmp DLEnd05EA
DL05EA:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "U"
	or rPOk, rPOk
	jnz SD05EB
	jmp SDEnd05EB
SD05EB:
	call pOut
	 db 0x06, 'Unit",'
SDEnd05EB:
	jrcxz DL05EC
	jmp DLEnd05EA
DL05EC:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "W"
	or rPOk, rPOk
	jnz SD05ED
	jmp SDEnd05ED
SD05ED:
	call pOut
	 db 0x04, 'Kg",'
SDEnd05ED:
	jrcxz DL05EE
	jmp DLEnd05EA
DL05EE:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "O"
	or rPOk, rPOk
	jnz SD05EF
	jmp SDEnd05EF
SD05EF:
	call pOut
	 db 0x06, 'None",'
SDEnd05EF:
	jrcxz DL05F0
	jmp DLEnd05EA
DL05F0:	inc rcx
	call cTop
	call b
	or rPOk, rPOk
	jnz SD05F1
	jmp SDEnd05F1
SD05F1:
	call pOut
	 db 0x1A, 'Warning, Unknown measure",'
SDEnd05F1:
DLEnd05EA:
	call cDrop
	or rPOk, rPOk
	jnz SD05F2
	jmp SDEnd05E5
SD05F2:
	call cPush
RSRep05F4:
	call cPush
	call n
	call cDrop
	jrcxz RSEnd05F4
	or rInEndFlg, rInEndFlg
	jnz RSEnd05F4
	jmp RSRep05F4
RSEnd05F4:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD05F5
	jmp SDEnd05E5
SD05F5:
	call pOut
	 db 0x21, 0x0a, 0x09, 0x09, '"B63-5.1 Quantity"         : "'
	or rPOk, rPOk
	jnz SD05F6
	jmp SDEnd05E5
SD05F6:
	call pOutLIdpTrim
	or rPOk, rPOk
	jnz SD05F7
	jmp SDEnd05E5
SD05F7:
	call pOut
	 db 0x02, '",'
	or rPOk, rPOk
	jnz SD05F8
	jmp SDEnd05E5
SD05F8:
	call cPush
	call pIn
	 db 0x0001, "P"
	or rPOk, rPOk
	jnz SD05F9
	jmp SDEnd05F9
SD05F9:
	call cPush
RSRep05FB:
	call cPush
	call n
	call cDrop
	jrcxz RSEnd05FB
	or rInEndFlg, rInEndFlg
	jnz RSEnd05FB
	jmp RSRep05FB
RSEnd05FB:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD05FC
	jmp SDEnd05F9
SD05FC:
	call pOut
	 db 0x21, 0x0a, 0x09, 0x09, '"B63-5.2 Pump"             : "'
	or rPOk, rPOk
	jnz SD05FD
	jmp SDEnd05F9
SD05FD:
	call pOutLI
	or rPOk, rPOk
	jnz SD05FE
	jmp SDEnd05F9
SD05FE:
	call pOut
	 db 0x02, '",'
SDEnd05F9:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD05FF
	jmp SDEnd05E5
SD05FF:
	call cPush
	call pIn
	 db 0x0001, "N"
	or rPOk, rPOk
	jnz SD0600
	jmp SDEnd0600
SD0600:
	call cPush
RSRep0602:
	call cPush
	call n
	call cDrop
	jrcxz RSEnd0602
	or rInEndFlg, rInEndFlg
	jnz RSEnd0602
	jmp RSRep0602
RSEnd0602:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD0603
	jmp SDEnd0600
SD0603:
	call pOut
	 db 0x21, 0x0a, 0x09, 0x09, '"B63-5.3 Nozzle"           : "'
	or rPOk, rPOk
	jnz SD0604
	jmp SDEnd0600
SD0604:
	call pOutLI
	or rPOk, rPOk
	jnz SD0605
	jmp SDEnd0600
SD0605:
	call pOut
	 db 0x02, '",'
SDEnd0600:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD0606
	jmp SDEnd05E5
SD0606:
	call pIn
	 db 0x0001, "\"
	or rPOk, rPOk
	jnz SD0607
	jmp SDEnd05E5
SD0607:
	call cPush
RSRep0609:
	call cPush
	call n
	call cDrop
	jrcxz RSEnd0609
	or rInEndFlg, rInEndFlg
	jnz RSEnd0609
	jmp RSRep0609
RSEnd0609:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD060A
	jmp SDEnd05E5
SD060A:
	call pOut
	 db 0x21, 0x0a, 0x09, 0x09, '"B63-6 Unit Price"         : "'
	or rPOk, rPOk
	jnz SD060B
	jmp SDEnd05E5
SD060B:
	call pOutLIdpTrim
	or rPOk, rPOk
	jnz SD060C
	jmp SDEnd05E5
SD060C:
	call pOut
	 db 0x02, '",'
	or rPOk, rPOk
	jnz SD060D
	jmp SDEnd05E5
SD060D:
	call pIn
	 db 0x0001, "\"
	or rPOk, rPOk
	jnz SD060E
	jmp SDEnd05E5
SD060E:
	call cPush
RSRep0610:
	call cPush
	call n
	call cDrop
	jrcxz RSEnd0610
	or rInEndFlg, rInEndFlg
	jnz RSEnd0610
	jmp RSRep0610
RSEnd0610:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD0611
	jmp SDEnd05E5
SD0611:
	call pOut
	 db 0x21, 0x0a, 0x09, 0x09, '"B63-7 Amount"             : "'
	or rPOk, rPOk
	jnz SD0612
	jmp SDEnd05E5
SD0612:
	call pOutLI
	or rPOk, rPOk
	jnz SD0613
	jmp SDEnd05E5
SD0613:
	call pOut
	 db 0x02, '",'
	or rPOk, rPOk
	jnz SD0614
	jmp SDEnd05E5
SD0614:
	call pIn
	 db 0x0001, "\"
	or rPOk, rPOk
	jnz SD0615
	jmp SDEnd05E5
SD0615:
	call an
	or rPOk, rPOk
	jnz SD0616
	jmp SDEnd05E5
SD0616:
	call pOut
	 db 0x21, 0x0a, 0x09, 0x09, '"B63-8 Tax code"           : "'
	or rPOk, rPOk
	jnz SD0617
	jmp SDEnd05E5
SD0617:
	call pOutLI
	or rPOk, rPOk
	jnz SD0618
	jmp SDEnd05E5
SD0618:
	call pOut
	 db 0x02, '",'
	or rPOk, rPOk
	jnz SD0619
	jmp SDEnd05E5
SD0619:
	call cPush
RSRep061B:
	call cPush
	call n
	call cDrop
	jrcxz RSEnd061B
	or rInEndFlg, rInEndFlg
	jnz RSEnd061B
	jmp RSRep061B
RSEnd061B:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD061C
	jmp SDEnd05E5
SD061C:
	call pOut
	 db 0x21, 0x0a, 0x09, 0x09, '"B63-9 Added product code" : "'
	or rPOk, rPOk
	jnz SD061D
	jmp SDEnd05E5
SD061D:
	call pOutLI
	or rPOk, rPOk
	jnz SD061E
	jmp SDEnd05E5
SD061E:
	call pOut
	 db 0x02, '",'
	or rPOk, rPOk
	jnz SD061F
	jmp SDEnd05E5
SD061F:
	call pIn
	 db 0x0001, "\"
SDEnd05E5:
	call cDrop
	dec rFactCnt
	jrcxz FacEnd05E4
	jz FacEnd05E4
	jmp FacRep05E4
FacEnd05E4:
	or rPOk, rPOk
	jnz SD0620
	jmp SDEnd0620
SD0620:
	call DropLastChar
	or rPOk, rPOk
	jnz SD0621
	jmp SDEnd0620
SD0621:
	call pOut
	 db 0x02, '},'
SDEnd0620:
	call cAndEpilog
ADEnd05E2:
	call cDrop
	ret

;Bit63 =  (3*n), pOut(0x0a, 0x09, 0x09, '"B63-1 Service level"      : "'),
;		("S", pOut('S=Self serve",')|
;		 "F", pOut('F=Full serve",')|
;		 " ", pOut('No info",')|
;		 b,   pOut('Warning, unknown IFSF code: '), pOutLI, pOut('",') ),
;	 	(2*n),			pOut(0x0a, 0x09, 0x09, '"B63-2 Number of products" : "'), pOutLI, pOut('",')
;	      + (2*n)* ( 		pOut(0x0a, 0x09, 0x09, '"B63-3 Product code"       : "'), IDSProduct, pOut('",'),
;					pOut(0x0a, 0x09, 0x09, '"B63-4 Unit of measure"    : "'),
;			 			("L", pOut('Liter",')|
;			 	 		 "U", pOut('Unit",')|
;			 	 		 "W", pOut('Kg",')|
;			 	 		 "O", pOut('None",')|
;			 	 		  b , pOut('Warning, Unknown measure",')),
;			 	{n}, 	pOut(0x0a, 0x09, 0x09, '"B63-5.1 Quantity"         : "'), pOutLIdpTrim,	pOut('",'),
;			 ["P",	{n}, 	pOut(0x0a, 0x09, 0x09, '"B63-5.2 Pump"             : "'), pOutLI,	pOut('",')],
;			 ["N",	{n}, 	pOut(0x0a, 0x09, 0x09, '"B63-5.3 Nozzle"           : "'), pOutLI,	pOut('",')],
;			 "\",	{n}, 	pOut(0x0a, 0x09, 0x09, '"B63-6 Unit Price"         : "'), pOutLIdpTrim,	pOut('",'),
;			 "\",	{n}, 	pOut(0x0a, 0x09, 0x09, '"B63-7 Amount"             : "'), pOutLI,	pOut('",'),
;			 "\",	 an, 	pOut(0x0a, 0x09, 0x09, '"B63-8 Tax code"           : "'), pOutLI,	pOut('",'),
;				{n}, 	pOut(0x0a, 0x09, 0x09, '"B63-9 Added product code" : "'), pOutLI,	pOut('",'),
;			 "\"
;		        ),
;	DropLastChar,
;	pOut('},');
;
;
