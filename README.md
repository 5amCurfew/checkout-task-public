### Resources:

- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
- current testing environment: https://console.cloud.google.com/bigquery?project=checkout-task&p=checkout-task&page=project

# Part 1

Throughout Part 1 please ensure you are in the `dbt` directory - `cd task/dbt`.

Ensure that `dbt` and `git` are installed on your machine. [Click here](https://docs.getdbt.com/docs/introduction) for more information.

## Load test data to your datawarehouse

1. Connect to your data warehouse: create the corresponding profile in `dbt/.dbt/profiles.yml` and add corresponding credential files here to set up database connection. Please refer to dbt [docs](https://docs.getdbt.com/reference/profiles.yml) for other supported data warehouses. This repo currently uses a Google BigQuery profile. If you are connecting to an existing data warehouse please ensure the schema name in `.dbt/profiles.yml` is correct (for example setting up test data in the default BigQuery schema, this is loaded under a schema titled analytics). Run `dbt debug --profiles-dir ./.dbt` to check this connection.
2. Load raw test data: **(This step is not necessary if tables users_extract and pageviews_extract already exist in your data warehouse corresponding to the profiles.yml)** switch to the branch `to_seed` using `git checkout to_seed` and run the command `dbt seed --profiles-dir ./.dbt` to load test data to your data warehouse (note you may also need to ensure the correct `profiles.yml` on this branch as well). The `to_seed` branch does not contain any dbt models which depend on the raw data already existing in the data warehouse. After successfully loading this test data move back to the main branch using `git checkout main`.

## Implement Transform Pipeline using DBT

3. Implement data model:
   - `dbt deps --profiles-dir ./.dbt` **(to load dbt_utils)**
   - `dbt snapshot --profiles-dir ./.dbt` **(this captures the users_extract as a type-2 slowly changing dimension)**
   - `dbt run --profiles-dir ./.dbt` **(this generates the data models incrementally)**
   - `dbt test --profiles-dir ./.dbt` **(ensure all data and relationships are consistent as defined in `schema.yml` files)**
4. View documentation on the database by running `dbt docs generate --profiles-dir ./.dbt` followed by `dbt docs serve --profiles-dir ./.dbt`

Resulting queries for BI tool/SQL client:
Latest postcode:

```
WITH current_users AS (

SELECT * FROM analytics.dim_users where is_current

)

SELECT
  TIMESTAMP_TRUNC(fct_page_views.recorded_at, DAY) as date,
  current_users.postcode,
  COUNT(fct_page_views.id) as page_view_count
 FROM
  analytics.fct_page_views
  INNER JOIN current_users ON current_users.natural_key = fct_page_views.users_nk
 GROUP BY
  date, postcode
 ORDER BY
  date
```

Postcode at time of page view:

```
SELECT
  TIMESTAMP_TRUNC(fct_page_views.recorded_at, DAY) as date,
  dim_users.postcode,
  COUNT(fct_page_views.id) as page_view_count
 FROM
  analytics.fct_page_views
  INNER JOIN analytics.dim_users ON dim_users.surrogate_key = fct_page_views.users_sk
 GROUP BY
  date, postcode
 ORDER BY
  date
```

# Part 2

## Scheduling

Throughout Part 2 please ensure you are in the `task` directory - if currently in the `dbt` directory used in Part 1 please run `cd ..`.

Ensure that Docker is installed on your machine. [Click here](https://www.docker.com/) for more information.

Proposal: the use of [Apache Airflow](https://airflow.apache.org/) for orchestration.

1. Ensure that Docker is running on your machine.
2. Run `docker build -t checkout-task .` to build the docker image
3. Run `docker run -p 8080:8080 checkout-task --rm` to run the image locally on port `8080`
4. Visit `localhost:8080` to view the Airflow scheduler and view DAG runs and turn on DAGs `scheduled_dbt_users` and `scheduled_dbt_page_views`
5. Note that here in this testing environment "hourly" is currently scheduled every 5 minutes and "daily" is scheduled every 15 minutes.
