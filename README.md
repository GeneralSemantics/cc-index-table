![Common Crawl Logo](http://commoncrawl.org/wp-content/uploads/2016/12/logocommoncrawl.png)

# Common Crawl Index Table

Provide an index to Common Crawl archives in a tabular format.

## Build Java tools

`mvn package`

## Conversion of the URL index

A Spark job converts the Common Crawl URL index into a table in [Parquet](http://parquet.apache.org/) or [ORC](https://orc.apache.org/) format.

```
> APPJAR=target/cc-spark-0.1-SNAPSHOT-jar-with-dependencies.jar
> $SPARK_HOME/bin/spark-submit --class org.commoncrawl.spark.CCIndex2Table $APPJAR

CCIndex2Table [options] <inputPathSpec> <outputPath>

Arguments:
  <inputPaths>
        pattern describing paths of input CDX files, e.g.
        s3a://commoncrawl/cc-index/collections/CC-MAIN-2017-43/indexes/cdx-*.gz
  <outputPath>
        output directory

Options:
  -h,--help                     Show this message
     --outputCompression <arg>  data output compression codec: gzip/zlib
                                (default), snappy, lzo, none
     --outputFormat <arg>       data output format: parquet (default), orc
     --partitionBy <arg>        partition data by columns (comma-separated,
                                default: crawl,subset)
     --useNestedSchema          use the schema with nested columns (default:
                                false, use flat schema)
```

The script [convert_url_index.sh](src/script/convert_url_index.sh) runs `CCIndex2Table` using Spark on Yarn.

Columns are defined described in the table schema ([flat](src/main/resources/schema/cc-index-schema-flat.json) or [nested](src/main/resources/schema/cc-index-schema-nested.json)).


## Query the table in AWS Athena

First, the table needs to be imported into Athena:

1. edit the "create table" statement ([flat](src/sql/athena/cc-index-create-table-flat.sql) or [nested](src/sql/athena/cc-index-create-table-nested.sql)) and add the correct table name and path to the Parquet/ORC data on `s3://`. Execute the "create table" query.
2. make Athena recognize the data partitions on `s3://`: `MSCK REPAIR TABLE 'ccindex';` (do not forget to adapt the table name). This step needs to be done again after new data partitions have been added.

A couple of sample queries are also provided:
- page/host/domain counts per top-level domain [count-by-tld-page-host-domain.sql](src/sql/examples/count-by-tld-page-host-domain.sql)
- [compare-mime-type-http-vs-detected.sql](src/sql/examples/compare-mime-type-http-vs-detected.sql): compare document MIME types (Content-Type in HTTP response header vs. MIME type detected by [Tika](http://tika.apache.org/)