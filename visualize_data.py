import matplotlib.pyplot as plt
import csv
import sys

def visualize_file(filepath, output_image):
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
        print(f"Error reading file: {e}")
        return

    if not accel_t and not gyro_t:
        print("No data found to plot.")
        return

    fig, (ax1, ax2) = plt.subplots(2, 1, sharex=True, figsize=(12, 8))

    # Plot Accelerometer
    ax1.plot(accel_t, accel_x, label='X', alpha=0.7)
    ax1.plot(accel_t, accel_y, label='Y', alpha=0.7)
    ax1.plot(accel_t, accel_z, label='Z', alpha=0.7)
    ax1.set_title('Accelerometer Data')
    ax1.set_ylabel('Acceleration (g)')
    ax1.legend(loc='upper right')
    ax1.grid(True)

    # Plot Gyroscope
    ax2.plot(gyro_t, gyro_x, label='X', alpha=0.7)
    ax2.plot(gyro_t, gyro_y, label='Y', alpha=0.7)
    ax2.plot(gyro_t, gyro_z, label='Z', alpha=0.7)
    ax2.set_title('Gyroscope Data')
    ax2.set_xlabel('Timestamp (ms)')
    ax2.set_ylabel('Angular Velocity (deg/s)')
    ax2.legend(loc='upper right')
    ax2.grid(True)

    plt.tight_layout()
    plt.savefig(output_image)
    print(f"Plot saved to {output_image}")

if __name__ == '__main__':
    # Using a sample file with known good data (Fall forward)
    sample_file = r'd:\MAC-LRN\MAC-LRN_FallDetection\UMAFall_Dataset_Filtered\UMAFall_Subject_18_Fall_forwardFall_1_2016-06-15_21-07-01.csv'
    output_file = r'd:\MAC-LRN\MAC-LRN_FallDetection\sensor_plot.png'
    visualize_file(sample_file, output_file)
