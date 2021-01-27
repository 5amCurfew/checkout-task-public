{{
  config(
    materialized="view"
  )
}}

WITH page_views as (
  SELECT 
    * 
  FROM 
    {{ ref('int_page_views') }}
)

SELECT * FROM page_views