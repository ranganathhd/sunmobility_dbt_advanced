# generate_realtime_data.py
# Simulates real time data generated every 10 minutes
# Includes: swap_records, station_alerts, battery_alerts, vehicle_live_data
# Run this repeatedly to simulate continuous pipeline

import pandas as pd
import boto3
import os
import random
import logging
from faker import Faker
from datetime import datetime, timedelta
from dotenv import load_dotenv

# load environment variables from .env file
load_dotenv()

# set up logging — better than print for production
logging.basicConfig(
    level  = logging.INFO,
    format = '%(asctime)s - %(levelname)s - %(message)s'
)

# initialize faker with Indian locale
fake = Faker('en_IN')

# ============================================
# Reference data — same IDs as master data
# ============================================
STATION_IDS   = [f'ST{str(i).zfill(3)}' for i in range(1, 51)]
VEHICLE_IDS   = [f'V{str(i).zfill(4)}' for i in range(1, 501)]
BATTERY_IDS   = [f'B{str(i).zfill(4)}' for i in range(1, 201)]
OPERATOR_IDS  = [f'OP{str(i).zfill(2)}' for i in range(1, 21)]
RETAIL_IDS    = [f'RC{str(i).zfill(4)}' for i in range(1, 201)]
FLEET_IDS     = [f'FC{str(i).zfill(3)}' for i in range(1, 21)]
DOCK_IDS      = [f'DK{str(i).zfill(2)}' for i in range(1, 21)]

# current timestamp for this batch
BATCH_TIME    = datetime.now()

# ============================================
# Swap records — 20 new swaps per 10 minutes
# ============================================
def generate_swap_records(batch_number):

    swap_statuses    = ['Success', 'Success', 'Success', 'Success', 'Failed']
    payment_types    = ['Cash', 'UPI', 'Subscription']
    payment_statuses = ['Paid', 'Paid', 'Paid', 'Pending', 'Failed']
    failure_reasons  = [
        'Error 2007 — Dock Communication Failure',
        'Internet Outage — Network Connectivity Issue',
        'Battery Theft Detected',
        'Dock Malfunction — Physical Issue',
        'Battery Not Charging — Low Charge Level',
        'Vehicle Not Recognized — RFID Failure',
        None, None, None, None  # more None means more success
    ]

    swaps = []
    for i in range(1, 21):  # 20 swaps per batch
        swap_id      = f'SW{str(batch_number).zfill(4)}{str(i).zfill(3)}'
        swap_status  = random.choice(swap_statuses)

        # retail or fleet customer
        if random.random() < 0.6:  # 60% retail
            customer_id   = random.choice(RETAIL_IDS)
            customer_type = 'Retail'
            payment_type  = random.choice(['Cash', 'UPI'])
        else:  # 40% fleet
            customer_id   = random.choice(FLEET_IDS)
            customer_type = 'Fleet'
            payment_type  = 'Subscription'

        battery_out  = random.choice(BATTERY_IDS)
        battery_in   = random.choice([b for b in BATTERY_IDS if b != battery_out])

        swaps.append({
            'swap_id'        : swap_id,
            'customer_id'    : customer_id,
            'customer_type'  : customer_type,
            'vehicle_id'     : random.choice(VEHICLE_IDS),
            'station_id'     : random.choice(STATION_IDS),
            'dock_id'        : random.choice(DOCK_IDS),
            'battery_out'    : battery_out,
            'battery_in'     : battery_in,
            'swap_date'      : BATCH_TIME.strftime('%Y-%m-%d'),
            'swap_time'      : BATCH_TIME.strftime('%H:%M:%S'),
            'operator_id'    : random.choice(OPERATOR_IDS),
            'amount'         : random.choice([50.0, 75.0, 100.0, 125.0, 150.0, 175.0, 200.0]),
            'payment_type'   : payment_type,
            'payment_status' : random.choice(payment_statuses),
            'swap_status'    : swap_status,
            'failure_reason' : random.choice(failure_reasons) if swap_status == 'Failed' else None
        })
    return pd.DataFrame(swaps)

