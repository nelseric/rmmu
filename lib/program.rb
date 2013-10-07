class Program
  def initialze(source)

  end

  def data

  end

  def text

  end
end

module MipsISA
  # $ denotes a register number
  # $d = $s + $t means to
  # set register $d to the value of register $s + the value of register $t
  # C is a constant for immediate instructions


  # $d = $s + $t; PC += 4
  def add(d, s, t)

  end

  # $d = $s + $t; PC += 4
  def addu(d, s, t)

  end

  # $d = $s - $t; PC += 4
  def sub(d, s, t)

  end

  # $d = $s - $t; PC += 4
  def subu(d, s, t)

  end

  # $d = $s + C; PC += 4
  def addi(d, s, c)

  end

  # $d = $s + C; PC += 4
  def addiu(d, s, c)

  end

  # LO = (($s * $t) << 32) >> 32;
  # HI = ($s * $t) >> 32;
  def mult(s, t)

  end

  # LO = (($s * $t) << 32) >> 32;
  # HI = ($s * $t) >> 32;
  def multu(s, t)

  end

  # LO = $s / $t     HI = $s % $t
  def div(s, t)

  end

  # LO = $s / $t     HI = $s % $t
  def divu(s, t)

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