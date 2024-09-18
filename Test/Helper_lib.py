import logging

def read_file_to_list(filename):
    with open(filename, 'r') as file:
        lines = file.readlines()
    return [line.strip() for line in lines]


class RISCVInstruction:

    def __init__(self, instruction):
        # Talimattaki boşlukları kaldır
        #instruction = instruction.replace(" ", "")
        # Hex talimatı 32-bit ikili dizeye dönüştür
        self.binary_instr = format(int(instruction, 16), '032b')
        self.instr = int(instruction, 16)  # Hex talimatını sakla
        
        # R-type
        self.opcode = int(self.binary_instr[25:32], 2)
        self.rd = int(self.binary_instr[20:25], 2)
        self.funct3 = int(self.binary_instr[17:20], 2)
        self.rs1 = int(self.binary_instr[12:17], 2)
        self.rs2 = int(self.binary_instr[7:12], 2)
        self.funct7 = int(self.binary_instr[0:7], 2)

        # I-type
        self.imm_i = self.sign_extend(int(self.binary_instr[0:12], 2), 12)

        # S-type
        self.imm_s = self.sign_extend((int(self.binary_instr[0:7], 2) << 5) | int(self.binary_instr[20:25], 2), 12)

        # B-type
        self.imm_b = self.sign_extend((int(self.binary_instr[0], 2) << 12) | (int(self.binary_instr[24:25], 2) << 11) | (int(self.binary_instr[1:7], 2) << 5) | (int(self.binary_instr[20:24], 2) << 1), 13)

        # U-type
        self.imm_u = int(self.binary_instr[0:20], 2) << 12

        # J-type
        self.imm_j = self.sign_extend((int(self.binary_instr[0], 2) << 20) | (int(self.binary_instr[12:20], 2) << 12) | (int(self.binary_instr[11], 2) << 11) | (int(self.binary_instr[1:11], 2) << 1), 21)

    def sign_extend(self, value, bits):
        sign_bit = 1 << (bits - 1)
        return (value & (sign_bit - 1)) - (value & sign_bit)

    def log(self, logger):
        logger.debug("****** Current Instruction *********")
        logger.debug("Binary string: %s", self.binary_instr)

        # R-type instructions
        if self.opcode == 0x33:  # 0x33 is the hex value for the binary opcode 0110011
            logger.debug("Operation type: R-type")
            logger.debug("funct7: %s", '{0:07b}'.format(self.funct7))
            logger.debug("rs2: %d", self.rs2)
            logger.debug("rs1: %d", self.rs1)
            logger.debug("funct3: %s", '{0:03b}'.format(self.funct3))
            logger.debug("rd: %d", self.rd)

        # I-type instructions
        elif self.opcode == 0x13:  # 0x13 is the hex value for the binary opcode 0010011
            logger.debug("Operation type: I-type")
            logger.debug("Immediate: %d", self.imm_i)
            logger.debug("rs1: %d", self.rs1)
            logger.debug("funct3: %s", '{0:03b}'.format(self.funct3))
            logger.debug("rd: %d", self.rd)

        elif self.opcode == 0x03:  # 0x03 is the hex value for the binary opcode 0000011
            logger.debug("Operation type: Load")
            logger.debug("Immediate: %d", self.imm_i)
            logger.debug("rs1: %d", self.rs1)
            logger.debug("funct3: %s", '{0:03b}'.format(self.funct3))
            logger.debug("rd: %d", self.rd)

        # S-type instructions
        elif self.opcode == 0x23:  # 0x23 is the hex value for the binary opcode 0100011
            logger.debug("Operation type: Store")
            logger.debug("Immediate: %d", self.imm_s)
            logger.debug("rs1: %d", self.rs1)
            logger.debug("funct3: %s", '{0:03b}'.format(self.funct3))
            logger.debug("rs2: %d", self.rs2)

        # B-type instructions
        elif self.opcode == 0x63:  # 0x63 is the hex value for the binary opcode 1100011
            logger.debug("Operation type: Branch")
            logger.debug("Immediate: %d", self.imm_b)
            logger.debug("rs1: %d", self.rs1)
            logger.debug("funct3: %s", '{0:03b}'.format(self.funct3))
            logger.debug("rs2: %d", self.rs2)

        # U-type instructions
        elif self.opcode == 0x37:  # 0x37 is the hex value for the binary opcode 0110111
            logger.debug("Operation type: LUI")
            logger.debug("Immediate: %d", self.imm_u)
            logger.debug("rd: %d", self.rd)

        elif self.opcode == 0x17:  # 0x17 is the hex value for the binary opcode 0010111
            logger.debug("Operation type: AUIPC")
            logger.debug("Immediate: %d", self.imm_u)
            logger.debug("rd: %d", self.rd)

        # J-type instructions
        elif self.opcode == 0x6f:  # 0x6f is the hex value for the binary opcode 1101111
            logger.debug("Operation type: JAL")
            logger.debug("Immediate: %d", self.imm_j)
            logger.debug("rd: %d", self.rd)

        elif self.opcode == 0x67:  # 0x67 is the hex value for the binary opcode 1100111
            logger.debug("Operation type: JALR")
            logger.debug("Immediate: %d", self.imm_i)
            logger.debug("rs1: %d", self.rs1)
            logger.debug("funct3: %s", '{0:03b}'.format(self.funct3))
            logger.debug("rd: %d", self.rd)
            