# ============================================
# Station alerts — 10 alerts per 10 minutes
# ============================================
def generate_station_alerts(batch_number):

    alert_types = [
        'Internet Outage',
        'Power Failure',
        'Dock Malfunction',
        'CCTV Failure',
        'Temperature Too High',
        'Network Connectivity Issue',
        'UPS Battery Low'
    ]
    severities  = ['Critical', 'High', 'Medium', 'Low']
    statuses    = ['Open', 'Open', 'Resolved']

    alerts = []
    for i in range(1, 11):  # 10 station alerts per batch
        alert_id   = f'SA{str(batch_number).zfill(4)}{str(i).zfill(3)}'
        alert_type = random.choice(alert_types)
        status     = random.choice(statuses)
        triggered  = BATCH_TIME - timedelta(minutes=random.randint(1, 10))
        resolved   = BATCH_TIME if status == 'Resolved' else None

        alerts.append({
            'alert_id'      : alert_id,
            'station_id'    : random.choice(STATION_IDS),
            'dock_id'       : random.choice(DOCK_IDS),
            'alert_type'    : alert_type,
            'severity'      : random.choice(severities),
            'alert_message' : f'{alert_type} detected at station',
            'triggered_at'  : triggered,
            'resolved_at'   : resolved,
            'status'        : status
        })
    return pd.DataFrame(alerts)

# ============================================
# Battery alerts — 10 alerts per 10 minutes
# ============================================
def generate_battery_alerts(batch_number):

    alert_types = [
        'Error 2007 — Communication Failure',
        'Battery Theft Detected',
        'Low Health — Below 20%',
        'High Temperature Warning',
        'Charge Cycle Limit Exceeded',
        'Voltage Irregularity Detected',
        'Physical Damage Reported'
    ]
    severities = ['Critical', 'High', 'Medium', 'Low']
    statuses   = ['Open', 'Open', 'Resolved']

    alerts = []
    for i in range(1, 11):  # 10 battery alerts per batch
        alert_id      = f'BA{str(batch_number).zfill(4)}{str(i).zfill(3)}'
        alert_type    = random.choice(alert_types)
        status        = random.choice(statuses)
        triggered     = BATCH_TIME - timedelta(minutes=random.randint(1, 10))
        resolved      = BATCH_TIME if status == 'Resolved' else None
        battery_health = round(random.uniform(10, 95), 2)

        alerts.append({
            'alert_id'      : alert_id,
            'battery_id'    : random.choice(BATTERY_IDS),
            'station_id'    : random.choice(STATION_IDS),
            'alert_type'    : alert_type,
            'severity'      : random.choice(severities),
            'alert_message' : f'{alert_type} detected on battery',
            'battery_health': battery_health,
            'triggered_at'  : triggered,
            'resolved_at'   : resolved,
            'status'        : status
        })
    return pd.DataFrame(alerts)

# ============================================
# Vehicle live data — 500 vehicles every 10 mins
# GPS coordinates and battery level
# ============================================
def generate_vehicle_live_data(batch_number):

    # Indian city coordinates for realistic GPS
    city_coords = [
        (13.0827, 80.2707),   # Chennai
        (19.0760, 72.8777),   # Mumbai
        (12.9716, 77.5946),   # Bangalore
        (28.6139, 77.2090),   # Delhi
        (22.5726, 88.3639),   # Kolkata
        (17.3850, 78.4867),   # Hyderabad
        (23.0225, 72.5714),   # Ahmedabad
        (18.5204, 73.8567),   # Pune
        (26.8467, 80.9462),   # Lucknow
        (26.9124, 75.7873),   # Jaipur
    ]

    live_data = []
    for i, vehicle_id in enumerate(VEHICLE_IDS):  # all 500 vehicles
        record_id = f'VL{str(batch_number).zfill(4)}{str(i+1).zfill(4)}'
        base_lat, base_lon = random.choice(city_coords)

        live_data.append({
            'record_id'      : record_id,
            'vehicle_id'     : vehicle_id,
            'latitude'       : round(base_lat + random.uniform(-0.1, 0.1), 6),
            'longitude'      : round(base_lon + random.uniform(-0.1, 0.1), 6),
            'battery_level'  : round(random.uniform(5, 100), 2),
            'speed_kmph'     : round(random.uniform(0, 60), 2),
            'ignition_status': random.choice(['On', 'On', 'Off']),
            'recorded_at'    : BATCH_TIME
        })
    return pd.DataFrame(live_data)

