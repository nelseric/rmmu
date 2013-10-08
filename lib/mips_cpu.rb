class MipsCpu

  # I am going to use N64 Calling conventions
  REG_MAP = {
    :zero => 0,
    :at => 1,
    :v0 => 2,
    :v1 => 3,
    :a0 => 4,
    :a1 => 5,
    :a2 => 6,
    :a3 => 7,
    :a4 => 8,
    :a5 => 9,
    :a6 => 10,
    :a7 => 11,
    :t4 => 12,
    :t5 => 13,
    :t6 => 14,
    :t7 => 15,
    :s0 => 16,
    :s1 => 17,
    :s2 => 18,
    :s3 => 19,
    :s4 => 20,
    :s5 => 21,
    :s6 => 22,
    :s7 => 23,
    :t8 => 24,
    :t9 => 25,
    :k0 => 26,
    :k1 => 27,
    :gp => 28,
    :sp => 29,
    :s8 => 30,
    :ra => 31
  }


  def reg(ident)
    if REG_MAP.has_key?(ident)
      REG_MAP[ident]
    elsif ident.is_a? Numeric && ident >= 0 && ident < 32
      ident
    else
      raise ArgumentError.new("Invalid Register")
    end
  end

  def reg_r(ident)
    @register_file[reg(ident)]
  end

  def reg_w(ident, val)
    @register_file[reg(ident)] = val
  end

  def adv_pc
    @pc = @pc + 4
  end

  public
  def initialize
    @register_file = [0]*32
    @hi = 0
    @lo = 0
    @pc = 0
  end


  # $ denotes a register number
  # $d = $s + $t means to
  # set register $d to the value of register $s + the value of register $t
  # C is a constant for immediate instructions

  # $d = $s + $t; PC += 4
  def add(d, s, t)
    reg_w(d, reg_r(s) + reg_r(t))
    adv_pc
  end

  # $d = $s + $t; PC += 4
  def addu(d, s, t)
    add(d, s, t)
  end

  # $d = $s - $t; PC += 4
  def sub(d, s, t)
    reg_w(d, reg_r(s) - reg_r(t))
    adv_pc
  end

  # $d = $s - $t; PC += 4
  def subu(d, s, t)
    sub(d, s, t)
  end

  # $d = $s + C; PC += 4
  def addi(d, s, c)
    reg_w(d, reg_r(s) +c)
    adv_pc
  end

  # $d = $s + C; PC += 4
  def addiu(d, s, c)
    addi(d, s, c)
  end

  # LO = (($s * $t) << 32) >> 32;
  # HI = ($s * $t) >> 32;
  def mult(s, t)
    @lo = ((reg_r(s) * reg_r(t)) << 32) >> 32
    @lo = (reg_r(s) * reg_r(t)) >> 32

    adv_pc
  end

  # LO = (($s * $t) << 32) >> 32;
  # HI = ($s * $t) >> 32;
  def multu(s, t)
    mult(s, t)
  end

  # LO = $s / $t     HI = $s % $t
  def div(s, t)
    @lo = reg_r(s) / reg_r(t)
    @hi = reg_r(s) % reg_r(t)

    adv_pc
  end

  # LO = $s / $t     HI = $s % $t
  def divu(s, t)
    div(s, t)
  end

  # $t = Memory[$s + C]
  def lw(t, s, c)

  end

  # $t = Memory[$s + C] (signed)
  def lh(t, s, c)

  end

  # $t = Memory[$s + C] (unsigned)
  def lhu(t, s, c)

  end

  # $t = Memory[$s + C] (signed)
  def lb(t, s, c)

  end

  # $t = Memory[$s + C] (unsigned)
  def lbu(t, s, c)

  end

  # Memory[$s + C] = $t
  def sw(t, s, c)

  end

  # Memory[$s + C] = $t
  def sh(t, s, c)

  end

  # Memory[$s + C] = $t
  def sb(t, s, c)

  end

  # $t = C << 16
  def lui(t, c)

  end

  # $d = HI
  def mfhi(d)

  end

  # $d = LO
  def mflo(d)

  end


  def and
  end

  def andi

  end

  def or
  end

  def ori

  end

  def xor

  end

  def nor

  end

  def slt

  end

  def slti

  end

  def sll

  end

  def srl

  end

  def sra

  end

  def beq

  end

  def bne

  end

  # PC = PC+4[31:28] . C*4
  def j

  end

  # PC = $s
  def jr

  end

  # $31 = PC + 4; PC = PC+4[31:28] . C*4
  def jal(c)

  end
end