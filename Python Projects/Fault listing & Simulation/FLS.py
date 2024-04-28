from itertools import chain
import sys
import random
import matplotlib.pyplot as plt
import numpy as np


def main():

  # part A1
  input_nodes, output_nodes, gates_info = get_bench_info()

  # part A2
  fault_list = part_A2_fault_listing(input_nodes, output_nodes, gates_info)

  # part B1
  part_B1_circ_analysis(input_nodes, output_nodes)

  # part B2
  part_B2_good_cir_simulation(input_nodes, output_nodes, gates_info)

  # part B3
  part_B3_any_one_fault(input_nodes, output_nodes, gates_info, fault_list)

  # part B4
  part_B4_one_tv_one_fault(input_nodes, output_nodes, gates_info, fault_list)

  # part B5
  part_B5_all_faults(input_nodes, output_nodes, gates_info, fault_list)

  # part C
  part_C_fault_coverage(input_nodes, output_nodes, gates_info, fault_list)


def get_bench_info():

  input_nodes = {}
  output_nodes = {}
  gate_nodes = {}
  gates_type = {}
  gates_input = {}

  print('Part A1:')
  file = get_user_file()

  for line in file:

    if line.find('=') > -1:  # gathers info for gates

      name = line[0:line.find('=') - 1]
      gate_type = line[line.index('=') + 2:line.index('(')]
      gate_inputs = line[line.index('(') + 1:line.index(')')].split(', ')

      gate_nodes[name] = -1
      gates_type[name] = gate_type
      gates_input[name] = gate_inputs

    elif line[:5] == 'INPUT' or line[:6] == 'OUTPUT':  # gathers input and output

      name = line[line.find('(') + 1:line.find(')')]

      if line[:5] == 'INPUT':
        input_nodes[name] = -1
      else:
        output_nodes[name] = -1

  file.close()

  return input_nodes, output_nodes, (gate_nodes, gates_type, gates_input)


def part_A2_fault_listing(input_nodes, output_nodes, gates_info):
  gate_nodes = gates_info[0]
  gate_inputs = gates_info[2]

  input_fault_list = []
  output_fault_list = []
  gate_fault_list = []
  stuck_zero, stuck_one = '-0', '-1'

  for key in input_nodes:
    input_fault_list.append(key + stuck_zero)
    input_fault_list.append(key + stuck_one)
  for key in output_nodes:
    output_fault_list.append(key + '-out' + stuck_zero)
    output_fault_list.append(key + '-out' + stuck_one)
  for key in gate_nodes:
    gate_fault = [key + stuck_zero, key + stuck_one]
    for node in gate_inputs[key]:
      gate_fault.append(key + '-' + node + stuck_zero)
      gate_fault.append(key + '-' + node + stuck_one)
    gate_fault_list.append(gate_fault)

  # get total number of faults
  total_faults = len(input_fault_list) + len(output_fault_list)
  for gate_list in gate_fault_list:
    total_faults += len(gate_list)

  # write info into f.txt
  file = open('f.txt', 'w')
  file.write('Input faults:\n')
  file.write('  '.join(input_fault_list))
  file.write('\n\nOutput faults:\n')
  file.write('  '.join(output_fault_list))
  file.write('\n\nGate faults:\n')
  for gate in gate_fault_list:
    file.write('  '.join(gate))
    file.write('\n')
  file.close()

  # print info to console
  file = open('f.txt', 'r')
  print('\n\nPart A2:')
  print('Total # of faults: ', total_faults, end='\n\n')
  print(file.read())

  return input_fault_list + list(chain(*gate_fault_list)) + output_fault_list


def part_B1_circ_analysis(input_nodes, output_nodes):
  print('\nPart B1:')
  print('Expected bits for input:', len(input_nodes))
  print('Expected bits for output:', len(output_nodes))


def part_B2_good_cir_simulation(input_nodes, output_nodes, gates_info):

  print('\n\nPart B2:')
  for value in range(2):

    tv = {key: value for key in input_nodes}

    c_output_nodes = simulator(input_nodes, output_nodes, gates_info, tv,
                               False, '')[1]

    print(f'Outputs from all {value}\'s inputs:', end=' ')
    for item in c_output_nodes.items():
      node, value = item[0], item[1]
      print(f'{node}={value}', end='  ')
    print('')


def part_B3_any_one_fault(input_nodes, output_nodes, gates_info, fault_list):

  print('\n\nPart B3:')
  fault = get_user_fault(fault_list)
  for value in range(2):
    tv = {key: value for key in input_nodes}

    c_inputs, c_outputs, c_gates_info = simulator(input_nodes, output_nodes,
                                                  gates_info, tv, True, fault)

    print(f'\nResult from all-{value} tv with fault {fault}:')

    print('\nInputs:', end=' ')
    for key in c_inputs:
      print(f'{key}={c_inputs[key]}', end='  ')

    print('\nGates:', end=' ')
    for key in c_gates_info[0]:
      print(f'{key}={c_gates_info[0][key]}', end='  ')

    print('\nOutputs:', end=' ')
    for key in c_outputs:
      print(f'{key}={c_outputs[key]}', end='  ')
    print('')


