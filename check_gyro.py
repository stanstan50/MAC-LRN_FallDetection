import os

def check_gyro(input_dir):
    gyro_count = 0
    files_with_gyro = 0
    
    if not os.path.exists(input_dir):
        print(f"Directory not found: {input_dir}")
        return

    for filename in os.listdir(input_dir):
        if filename.endswith('.csv'):
            filepath = os.path.join(input_dir, filename)
            has_gyro = False
            with open(filepath, 'r') as f:
                for line in f:
                    if line.startswith('%'):
                        continue
                    parts = line.strip().split(';')
                    if len(parts) >= 6:
                        # Sensor Type is at index 5 (0-based)
                        if parts[5].strip() == '1':
                            gyro_count += 1
                            has_gyro = True
            
            if has_gyro:
                files_with_gyro += 1

    print(f"Total Gyroscope Samples found: {gyro_count}")
    print(f"Files containing Gyroscope data: {files_with_gyro}")

if __name__ == '__main__':
    check_gyro(r'd:\MAC-LRN\MAC-LRN_FallDetection\UMAFall_Dataset_Filtered')
