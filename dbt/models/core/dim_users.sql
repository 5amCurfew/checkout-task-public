{{
  config(
    materialized="view"
  )
}}

{%- set users = ref('stg_users') -%}

WITH final as (
  SELECT * FROM {{ users }}
)

SELECT * FROM final
