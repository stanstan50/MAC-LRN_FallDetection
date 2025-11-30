import os

def check_gyro_original(input_dir):
    gyro_count = 0
    files_with_gyro = 0
    
    if not os.path.exists(input_dir):
        print(f"Directory not found: {input_dir}")
        return

    for filename in os.listdir(input_dir):
        if filename.endswith('.csv'):
            filepath = os.path.join(input_dir, filename)
            right_pocket_id = None
            has_gyro = False
            
            with open(filepath, 'r') as f:
                lines = f.readlines()
                
            # Find RIGHTPOCKET ID
            for line in lines:
                if line.startswith('%') and 'RIGHTPOCKET' in line:
                    parts = line.split(';')
                    if len(parts) >= 2:
                        right_pocket_id = parts[1].strip()
                        break
            
            if right_pocket_id is None:
                continue

            # Check data
            for line in lines:
                if line.startswith('%'):
                    continue
                parts = line.strip().split(';')
                if len(parts) >= 7:
                    # Sensor Type is index 5, Sensor ID is index 6
                    if parts[6].strip() == right_pocket_id and parts[5].strip() == '1':
                        gyro_count += 1
                        has_gyro = True
                        # Optimization: if we just want to know if ANY exist, we could break here
                        # but counting is nice.
            
            if has_gyro:
                files_with_gyro += 1
                print(f"Found gyro in {filename}")

    print(f"Total Gyroscope Samples found: {gyro_count}")
    print(f"Files containing Gyroscope data: {files_with_gyro}")

if __name__ == '__main__':
    check_gyro_original(r'd:\MAC-LRN\MAC-LRN_FallDetection\UMAFall_Dataset')