def part_B4_one_tv_one_fault(input_nodes, output_nodes, gates_info,
                             fault_list):

  print('\n\nPart B4:')
  tv = get_user_tv(input_nodes)
  if tv == 's':
    return
  fault = get_user_fault(fault_list)

  c_inputs, c_outputs, c_gates = simulator(input_nodes, output_nodes,
                                           gates_info, tv, True, fault)

  print('\nInputs:', end=' ')
  for key in c_inputs:
    print(f'{key}={c_inputs[key]}', end='  ')

  print('\nGates:', end=' ')
  for key in c_gates[0]:
    print(f'{key}={c_gates[0][key]}', end='  ')

  print('\nOutputs:', end=' ')
  for key in c_outputs:
    print(f'{key}={c_outputs[key]}', end='  ')
  print('')

  outputs_value = [c_outputs[key] for key in c_outputs]
  if all((str(x) in '01') for x in outputs_value):
    print(f"TV can not detect fault {fault}")
  else:
    print(f'TV can detect fault {fault}')


def part_B5_all_faults(input_nodes, output_nodes, gates_info, fault_list):

  print('\n\nPart B5:')
  tv = get_user_tv(input_nodes)
  if tv == 's':
    return
  is_detected_list = []
  print('Loading...')
  for fault in fault_list:

    c_outputs = simulator(input_nodes, output_nodes, gates_info, tv, True,
                          fault)[1]

    is_detected = False
    for key in c_outputs:
      if type(c_outputs[key]) is str:
        is_detected = True
    is_detected_list.append(is_detected)

  count_detected = is_detected_list.count(True)

  print(f'\nFull fault list detection:')
  for idx, fault in enumerate(fault_list):
    detected = 'Detected' if is_detected_list[idx] is True else 'Undetected'
    print(f'{fault:>15}: {detected}')
  print(f'\nTotal detected: {count_detected}')
  print(f'Percentage: {(count_detected/len(fault_list))*100:.1f}%')


def part_C_get_detected(input_nodes, output_nodes, gates_info, fault_list,
                        tv_list):

  is_detected_list = []
  for fault in fault_list:

    c_output_nodes = simulator(input_nodes, output_nodes, gates_info, tv_list,
                               True, fault)[1]

    is_detected = False
    for key in c_output_nodes:
      if type(c_output_nodes[key]) is str:
        is_detected = True
    is_detected_list.append(is_detected)

  return is_detected_list


def part_C_fault_coverage(input_nodes, output_nodes, gates_info, fault_list):

  print('\nPart C:')
  try_part_c = ''
  while try_part_c == '':
    try_part_c = input('Try random TVs fault coverage(y/n): ')
    if try_part_c.lower() == 'y':
      break
    else:
      return

  fault_coverage_list = []
  for steps in range(1, 21):
    step_list = []
    for step in range(steps):
      tv_num = random.randrange(0, 2**len(input_nodes))
      tv_bin = bin(tv_num)[2:].zfill(len(input_nodes))
      tv_list = {key: int(i) for i, key in zip(tv_bin, input_nodes)}

      print(f'Loading... Steps: {steps}/20, at tv # {step + 1}')
      detected_list = part_C_get_detected(input_nodes, output_nodes,
                                          gates_info, fault_list, tv_list)
      step_list.append(detected_list)
    fault_coverage_list.append(step_list)

  total_coverage = [fault_coverage_list[0][0]]
  for idx in range(1, len(fault_coverage_list)):
    total_coverage.append([any(x) for x in zip(*fault_coverage_list[idx])])

  detections_list = []
  for i in range(len(total_coverage)):
    count_detected = total_coverage[i].count(True)
    detections_list.append(count_detected)
    percentage = int((count_detected / len(fault_list)) * 100)
    print(f'\nRandom TVs picked: {i+1}')
    print(f'Total detected: {count_detected}')
    print(f'Percentage: {percentage:.1f}%')

  def add_labels(x, y):
    for i in range(len(x)):
      plt.text(i, y[i], y[i])

  x_axis_tvs = np.array([str(x) for x in range(1, 21)])
  y_axis_detections = np.array(detections_list)
  plt.bar(x_axis_tvs, y_axis_detections, color='#4CAF50')
  add_labels(x_axis_tvs, y_axis_detections)
  plt.xlabel('# of random TVs')
  plt.ylabel('# of detections')
  plt.show()


