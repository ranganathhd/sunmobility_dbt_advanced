# generate_initial_data.py
# Generates master data for SunMobility Advanced Project
# Simulates real SunMobility data patterns
# Runs ONCE to create initial master data

import pandas as pd
import boto3
import os
import random
from faker import Faker
from datetime import datetime, timedelta
from dotenv import load_dotenv

# load environment variables from .env file
load_dotenv()

# initialize faker with Indian locale
fake = Faker('en_IN')

# set random seed for reproducibility
random.seed(42)

# ============================================
# Station data — 50 stations across India
# ============================================
def generate_stations():

    # real Indian cities with GPS coordinates
    city_data = [
        {'city': 'Chennai',   'state': 'Tamil Nadu',       'region': 'South', 'lat': 13.0827, 'lon': 80.2707},
        {'city': 'Mumbai',    'state': 'Maharashtra',      'region': 'West',  'lat': 19.0760, 'lon': 72.8777},
        {'city': 'Bangalore', 'state': 'Karnataka',        'region': 'South', 'lat': 12.9716, 'lon': 77.5946},
        {'city': 'Delhi',     'state': 'Delhi',            'region': 'North', 'lat': 28.6139, 'lon': 77.2090},
        {'city': 'Kolkata',   'state': 'West Bengal',      'region': 'East',  'lat': 22.5726, 'lon': 88.3639},
        {'city': 'Hyderabad', 'state': 'Telangana',        'region': 'South', 'lat': 17.3850, 'lon': 78.4867},
        {'city': 'Ahmedabad', 'state': 'Gujarat',          'region': 'West',  'lat': 23.0225, 'lon': 72.5714},
        {'city': 'Pune',      'state': 'Maharashtra',      'region': 'West',  'lat': 18.5204, 'lon': 73.8567},
        {'city': 'Lucknow',   'state': 'Uttar Pradesh',    'region': 'North', 'lat': 26.8467, 'lon': 80.9462},
        {'city': 'Jaipur',    'state': 'Rajasthan',        'region': 'North', 'lat': 26.9124, 'lon': 75.7873},
    ]

    station_areas = [
        'Anna Nagar', 'Koramangala', 'Bandra', 'Connaught Place',
        'Salt Lake', 'Banjara Hills', 'Navrangpura', 'Aundh',
        'Gomti Nagar', 'Malviya Nagar', 'Velachery', 'Whitefield',
        'Andheri', 'Dwarka', 'Park Street', 'Jubilee Hills',
        'Satellite', 'Kothrud', 'Hazratganj', 'Vaishali Nagar'
    ]

    statuses = ['Online', 'Online', 'Online', 'Online', 'Offline', 'Onboarding']

    stations = []
    for i in range(1, 51):  # 50 stations
        station_id   = f'ST{str(i).zfill(3)}'
        city_info    = random.choice(city_data)
        area         = random.choice(station_areas)
        station_name = f'{area} Station'
        total_docks  = random.randint(5, 20)
        status       = random.choice(statuses)
        active_docks = total_docks if status == 'Online' else random.randint(0, total_docks)
        onboarded    = fake.date_between(start_date='-2y', end_date='-6m')
        last_online  = fake.date_between(start_date='-7d', end_date='today')

        stations.append({
            'station_id'       : station_id,
            'station_name'     : station_name,
            'city'             : city_info['city'],
            'state'            : city_info['state'],
            'region'           : city_info['region'],
            'latitude'         : round(city_info['lat'] + random.uniform(-0.05, 0.05), 6),
            'longitude'        : round(city_info['lon'] + random.uniform(-0.05, 0.05), 6),
            'total_docks'      : total_docks,
            'active_docks'     : active_docks,
            'status'           : status,
            'onboarded_date'   : onboarded,
            'last_online_date' : last_online,
            'manager_name'     : fake.name(),
            'manager_phone'    : f'9{random.randint(100000000, 999999999)}'
        })
    return pd.DataFrame(stations)

