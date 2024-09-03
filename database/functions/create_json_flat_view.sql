/* 
    This function take in three parameters: the table name, the non-json columns, the json columns 
    To execute after flattening json into columns, you can run 'SELECT * FROM TABLE_NAME_view;'
    Example, create_json_flat_view('example', 'id, first_name, last_name', 'params');
*/
CREATE OR REPLACE FUNCTION create_json_flat_view
    (table_name text, regular_columns text, json_column text)
    RETURNS text LANGUAGE plpgsql AS $$
DECLARE
    cols text;
BEGIN
    EXECUTE format ($ex$
        SELECT string_agg(format('%2$s->>%%1$L "%%1$s"', key), ', ')
        FROM (
            SELECT DISTINCT key
            FROM %1$s, jsonb_each(%2$s)
            ORDER BY 1
            ) s;
        $ex$, table_name, json_column)
    INTO cols;
    EXECUTE format($ex$
        DROP VIEW IF EXISTS %1$s_view;
        CREATE view %1$s_view AS 
        SELECT %2$s, %3$s FROM %1$s
        $ex$, table_name, regular_columns, cols);
    RETURN cols;
END $$;
