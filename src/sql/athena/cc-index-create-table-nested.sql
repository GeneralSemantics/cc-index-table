-- Create cc-index table with nested schema
--
-- Parameters to be reviewed/adapted:
--  * table name
--  * format (STORED AS)
--  * s3:// path (LOCATION)
--
CREATE EXTERNAL TABLE IF NOT EXISTS 'ccindex' (
  url     STRUCT<surtkey:STRING, url:STRING, host:STRUCT<name:STRING, reverse_host:ARRAY<STRING>, registry_suffix:STRING, registered_domain:STRING, private_suffix:STRING, private_domain:STRING>, protocol:STRING, port:INT, path:STRING, query:STRING>,
  fetch   STRUCT<time:BIGINT, status:SMALLINT>,
  content STRUCT<digest:STRING, mime_type:STRING, mime_detected:STRING>,
  warc    STRUCT<filename:STRING, record_offset:INT, record_length:INT, segment:STRING>)
PARTITIONED BY(crawl STRING, subset STRING)
STORED AS parquet
LOCATION 's3://path_to_table/'

