INCLUDE MACRO.ASM

EXTRN _DISPLAY_STRING:FAR
EXTRN _SAVE_BLOCK:FAR
EXTRN _RESTORE_BLOCK:FAR
EXTRN _WRITE_BLOCK_PIXEL:FAR

;��������

PUBLIC _INIT_MOUSE           ;��ʼ�����
PUBLIC _DRAW_MOUSE
PUBLIC _DISPLAY_COOR

;�ⲿ���� 

;�������ݶ�
PUBLIC DRAW_X,DRAW_Y
GLOBAL SEGMENT PUBLIC
	EXTRN FILE_CLICK:BYTE,GRAPH_CLICK:BYTE,COLOR_CLICK:BYTE,HELP_CLICK:BYTE
	EXTRN MOUSE_BUF:BYTE
	EXTRN CUR_X:WORD, CUR_Y:WORD, PRE_X:WORD, PRE_Y:WORD
	EXTRN ON_LEFT_CLICK:WORD, ON_RIGHT_CLICK:WORD
	DRAW_X DW 00FFH
	DRAW_Y DW 00FFH
GLOBAL ENDS


;
DATA SEGMENT
	EDGE    DW 8000H, 0C000H, 0A000H, 9000H, 8800H, 8400H, 8200H, 8100H
            DW 8080H, 8040H, 8020H, 81F0H, 8900H, 9900H, 0A480H, 0C480H
            DW 8240H, 0240H, 01C0H
    INNER   DW 0000H, 0000H, 4000H, 6000H, 7000H, 7800H, 7C00H, 7E00H
            DW 7F00H, 7F80H, 7FC0H, 7E00H, 7600H, 6600H, 4300H, 0300H
            DW 0180H, 0180H, 0000H
    
	COOR_STR DB '   ,   '  ;�����ַ���
DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE,DS:DATA,ES:GLOBAL

	
__TO_STRING MACRO VALUE,COOR_STR_SEG,COOR_STR_ADDR
	PUSH AX
	MOV AX,VALUE
	PUSH AX
	MOV AX,COOR_STR_SEG
	PUSH AX
	;;;;;;MOV AX,OFFSET COOR_STR_ADDR
	LEA AX,COOR_STR_ADDR
	PUSH AX
	CALL _TO_STRING
	ADD SP,6
	POP AX
	ENDM
	
;��ʾ��굱ǰ����    ���˵���򿪻��߲��ڰװ巶Χ������ʾ
_DISPLAY_COOR PROC FAR
	PUSH AX
	PUSH BX
	PUSH ES
	MOV AX,GLOBAL
	MOV ES,AX
	CMP ES:CUR_X,8         ;�ж�����Ƿ��ڻ��巶Χ��
	JB NOT_IN_RANGE
	CMP ES:CUR_X,536
	JAE NOT_IN_RANGE
	CMP ES:CUR_Y,32
	JB NOT_IN_RANGE
	CMP ES:CUR_Y,464
	JAE NOT_IN_RANGE
	;JMP IN_RANGE
	
	;�жϲ˵����Ƿ��
	MOV AL,ES:FILE_CLICK
	OR  AL,ES:GRAPH_CLICK
	OR  AL,ES:COLOR_CLICK
	OR  AL,ES:HELP_CLICK
	CMP AL,01H
	JNZ MENU_NOT_SELECTED
	
MENU_SELECTED:
NOT_IN_RANGE:
	__FILL 28,70,28,76,00H
	MOV ES:DRAW_X,00FFH
	MOV ES:DRAW_Y,00FFH
	JMP DISPLAY_COOR_FINISH
MENU_NOT_SELECTED:
IN_RANGE:
	MOV BX,OFFSET COOR_STR
	MOV AX,ES:CUR_X
	SUB AX,8
	MOV ES:DRAW_X,AX
	__TO_STRING ES:DRAW_X,DATA,[BX]
	MOV AX,ES:CUR_Y
	SUB AX,32
	MOV ES:DRAW_Y,AX
	__TO_STRING ES:DRAW_Y,DATA,[BX+4]
	__DISPLAY_STRING 28,70,DATA,COOR_STR,7,04H
