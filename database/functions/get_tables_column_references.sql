/*
* Get all tables that reference another table's column
* table_name: the table to find references for
* column_name: the FK in other tables 
* Usage: SELECT * FROM get_tables_column_references('user', 'id');
*/
CREATE OR REPLACE FUNCTION admin.get_tables_column_references
    (referenced_table_name text, referenced_column_name text)
	RETURNS TABLE ("database" text, "schema" text, "table" text) AS $$
BEGIN
    RETURN QUERY 
    SELECT u.table_catalog::text AS "database", u.table_schema::text AS "schema", r.table_name::text AS "table"
    FROM information_schema.constraint_column_usage u
    INNER JOIN information_schema.referential_constraints fk
           ON u.constraint_catalog = fk.unique_constraint_catalog
               AND u.constraint_schema = fk.unique_constraint_schema
               AND u.constraint_name = fk.unique_constraint_name
    INNER JOIN information_schema.key_column_usage r
           ON r.constraint_catalog = fk.constraint_catalog
               AND r.constraint_schema = fk.constraint_schema
               AND r.constraint_name = fk.constraint_name
    WHERE
        u.table_name = referenced_table_name
        AND u.column_name = referenced_column_name;
END $$ LANGUAGE plpgsql;

