-- Create role owners
CREATE ROLE public_owner;
CREATE ROLE devops_owner;

-- Create users
CREATE USER demo_app_api_iam
WITH LOGIN;

-- serverless
CREATE USER demo_serverless_iam
WITH LOGIN;

-- Grant devops_owner to users
GRANT devops_owner TO demo_serverless_iam;

-- Grant public_owner to users
GRANT public_owner TO demo_serverless_iam;
GRANT public_owner TO demo_app_api_iam;

-- Grant necessary privileges to owners
-- ** Make sure you execute this on the database that has the schema **


-- Create schemas if they don't exist
CREATE SCHEMA
IF NOT EXISTS public;

CREATE SCHEMA
IF NOT EXISTS devops;


-- For public_owner
GRANT CREATE, USAGE ON SCHEMA public TO public_owner;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO public_owner;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO public_owner;

-- For demo_devops database
GRANT CREATE, TEMPORARY ON DATABASE your_database TO devops_owner;
GRANT USAGE ON SCHEMA devops TO devops_owner;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA devops TO devops_owner;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA devops TO devops_owner;
GRANT ALL PRIVILEGES ON SCHEMA devops TO devops_owner;



