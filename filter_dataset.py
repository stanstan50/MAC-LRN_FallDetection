import os
import csv

def filter_file(input_path, output_path):
    with open(input_path, 'r') as f_in:
        lines = f_in.readlines()

    header_lines = []
    data_lines = []
    right_pocket_id = None

    # Parse header to find RIGHTPOCKET ID
    for line in lines:
        if line.startswith('%'):
            header_lines.append(line)
            if 'WAIST' in line:
                # Example: %C4:BE:84:71:A5:02; 2; WAIST; SensorTag
                parts = line.split(';')
                if len(parts) >= 2:
                    try:
                        waist_id = parts[1].strip()
                    except IndexError:
                        pass
        else:
            data_lines.append(line)

    if waist_id is None:
        print(f"Skipping {input_path}: WAIST not found in header.")
        return

    filtered_data = []
    for line in data_lines:
        parts = line.strip().split(';')
        if len(parts) >= 7:
            sensor_type = parts[5].strip()
            sensor_id = parts[6].strip()
            
            # Filter for WAIST (Sensor ID) and Accel(0)/Gyro(1) (Sensor Type)
            if sensor_id == waist_id and sensor_type in ['0', '1']:
                filtered_data.append(line)

    if filtered_data:
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with open(output_path, 'w') as f_out:
            f_out.writelines(header_lines)
            f_out.writelines(filtered_data)
        print(f"Processed {input_path} -> {output_path}")
    else:
        print(f"Skipping {input_path}: No matching data found.")

def main():
    input_dir = r'd:\MAC-LRN\MAC-LRN_FallDetection\UMAFall_Dataset'
    output_dir = r'd:\MAC-LRN\MAC-LRN_FallDetection\UMAFall_Dataset_Filtered'

    if not os.path.exists(input_dir):
        print(f"Input directory not found: {input_dir}")
        return

    for filename in os.listdir(input_dir):
        if filename.endswith('.csv'):
            input_path = os.path.join(input_dir, filename)
            output_path = os.path.join(output_dir, filename)
            filter_file(input_path, output_path)

if __name__ == '__main__':
    main()
