f = open('machineCode.asm')
lines = f.readlines()
f.close()

addr = [] # holds all the addresses 
MC_dict = {} # code by address

# Remove '\n' and arrange addr with their appropriate code
for i in range(len(lines)):
  lines[i] = lines[i].replace('\n', '')
  addr.append(i*4)
  MC_dict[addr[i]] = lines[i]


reg_list = [] 
for x in range(0, 32):
  reg_list.append(0)

data_mem = {} # data by addr from 8192 - 8704
for x in range(8192, 8708, 4):
  data_mem[x] = 'null'
PC = 0 
mult = 0 # for mult and mflo instr

# Counters
instrC = 0
ALUC = 0
BranchC = 0
MemoryC = 0
OtherC = 0


# Operations 
def operations():
  global PC, mult, components, ASM, prevnum
  global instrC, ALUC, BranchC, MemoryC, OtherC
  
  while PC < addr[-1] + 4:
    codeB = bin(int(MC_dict[PC], 16))[2:].zfill(32) # code in binary
    op = hex(int(codeB[:6], 2))[2:] # op of code in hex
    func = '0'
    if op == '0': func = hex(int(codeB[26:], 2))[2:]
      
    # Universal Components 
    rs = int(codeB[6:11], 2)
    rt = int(codeB[11:16], 2)
    components = []
    components.append(rs)
    components.append(rt)
    
    if op == '0': # R-type components
      rd = int(codeB[16:21], 2)
      sh = int(codeB[21:26], 2)
      components.append(rd)
      components.append(sh)
    else: # I-type components 
      if codeB[16] == '1': imm = -(2**16 - int(codeB[16:], 2))
      else: imm = int(codeB[16:], 2)
      components.append(imm)

    PC += 4
    prevnum = int(reg_list[rs])
    # I-type
    if op == '8': # addi
      ALUC += 1
      reg_list[rt] = reg_list[rs] + imm
      ASM = 'addi $' + str(rt) + ', $' + str(rs) + ', ' + str(imm)
      
    elif op == '2b': # sw
      MemoryC += 1
      data_mem[reg_list[rs] + imm] = reg_list[rt]
      ASM = 'sw $'+str(rt)+', ' + str(imm) + '($' + str(rs) + ')'
      
    elif op == '4': # beq
      BranchC += 1
      if reg_list[rt] == reg_list[rs]: PC += imm*4
      ASM = 'beq $' + str(rs) + ', $' + str(rt) + ', ' + str(imm)
      
    elif op == 'c': # andi
      ALUC += 1
      reg_list[rt] = int(reg_list[rs]) & imm
      ASM = 'andi $' + str(rt) + ', $' + str(rs) + ', ' + str(imm)
      
    elif op == '5': # bne
      BranchC += 1
      if reg_list[rt] != reg_list[rs]: PC += imm*4
      ASM = 'bne $' + str(rt) + ', $' + str(rs) + ', '+str(imm)
      
    elif op == '23': # lw
      MemoryC += 1
      reg_list[rt] = data_mem[reg_list[rs] + imm]
      ASM = 'lw $' + str(rt) + ', ' + str(imm) + '($'+str(rs)+')'
      
    # R-type
    elif op == '0' and func == '18': # mult
      ALUC += 1
      mult = int(reg_list[rs]) * int(reg_list[rt])
      ASM = 'mult $' + str(rs) + ', $' + str(rt)
      
    elif op == '0' and func == '12': # mflo
      ALUC += 1
      reg_list[rd] = mult
      ASM = 'mflo $' + str(rd)
      
    elif op == '0' and func == '20': # add
      ALUC += 1
      reg_list[rd] = reg_list[rs] + reg_list[rt]
      ASM = 'add $' + str(rd) + ', $'+ str(rs) + ', $'+str(rt)
      
    elif op == '0' and func == '2': #srl
      ALUC += 1
      reg_list[rd] = reg_list[rt] >> sh
      ASM = 'srl $'+ str(rd) + ', $'+str(rt) + ', ' + str(sh)

    elif op == '0' and func == '2a': #slt
      ALUC += 1
      if reg_list[rs] < reg_list[rt]: reg_list[rd] = '1'
      else: reg_list[rd] = '0'
      ASM = 'slt $'+ str(rd) + ', $'+str(rs) + ', $'+ str(rt)

    # Special Instruction
    else: # par
      OtherC += 1
      num = int(reg_list[rs])
      if num < 0: num = 2**16 + num # neg to pos
      num = bin(num).count('1')
      if (num % 2)  == 0 : par = 0
      else: par = 1
      reg_list[rt] = par
      ASM = 'par $'+str(rt) + ' $'+str(rs)
      

    instrC += 1
    if stepMode == True: break
  return ASM, components, prevnum
  
#Output for step function
def sOutput(ASM, PC, components, prevnum):

  #print MC and ASMC
  print('{:<21} {}'.format('Basic:', 'Code:'))
  print(f'{ASM:<18}    0x{MC_dict[PC-4]}')
  print('')

  # print componets
  print('Components:')
  if len(components) > 3:
    print(f'rd = ${components[2]} = {reg_list[int(components[2])]}')
    print(f'rs = ${components[0]} = {prevnum}')
    print(f'rt = ${components[1]} = {reg_list[int(components[1])]}')
    print(f'sh = {components[3]}')
  else: 
    print(f'rs = ${components[0]} = {prevnum}')
    print(f'rt = ${components[1]} = {reg_list[int(components[1])]}')
    print(f'imm = {components[2]}')
  print('')

  # print updated registers
  if ASM[:3] != 'beq' and ASM[:3] != 'bne' and ASM[:2] != 'sw' and     ASM[:2] != 'lw' and ASM[:4] != 'mult':
    print('Updated Registers:')
    print(f'${components[1]} = {reg_list[int(components[1])]}')
    print('') 
  
  #Print PC
  print(f'PC = {PC}')
  print('\n')            




# Output of entire program
def nOutput():
  print('Register   Value')
  for x in range(6, 13):
    print(f'{x:>2}:{reg_list[x]:>13}')
  print(f'PC: {PC:>12}')
  print('\n')
  print('Memory:')
  for x in range(8192, 8708, 12):
    print(f'M[{hex(x)}] = {data_mem[x]:>4} |', end=' ')
    print(f'M[{hex(x+4)}] = {data_mem[x+4]:>4} |', end=' ')
    print(f'M[{hex(x+8)}] = {data_mem[x+8]:>4}')

  print('\n')
  print('Instruction Statistics:')
  print(f'Total: {instrC}')
  print(f'ALU: {ALUC}')
  print(f'Jump: 0')
  print(f'Branch: {BranchC}')
  print(f'Memory: {MemoryC}')
  print(f'Other: {OtherC}')

stepMode = True
while(stepMode):

  i = input('Press s to run a step or n to run the program: ')
  print('')

  if PC > addr[-1]: 
    print('End of Step Mode')
    print('printing Nonstop Mode...')
    print('')
    stepMode = False
  
  if i == 'n': stepMode = False

  ASM, components, prevnum = operations()

  if stepMode == False: 
    # print function run entire program
    # registers used, data memory, instr count, ALU count,
    # Jump count, Branch count, Memory count, other count
    nOutput()
  else:
    # print function run step function
    # assembly code, machine code, (rs, rt, imm, etc) 
    # updated register or memory locaation, updated PC
    sOutput(ASM, PC, components, prevnum)
