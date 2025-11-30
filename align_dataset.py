import os

def align_dataset(input_dir, output_dir):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"Created directory: {output_dir}")

    files = [f for f in os.listdir(input_dir) if f.endswith('.csv')]
    total_files = len(files)
    print(f"Found {total_files} CSV files to process.")

    for i, filename in enumerate(files):
        input_filepath = os.path.join(input_dir, filename)
        output_filepath = os.path.join(output_dir, filename)
        
        print(f"[{i+1}/{total_files}] Processing {filename}...")
        
        header_lines = []
        accel_data = {} # Sample No -> {'t': timestamp, 'x': x, 'y': y, 'z': z}
        gyro_data = {}  # Sample No -> {'t': timestamp, 'x': x, 'y': y, 'z': z}

        try:
            with open(input_filepath, 'r') as f:
                for line in f:
                    if line.startswith('%'):
                        header_lines.append(line)
                        continue
                    
                    parts = line.strip().split(';')
                    if len(parts) < 6:
                        continue
                    
                    try:
                        timestamp = parts[0]
                        sample_no = int(parts[1])
                        x = parts[2]
                        y = parts[3]
                        z = parts[4]
                        sensor_type = parts[5].strip()

                        data_point = {'t': timestamp, 'x': x, 'y': y, 'z': z}

                        if sensor_type == '0': # Accelerometer
                            accel_data[sample_no] = data_point
                        elif sensor_type == '1': # Gyroscope
                            gyro_data[sample_no] = data_point
                    except ValueError:
                        continue
            
            # Find common samples
            common_samples = sorted(list(set(accel_data.keys()) & set(gyro_data.keys())))
            
            if not common_samples:
                print(f"Skipping {filename}: No aligned data found.")
                continue

            with open(output_filepath, 'w') as f:
                # Write original header
                for line in header_lines:
                    # Update column description if it exists
                    if "TimeStamp; Sample No;" in line:
                         f.write("% TimeStamp; Sample No; Accel-X; Accel-Y; Accel-Z; Gyro-X; Gyro-Y; Gyro-Z\n")
                    else:
                        f.write(line)
                
                # Write aligned data
                for sample_no in common_samples:
                    accel = accel_data[sample_no]
                    gyro = gyro_data[sample_no]
                    # Using Accelerometer timestamp as the primary timestamp
                    line = f"{accel['t']};{sample_no};{accel['x']};{accel['y']};{accel['z']};{gyro['x']};{gyro['y']};{gyro['z']}\n"
                    f.write(line)
                    
        except Exception as e:
            print(f"Error processing {filename}: {e}")

    print("Alignment complete.")

if __name__ == '__main__':
    input_directory = r'd:\MAC-LRN\MAC-LRN_FallDetection\UMAFall_Dataset_Filtered'
    output_directory = r'd:\MAC-LRN\MAC-LRN_FallDetection\UMAFall_Dataset_Aligned'
    align_dataset(input_directory, output_directory)
