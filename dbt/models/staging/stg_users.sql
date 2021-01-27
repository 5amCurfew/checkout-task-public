{%- set users = ref('users_snapshot') -%}

WITH final AS (
    SELECT
        {{ dbt_utils.surrogate_key(['id', 'dbt_updated_at']) }} as surrogate_key,
        id as natural_key,
        postcode,
        dbt_valid_from as valid_from,
        COALESCE(dbt_valid_to, TIMESTAMP(DATE_ADD(CURRENT_DATE, INTERVAL 1 YEAR))) as valid_to,
        CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END AS is_current
    FROM 
        {{ users }}
)

SELECT * FROM final