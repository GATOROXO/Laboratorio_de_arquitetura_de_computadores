# ==============================================================================
# wave.do - Script COMPLETO com nomes de sinais ajustados (Renomeado)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. LIMPEZA E PREPARAÇÃO
# ------------------------------------------------------------------------------
echo "=== Limpando ambiente anterior ==="
quit -sim
if {[file exists work]} {
    vdel -all -lib work
}
vlib work

# ------------------------------------------------------------------------------
# 2. COMPILAÇÃO DOS ARQUIVOS (MANTIDA A ORDEM ORIGINAL)
# ------------------------------------------------------------------------------
echo "=== Compilando arquivos VHDL ==="
vcom -2008 registerfile.vhd
vcom -2008 mux2.vhd
vcom -2008 rcadder.vhd
vcom -2008 register1.vhd
vcom -2008 signext.vhd
vcom -2008 sl2.vhd
vcom -2008 ula.vhd
vcom -2008 instruction_mem.vhd
vcom -2008 data_mem.vhd
vcom -2008 datapath.vhd
vcom -2008 CompSemUC.vhd
vcom -2008 CompSemUC_tb.vhd
echo "=== Compilação concluída ==="

# ------------------------------------------------------------------------------
# 3. INICIAR SIMULAÇÃO
# ------------------------------------------------------------------------------
echo "=== Iniciando simulação ==="
vsim -voptargs="+acc" work.compsemuc_tb

# ------------------------------------------------------------------------------
# 4. CONFIGURAR JANELA WAVE
# ------------------------------------------------------------------------------
echo "=== Configurando sinais na Wave ==="
quietly delete wave *

# ==============================================================================
# GRUPO: CLOCK E RESET
# ==============================================================================
add wave -noupdate -divider -height 25 "CLOCK E RESET"
add wave -noupdate -color Yellow -label "CLK (Clock)" /compsemuc_tb/clk
add wave -noupdate -color Orange -label "RESET" /compsemuc_tb/reset

# ==============================================================================
# GRUPO: SINAIS DE CONTROLE (UC)
# ==============================================================================
add wave -noupdate -divider -height 25 "SINAIS DE CONTROLE (UC)"
add wave -noupdate -label "UC: RegWrite (Habilita Escrita)" /compsemuc_tb/regwrite
add wave -noupdate -label "UC: MemWrite" /compsemuc_tb/memwrite
add wave -noupdate -label "UC: ALUSrc (0=Reg, 1=Imm)" /compsemuc_tb/alusrc
add wave -noupdate -label "UC: RegDst (0=rt, 1=rd)" /compsemuc_tb/regdst
add wave -noupdate -label "UC: MemtoReg (0=ALU, 1=Mem)" /compsemuc_tb/memtoreg
add wave -noupdate -color Orange -label "UC: Branch Enable" /compsemuc_tb/Branch
add wave -noupdate -label "UC: Jump" /compsemuc_tb/jump
add wave -noupdate -radix binary -label "UC: ALU Control" /compsemuc_tb/alucontrol

# ==============================================================================
# DEBUG BRANCH (BEQ) - NOVO GRUPO
# ==============================================================================
add wave -noupdate -divider -height 30 "DEBUG BRANCH (BEQ) - LOGICA"
add wave -noupdate -color Orange -label "ALU: Zero Flag" /compsemuc_tb/dut/sZero
add wave -noupdate -color Green -label "PCSrc (Branch AND Zero)" /compsemuc_tb/dut/sPCSrc
add wave -noupdate -radix hexadecimal -label "PC Branch Target" /compsemuc_tb/dut/meu_datapath/PCBranch
add wave -noupdate -radix hexadecimal -label "Branch Offset (SignImm << 2)" /compsemuc_tb/dut/meu_datapath/shiftlY

# ==============================================================================
# DEBUG JUMP (J) - NOVO GRUPO
# ==============================================================================
add wave -noupdate -divider -height 30 "DEBUG JUMP (J) - LOGICA"
add wave -noupdate -radix hexadecimal -label "PC Jump Target" /compsemuc_tb/dut/meu_datapath/PCJump
add wave -noupdate -radix hexadecimal -label "PC MUX JUMP (Final Selecao)" /compsemuc_tb/dut/meu_datapath/PCMuxJumpOut

# ==============================================================================
# GRUPO: PC E INSTRUÇÃO
# ==============================================================================
add wave -noupdate -divider -height 25 "PC E INSTRUÇÃO"
add wave -noupdate -radix hexadecimal -label "PC Atual (Endereço)" /compsemuc_tb/dut/sPC_out
add wave -noupdate -radix hexadecimal -label "Instrução Completa (32 bits)" /compsemuc_tb/dut/sInstruct

