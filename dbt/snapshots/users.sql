{% snapshot users_snapshot %}

{{
    config(
      target_database='checkout-task',
      target_schema='analytics',
      unique_key='id',

      strategy='check',
      check_cols=['postcode']
    )
}}

{%- set users = ref('users_extract')  -%}

WITH final AS (
    SELECT 
        id,
        postcode
    FROM 
        {{ users }}
)

SELECT * FROM final

{% endsnapshot %}