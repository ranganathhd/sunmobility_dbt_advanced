-- fleet_customers_snapshot.sql
-- tracks how fleet customer data changes over time
-- SCD Type 2 — keeps full history
-- useful for: subscription plan changed, balance topped up, vehicle count changed

{% snapshot fleet_customers_snapshot %}

{{
    config(
        target_schema = 'SNAPSHOTS',
        unique_key    = 'fleet_id',
        strategy      = 'check',
        check_cols    = ['subscription_plan', 'current_balance', 'vehicle_count', 'status']
    )
}}

SELECT
    fleet_id,
    company_name,
    contact_person,
    phone,
    email,
    city,
    state,
    subscription_plan,
    monthly_deposit,
    current_balance,
    vehicle_count,
    registered_date,
    status
FROM {{ ref('stg_fleet_customers') }}

{% endsnapshot %}