DISPLAY_COOR_FINISH:
	POP ES
	POP BX
	POP AX
	RET
_DISPLAY_COOR ENDP


;����ֵת��Ϊ�ַ���,���3λ
;��ڲ���:��Ҫת������ֵ,�����ַ����ĵ�ַ    
VALUE          EQU  [BP+20]
COOR_STR_SEG   EQU  [BP+18]
COOR_STR_ADDR  EQU  [BP+16]

_TO_STRING PROC NEAR
	__PUSH_REGS
	PUSH ES
	PUSH DI
	PUSH BP
	
	MOV BP,SP
	MOV ES,COOR_STR_SEG
	MOV DI,COOR_STR_ADDR
	MOV AX,VALUE
	
	MOV CX,0         ;λ������
	MOV BX,10        ;������ʼ��
BLOCK1:
	MOV DX,0
	DIV BX
	PUSH DX          ;��������
	INC CX           ;λ����1
	CMP AX,0         ;�̲�Ϊ0����
	JNE BLOCK1
	
	MOV BX,3         ;Ĭ�����3λ�� 
	SUB BX,CX
BLOCK2:
	POP DX           ;��ջ�е������λ
	ADD DL,30H       ;ת����ASCII��
	MOV ES:[DI],DL
	INC DI
	LOOP BLOCK2
	CMP BX,0         ;�����һλ,���˳�
	JE BLOCK4
	MOV CX,BX
BLOCK3:
	MOV BYTE PTR ES:[DI],20H  ;����3λ���ո�
	INC DI
	LOOP BLOCK3
BLOCK4:
	POP BP
	POP DI
	POP ES
	__POP_REGS
	RET
_TO_STRING ENDP

;�����
;��ں�������    ���ں���:��
_DRAW_MOUSE PROC FAR
	__PUSH_REGS
	PUSH SI
	PUSH DI
	PUSH DS
	PUSH ES
	
	MOV AX,DATA
	MOV DS,AX
	MOV AX,GLOBAL
	MOV ES,AX
	
	;__RESTORE_BLOCK ES:PRE_X,ES:PRE_Y,12,19,ES:MOUSE_BUF
	;__SAVE_BLOCK ES:CUR_X,ES:CUR_Y,12,19,ES:MOUSE_BUF
	
	LEA SI,EDGE
	LEA DI,INNER
	PUSH ES:CUR_Y
	MOV CX,19
OUTER_LOOP:             ;��ѭ��
	PUSH CX
	PUSH ES:CUR_X
	MOV CX,12
	MOV AX,8000H
INNER_LOOP:             ;��ѭ��
	TEST [SI],AX
	JZ NOT_DRAW_EDGE
	__WRITE_PIXEL ES:CUR_X,ES:CUR_Y,0
NOT_DRAW_EDGE:          ;�õ㲻������Ե
	TEST [DI],AX
	JZ NOT_DRAW_INNER
	__WRITE_PIXEL ES:CUR_X,ES:CUR_Y,0FH
NOT_DRAW_INNER:         ;�õ㲻������ڲ�
	INC ES:CUR_X
	SHR AX,1
	LOOP INNER_LOOP
	ADD SI,2
	ADD DI,2
	INC ES:CUR_Y
	POP ES:CUR_X
	POP CX
	LOOP OUTER_LOOP
	POP ES:CUR_Y
	
	POP ES
	POP DS
	POP DI
	POP SI
	__POP_REGS
	RET
_DRAW_MOUSE ENDP

;��ʼ�����
_INIT_MOUSE PROC FAR
	__PUSH_REGS
	PUSH ES
	
	MOV AX,GLOBAL
	MOV ES,AX
	MOV AX,00H   
	INT 33H
	MOV ES:CUR_X,CX
	MOV ES:CUR_Y,DX
	__SAVE_BLOCK ES:CUR_X,ES:CUR_Y,12,19,ES:MOUSE_BUF
	
	POP ES
	__POP_REGS
	RET
_INIT_MOUSE ENDP

CODE ENDS
END