import matplotlib.pyplot as plt
import os
import sys

def visualize_all(input_dir, output_dir):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"Created directory: {output_dir}")

    files = [f for f in os.listdir(input_dir) if f.endswith('.csv')]
    total_files = len(files)
    print(f"Found {total_files} CSV files to process.")

    for i, filename in enumerate(files):
        filepath = os.path.join(input_dir, filename)
        output_image = os.path.join(output_dir, filename.replace('.csv', '.png'))
        
        if os.path.exists(output_image):
             print(f"[{i+1}/{total_files}] Skipping {filename} (already exists)")
             continue

        print(f"[{i+1}/{total_files}] Processing {filename}...")
        
        accel_t, accel_x, accel_y, accel_z = [], [], [], []
        gyro_t, gyro_x, gyro_y, gyro_z = [], [], [], []

        try:
            with open(filepath, 'r') as f:
                for line in f:
                    if line.startswith('%'):
                        continue
                    parts = line.strip().split(';')
                    if len(parts) < 6:
                        continue
                    
                    try:
                        t = float(parts[0])
                        x = float(parts[2])
                        y = float(parts[3])
                        z = float(parts[4])
                        sensor_type = parts[5].strip()

                        if sensor_type == '0': # Accelerometer
                            accel_t.append(t)
                            accel_x.append(x)
                            accel_y.append(y)
                            accel_z.append(z)
                        elif sensor_type == '1': # Gyroscope
                            gyro_t.append(t)
                            gyro_x.append(x)
                            gyro_y.append(y)
                            gyro_z.append(z)
                    except ValueError:
                        continue
        except Exception as e:
            print(f"Error reading file {filename}: {e}")
            continue

        if not accel_t and not gyro_t:
            print(f"No data found in {filename}")
            continue

        fig, (ax1, ax2) = plt.subplots(2, 1, sharex=True, figsize=(12, 8))

        # Plot Accelerometer
        ax1.plot(accel_t, accel_x, label='X', alpha=0.7, linewidth=1)
        ax1.plot(accel_t, accel_y, label='Y', alpha=0.7, linewidth=1)
        ax1.plot(accel_t, accel_z, label='Z', alpha=0.7, linewidth=1)
        ax1.set_title(f'Accelerometer Data - {filename}')
        ax1.set_ylabel('Acceleration (g)')
        ax1.legend(loc='upper right')
        ax1.grid(True)

        # Plot Gyroscope
        ax2.plot(gyro_t, gyro_x, label='X', alpha=0.7, linewidth=1)
        ax2.plot(gyro_t, gyro_y, label='Y', alpha=0.7, linewidth=1)
        ax2.plot(gyro_t, gyro_z, label='Z', alpha=0.7, linewidth=1)
        ax2.set_title('Gyroscope Data')
        ax2.set_xlabel('Timestamp (ms)')
        ax2.set_ylabel('Angular Velocity (deg/s)')
        ax2.legend(loc='upper right')
        ax2.grid(True)

        plt.tight_layout()
        plt.savefig(output_image)
        plt.close(fig) # Close the figure to free memory

    print("Batch visualization complete.")

if __name__ == '__main__':
    input_directory = r'd:\MAC-LRN\MAC-LRN_FallDetection\UMAFall_Dataset_Filtered'
    output_directory = r'd:\MAC-LRN\MAC-LRN_FallDetection\visualizations'
    visualize_all(input_directory, output_directory)