# ============================================
# Save DataFrame as CSV file
# ============================================
def save_to_csv(df, filename, subfolder):
    # create folder if not exists
    os.makedirs(f'data/realtime/{subfolder}', exist_ok=True)
    filepath = f'data/realtime/{subfolder}/{filename}'
    # index=False — do not save row numbers as column
    df.to_csv(filepath, index=False)
    logging.info(f'Saved {filename} — {len(df)} rows')
    return filepath

# ============================================
# Upload CSV files to AWS S3
# ============================================
def upload_to_s3(filepath, filename, folder):
    # create S3 client using credentials from .env file
    s3 = boto3.client(
        's3',
        aws_access_key_id     = os.getenv('AWS_ACCESS_KEY_ID'),
        aws_secret_access_key = os.getenv('AWS_SECRET_ACCESS_KEY'),
        region_name           = os.getenv('AWS_REGION')
    )

    bucket_name = os.getenv('AWS_BUCKET_NAME')
    # timestamp in folder name — keeps each batch separate in S3
    timestamp   = BATCH_TIME.strftime('%Y%m%d_%H%M%S')
    s3_key      = f'sunmobility-advanced/realtime/{folder}/{timestamp}/{filename}'

    # upload file to S3
    s3.upload_file(filepath, bucket_name, s3_key)
    logging.info(f'Uploaded to s3://{bucket_name}/{s3_key}')

# ============================================
# Main function — runs everything
# ============================================
def main():
    # batch number based on current timestamp
    batch_number = int(BATCH_TIME.strftime('%H%M%S'))

    logging.info('Starting SunMobility Real Time Data Generation...')
    logging.info(f'Batch time: {BATCH_TIME}')
    logging.info('=' * 60)

    try:
        # generate real time data
        logging.info('Generating real time data...')
        df_swaps        = generate_swap_records(batch_number)
        df_sta_alerts   = generate_station_alerts(batch_number)
        df_bat_alerts   = generate_battery_alerts(batch_number)
        df_live_data    = generate_vehicle_live_data(batch_number)

        # save to CSV files
        logging.info('Saving CSV files...')
        swaps_file      = save_to_csv(df_swaps,      'swap_records.csv',   'swaps')
        sta_alert_file  = save_to_csv(df_sta_alerts, 'station_alerts.csv', 'alerts')
        bat_alert_file  = save_to_csv(df_bat_alerts, 'battery_alerts.csv', 'alerts')
        live_file       = save_to_csv(df_live_data,  'vehicle_live_data.csv', 'live')

        # upload to S3
        logging.info('Uploading to S3...')
        upload_to_s3(swaps_file,     'swap_records.csv',    'swaps')
        upload_to_s3(sta_alert_file, 'station_alerts.csv',  'alerts')
        upload_to_s3(bat_alert_file, 'battery_alerts.csv',  'alerts')
        upload_to_s3(live_file,      'vehicle_live_data.csv', 'live')

        logging.info('=' * 60)
        logging.info('Real Time Batch Completed Successfully!')
        logging.info(f'Swap Records     : {len(df_swaps)} rows')
        logging.info(f'Station Alerts   : {len(df_sta_alerts)} rows')
        logging.info(f'Battery Alerts   : {len(df_bat_alerts)} rows')
        logging.info(f'Vehicle Live Data: {len(df_live_data)} rows')

    except Exception as e:
        # log error if anything goes wrong
        logging.error(f'Pipeline failed: {e}')

# entry point
if __name__ == '__main__':
    main()