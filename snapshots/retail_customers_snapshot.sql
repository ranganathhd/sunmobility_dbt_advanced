-- retail_customers_snapshot.sql
-- tracks how retail customer data changes over time
-- SCD Type 2 — keeps full history
-- useful for: customer changed plan, moved city, became inactive

{% snapshot retail_customers_snapshot %}

{{
    config(
        target_schema = 'SNAPSHOTS',
        unique_key    = 'customer_id',
        strategy      = 'check',
        check_cols    = ['plan_type', 'city', 'status', 'phone']
    )
}}

SELECT
    customer_id,
    customer_name,
    phone,
    email,
    city,
    state,
    vehicle_id,
    plan_type,
    registered_date,
    status
FROM {{ ref('stg_retail_customers') }}

{% endsnapshot %}