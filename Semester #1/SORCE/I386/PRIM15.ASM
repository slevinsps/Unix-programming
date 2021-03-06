;/*
; �ਬ�� 15
; �ਬ�� �ᯮ�짮����� ���஥����� �����୮�� �⫠�稪� ���
;  �⫠��� ����㯠 � ����� �ணࠬ��, �ணࠬ�� ᮤ�ন� �訡��

.386p

include struct.ash
include macros.ash

INTNO           equ     256     ; �᫮ ����஢ � ⠡��� IDT
DSCPSIZE        equ     8       ; ࠧ��� ���ਯ��
INTSIZE         equ     4       ; ࠧ��� ����� ������ ���뢠���

TWO             equ     2
WORDLEN         equ     4       ; �᫮ ᨬ����� � ��ப� �ᥫ
DOUBLELEN       equ     8       ; �᫮ ᨬ����� � ��ப� �ᥫ DWORD
prot_enable     equ     01h     ; ��� ����祭�� ���饭���� ०���
attribute       equ     07h     ; ��ਡ�� ᨬ����� �� ��࠭�
space           equ     20h     ; ��� ᨬ���� �஡���

;
; ��� 1: ������쭠� ⠡��� ���ਯ�஢ ᥣ���⮢ ��⥬�
;
GDT             segment para    public  use16   'GDT'

gdt_tab label   qword   ; ���ਯ�� *!! �ॡ��� ���樠����樨 ����

; NULL ᥫ���� GDT, ������ ���� �ᥣ�� � ���� � ⠡���
null_selec      equ     0
   dscp         <0,0,0,0,0,0>

; ᥫ���� � ᥣ����� GDT ��� � ᥣ����� ������
gdt_selec      equ     $-gdt_tab or TBL_GDT or RPL_0            ;*!!
   d_data       <gdt_limit>,0,<DATA_ACC or DPL_0>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� ��⥬��� ����� ����㧪� �ணࠬ��, �ᥣ�� RPL=DPL=0
code_selec      equ     $-gdt_tab or TBL_GDT or RPL_0           ;*!!
   d_code       <code_limit>,0,<CODE_ACC or DPL_0>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� TSS ����� ����㧪�, RPL,DPL � ���ண� ����� �������
task0_TSS_selec equ     $-gdt_tab or TBL_GDT or RPL_0           ;*!!
   d_tss        <task0_TSS_limit>,0,<TSS_ACC or DPL_0>,<ACC2_G_BYTE>

; ᥣ���� �⥪� ����� �஢�� 0, RPL=DPL=0 �ᥣ��
stk0_selec      equ     $-gdt_tab or TBL_GDT or RPL_0           ;*!!
   d_data       <stk0_limit>,0,<DATA_ACC or DPL_0>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� �⥪� ����� �஢�� 1, RPL=DPL=1 �ᥣ��
stk1_selec      equ     $-gdt_tab or TBL_GDT or RPL_1           ;*!!
   d_data       <stk1_limit>,0,<DATA_ACC or DPL_1>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� �⥪� ����� �஢�� 2, RPL=DPL=2 �ᥣ��
stk2_selec      equ     $-gdt_tab or TBL_GDT or RPL_2           ;*!!
   d_data       <stk2_limit>,0,<DATA_ACC or DPL_2>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� �⥪� ����� �஢�� 3, RPL=DPL=3 �ᥣ��
stk3_selec      equ     $-gdt_tab or TBL_GDT or RPL_3           ;*!!
   d_data       <stk3_limit>,0,<DATA_ACC or DPL_3>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� ���������� 梥⭮�� ०���, RPL=0, DPL=3
video_selec     equ     $-gdt_tab or TBL_GDT or RPL_0
   d_data       <CRT_SIZE-1>,<CRT_ADDR>,<DATA_ACC or DPL_3>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� ������ ����� ����㧪�, RPL,DPL ࠧ�襭���� ����㯠
gdata_selec     equ     $-gdt_tab or TBL_GDT or RPL_0           ;*!!
   d_data       <gdata_limit>,0,<DATA_ACC or DPL_3>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� ����� �ணࠬ� ��ࠡ�⪨ ���뢠���, RPL,DPL �६��� �믮������
int_selec       equ     $-gdt_tab or TBL_GDT or RPL_0           ;*!!
   d_code       <code_limit>,0,<CODE_ACC or DPL_0>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥫ���� � ���ਯ�� ������ � �ଠ� ॠ�쭮� ���� ������
dmy_selec       equ     $-gdt_tab or TBL_GDT or RPL_0           ;*!!
   d_data       <0ffffh>,0,<DATA_ACC or DPL_0>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥫ���� � ���ਯ�� ����� � �ଠ� ॠ�쭮� ���� ������
rc_selec        equ     $-gdt_tab or TBL_GDT or RPL_0           ;*!!
   d_code       <0ffffh>,0,<CODE_ACC or DPL_0>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� ������ ����㭨��樨 BIOS, RPL,DPL �� �ᬮ�७�� ����
bios_selec      equ     $-gdt_tab or TBL_GDT or RPL_0
   d_data       <B_DATA_SIZE-1>,<B_DATA_ADDR>,<DATA_ACC or DPL_0>,<ACC2_B_SMALL or ACC2_G_BYTE>

;
; ��� 1.1: ���ਯ�� ᥣ���⮢ ����㠫쭮�� v86
;
; ᥣ���� ������ ������ ����஢ IDT                           ;*!!
idt_selec       equ     $-gdt_tab or TBL_GDT or RPL_0
   d_data       0,0,<DATA_ACC or DPL_0>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� ������ v86 �� ������ ����஢ �� 1�����
dos_selec       equ     $-gdt_tab or TBL_GDT or RPL_0
   d_data       <0fffffh>,0,<DATA_ACC or DPL_0>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� TSS ����� v86, RPL = DPL = 3         (above 1M)
task1_TSS_selec equ     $-gdt_tab or TBL_GDT or RPL_3           ;*!!
   d_tss        <task1_TSS_limit>,0,<TSS_ACC or DPL_3>,<ACC2_G_BYTE>
;;;   d_tss        <task1_TSS_limit>,00080000h,<TSS_ACC or DPL_3>,<ACC2_G_BYTE>

; ᥣ���� data on TSS ����� v86, DPL = 3
task1_OTSS_selec equ    $-gdt_tab or TBL_GDT or RPL_0           ;*!!
   d_data       <task1_TSS_limit>,0,<DATA_ACC or DPL_3>,<ACC2_B_SMALL or ACC2_G_BYTE>

; DPL = 3
task1_seg_selec equ     $-gdt_tab or TBL_GDT or RPL_0           ;*!!
   d_data       <0ffffh>,0,<DATA_ACC or DPL_3>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� �⥪� ������ v86 �஢�� 0, RPL=DPL=0 �ᥣ��
stack0_selec    equ     $-gdt_tab or TBL_GDT or RPL_0           ;*!!
   d_data       <stack0_limit>,0,<DATA_ACC or DPL_0>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� �⥪� ����� v86 �஢�� 0, RPL=DPL=0 �ᥣ��
stack3_selec    equ     $-gdt_tab or TBL_GDT or RPL_0           ;*!!
   d_data       <stack3_limit>,0,<DATA_ACC or DPL_0>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� ������ ����� v86, RPL,DPL ࠧ�襭���� ����㯠
; �ᯮ��. ��� ����㯠 � ����� v86 ��� ������� ������権
; � ��� ����㯠 � �⥪� ����� v86
gdata1_selec    equ     $-gdt_tab or TBL_GDT or RPL_0
gdata1  label   byte
   d_data       <0ffffh>,0,<DATA_ACC or DPL_3>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� ������ ����� for base linear address 00180000h
gdata3_selec    equ     $-gdt_tab or TBL_GDT or RPL_0
   d_data       <0fffffh>,00180000h,<DATA_ACC or DPL_3>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� ������ ����� for base linear address 00190000h
gdata4_selec    equ     $-gdt_tab or TBL_GDT or RPL_0
   d_data       <0fffffh>,00190000h,<DATA_ACC or DPL_3>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� ������ ����� for base linear address 00000000h
gdata5_selec    equ     $-gdt_tab or TBL_GDT or RPL_0           ;*!!
   d_data       <0fffffh>,00000000h,<DATA_ACC or DPL_3>,<ACC2_B_SMALL or ACC2_G_BYTE>

; ᥣ���� ������ ����� for base linear address 00100000h
gdata6_selec    equ     $-gdt_tab or TBL_GDT or RPL_0           ;*!!
   d_data       <0fffffh>,00100000h,<DATA_ACC or DPL_3>,<ACC2_B_SMALL or ACC2_G_BYTE>

GDT_size        equ     $-gdt_tab       ; ����� ⠡����
GDT_limit       equ     GDT_size-1
GDT             ends

;
; ��� 2: ⠡��� ���ਯ�஢ ���뢠��� ��⥬�
;
IDT             segment para    public  use16   'IDT'

idt_tab         equ     $
        REPT    INTNO
; ����. ���⨫� ���뢠���, DPL ��।���� �ਢ������ ����㯠 � ������,
; �ਢ������ ��ࠡ�⪨ ���뢠��� ������ ��� DPL � ���ਯ�� �����
; �� ����稨 v86 �ਢ������ ����㯠 � ���ਯ�ࠬ ���뢠��� ������
; ���� �㫥�묨 (DPL=0) ��� ���墠� ���뢠��� ०��� v86 �� ��饩 ����
          d_int 0,<int_selec>,<INT_ACC or DPL_0>
        ENDM
IDT_size        equ     $-idt_tab
IDT_limit       equ     IDT_size-1
IDT             ends

;
; ������� ������ ��⥬�
;
Gdata           segment para    public  use16   'Gdata'
gdata_beg       equ     $
;
; ��� 3: ����⥫� ���ਯ���� ⠡��� ��� ����㧪� ॣ���஢
;
pGDT    label   fword
        dw      GDT_limit               ; ࠧ��� GDT
        dd      0                       ; ���. ������ ���� GDT
pIDT    label   fword
        dw      IDT_limit               ; ࠧ��� IDT ����. ०���
        dd      0                       ; ���. ������ ���� IDT
pold    label   fword
        dw      03ffh                   ; ࠧ��� IDT ॠ�쭮� ����
        dd      0                       ; 䨧. ������ ���� IDT

;
; ��� 4: ⠡��� �८�ࠧ���⥫�� ���ਯ�஢ ᥣ���⮢ GDT
;
gdt_phys_tab    label   word
        dw      task0_TSS_selec,task0_TSS       ; ᥫ����,ᥣ����� ����
        dw      stk0_selec,stk0
        dw      stk1_selec,stk1
        dw      stk2_selec,stk2
        dw      stk3_selec,stk3
        dw      code_selec,code
        dw      gdata_selec,Gdata
        dw      int_selec,code
        dw      dmy_selec,dmy
        dw      rc_selec,code
        dw      gdt_selec,gdt
;
; ��� 4.1: ��� �������⥫��� ���ਯ�஢
;
        dw      idt_selec,idt
        dw      stack0_selec,stack0
        dw      stack3_selec,stack3
        dw      task1_TSS_selec,task1_TSS
        dw      task1_OTSS_selec,task1_TSS
        dw      task1_seg_selec,task1_seg

gdt_tab_count   equ     ($-gdt_phys_tab)/4

;
; ��� 5: ��⥬�� ᮮ�饭��
;
msg_addr        dw      05               ; ��ப� ��砫� �뢮�� �� ��࠭
in_protected    db      'in protected mode',0
int_msg         db      'interrupt '
int_num         db      '????','H '
err_num         db      '????','H',0

;
; ��� 5.1: ��⥬�� ᮮ�饭�� v86
;
error           db      'error !',0
retmsg          db      'return to protected mode',0
stopmsg         db      'stop',0
intnum          db      ?
retaddr         dw      ?
err1            dw      0
err2            dw      0
pdbr1           dd      ?               ; cr3 ��� ����� 1
pdbr0           dd      ?               ; cr3 ��� ����� 0

;
; ������ ��� �࠭���� ॣ���஢ SS,SP,ES.
; ��� ��࠭����� ����� ��। �室�� � ���饭�� ०��.
real_ss         dw      ?
real_sp         dw      ?
real_es         dw      ?
int_mask        db      ?       ; ��� ᯠᥭ�� ��᪨ ���뢠���

Gdata_size      equ     $-gdata_beg
Gdata_limit     equ     Gdata_size-1
Gdata           ends

;
; ��� 6: �⥪��� ᥣ����� ��� ��� �஢��� �ਢ������
;
stk0            segment para    public  use16   'stk0'
stk0_beg        equ     $
        db      100h    dup(0)
stk0_size       equ     $-stk0_beg
stk0_limit      equ     stk0_size-1
stk0            ends

stk1            segment para    public  use16   'stk1'
stk1_beg        equ     $
        db      100h    dup(0)
stk1_size       equ     $-stk1_beg
stk1_limit      equ     stk1_size-1
stk1            ends

stk2            segment para    public  use16   'stk2'
stk2_beg        equ     $
        db      100h    dup(0)
stk2_size       equ     $-stk2_beg
stk2_limit      equ     stk2_size-1
stk2            ends

stk3            segment para    public  use16   'stk3'
stk3_beg        equ     $
        db      100h    dup(0)
stk3_size       equ     $-stk3_beg
stk3_limit      equ     stk3_size-1
stk3            ends

DOS_stack       segment para    stack   'stack'
DOS_stack_beg   equ     $
        db      100h    dup(?)
stk_DOS_size    equ     $-DOS_stack_beg
stk_DOS_limit   equ     stk_DOS_size-1
DOS_stack       ends

;
; ��� 6.1: �⥪��� ᥣ����� ��� v86
;
stack0          segment para    public  use16   'stack0'
stack0_beg      equ     $
        db      100h    dup(?)
stack0_size     equ     $-stack0_beg
stack0_limit    equ     stack0_size-1
stack0          ends

stack3          segment para    public  use16   'stack3'
stack3_beg      equ     $
        db      100h    dup(?)
stack3_size     equ     $-stack3_beg
stack3_limit    equ     stack3_size-1
stack3          ends

;
; ��� 7: ᥣ���� ���ﭨ� ����� TSS
;
task0_TSS       segment para    public  use16   'task0'
task0_TSS_beg   equ     $
TSS_stack       stk0_selec,stk0_size,stk1_selec,stk1_size,stk2_selec,stk2_size
TSS_cr3         0
TSS_regs        0,0,0,0,0,0,0,0,0,stk0_size
TSS_seg         gdata_selec,code_selec,stk0_selec,gdata_selec,gdata_selec,gdata_selec
                dd      0       ; LDT
                dw      0       ; T ��� TSS �ᥣ�� 0 �� ���樠����樨
                dw      068h    ; I/O table start
                db      200h dup(0ffh) ; 4096 i/o ports bit map disable
task0_TSS_size  equ     $-task0_TSS_beg
task0_TSS_limit equ     task0_TSS_size-1
task0_TSS       ends

;
; ��� 7.1: ᥣ���� ���ﭨ� ����� v86
; EFLAGS ����� IOPL=3, VM-set, IF-set
; v86_flags     equ     fl_vm or fl_iopl3 or fl_if or fl_set
; ᯠᥭ�� ᥣ����� ॣ����� ᮤ�ঠ� ᥣ����� ���� (CS,SS)
task1_TSS       segment para    public  use16   'task1'
task1_TSS_beg   equ     $
TSS_stack       stack0_selec,stack0_size,stk1_selec,stk1_size,stk2_selec,stk2_size
TSS_cr3         0
TSS_regs        task1_entry,v86_flags,0,0,0,0,0,0,0,stack3_size
TSS_seg         0,9000h,stack3,0,0,0
                dd      0       ; LDT
                dw      0       ; T ��� TSS �ᥣ�� 0 �� ���樠����樨
                dw      068h    ; I/O table start
                db      200h dup(0)    ; 4096 ���� ���⮢ i/o enable
task1_TSS_size  equ     $-task1_TSS_beg
task1_TSS_limit equ     task1_TSS_size-1
task1_TSS       ends

;
; ��� 7.2: ᥣ���� ��࠭��, ᮤ�ন� ⠡���� ��࠭�� � ��⠫����
;          ��� 䨧��᪮�� ���᭮�� ����࠭�⢠ 0..1�����
;
pagetbl0        segment para    public  use16   'pagetbl0'
pagetbl0_beg    equ     $

        db      4096    dup(0)  ; ��� ��ࠢ������� �� �࠭��� 4��.

tmp_ptbl0       label   byte    ; ⠡��� ��࠭��, �㤥� ��६������ �����

      REPT      256     ; 256 ���ਯ�஢ �� ��࠭�� (1�����)
        dd      (($-tmp_ptbl0)/4*1000h + pg_present+pg_write+pg_user)
      ENDM

page_tbl0_size  equ     ($-tmp_ptbl0)/4 ; �᫮ �室�� � ⠡���� ��࠭��

;
; ������ ��࠭��� �� ᠬ�� ���� �� 1024 ���ਯ�� ��࠭��,
; ���⮬� ����� ��࠭��� ��⠫��� ��࠭�� ���� ��������
;
        org     tmp_ptbl0+pdbr_offset   ; ��砫� ��⠫��� ��࠭��
        dd      ?                       ; � ��⠫��� ��࠭�� �㤥�
                                        ; ⮫쪮 ���� �室
ptbl0_addr      dw      ?               ; ��� ���᫥����� ᬥ饭�� ⠡����
                                        ; ��࠭�� �� 䨧��᪮� �࠭�� 4�.
pagetbl0_size   equ     $-pagetbl0_beg
pagetbl0_limit  equ     pagetbl0_size-1

pagetbl0        ends

;
; ��� 7.3: ᥣ���� ��࠭��, ᮤ�ন� ⠡���� ��࠭�� � ��⠫����
;          ��� 䨧��᪮�� ���᭮�� ����࠭�⢠ 1..2�����
;
pagetbl1        segment para    public  use16   'pagetbl1'
pagetbl1_beg    equ     $

        db      4096    dup(0)  ; ��� ��ࠢ������� �� �࠭��� 4��.

tmp_ptbl1       label   byte    ; ⠡��� ��࠭��, �㤥� ��६������ �����

      REPT      256     ; 256 ���ਯ�஢ �� ��࠭�� (1�����)
        dd      (($-tmp_ptbl1)/4*1000h + pg_present+pg_write+pg_user + 100000h)
      ENDM

page_tbl1_size  equ     ($-tmp_ptbl1)/4 ; �᫮ �室�� � ⠡���� ��࠭��

;
; ������ ��࠭��� �� ᠬ�� ���� �� 1024 ���ਯ�� ��࠭��,
; ���⮬� ����� ��࠭��� ��⠫��� ��࠭�� ���� ��������
;
        org     tmp_ptbl1+pdbr_offset   ; ��砫� ��⠫��� ��࠭��
        dd      ?                       ; � ��⠫��� ��࠭�� �㤥�
                                        ; ⮫쪮 ���� �室
ptbl1_addr      dw      ?               ; ��� ���᫥����� ᬥ饭�� ⠡����
                                        ; ��࠭�� �� 䨧��᪮� �࠭�� 4�.
pagetbl1_size   equ     $-pagetbl1_beg
pagetbl1_limit  equ     pagetbl1_size-1

pagetbl1        ends

;
; ��� 8: ᥣ���� ������ � �ଠ� ॠ�쭮� ���� ��� ������ � DOS
;
dmy             segment para    public  use16   'dmy'
dmy_beg         equ     $
        db      128     dup(0)
dmy_size        equ     $-dmy_beg
dmy_limit       equ     0ffffh
dmy             ends

;
; ������� ����� ��⥬�
;
code            segment para    public  use16   'code'
code_beg        equ     $
        assume  cs:code, ds:gdata

main    proc    far
        cli
        mov     ax,gdata
        mov     ds,ax

        mov     ax,stk0
        mov     ss,ax
        mov     sp,offset stk0_size
        sti
;
; ��� 9: ���樠������ IDT
;
        mov     ax,IDT
        mov     es,ax
        mov     di,offset idt_tab       ; DI=⠡��� ���뢠��� IDT
        mov     ax,offset int_entry     ; AX=���� �ண�. ��ࠡ. ���뢠���
                                        ; ��� ᬥ饭�� �� int_selec
        mov     cx,INTNO
fillidt:
        mov     es:[di],ax              ; ��� �室� � ���ਯ�� �맮��
        add     di,DSCPSIZE             ; ᫥�. ���ਯ�� � IDT
        add     ax,INTSIZE              ; �窠 �室� ��� ᫥�. ���뢠���
        loop    fillidt                 ; ��� ��� ���뢠��� � IDT

;
; ��� 9.1: ��ந� ⠡���� ��࠭��
;
        call    setup_pgtbl0            ; ����ந� ⠡���� ��࠭�� 0
        call    setup_pgtbl1            ; ����ந� ⠡���� ��࠭�� 1

;
; ��� 9.2: set PDBR 0
;
        mov     eax,pdbr0               ; ���� ���� ��⠫��� ��࠭�� 0
        mov     cr3,eax                 ; �� � CR3
        mov     bx,task0_TSS
        mov     es,bx                   ; ES = task0 TSS selector
        mov     es:[T_cr3],eax          ; CR3 in task0 TSS

;
; ��� 9.3: set PDBR 1
;
        mov     eax,pdbr1               ; ���� ���� ��⠫��� ��࠭�� 1
        mov     bx,task1_TSS
        mov     es,bx                   ; ES = task1 TSS selector
        mov     es:[T_cr3],eax          ; CR3 in task1 TSS

;
; ��� 10: ��ந� ����⥫� GDT
;
        build_gdtr      gdt,pgdt,gdt_limit

;
; ��� 11: ��ந� ����⥫� IDT
;
        build_idtr      idt,pidt,idt_limit

;
; ��� 12: ��ந� ��������� ⠡���� ���ਯ�஢ ��⥬� GDT
;
        build_dt        gdt,gdt_phys_tab,gdt_tab_count

;
; ��� 13: ���室�� � ���饭�� ०�� �� 0 �஢�� �ਢ������
;
        goto_prot       pgdt,pidt,code_selec,stk0_selec,stk0_size,Gdata_selec

;
; ��� 14: �뢮� ᮮ�饭�� � ���室� � ���饭�� ०��
;
        call    clr_disp                ; clear display

        mov     ax,[msg_addr]           ; ����� ��ப� �� ��࠭�
        inc     [msg_addr]              ; ᫥�. ��ப� �� 1 �����
        mov     cl,160                  ; ����� ��ப� � �����
        mul     cl                      ; AX = ���� ᮮ�饭�� �� ��࠭�
        mov     si,offset in_protected  ; ���� ᮮ�饭�� (���筨�)
        mov     di,ax                   ; ���� ��࠭�    (�ਥ����)
        call    disp_it                 ; �뢥�� ��ப� �� ��࠭

;
; ��� 14.1: copy data from first megabyte to second
;
        push    ds

        cld
        mov     ax,gdata5_selec
        mov     ds,ax                   ; ds = 0..0fffffh address
        mov     ax,gdata6_selec
        mov     es,ax                   ; es = 100000h..1fffffh address
        xor     esi,esi
        xor     edi,edi
        mov     ecx,0fffffh             ; counter= 1M
        db      066h                    ; large operand
        db      067h                    ; large address
        rep     movsb                   ; copy 1-st Mbyte to 2-nd Mbyte

;
; ��� 14.2: copy task1 TSS to linear address 180000h
;
        mov     ax,task1_OTSS_selec     ; task1 TSS selector as data in 1M
        mov     ds,ax
        mov     ax,gdata3_selec         ; selector for linear address 180000h
        mov     es,ax
        xor     si,si
        xor     di,di
        mov     cx,task1_TSS_size
        rep     movsb                   ; task 1 TSS from 1M to 180000h

;
; ��� 14.3: copy task1 code to linear address 190000h
;
        mov     ax,task1_seg_selec      ; task1 code selector in first Mbyte
        mov     ds,ax
        mov     ax,gdata4_selec         ; linear address 190000h
        mov     es,ax
        xor     si,si
        xor     di,di
        mov     cx,task1_seg_size
        rep     movsb                   ; copy code task1

        pop     ds

;
; ��� 15: ����㧪� � TR TSS
;
        mov     ax,task0_TSS_selec
        ltr     ax

;
; ��� 15.0: enable memory paging
;
        mov     eax,cr0
        or      eax,pg_enable           ; enable paging
        mov     cr0,eax

;
; ��� 15.1: ��४��祭�� �� ������ v86
;
        jmpf    task1_TSS_selec

;
; ��� 15.2: ��୥��� � ��᫥ ������ �� v86
;
        mov     eax,cr0
        and     eax,not pg_enable       ; disable paging
        mov     cr0,eax
        xor     eax,eax
        mov     cr3,eax                 ; ������ ��� ��࠭��

;;;                jmp     $

        mov     ax,[msg_addr]           ; ����� ��ப� �� ��࠭�
        inc     [msg_addr]              ; ᫥�. ��ப� �� 1 �����
        mov     cl,160                  ; ����� ��ப� � �����
        mul     cl                      ; AX = ���� ᮮ�饭�� �� ��࠭�
        mov     si,offset retmsg        ; ���� ��ப� (���筨�)
        mov     di,ax                   ; ���� ��࠭� (�ਥ����)
        call    disp_it

;
; ��� 16: ������ ���⭮ � DOS
;
        jmp     goto_real_

;
; ��� 16.1: ��।���� �⥪ �� �室� � ���뢠���
;
spcheck         equ     offset (stk0_size - v86stklen - 4)
                ; �� �⮬� ����� �㤥� ��� �訡��, �᫨ �� ��,
                ; �� ���뢠��� �� ०��� v86

;
; ��� 17: ���ᨢ �祪 �室� �� ��ࠡ�⪥ ���뢠���
;
int_entry:
      REPT    INTNO
        call  intchk                    ; ��楤�� ��ࠡ�⪨ ���뢠���
        iret
      ENDM

;
; ��� 17.1: ������ ��ࠡ�⪨ ���뢠��� ��⥬�
;       1. ��⠭�������� ᥫ���� ��⥬��� ������
;       2. ���������� ���� ������ �� ������ ���뢠���
;       3. ���������� ��� �訡��, �᫨ ��� �뫠
intchk:
        push    eax
        mov     ax,gdata_selec
        mov     ds,ax                   ; ��⠭�� �� ��⥬�� �����
        pop     eax

        pop     [retaddr]               ; ���� ������樨 iret

        mov     [err1],0ffffh
        cmp     sp,spcheck              ; ��㡨�� �⥪� ����砥� �訡�� ?
        jne     contint                 ; neq, ���, �ய��⨬
        pop     [err1]                  ; ��� �訡�� �� �⥪�
        pop     [err2]                  ; �㤠 �� ����饭 dd, ���⨬ �⥪

;
; ��� 17.2: ����稬 ����� ����� ���뢠���
;
contint:
        pushad                          ; push all regs

        call    disp

        mov     ax,[retaddr]            ; ���� �窨 ������
        sub     ax,offset int_entry     ; ᬥ饭�� �窨 �室� � �����
        shr     ax,TWO                  ; /4 ��� ����祭�� ����� �����

        cmp     ax,13                   ; ���뢠��� ��饩 ����� 13 ?
        je      int_13                  ; eq, ��, ��ࠡ�⠥� ���

;
; ��� 17.3: �� ���뢠��� ��饩 �����, ����稬 ���� ������
;
        mov     cx,stk0_selec
        mov     es,cx                   ; ES = stk0
        mov     bx,sp
        add     bx,size pushaddef       ; �ய��⨬ pushad
        mov     esi,es:[bx].oldeip      ; ���� ������ �� ���뢠��� (DOS)
        jmp     setint                  ; ax = #���뢠���

;
; ��� 17.4: ���뢠��� ��饩 �����, �᫨ �� intn, � ��ࠡ�⠥�,
;           ���� ����� �ணࠬ��
;
int_13:
        mov     ax,stk0_selec
        mov     es,ax                   ; ES = stk0
        mov     bx,sp
        add     bx,size pushaddef       ; �ய��⨬ pushad
        mov     eax,es:[bx].oldecs      ; ᥣ���� ����� � DOS
        mov     ch,ah
        shl     ax,4
        shr     ch,4                    ; ch:ax = 24 bit ������� ����

        assume  ds:gdt

        mov     dx,gdt_selec
        mov     ds,dx                   ; DS = gdt
        mov     [gdata1.d_base1],ax     ; ������� ���� ����� � ���ਯ��
        mov     [gdata1.d_base2],ch     ; ������ ��� ����㯠 � ��������
        mov     ax,gdata1_selec
        mov     ds,ax                   ; DS = ᥣ���� ����� ����� v86
        mov     esi,es:[bx].oldeip      ; si = ���� ������樨 ���뢠���
        cld
        lodsb                           ; al = �������, �맢���� ���뢠���
        cmp     al,0cdh                 ; ��� ������� "INT n" ?
        jne     stop                    ; neq, ���, ����� �ணࠬ��

;
; ��� 17.5: �뫮 ���뢠��� v86 "INT n", 㧭��� �����
;
procint:
        lodsb                           ; al = # ����襭���� ���뢠���

;
; ��� 17.6: �᫨ ����襭� ���뢠��� INT 1 (T-bit), ����� ࠡ���
;
        cmp     al,1
        je      int_1

;
; ��� 17.7: ��⮢�� �⥪ ����� v86 ��� ��室� �� ᢮��� ���뢠���,
;           ��᪮��� ������ ���뢠��� �뫠 �믮����� � ०���
;           v86, � �� 8086 � � �⥪� 0 ��⥬�
;   SI = IP (v86) ������ �� ���뢠���
;   AL = �ந��襤襥 ��� ����襭��� ���뢠��� � ०��� v86
setint:
        mov     ecx,es:[bx].oldess
        mov     dh,ch
        shl     cx,4
        shr     dh,4                    ; dh:cx = 24 bit ���� �⥪� v86
        mov     di,gdt_selec
        mov     ds,di
        mov     [gdata1.d_base1],cx
        mov     [gdata1.d_base2],dh     ; ����ந� ࠡ�稩 ���ਯ�� �� SS
        mov     dx,gdata1_selec
        mov     ds,dx                   ; DS = v86 SS ᥫ����
        mov     edi,es:[bx].oldesp      ; DI = v86 SP
        sub     edi,6                   ; ��१�ࢨ�㥬 ���� ��� 3 ��ࠬ���
        mov     es:[bx].oldesp,edi      ; ���뢠��� (IP,CS,FLAGS)
        mov     [di],si                 ; IP �������� � �⥪ v86
        mov     edx,es:[bx].oldecs
        mov     [di+2],dx               ; CS �������� � �⥪ v86
        mov     edx,es:[bx].oldeflg
        mov     [di+4],dx               ; FLAGS �������� � �⥪ v86

;
; ��� 17.8: ��⮢�� ���室 �� ��ࠡ��� ���뢠��� DOS
;   AL  = �ந��襤襥 ��� ����襭��� ���뢠��� � ०��� v86
;   EDX = ᫮�� 䫠��� v86 � ������ ���뢠���
        and     dx,NOT (fl_if or fl_tf) ; ���⨬ IF � TF � ᫮�� 䫠��� v86
        mov     cx,dos_selec
        mov     ds,cx                   ; DS = ᥫ���� ����஢ v86
        xor     ah,ah
        shl     ax,2                    ; ���� ����⥫� �����
        xor     si,si
        add     si,ax                   ; SI = ������ ����� � ⠡��� DOS
        xor     eax,eax
        mov     ax,[si]                 ; v86 vector offset
        xor     ecx,ecx
        mov     cx,[si+2]               ; v86 vector segment
        mov     es:[bx].oldecs,ecx      ; vector's CS     �������� � stk0
        mov     es:[bx].oldeip,eax      ; vector's EIP    �������� � stk0
        mov     es:[bx].oldeflg,edx     ; vector's EFLAGS �������� � stk0
        popad
        db      066h                    ; LARGE ��䨪�
        iret                            ; ��३� �� ��ࠡ��� ���뢠���
                                        ; � ����� v86

;
; ��� 17.9: ��⠭�� �ணࠬ��, ��� � �訡��
;
stop:
        assume  ds:gdata

        mov     dx,gdata_selec
        mov     ds,dx                   ; DS = gdata
        mov     ax,[msg_addr]           ; ����� ��ப� �� ��࠭�
        inc     [msg_addr]              ; ᫥�. ��ப� �� 1 �����
        mov     cl,160                  ; ����� ��ப� � �����
        mul     cl                      ; AX = ���� ᮮ�饭�� �� ��࠭�
        mov     si,offset stopmsg       ; ���� ��ப� (���筨�)
        mov     di,ax                   ; ���� ��࠭� (�ਥ����)
        call    disp_it

;
; ��� 17.10: ������ � ���饭�� ०�� �� ०��� v86
;
int_1:
        popad                           ; ����⠭����� �⥪

        jmpf    task0_TSS_selec         ; ��४����� ������

;
; ��� 18: ������ �⠭���⭮� ��ࠡ�⪨ ���뢠���
;         ������ ����� ����� � �뢮��� ��� �� ��࠭
;         � �����頥��� � DOS
;
disp    proc    near
        push    eax
        push    esi
        push    ecx

        xor     eax,eax                 ; ���⨬ �᫮ ��� �८�ࠧ������
        mov     ax,[err1]               ; ��� �訡��
        shr     ax,3                    ; ax = ����� ����� DOS

        cmp     ax,029h
        jz      no_disp
        cmp     ax,010h
        jz      no_disp
        cmp     ax,028h
        jz      no_disp
        cmp     ax,016h
        jz      no_disp
        cmp     ax,02ah
        jz      no_disp
        cmp     ax,01ch
        jz      no_disp
        cmp     ax,01ah
        jz      no_disp
        cmp     ax,015h
        jz      no_disp

        xor     eax,eax                 ; ���⨬ �᫮ ��� �८�ࠧ������
        mov     ax,[retaddr]            ; ���� ������
        sub     ax,offset int_entry
        shr     ax,TWO                  ; ax= ����� �����

        cmp     ax,008h                 ; DOS timer �ய��⨬
        jz      no_disp

        xor     esi,esi                 ; ���⨬ ���� ��ப�
        mov     si,offset int_num       ; ���� ��ப� ����� �����
        mov     cx,WORDLEN              ; �᫮ ᨬ����� � ��ப�
        call    htoa                    ; HEX->ASCII (esi,cx,eax)

        xor     eax,eax                 ; ���⨬ �᫮ ��� �८�ࠧ������
        mov     ax,[err1]               ; ��� �訡��
        xor     esi,esi
        mov     si,offset err_num       ; ���� ��ப� ���� �訡��
        mov     cx,WORDLEN              ; �᫮ ᨬ����� � ��ப�
        call    htoa                    ; HEX->ASCII (esi,cx,eax)

        mov     ax,[msg_addr]           ; ����� ��ப� �� ��࠭�
        cmp     ax,25
        ja      no_disp
        inc     [msg_addr]              ; ᫥�. ��ப� �� 1 �����
        mov     cl,160                  ; ����� ��ப� � �����
        mul     cl                      ; AX = ���� ᮮ�饭�� �� ��࠭�
        mov     si,offset int_msg       ; ���� ��ப� (���筨�)
        mov     di,ax                   ; ���� ��࠭� (�ਥ����)
        call    disp_it                 ; �뢥�� ��ப� �� ��࠭

no_disp:
        pop     ecx
        pop     esi
        pop     eax
        ret
disp    endp

;
; ��� 19: ������ � ॠ��� ०�� ������
;
goto_real_:
        cli
;;        mov     eax,cr0
;;        and     eax,not pg_enable       ; disable paging
;;        mov     cr0,eax
;;        xor     eax,eax
;;        mov     cr3,eax                 ; ������ ��� ��࠭��

        goto_real dmy_selec,code,stk0,stk0_size,Gdata

;
; ��� 20: ������ � DOS
;
        mov     ax,4c00h                ; Exit Process
        int     21h

main    endp

;
; ��楤�� �뢮�� ��ப� �� ��ᯫ�� � ���饭��� ०���
;  DS:SI - ���� ��ப� ᨬ����� ASCIZ; DI - ᬥ饭�� � ����������
;
disp_it         proc    near
        push    ax
        push    es
        mov     ax,video_selec          ; ᥫ���� ����������
        mov     es,ax
        mov     ah,attribute            ; ��ਡ�� ᨬ�����
disp_loop:
        lodsb                           ; ᨬ��� �� ��ப�
        cmp     al,0                    ; ����� ��ப� ?
        jz      end_disp                ; z, ��, ������
        stosw                           ; ᨬ��� � �����������
        jmp     disp_loop               ; ������� �� ���� ��ப�
end_disp:
        pop     es
        pop     ax
        ret
disp_it         endp

;
; ��楤�� ���⪨ ��ᯫ�� � ���饭��� ०���
; �室:
; ��室:
;
clr_disp        proc    near
        push    ax
        push    cx
        push    di
        push    es

        mov     ax,video_selec          ; ᥫ���� ����������
        mov     es,ax
        mov     cx,CRT_SIZE             ; ࠧ��� ����������
        shr     cx,TWO                  ; � ᫮���
        xor     di,di
        mov     ah,attribute
        mov     al,space
        rep     stosw                   ; ���⨬ ��࠭

        pop     es
        pop     di
        pop     cx
        pop     ax
        ret
clr_disp        endp

;
; ��楤�� �८�ࠧ������ HEX->ASCII
;  DS:ESI - ���� ��ப� ᨬ�����, CX - �� �����,
;  EAX    - �᫮ ��� �८�ࠧ������
htoa_tab        db      '0123456789ABCDEF'
htoa            proc    near
        push    ebx
        push    eax
        xor     ebx,ebx
        add     si,cx
        dec     si                      ; ��⠭�� �� ����� ��ப�
htoa_loop:
        mov     bl,al
        and     bl,0fh
        mov     bl,cs:[ebx+htoa_tab]    ; ASCII ��� ᨬ����
        mov     byte ptr [esi],bl       ; ��� � ��ப� ᨬ�����
        dec     esi                     ; �த������� � ��ப� ᨬ�����
        shr     eax,4                   ; �த������� � �᫥ �� ��ࠤ�
        loop    htoa_loop
        pop     eax
        pop     ebx
        ret
htoa            endp

;
; 1. ��楤�� ������ 䨧��᪨� ���� ⠡���� ��࠭�� �� �࠭��
;    4����� � ��६�頥� �㤠 ����⮢������ ⠡���� ��࠭��
; 2. ��ନ��� ���ਯ�� �⮩ ⠡���� � ��⠫��� ��࠭��, �����
;    ࠧ��饭� �ࠧ� �� ���
;
setup_pgtbl0    proc    near
        assume  ds:pagetbl0

        push    ds
        push    es
        push    eax

        mov     ax,pagetbl0
        mov     ds,ax
        mov     es,ax                   ; DS=ES= pagetbl sement
        mov     cx,page_tbl0_size       ; �᫮ �室�� � ⠡���� ��࠭��

        mov     bx,ax                   ; BX= pagetbl sement
        and     bx,00ffh                ; ᬥ饭�� �� �࠭��� � 4�����
        xor     edi,edi
        mov     di,0100h                ; �� ��१�ࢨ஢��� 4096 ����
        sub     di,bx                   ; �⮡� ������� �� �࠭��� 4�����
        shl     di,4                    ; ���� ��६����� ⠡���� �� �⮬�
                                        ; 䨧��᪮�� �����
        mov     [ptbl0_addr],di         ; �������� ᬥ饭�� �� ⠡����
        push    di                      ; ��࠭�� �� ��砫� ᥣ����

        mov     si,offset tmp_ptbl0     ; ��� ⠡��� ��室���� �� �⮬� ���.

        rep     movsd                   ; ��६��⨬ ⠡���� � ��. ����

        pop     di                      ; di= ᬥ饭�� �� ⠡�. ���. �� ᥣ�.

;
; ��⠭�������� ��⠫�� ��࠭��
;
        xor     ebx,ebx
        mov     bx,ax                   ; bx = seg pagetbl
        shl     ebx,4                   ; 20-��� ���� ᥣ����
        add     ebx,edi                 ; 20-��� ���� ⠡���� ��࠭��
        or      bl,pg_present or pg_user or pg_write
                                        ; ��ਡ��� ���ਯ�� ⠡���� ���.
        mov     dword ptr [di + pdbr_offset],ebx
                                        ; ��⠫�� �ࠧ� �� ⠡��楩 ��࠭��
                                        ; �㤠 � �����⨬ �� ����
        add     ebx,offset pdbr_offset  ; ��⠭�� �� ��� ���� ���� ��⠫���
        and     ebx,pg_addrmsk          ; ��⠢�� � ���ਯ�� ⮫쪮 ����
                                        ; �� � �㤥� ���ᮬ ���� ��⠫���
        push    ds

        assume  ds:gdata

        mov     ax,gdata
        mov     ds,ax
        mov     pdbr0,ebx               ; �������� ���� ��⠫���
        pop     ds

        assume  ds:pagetbl0

        pop     eax
        pop     es
        pop     ds
        ret
setup_pgtbl0    endp

;
; 1. ��楤�� ������ 䨧��᪨� ���� ⠡���� ��࠭�� �� �࠭��
;    4����� � ��६�頥� �㤠 ����⮢������ ⠡���� ��࠭��
; 2. ��ନ��� ���ਯ�� �⮩ ⠡���� � ��⠫��� ��࠭��, �����
;    ࠧ��饭� �ࠧ� �� ���
;
setup_pgtbl1    proc    near
        assume  ds:pagetbl1

        push    ds
        push    es
        push    eax

        mov     ax,pagetbl1
        mov     ds,ax
        mov     es,ax                   ; DS=ES= pagetbl sement
        mov     cx,page_tbl1_size       ; �᫮ �室�� � ⠡���� ��࠭��

        mov     bx,ax                   ; BX= pagetbl sement
        and     bx,00ffh                ; ᬥ饭�� �� �࠭��� � 4�����
        xor     edi,edi
        mov     di,0100h                ; �� ��१�ࢨ஢��� 4096 ����
        sub     di,bx                   ; �⮡� ������� �� �࠭��� 4�����
        shl     di,4                    ; ���� ��६����� ⠡���� �� �⮬�
                                        ; 䨧��᪮�� �����
        mov     [ptbl1_addr],di         ; �������� ᬥ饭�� �� ⠡����
        push    di                      ; ��࠭�� �� ��砫� ᥣ����

        mov     si,offset tmp_ptbl1     ; ��� ⠡��� ��室���� �� �⮬� ���.

        rep     movsd                   ; ��६��⨬ ⠡���� � ��. ����

        pop     di                      ; di= ᬥ饭�� �� ⠡�. ���. �� ᥣ�.

;
; ��⠭�������� ��⠫�� ��࠭��
;
        xor     ebx,ebx
        mov     bx,ax                   ; bx = seg pagetbl
        shl     ebx,4                   ; 20-��� ���� ᥣ����
        add     ebx,edi                 ; 20-��� ���� ⠡���� ��࠭��
        or      bl,pg_present or pg_user or pg_write
                                        ; ��ਡ��� ���ਯ�� ⠡���� ���.
        mov     dword ptr [di + pdbr_offset],ebx
                                        ; ��⠫�� �ࠧ� �� ⠡��楩 ��࠭��
                                        ; �㤠 � �����⨬ �� ����
        add     ebx,offset pdbr_offset  ; ��⠭�� �� ��� ���� ���� ��⠫���
        and     ebx,pg_addrmsk          ; ��⠢�� � ���ਯ�� ⮫쪮 ����
                                        ; �� � �㤥� ���ᮬ ���� ��⠫���
        push    ds

        assume  ds:gdata

        mov     ax,gdata
        mov     ds,ax
        mov     pdbr1,ebx               ; �������� ���� ��⠫���
        pop     ds

        assume  ds:pagetbl1
;
; Set Linear Video Memory Address To Physical Area b8000h..bffffh
;
        mov     bx,ptbl1_addr           ; ᬥ饭�� �� ⠡���� ��࠭��
        add     bx,0b8h shl 2           ; get entry 0b8000h
        mov     eax,0b8000h + pg_present+pg_write+pg_user
        mov     dword ptr [bx],eax      ; 0b8000h
        add     eax,001000h             ; next video page address
        add     bx,4                    ; next video page descriptor
        mov     dword ptr [bx],eax      ; 0b9000h
        add     eax,001000h             ; next video page address
        add     bx,4                    ; next video page descriptor
        mov     dword ptr [bx],eax      ; 0ba000h
        add     eax,001000h             ; next video page address
        add     bx,4                    ; next video page descriptor
        mov     dword ptr [bx],eax      ; 0bb000h
        add     eax,001000h             ; next video page address
        add     bx,4                    ; next video page descriptor
        mov     dword ptr [bx],eax      ; 0bc000h
        add     eax,001000h             ; next video page address
        add     bx,4                    ; next video page descriptor
        mov     dword ptr [bx],eax      ; 0bd000h
        add     eax,001000h             ; next video page address
        add     bx,4                    ; next video page descriptor
        mov     dword ptr [bx],eax      ; 0be000h
        add     eax,001000h             ; next video page address
        add     bx,4                    ; next video page descriptor
        mov     dword ptr [bx],eax      ; 0bf000h

        pop     eax
        pop     es
        pop     ds
        ret
setup_pgtbl1    endp

code_size       equ     $-code_beg
code_limit      equ     code_size-1
code            ends

;
; ��� 23: ������ ᥣ���� ����� v86
;       �ᯮ������ �����⢫���� � ०��� v86
;
task1_seg       segment para    public  use16   'task1_seg'
task1_seg_beg   equ     $
        assume  cs:task1_seg, ds:gdata

task_entry      proc    near
entry:
                        jmp $
        push    cs
        pop     ds                      ; cs=ds

;;        mov     al,[int_mask]           ; ��᪠ ���뢠���
;;        and     al,NOT 002h             ; ࠧ�訬 ���뢠��� ���������
        mov     al,NOT 002h             ; ࠧ�訬 ���뢠��� ���������
        out     INT_MASK_PORT,al        ; ���뢠���
;
; ��� 24: ����� � DOS (INT 21h) �� �뢮� ��ப�
;
        mov     dx,offset task1msg      ; ���� ᮮ�饭�� DOS
        mov     ah,09                   ; ������� �뢮�� ��ப�
        int     21h                     ; ���뢠��� � DOS

        mov     dx,offset success       ; ���� ᮮ�饭�� DOS
        mov     ah,09                   ; ������� �뢮�� ��ப�
        int     21h                     ; ���뢠��� � DOS

;
; ��� 25: ����� � DOS (INT 21h) �� ���� ᨬ���� � ����������
;
        mov     ah,1
        int     21h                     ; ���� ����� ᨬ���� � ����������

;
; ��� 26: ������ �� ०��� v86 � ���饭�� ०��
;
        mov     al,0ffh                 ; ����⨬ ���뢠��� ����஫����
        out     INT_MASK_PORT,al        ; ���뢠���

        int     1
task_entry      endp

task1msg        db      'now in v86 mode task1',0dh,0ah,'$'
success         db      'press any key to return to protected mode',0dh,0ah,'$'

task1_seg_size  equ     $-task1_seg_beg
task1_seg_limit equ     task1_seg_size-1

task1_seg       ends

        end     main