# ============================================
# Retail customers — 200 individual customers
# ============================================
def generate_retail_customers():

    cities = ['Chennai', 'Mumbai', 'Bangalore', 'Delhi', 'Kolkata',
              'Hyderabad', 'Ahmedabad', 'Pune', 'Lucknow', 'Jaipur']
    states = ['Tamil Nadu', 'Maharashtra', 'Karnataka', 'Delhi',
              'West Bengal', 'Telangana', 'Gujarat', 'Uttar Pradesh', 'Rajasthan']
    plan_types = ['Pay Per Swap', 'Monthly Unlimited', 'Weekly Pack']
    statuses   = ['Active', 'Active', 'Active', 'Inactive']

    customers = []
    for i in range(1, 201):  # 200 retail customers
        customer_id = f'RC{str(i).zfill(4)}'
        city        = random.choice(cities)
        state       = random.choice(states)

        customers.append({
            'customer_id'     : customer_id,
            'name'            : fake.name(),
            'phone'           : f'9{random.randint(100000000, 999999999)}',
            'email'           : fake.email(),
            'city'            : city,
            'state'           : state,
            'vehicle_id'      : f'V{str(i).zfill(4)}',
            'plan_type'       : random.choice(plan_types),
            'registered_date' : fake.date_between(start_date='-2y', end_date='-1m'),
            'status'          : random.choice(statuses)
        })
    return pd.DataFrame(customers)

# ============================================
# Fleet customers — 20 companies
# ============================================
def generate_fleet_customers():

    companies = [
        'Swiggy Delivery', 'Zomato Fleet', 'Dunzo Logistics',
        'Delhivery Express', 'Porter Logistics', 'BigBasket Fleet',
        'Amazon Flex', 'Flipkart Logistics', 'BlueDart Courier',
        'DTDC Express', 'Shadowfax', 'Rapido Fleet',
        'Borzo Delivery', 'WeFast Logistics', 'Lalamove India',
        'XpressBees', 'Ecom Express', 'Rivigo Transport',
        'Mahindra Logistics', 'TVS Supply Chain'
    ]

    cities  = ['Chennai', 'Mumbai', 'Bangalore', 'Delhi', 'Hyderabad']
    states  = ['Tamil Nadu', 'Maharashtra', 'Karnataka', 'Delhi', 'Telangana']
    plans   = ['Monthly', 'Quarterly', 'Annual']
    statuses = ['Active', 'Active', 'Active', 'Inactive']

    fleets = []
    for i, company in enumerate(companies, 1):
        fleet_id        = f'FC{str(i).zfill(3)}'
        monthly_deposit = random.choice([5000, 10000, 15000, 20000, 25000])
        vehicle_count   = random.randint(10, 100)

        fleets.append({
            'fleet_id'         : fleet_id,
            'company_name'     : company,
            'contact_person'   : fake.name(),
            'phone'            : f'9{random.randint(100000000, 999999999)}',
            'email'            : f'fleet@{company.lower().replace(" ", "")}.com',
            'city'             : random.choice(cities),
            'state'            : random.choice(states),
            'subscription_plan': random.choice(plans),
            'monthly_deposit'  : monthly_deposit,
            'current_balance'  : round(monthly_deposit * random.uniform(0.2, 1.5), 2),
            'vehicle_count'    : vehicle_count,
            'registered_date'  : fake.date_between(start_date='-2y', end_date='-3m'),
            'status'           : random.choice(statuses)
        })
    return pd.DataFrame(fleets)

