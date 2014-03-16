;公共数据段
PUBLIC BUF,MOUSE_BUF
PUBLIC CUR_X, CUR_Y, PRE_X, PRE_Y
PUBLIC ON_LEFT_CLICK, ON_RIGHT_CLICK
GLOBAL SEGMENT PUBLIC
    BUF              DB 16384 DUP(?);8192 DUP(?)           ;缓冲区
	MOUSE_BUF        DB 228  DUP(?)    
    CUR_X            DW ?                     ;当前鼠标坐标
    CUR_Y            DW ? 
    PRE_X            DW ?                     ;前一时刻鼠标坐标
    PRE_Y            DW ?
    ON_LEFT_CLICK    DW 0                     ;鼠标左键是否按下
	ON_RIGHT_CLICK   DW 0
GLOBAL ENDS

END
