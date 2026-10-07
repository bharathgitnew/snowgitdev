select 'DROP VIEW ' || UPPER(db.database_name) || '.' ||
UPPER(sc.schema_name) || '.' ||
UPPER(tb.table_name) || ';'
from
information_schema.databases db
inner join information_schema.schemata sc
on db.database_name=sc.catalog_name
inner join information_schema.tables tb
on tb.table_schema=sc.schema_name
where
db.database_name='PUB_QA'
and sc.schema_name!='INFORMATION_SCHEMA'
and tb.table_type='VIEW';