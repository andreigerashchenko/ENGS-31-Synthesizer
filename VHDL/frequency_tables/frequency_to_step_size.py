sample_rate = 48000
step_bits = 14
input_file_path = "raw_frequencies_expanded.txt"
output_file_path = "step_sizes.coe"
started = False

with open(input_file_path, "r") as input_file:
    with open(output_file_path, "w") as output_file:
        output_file.write("MEMORY_INITIALIZATION_RADIX=16;\n")
        output_file.write("MEMORY_INITIALIZATION_VECTOR=\n")

        current_line = input_file.readline()

        while current_line is not "":
            if started:
                output_file.write(",\n")
            else:
                started = True
            frequency = float(current_line.rstrip())
            step_size = '{:03x}'.format(round(frequency/(sample_rate/(2**step_bits))))
            output_file.write(str(step_size))
            current_line = input_file.readline()
        output_file.write(";")
    output_file.close()
input_file.close()

print("Generated .coe: "+output_file_path)