def simulator(input_nodes, output_nodes, gates_info, tv, is_fault, fault):
  c_input_nodes = input_nodes.copy()
  c_output_nodes = output_nodes.copy()
  c_gate_nodes = gates_info[0].copy()
  c_gates_type = gates_info[1].copy()
  c_gates_input = gates_info[2].copy()

  def get_gate_input_values(kei):
    dump_list = []
    for node in c_gates_input[kei]:
      if node in c_gate_nodes:
        dump_list.append(c_gate_nodes[node])
      else:
        dump_list.append(c_input_nodes[node])
    return dump_list

  fault_node = ''
  fault_value = ''

  if is_fault:
    if fault.count('-') > 1 and fault[fault.find('-') +
                                      1:fault.rfind('-')] != 'out':
      fault_node = fault[fault.find('-') + 1:fault.rfind('-')]
    else:
      fault_node = fault[:fault.find('-')]
    fault_value = 'D' if fault[-1] == '0' else "D'"

  def check_fault(kei, node_type):
    if fault_value == 'D' and node_type[kei] == 1 or \
            fault_value == "D'" and node_type[kei] == 0:
      node_type[kei] = fault_value

  for key in c_input_nodes:
    c_input_nodes[key] = tv[key]
    if fault_node == key:
      check_fault(key, c_input_nodes)

  change = True
  while change:
    change = False

    for key in c_gate_nodes:

      inputs_value = get_gate_input_values(key)
      if inputs_value.count(-1) > 0 or c_gate_nodes[key] != -1:
        continue

      change = True
      c_gate_nodes[key] = gate_output(c_gates_type[key], inputs_value)

      if fault_node == key:
        check_fault(key, c_gate_nodes)

  for key in c_output_nodes:
    if key in c_input_nodes:
      c_output_nodes[key] = c_input_nodes[key]
    else:
      c_output_nodes[key] = c_gate_nodes[key]

  return c_input_nodes, c_output_nodes, (c_gate_nodes, c_gates_type,
                                         c_gate_nodes)


def gate_output(node_type, inputs):

  def not_fault_value(name):
    if name == 'D':
      return "D'"
    else:
      return 'D'

  is_fault = any(type(n) == str for n in inputs)
  output_value = None
  fault = None

  if is_fault:
    if inputs.count('D') > 0:
      fault = 'D'
    if inputs.count("D'") > 0 and fault is None:
      fault = "D'"
    if inputs.count('D') > 0 and fault == "D'":
      if node_type == 'AND' or node_type == 'NOR':
        return 0
      else:
        return 1
    inputs = [num for num in inputs if type(num) is int]

  if node_type == 'AND':
    if all(inputs):
      output_value = 1 if not is_fault else fault
    else:
      output_value = 0
  elif node_type == 'NAND':
    if all(inputs):
      output_value = 0 if not is_fault else not_fault_value(fault)
    else:
      output_value = 1
  elif node_type == 'OR':
    if any(inputs):
      output_value = 1
    else:
      output_value = 0 if not is_fault else fault
  elif node_type == 'NOR':
    if any(inputs):
      output_value = 0
    else:
      output_value = 1 if not is_fault else not_fault_value(fault)
  elif node_type == 'NOT':
    if is_fault:
      output_value = not_fault_value(fault)
    elif any(inputs) == 1:
      output_value = 0
    else:
      output_value = 1
  elif node_type == 'BUFF':
    if is_fault:
      output_value = fault
    elif any(inputs) == 1:
      output_value = 1
    else:
      output_value = 0

  return output_value


def get_user_file():
  print('default file (HW1 bench file): c.bench')
  file_name = input("Enter circuit bench file: ")
  try:
    file = open(file_name, 'r')
  except OSError:
    print('File does not exist, try again')
    sys.exit()
  return file


def get_user_tv(input_nodes):
  tv = ''
  inputs_name = [key for key in input_nodes]
  quick_inputs = '\n(quick inputs: a1= all Ones TV, a0= all Zeros TV, r= Random Generated TV)'
  while tv == '':
    tv = input(
        f'Enter a TV of size {len(input_nodes)} {quick_inputs} (skip part = s): '
    )
    if tv.lower() == 'a1':
      tv = [1 for _ in input_nodes]
    elif tv.lower() == 'a0':
      tv = [0 for _ in input_nodes]
    elif tv.lower() == 'r':
      tv = [random.randrange(0, 2) for _ in input_nodes]
    elif tv.lower() == 's':
      return 's'
    elif not all((x in '01') for x in tv) or len(tv) != len(input_nodes):
      tv = ''
      print('Invalid TV try again')
  return {inputs_name[idx]: int(tv[idx]) for idx in range(len(input_nodes))}


def get_user_fault(fault_list):
  fault = None
  while fault is None:
    fault = input('Enter a fault from list above: ')
    if fault not in fault_list:
      fault = None
      print('Invalid fault try again')
  return fault


main()

