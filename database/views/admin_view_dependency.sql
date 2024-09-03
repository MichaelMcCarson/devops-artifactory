/*
    If you get an issue "Cannot drop table users because other objects depend on it", you can run
    a select against the table by running:
    SELECT * FROM admin.v_view_dependency WHERE src_objectname LIKE '%the_table_name_it_complained_about%';
*/
CREATE OR REPLACE VIEW admin.view_dependency AS 
SELECT DISTINCT srcobj.oid AS src_oid
  , srcnsp.nspname AS src_schemaname
  , srcobj.relname AS src_objectname
  , tgtobj.oid AS dependent_viewoid
  , tgtnsp.nspname AS dependant_schemaname
  , tgtobj.relname AS dependant_objectname
FROM pg_class srcobj
  JOIN pg_depend srcdep ON srcobj.oid = srcdep.refobjid
  JOIN pg_depend tgtdep ON srcdep.objid = tgtdep.objid
  JOIN pg_class tgtobj ON tgtdep.refobjid = tgtobj.oid AND srcobj.oid <> tgtobj.oid
  LEFT JOIN pg_namespace srcnsp ON srcobj.relnamespace = srcnsp.oid
  LEFT JOIN pg_namespace tgtnsp ON tgtobj.relnamespace = tgtnsp.oid
WHERE tgtdep.deptype = 'i'::"char" AND tgtobj.relkind = 'v'::"char";