# ============================================
# Vehicles — 500 vehicles
# retail + fleet combined
# ============================================
def generate_vehicles():

    cities  = ['Chennai', 'Mumbai', 'Bangalore', 'Delhi', 'Kolkata',
               'Hyderabad', 'Ahmedabad', 'Pune', 'Lucknow', 'Jaipur']
    states  = ['Tamil Nadu', 'Maharashtra', 'Karnataka', 'Delhi',
               'West Bengal', 'Telangana', 'Gujarat', 'Uttar Pradesh', 'Rajasthan']
    types   = ['Two Wheeler', 'Three Wheeler']
    statuses = ['Active', 'Active', 'Active', 'Inactive']

    vehicles = []
    for i in range(1, 501):  # 500 vehicles
        vehicle_id    = f'V{str(i).zfill(4)}'
        # first 200 are retail customers
        # remaining 300 are fleet vehicles
        if i <= 200:
            customer_id   = f'RC{str(i).zfill(4)}'
            customer_type = 'Retail'
        else:
            fleet_num     = ((i - 201) // 15) + 1
            customer_id   = f'FC{str(min(fleet_num, 20)).zfill(3)}'
            customer_type = 'Fleet'

        vehicles.append({
            'vehicle_id'      : vehicle_id,
            'vehicle_no'      : fake.license_plate(),
            'customer_id'     : customer_id,
            'customer_type'   : customer_type,
            'city'            : random.choice(cities),
            'state'           : random.choice(states),
            'vehicle_type'    : random.choice(types),
            'registered_date' : fake.date_between(start_date='-2y', end_date='-1m'),
            'status'          : random.choice(statuses)
        })
    return pd.DataFrame(vehicles)

# ============================================
# Battery packs — 200 batteries
# with health percentage
# ============================================
def generate_battery_packs():

    manufacturers = ['Exide', 'Amara Raja', 'Luminous', 'Okaya',
                     'Livguard', 'Tata Green', 'HBL Power', 'Su-Kam']
    statuses      = ['Available', 'Available', 'In Use', 'In Use', 'Faulty']
    station_ids   = [f'ST{str(i).zfill(3)}' for i in range(1, 51)]

    batteries = []
    for i in range(1, 201):  # 200 batteries
        cycle_count      = random.randint(10, 1000)
        # health decreases as cycle count increases
        health_pct       = max(20, round(100 - (cycle_count * 0.07), 2))

        batteries.append({
            'battery_id'       : f'B{str(i).zfill(4)}',
            'battery_code'     : f'SM-BAT-{str(i).zfill(5)}',
            'capacity_kwh'     : round(random.choice([1.5, 2.0, 2.5, 3.0, 3.5]), 1),
            'manufacture_date' : fake.date_between(start_date='-3y', end_date='-6m'),
            'manufacturer'     : random.choice(manufacturers),
            'health_percentage': health_pct,
            'status'           : random.choice(statuses),
            'cycle_count'      : cycle_count,
            'station_id'       : random.choice(station_ids),
            'last_charged_at'  : fake.date_time_between(start_date='-7d', end_date='now')
        })
    return pd.DataFrame(batteries)

# ============================================
# Save DataFrame as CSV file
# ============================================
def save_to_csv(df, filename):
    # create data folder if not exists
    os.makedirs('data/initial', exist_ok=True)
    filepath = f'data/initial/{filename}'
    # index=False — do not save row numbers as column
    df.to_csv(filepath, index=False)
    print(f'Saved {filename} — {len(df)} rows')
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
    # folder path inside S3 bucket
    s3_key      = f'sunmobility-advanced/{folder}/{filename}'

    # upload file to S3
    s3.upload_file(filepath, bucket_name, s3_key)
    print(f'Uploaded to s3://{bucket_name}/{s3_key}')

# ============================================
# Main function — runs everything
# ============================================
def main():
    print('Generating SunMobility Initial Master Data...')
    print('=' * 60)

    # generate all master data
    print('\nGenerating master data...')
    df_stations         = generate_stations()
    df_retail_customers = generate_retail_customers()
    df_fleet_customers  = generate_fleet_customers()
    df_vehicles         = generate_vehicles()
    df_batteries        = generate_battery_packs()

    # save to CSV files
    print('\nSaving CSV files...')
    stations_file  = save_to_csv(df_stations,         'stations.csv')
    retail_file    = save_to_csv(df_retail_customers, 'retail_customers.csv')
    fleet_file     = save_to_csv(df_fleet_customers,  'fleet_customers.csv')
    vehicles_file  = save_to_csv(df_vehicles,         'vehicles.csv')
    batteries_file = save_to_csv(df_batteries,        'battery_packs.csv')

    # upload to S3
    print('\nUploading to S3...')
    upload_to_s3(stations_file,  'stations.csv',         'master')
    upload_to_s3(retail_file,    'retail_customers.csv', 'master')
    upload_to_s3(fleet_file,     'fleet_customers.csv',  'master')
    upload_to_s3(vehicles_file,  'vehicles.csv',         'master')
    upload_to_s3(batteries_file, 'battery_packs.csv',    'master')

    print('\n' + '=' * 60)
    print('Initial Master Data Generated Successfully!')
    print(f'Stations         : {len(df_stations)} rows')
    print(f'Retail Customers : {len(df_retail_customers)} rows')
    print(f'Fleet Customers  : {len(df_fleet_customers)} rows')
    print(f'Vehicles         : {len(df_vehicles)} rows')
    print(f'Battery Packs    : {len(df_batteries)} rows')

# entry point
if __name__ == '__main__':
    main()