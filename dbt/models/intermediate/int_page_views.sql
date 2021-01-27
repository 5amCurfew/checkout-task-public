  
{{
  config(
    sort=["users_sk", "recorded_at", "page_path"],
    dist="users_sk",
    unique_key='id',
    materialized='incremental'
  )
}}

WITH page_views AS (
  SELECT 
    * 
  FROM 
    {{ ref('stg_page_views') }}

  {% if is_incremental() %}

  where recorded_at >= (select max(recorded_at) from {{ this }})
  
  {% endif %}
),
users AS (
  SELECT * FROM {{ ref('stg_users') }}
)

SELECT
    page_views.id,
    page_views.recorded_at,
    page_views.page_path,
    page_views.users_nk,
    users.surrogate_key as users_sk
FROM
    page_views
    INNER JOIN users ON users.natural_key = page_views.users_nk AND
        users.valid_from <= page_views.recorded_at AND
        users.valid_to > page_views.recorded_at