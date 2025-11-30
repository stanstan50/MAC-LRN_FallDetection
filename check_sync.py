import os
import statistics

def check_sync(input_dir):
    print(f"Checking synchronization in {input_dir}...")
    
    delays = []
    files_checked = 0
    
    for filename in os.listdir(input_dir):
        if not filename.endswith('.csv'):
            continue
            
        filepath = os.path.join(input_dir, filename)
        accel_data = {} # Sample No -> Timestamp
        gyro_data = {}  # Sample No -> Timestamp
        
        try:
            with open(filepath, 'r') as f:
                for line in f:
                    if line.startswith('%'):
                        continue
                    parts = line.strip().split(';')
                    if len(parts) < 6:
                        continue
                        
                    try:
                        timestamp = int(parts[0])
                        sample_no = int(parts[1])
                        sensor_type = parts[5].strip()
                        
                        if sensor_type == '0': # Accel
                            accel_data[sample_no] = timestamp
                        elif sensor_type == '1': # Gyro
                            gyro_data[sample_no] = timestamp
                    except ValueError:
                        continue
            
            if not accel_data or not gyro_data:
                continue
                
            files_checked += 1
            
            # Compare timestamps for matching Sample Nos
            common_samples = set(accel_data.keys()) & set(gyro_data.keys())
            
            for sample in common_samples:
                diff = abs(accel_data[sample] - gyro_data[sample])
                delays.append(diff)
                
        except Exception as e:
            print(f"Error processing {filename}: {e}")

    if delays:
        print(f"Checked {files_checked} files.")
        print(f"Total matching samples: {len(delays)}")
        print(f"Average timestamp difference: {statistics.mean(delays):.2f} ms")
        print(f"Max timestamp difference: {max(delays)} ms")
        print(f"Min timestamp difference: {min(delays)} ms")
        
        # Check for perfect sync
        perfect_sync = len([d for d in delays if d == 0])
        print(f"Perfectly synced samples (0ms diff): {perfect_sync} ({perfect_sync/len(delays)*100:.2f}%)")
    else:
        print("No common samples found between Accel and Gyro.")

if __name__ == '__main__':
    check_sync(r'd:\MAC-LRN\MAC-LRN_FallDetection\UMAFall_Dataset_Filtered')
