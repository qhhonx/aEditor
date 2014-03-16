INCLUDE MACRO.ASM

EXTRN _DISPLAY_STRING:FAR
EXTRN _SAVE_BLOCK:FAR
EXTRN _RESTORE_BLOCK:FAR
EXTRN _WRITE_BLOCK_PIXEL:FAR


GLOBAL SEGMENT PUBLIC
    EXTRN MOUSE_BUF:BYTE,BUF:BYTE
	EXTRN CUR_X:WORD, CUR_Y:WORD, PRE_X:WORD, PRE_Y:WORD
	EXTRN ON_LEFT_CLICK:WORD, ON_RIGHT_CLICK:WORD
	EXTRN FILE_CLICK:BYTE
GLOBAL ENDS
;
PUBLIC _FILE_NEW
PUBLIC _FILE_OPEN
PUBLIC _FILE_SAVE
PUBLIC _FILE_QUIT

;
EXTRN _DRAW_MOUSE:FAR
EXTRN _SAVE_BLOCK:FAR
EXTRN _RESTORE_BLOCK:FAR
EXTRN _DISPLAY_STRING:FAR

EXTRN _OPEN_FILE:FAR
EXTRN _SAVE_FILE:FAR

;;;;;
DATA SEGMENT
	S_FILE   DB 'FILE'
DATA ENDS

;;;;;
CODE SEGMENT
	ASSUME CS:CODE,DS:DATA,ES:GLOBAL

_FILE_NEW PROC FAR
	__DELAY 33144
	PUSH AX
	PUSH ES
	MOV AX,GLOBAL
	MOV ES,AX
	__RESTORE_BLOCK ES:CUR_X,ES:CUR_Y,12,19,ES:MOUSE_BUF
	__FILL 2,1,28,66, 0FH                                ;��ʼ���װ�
	__DISPLAY_STRING 1,10,DATA,S_FILE, 4,09H
	__SAVE_BLOCK ES:CUR_X,ES:CUR_Y,12,19,ES:MOUSE_BUF
	;__SAVE_BLOCK 72,32,48,64,ES:BUF
	CALL _DRAW_MOUSE
	
	MOV ES:ON_LEFT_CLICK,0                              ;�����������
	MOV ES:FILE_CLICK,0
	POP ES
	POP AX
	RET
_FILE_NEW ENDP

_FILE_OPEN PROC FAR
	__DELAY 33144
	PUSH AX
	PUSH ES
	MOV AX,GLOBAL
	MOV ES,AX
	__RESTORE_BLOCK ES:CUR_X,ES:CUR_Y,12,19,ES:MOUSE_BUF
	__RESTORE_BLOCK 72,32,48,64,ES:BUF
	__DISPLAY_STRING 1,10,DATA,S_FILE, 4,09H
	
	CALL _OPEN_FILE
	
	
	
	__SAVE_BLOCK ES:CUR_X,ES:CUR_Y,12,19,ES:MOUSE_BUF
	CALL _DRAW_MOUSE
	
	MOV ES:ON_LEFT_CLICK,0                              ;�����������
	MOV ES:FILE_CLICK,0
	POP ES
	POP AX
	RET
_FILE_OPEN ENDP

_FILE_SAVE PROC FAR
	__DELAY 33144
	PUSH AX
	PUSH ES
	MOV AX,GLOBAL
	MOV ES,AX
	;__DISPLAY_STRING 12,10,DATA,STR_SAVE,6,04H
	__RESTORE_BLOCK ES:CUR_X,ES:CUR_Y,12,19,ES:MOUSE_BUF
	__RESTORE_BLOCK 72,32,48,64,ES:BUF
	__DISPLAY_STRING 1,10,DATA,S_FILE, 4,09H
	CALL _SAVE_FILE
	__SAVE_BLOCK ES:CUR_X,ES:CUR_Y,12,19,ES:MOUSE_BUF
	CALL _DRAW_MOUSE
	
	MOV ES:ON_LEFT_CLICK,0                              ;�����������
	MOV ES:FILE_CLICK,0
	POP ES
	POP AX
	RET
_FILE_SAVE ENDP

_FILE_QUIT PROC FAR
	PUSH AX
	PUSH ES
	MOV AX,GLOBAL
	MOV ES,AX
	MOV ES:ON_LEFT_CLICK,0                              ;�����������
	MOV ES:FILE_CLICK,0
	POP ES
	POP AX
	MOV AH,4CH
	INT 21H
	RET
_FILE_QUIT ENDP

CODE ENDS
END