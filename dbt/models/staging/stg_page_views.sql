{{
    config(
        materialized='incremental',
        unique_key='id',
        sort=["users_nk", "recorded_at"],
        dist="users_nk",
    )
}}

{%- set page_views = ref('pageviews_extract') -%}

WITH final AS (
    SELECT 
        user_id as users_nk,
        page_path,
        TIMESTAMP(pageview_datetime) as recorded_at,
        {{ dbt_utils.surrogate_key(['user_id', 'pageview_datetime']) }} AS id 
    FROM
        {{ page_views }}
)

SELECT * FROM final

{% if is_incremental() %}

  where recorded_at >= (select max(recorded_at) from {{ this }})

{% endif %}