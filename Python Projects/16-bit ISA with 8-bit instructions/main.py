f = open('machineCode.asm')
lines = f.readlines()
f.close()

addr = [] # holds all the addresses 
MC_dict = {} # code by address

# Remove '\n' and arrange addr with their appropriate code
for i in range(len(lines)):
  lines[i] = lines[i].replace('\n', '')
  addr.append(i)
  MC_dict[addr[i]] = lines[i]

reg_list = [] 
for x in range(0, 8):
  reg_list.append(0)

data_mem = {} # data by addr from 8192 - 8704
for x in range(0, 65):
  data_mem[x] = 'null'
PC = 0 
ASM = '0'
instrC = 0
bpc = 0

def operations():
  global PC, ASM, instrC, bpc
  
  codeB = bin(int(MC_dict[PC], 16))[2:].zfill(8) # code in binary
  op = str(int(codeB[:3], 2)) # op of code in hex
  func = '0'
  if op == '0': func = str(int(codeB[6:], 2))
  
  # Components 
  rx = int(codeB[3:6], 2)
  ry = int(codeB[6:], 2)
  if op == '3': jump = int(codeB[3:], 2)

  # imm
  imm = 0
  if ry == 0: imm = 0
  elif ry == 1: imm = 1
  elif ry == 2: imm = -1
  else: imm = 31
    
  PC += 1
  instrC += 1
  
  # Instructions
  if op == '0':
    if func == '0': # xone
      if reg_list[rx] < 0: reg_list[rx] = -(reg_list[rx] - 1)
      else: reg_list[rx] = -(reg_list[rx] + 1)
      ASM = 'xone $'+ str(rx)
      
    else: # par
      num = int(reg_list[rx])
      if num < 0: num = 2**16 + num # neg to pos
      num = bin(num).count('1')
      if (num % 2)  == 0 : par = 0
      else: par = 1
      reg_list[7] = par
      ASM = 'par $'+ str(rx)
   
  elif op == '1': # sw
    data_mem[reg_list[ry]] = reg_list[rx]
    ASM = 'sw $' + str(rx) + ', $' + str(ry)
    
  elif op == '2': # lw
    reg_list[rx] = data_mem[reg_list[ry]]
    ASM = 'lw $' + str(rx) + ', $' + str(ry)
    
  elif op == '3': # bneR6
    bpc = PC
    if reg_list[6] != 1: PC = PC - jump
    ASM = 'bneR6 ' + str(jump)

  elif op == '6': # addi
    reg_list[rx] = reg_list[rx] + imm
    ASM = 'addi $' + str(rx) + ', ' + str(imm)
    
  else: # sltR6
    if reg_list[rx] < ry: reg_list[6] = 1
    else: reg_list[6] = 0
    ASM = 'sltR6 $' + str(rx) + ', ' + str(imm)

loopC = True
def output(): # output
  print('{:<21} {}'.format('Basic:', 'Code:'))
  if ASM[:5] == 'bneR6': print(f'{ASM:<21} 0x{MC_dict[bpc-1]}\n')
  else: print(f'{ASM:<21} 0x{MC_dict[PC-1]}\n')

  print(f'Instruction Count: {instrC}')
  print(f'PC = {PC}\n')
  
  print('Register   Value')
  for x in range(0, 8):
    print(f'{x:>2}:{reg_list[x]:>13}')
  print('')
  
  print('Memory:')
  for x in range(0, 64, 3):
    y = hex(x)[2:].zfill(2)
    y1 = hex(x+1)[2:].zfill(2)
    y2 = hex(x+2)[2:].zfill(2)
    if x == 63:
      print(f'M[0x{y}] = {data_mem[x]:>4}\n')
    else:
      print(f'M[0x{y}] = {data_mem[x]:>4} |', end=' ')
      print(f'M[0x{y1}] = {data_mem[x+1]:>4} |', end=' ')
      print(f'M[0x{y2}] = {data_mem[x+2]:>4}')

notDone = True
while(notDone):
  i = input('Press any key to execute next instruction: ')
  print('')
  
  #print(PC)
  if PC > addr[-1]: 
    notDone = False
    print('End of Code')
    print('')
    break
  if loopC == True:
    loopC = False
    for loop in range(1): operations() # range 451 for last instruction
  else: operations()
  output()