# ==============================================================================
# GRUPO: REGISTER FILE - ENDEREÇOS E CONTROLE
# ==============================================================================
add wave -noupdate -divider -height 25 "REGISTER FILE - CONTROLE"
add wave -noupdate -radix unsigned -label "RF Endereço 1 (rs)" /compsemuc_tb/dut/meu_datapath/rf_inst/a1
add wave -noupdate -radix unsigned -label "RF Endereço 2 (rt)" /compsemuc_tb/dut/meu_datapath/rf_inst/a2
add wave -noupdate -radix unsigned -label "RF Endereço Escrita (rd/rt)" /compsemuc_tb/dut/meu_datapath/rf_inst/a3
add wave -noupdate -label "RF Write Enable (WE)" /compsemuc_tb/dut/meu_datapath/rf_inst/we
add wave -noupdate -radix decimal -label "RF Write Data (WD3)" /compsemuc_tb/dut/meu_datapath/rf_inst/wd3

# ==============================================================================
# GRUPO: REGISTRADORES $0 a $7 (Conteúdo)
# ==============================================================================
add wave -noupdate -divider -height 25 "REGISTRADORES ($0-$7)"
add wave -noupdate -radix decimal -label "$0 (zero)" /compsemuc_tb/dut/meu_datapath/rf_inst/mem(0)
add wave -noupdate -radix decimal -label "$1" /compsemuc_tb/dut/meu_datapath/rf_inst/mem(1)
add wave -noupdate -radix decimal -label "$2" -color Cyan /compsemuc_tb/dut/meu_datapath/rf_inst/mem(2)
add wave -noupdate -radix decimal -label "$3" -color Cyan /compsemuc_tb/dut/meu_datapath/rf_inst/mem(3)
add wave -noupdate -radix decimal -label "$4" -color Cyan /compsemuc_tb/dut/meu_datapath/rf_inst/mem(4)
add wave -noupdate -radix decimal -label "$5" -color Cyan /compsemuc_tb/dut/meu_datapath/rf_inst/mem(5)
add wave -noupdate -radix decimal -label "$6" /compsemuc_tb/dut/meu_datapath/rf_inst/mem(6)
add wave -noupdate -radix decimal -label "$7" -color Cyan /compsemuc_tb/dut/meu_datapath/rf_inst/mem(7)

# ==============================================================================
# GRUPO: ALU
# ==============================================================================
add wave -noupdate -divider -height 25 "ALU"
add wave -noupdate -radix decimal -label "ALU A (Reg Read Data 1)" /compsemuc_tb/dut/meu_datapath/sRD1
add wave -noupdate -radix decimal -label "ALU B (Mux ALUSrc Out)" /compsemuc_tb/dut/meu_datapath/mux_alu_b_out
add wave -noupdate -radix decimal -label "Sign Extended Imm (16->32)" /compsemuc_tb/dut/meu_datapath/Signimm
add wave -noupdate -radix decimal -label "ALU Result" -color Green /compsemuc_tb/dut/meu_datapath/sALUResult

# ==============================================================================
# GRUPO: MEMÓRIA DE DADOS
# ==============================================================================
add wave -noupdate -divider -height 25 "MEMÓRIA DE DADOS"
add wave -noupdate -radix hexadecimal -label "Mem Address (ALUOut)" /compsemuc_tb/dut/sALUOut
add wave -noupdate -radix decimal -label "Mem Write Data (WD)" /compsemuc_tb/dut/sWD_out
add wave -noupdate -radix decimal -label "Mem Read Data" /compsemuc_tb/dut/sReadData_in
add wave -noupdate -label "MemWrite Enable" /compsemuc_tb/MemWrite

# ==============================================================================
# GRUPO: SINAIS INTERNOS DO DATAPATH (Sobras)
# ==============================================================================
add wave -noupdate -divider -height 25 "DATAPATH INTERNOS (SOBRAS)"
add wave -noupdate -radix decimal -label "sRD2 (Data 2)" /compsemuc_tb/dut/meu_datapath/sRD2
add wave -noupdate -radix decimal -label "sWD3 (Data Escrita Reg)" /compsemuc_tb/dut/meu_datapath/sWD3
add wave -noupdate -radix hexadecimal -label "PC Reg Interno" /compsemuc_tb/dut/meu_datapath/pc_reg
add wave -noupdate -radix hexadecimal -label "PC + 4" /compsemuc_tb/dut/meu_datapath/PCPlus4
add wave -noupdate -label "sPCSrc (Interno DUT)" /compsemuc_tb/dut/sPCSrc

# ------------------------------------------------------------------------------
# 5. CONFIGURAÇÕES DA WAVE
# ------------------------------------------------------------------------------
configure wave -namecolwidth 250
configure wave -valuecolwidth 80
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 10
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns

# Atualiza a wave
update

# ------------------------------------------------------------------------------
# 6. EXECUTAR SIMULAÇÃO
# ------------------------------------------------------------------------------
echo "=== Executando simulação por 150ns ==="
run 150ns
wave zoom full

# ------------------------------------------------------------------------------
# 7. MENSAGENS FINAIS
# ------------------------------------------------------------------------------
echo "=============================================="
echo "Simulação concluída com sucesso!"
echo "=============================================="