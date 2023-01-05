        SEG.U RAM
        ORG $80

MAP            ds 96   ; $80 - $DF

eLPF0          ds 1    ; $E0      Left side PF0
eLPF1          ds 1    ; $E1      Left side PF1
eLPF2          ds 1    ; $E2      Left side PF2
eRPF0          ds 1    ; $E3      Right side PF0
eRPF1          ds 1    ; $E4      Right side PF1
eRPF2          ds 1    ; $E5      Right side PF2
BLOCKCOUNTDOWN ds 1    ; $E6
LEVELOFFSET    ds 1    ; $E7
MAPSPOT        ds 1    ; $E8
LINECOUNTER    ds 1    ; $E9

Level          ds 2    ; $EA      Current level pointer
LevelEnd       ds 2    ; $EC
lSWCHA         ds 1    ; $EE      for SWCHA debouncing
lSWCHB         ds 1    ; $EF      for SWCHB debouncing

eCOLUPF        ds 1    ; $F0
PLAYERX        ds 1    ; $F1
PLAYERY        ds 1    ; $F2
rPLAYERX       ds 1    ; $F3
DRAWY          ds 1    ; $F4
fGRP0          ds 1    ; $F5
AUDT           ds 1    ; $F6
SHIMMER        ds 1    ; $F7
SHIMMERT       ds 1    ; $F8
MOVECOUNTER    ds 1    ; $F9

; 2 levels of call stack left...
;FA
;FB
;FC
;FD
;FE
;FF

; these availble when not frame processing
        ORG $E0
tmp0           ds 1    ; $E0
tmp1           ds 1    ; $E1
tmp2           ds 1    ; $E2
tmp3           ds 1    ; $E3
tmp4           ds 1    ; $E4
tmp5           ds 1    ; $E5
tmp6           ds 1    ; $E6
tmp7           ds 1    ; $E7
tmp8           ds 1    ; $E8
tmp9           ds 1    ; $E9

