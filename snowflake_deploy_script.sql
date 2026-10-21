-- 0. One-time admin setup: an OPS schema for the dbt objects, owned by nobody special.
--    TRANSFORMER creates the object and the task there and runs them.
USE ROLE ACCOUNTADMIN;
CREATE SCHEMA DBT_MASTERY_LAB.OPS;
CREATE STAGE  DBT_MASTERY_LAB.OPS.dbt_src;
CREATE STAGE  DBT_MASTERY_LAB.OPS.dbt_src_pr;
GRANT USAGE, CREATE DBT PROJECT, CREATE TASK ON SCHEMA DBT_MASTERY_LAB.OPS TO ROLE TRANSFORMER;
GRANT READ, WRITE ON STAGE DBT_MASTERY_LAB.OPS.dbt_src TO ROLE TRANSFORMER;
GRANT READ, WRITE ON STAGE DBT_MASTERY_LAB.OPS.dbt_src_pr TO ROLE TRANSFORMER;
GRANT EXECUTE TASK ON ACCOUNT TO ROLE TRANSFORMER;
USE ROLE TRANSFORMER;
GRANT ROLE TRANSFORMER TO ROLE SYSADMIN;

-- 1. Upload a deploy copy of the project: dbt_project.yml, profiles.yml and env.yml at the
--    stage root, plus models/ macros/ seeds/ snapshots/ tests/ and the vendored dbt_packages/.
--    From your laptop:  snow stage copy ./deploy @DBT_MASTERY_LAB.OPS.dbt_src --recursive --overwrite
--    Then create the object from it (a Git repository stage or Workspace also works):
CREATE OR REPLACE DBT PROJECT DBT_MASTERY_LAB.OPS.MARKET_ANALYTICS
  FROM '@DBT_MASTERY_LAB.OPS.dbt_src'
  DBT_VERSION = '1.12.3'          -- pin it: the account default may be older
  DEFAULT_TARGET = 'prod';


-- Once the dbt project is in a stage, you can IMPORT it into a workspace to get a proper file directory and edit files, see the DAG, etc. in workspaces. 

-- ALTER ACCOUNT SET DEFAULT_DBT_VERSION = '1.12.3'; to pin a default DBT version in Snowflake account. 