def rotate_right(value, shift, n_bits=32):
    """
    Rotate `value` to the right by `shift` bits.

    :param value: The integer value to rotate.
    :param shift: The number of bits to rotate by.
    :param n_bits: The bit-width of the integer (default 32 for standard integer).
    :return: The value after rotating to the right.
    """
    shift %= n_bits  # Ensure the shift is within the range of 0 to n_bits-1
    return (value >> shift) | (value << (n_bits - shift)) & ((1 << n_bits) - 1)

def reverse_hex_string_endiannes(hex_string):  
    reversed_string = bytes.fromhex(hex_string)
    reversed_string = reversed_string[::-1]
    reversed_string = reversed_string.hex()        
    return  reversed_string

class ByteAddressableMemory:
    def __init__(self, size):
        self.size = size
        self.memory = bytearray(size)  # Initialize memory as a bytearray of the given size

    def read(self, address):
        if address < 0 or address + 4 > self.size:
            raise ValueError("Invalid memory address or length")
        return_val = bytes(self.memory[address : address + 4])
        return_val = return_val[::-1]
        return return_val

    def write(self, address, data):
        if address < 0 or address + 4> self.size:
            raise ValueError("Invalid memory address or data length")
        data_bytes = data.to_bytes(4, byteorder='little')
        self.memory[address : address + 4] = data_bytes        



def Log_Datapath(dut, logger):
    logger.debug(f"PC: {dut.PC.value}")
    logger.debug(f"Debug_out: {dut.Debug_out.value}")
    logger.debug(f"RegWrite: {dut.RegWrite.value}")
    logger.debug(f"MemWrite: {dut.MemWrite.value}")
    logger.debug(f"ALUSrc: {dut.ALUSrc.value}")
    logger.debug(f"ALUControl: {dut.ALUControl.value}")
    logger.debug(f"PCSrc: {dut.PCSrc.value}")
    logger.debug(f"ResultSrc: {dut.ResultSrc.value}")

def Log_Controller(dut, logger):
    logger.debug(f"instr:%s", hex (dut.instr.value))
    logger.debug(f"zero: {dut.zero.value}")
    logger.debug(f"Neg: {dut.Neg.value}")
    logger.debug(f"NegU: {dut.NegU.value}")
    logger.debug(f"RegWrite: {dut.RegWrite.value}")
    logger.debug(f"MemWrite: {dut.MemWrite.value}")
    logger.debug(f"ALUSrc: {dut.ALUSrc.value}")
    logger.debug(f"ALUControl: {dut.ALUControl.value}")
    logger.debug(f"PCSrc: {dut.PCSrc.value}")
    logger.debug(f"ResultSrc: {dut.ResultSrc.value}")
