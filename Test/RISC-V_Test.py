import logging
import cocotb
from Helper_lib import read_file_to_list,RISCVInstruction, ByteAddressableMemory, reverse_hex_string_endiannes, Log_Datapath, Log_Controller
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Edge, Timer
from cocotb.binary import BinaryValue

class TB:
    def __init__(self, Instruction_list,dut,dut_PC,dut_regfile):
        self.dut = dut
        self.dut_PC = dut_PC
        self.dut_regfile = dut_regfile
        self.Instruction_list = Instruction_list
        #Configure the logger
        self.logger = logging.getLogger("Performance Model")
        self.logger.setLevel(logging.DEBUG)
        #Initial values are all 0 as in a FPGA
        self.PC = 0
        self.zero = 0
        self.Register_File =[]
        for i in range(32):
            self.Register_File.append(0)
        #Memory is a special class helper lib to simulate HDL counterpart    
        self.Memory = ByteAddressableMemory(1024)

        self.clock_cycle_count = 0        


    def log_dut(self):
        Log_Datapath(self.dut, self.logger)
        Log_Controller(self.dut, self.logger)

    # RISC-V mimarisi için performans modeli ve DUT verilerini karşılaştırır ve günlükler
    def compare_result(self):
        self.logger.debug("************* Performance Model / DUT Data  **************")
        self.logger.debug("PC:%d \t PC:%d", self.PC, self.dut.PC.value.integer)
        for i in range(32):
            
            self.logger.debug("Register%d: %d \t %d",i,self.Register_File[i], self.dut_regfile.Reg_Out[i].value.integer)
            assert self.Register_File[i] == self.dut_regfile.Reg_Out[i].value
        assert self.PC == self.dut.PC.value.integer


    def write_to_register_file(self, register_no, data):
        
        if register_no == 0:
            self.Register_File[register_no] = 0  # x0 is hardwired to zero
        else:
            self.Register_File[register_no] = data

    def performance_model(self):
        self.logger.debug("**************** Clock cycle: %d **********************", self.clock_cycle_count)
        self.clock_cycle_count += 1
        # Read current instructions, extract and log the fields
        self.logger.debug("**************** Instruction No: %d **********************", int(self.PC // 4))
        current_instruction = self.Instruction_list[int((self.PC)/4)]
        current_instruction = current_instruction.replace(" ", "")
        current_instruction = reverse_hex_string_endiannes(current_instruction)
        
        riscv_instr = RISCVInstruction(current_instruction)
        riscv_instr.log(self.logger)

        opcode = riscv_instr.opcode
        rd = riscv_instr.rd
        rs1 = riscv_instr.rs1
        rs2 = riscv_instr.rs2
        funct3 = riscv_instr.funct3
        funct7 = riscv_instr.funct7
        imm_i = riscv_instr.imm_i
        imm_s = riscv_instr.imm_s
        imm_b = riscv_instr.imm_b
        imm_u = riscv_instr.imm_u
        imm_j = riscv_instr.imm_j

        if ((opcode != 0x67) & (opcode != 0x17) & (opcode != 0x6F) & (opcode != 0x63)):
            self.PC += 4

        # Embedded constant for XORID
        xorid_constant = 2232700 ^ 2110047

        if opcode == 0x33:  # R-type
            if funct3 == 0x0:
                if funct7 == 0x00:  # ADD
                    self.Register_File[rd] = self.Register_File[rs1] + self.Register_File[rs2]
                elif funct7 == 0x20:  # SUB
                    self.Register_File[rd] = self.Register_File[rs1] - self.Register_File[rs2]
            elif funct3 == 0x1:  # SLL
                self.Register_File[rd] = self.Register_File[rs1] << (self.Register_File[rs2] & 0x1F)
            elif funct3 == 0x2:  # SLT
                self.Register_File[rd] = 1 if self.Register_File[rs1] < self.Register_File[rs2] else 0
            elif funct3 == 0x3:  # SLTU
                self.Register_File[rd] = 1 if (self.Register_File[rs1] & 0xFFFFFFFF) < (self.Register_File[rs2] & 0xFFFFFFFF) else 0
            elif funct3 == 0x4:  # XOR
                self.Register_File[rd] = self.Register_File[rs1] ^ self.Register_File[rs2]
            elif funct3 == 0x5:
                if funct7 == 0x00:  # SRL
                    self.Register_File[rd] = (self.Register_File[rs1] & 0xFFFFFFFF) >> (self.Register_File[rs2] & 0x1F)
                elif funct7 == 0x20:  # SRA
                    self.Register_File[rd] = self.Register_File[rs1] >> (self.Register_File[rs2] & 0x1F)
            elif funct3 == 0x6:  # OR
                self.Register_File[rd] = self.Register_File[rs1] | self.Register_File[rs2]
            elif funct3 == 0x7:  # AND
                self.Register_File[rd] = self.Register_File[rs1] & self.Register_File[rs2]

        elif opcode == 0x13:  # I-type
            if funct3 == 0x0:  # ADDI
                self.Register_File[rd] = self.Register_File[rs1] + imm_i
            elif funct3 == 0x1:  # SLLI
                self.Register_File[rd] = self.Register_File[rs1] << (imm_i & 0x1F)
            elif funct3 == 0x2:  # SLTI
                self.Register_File[rd] = 1 if self.Register_File[rs1] < imm_i else 0
            elif funct3 == 0x3:  # SLTIU
                self.Register_File[rd] = 1 if (self.Register_File[rs1] & 0xFFFFFFFF) < (imm_i & 0xFFFFFFFF) else 0
            elif funct3 == 0x4:  # XORI
                self.Register_File[rd] = self.Register_File[rs1] ^ imm_i
            elif funct3 == 0x5:
                if funct7 == 0x00:  # SRLI
                    self.Register_File[rd] = (self.Register_File[rs1] & 0xFFFFFFFF) >> (imm_i & 0x1F)
                elif funct7 == 0x20:  # SRAI
                    self.Register_File[rd] = self.Register_File[rs1] >> (imm_i & 0x1F)
            elif funct3 == 0x6:  # ORI
                self.Register_File[rd] = self.Register_File[rs1] | imm_i
            elif funct3 == 0x7:  # ANDI
                self.Register_File[rd] = self.Register_File[rs1] & imm_i
        elif opcode == 0x0B:  # Custom opcode for XORID
            if funct3 == 0x4:  # XORID
                self.Register_File[rd] = self.Register_File[rs1] ^ xorid_constant

        elif opcode == 0x3:  # Load instructions
            address = self.Register_File[rs1] + imm_i
            if funct3 == 0x0:  # LB
                self.Register_File[rd] = int.from_bytes(self.Memory.read(address)[1:], signed=True)
            elif funct3 == 0x1:  # LH
                self.Register_File[rd] = int.from_bytes(self.Memory.read(address)[2:], signed=True)
            elif funct3 == 0x2:  # LW
                self.Register_File[rd] = int.from_bytes(self.Memory.read(address), signed=True)
            elif funct3 == 0x4:  # LBU
                self.Register_File[rd] = int.from_bytes(self.Memory.read(address)[1:], signed=False)
            elif funct3 == 0x5:  # LHU
                self.Register_File[rd] = int.from_bytes(self.Memory.read(address)[2:], signed=False)

        elif opcode == 0x23:  # S-type
            address = self.Register_File[rs1] + imm_s
            if funct3 == 0x0:  # SB
                self.Memory.write(address, self.Register_File[rs2] & 0x000000FF)
            elif funct3 == 0x1:  # SH
                self.Memory.write(address, self.Register_File[rs2] & 0x0000FFFF)
            elif funct3 == 0x2:  # SW
                self.Memory.write(address, self.Register_File[rs2] & 0xFFFFFFFF)

        elif opcode == 0x63:  # B-type
            if funct3 == 0x0:  # BEQ
                if self.Register_File[rs1] == self.Register_File[rs2]:
                    self.PC += imm_b
            elif funct3 == 0x1:  # BNE
                if self.Register_File[rs1] != self.Register_File[rs2]:
                    self.PC += imm_b
            elif funct3 == 0x4:  # BLT
                if self.Register_File[rs1] < self.Register_File[rs2]:
                    self.PC += imm_b 
            elif funct3 == 0x5:  # BGE
                if self.Register_File[rs1] >= self.Register_File[rs2]:
                    self.PC += imm_b
            elif funct3 == 0x6:  # BLTU
                if (self.Register_File[rs1] & 0xFFFFFFFF) < (self.Register_File[rs2] & 0xFFFFFFFF):
                    self.PC += imm_b
            elif funct3 == 0x7:  # BGEU
                if (self.Register_File[rs1] & 0xFFFFFFFF) >= (self.Register_File[rs2] & 0xFFFFFFFF):
                    self.PC += imm_b 

        elif opcode == 0x6F:  # J-type
            self.Register_File[rd] = self.PC + 4
            self.PC = imm_j 

        elif opcode == 0x67:  # I-type for JALR
            self.Register_File[rd] = self.PC + 4
            self.PC = (self.Register_File[rs1] + imm_i) & ~1

        elif opcode == 0x37:  # U-type LUI
            self.Register_File[rd] = imm_u

        elif opcode == 0x17:  # U-type AUIPC
            self.Register_File[rd] = self.PC + 4
            self.PC = self.PC + imm_u


        # Ensure x0 is always 0
        self.Register_File[0] = 0

        return True

    async def run_test(self):
        self.performance_model()
        #Wait 1 us the very first time bc. initially all signals are "X"
        await Timer(1, units="us")
        self.log_dut()
        await RisingEdge(self.dut.clk)
        await FallingEdge(self.dut.clk)
        self.compare_result()
        while(int(self.Instruction_list[int((self.PC)/4)].replace(" ", ""),16)!=0):
            self.performance_model()
            #Log datapath and controller before clock edge, this calls user filled functions
            self.log_dut()
            await RisingEdge(self.dut.clk)
            await FallingEdge(self.dut.clk)
            self.compare_result()

@cocotb.test()
async def Single_cycle_test(dut):
    #Generate the clock
    await cocotb.start(Clock(dut.clk, 10, 'us').start(start_high=False))
    #Reset onces before continuing with the tests
    dut.reset.value=1
    await RisingEdge(dut.clk)
    dut.reset.value=0
    await FallingEdge(dut.clk)
    instruction_lines = read_file_to_list('Instructions.hex')
    #Give PC signal handle and Register File MODULE handle
    tb = TB(instruction_lines,dut, dut.PC, dut.my_datapath.reg_file_dp)
    await tb.run_test()
