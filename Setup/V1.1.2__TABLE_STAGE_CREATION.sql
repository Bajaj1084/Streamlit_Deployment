CREATE OR REPLACE FILE FORMAT streamlit_db.streamlit_schema.csv_ff 
TYPE = 'csv';

CREATE OR REPLACE STAGE streamlit_db.streamlit_schema.s3load
COMMENT = 'Quickstarts S3 Stage Connection'
url = 's3://sfquickstarts/tastybytes-cx/app/'
file_format = streamlit_db.streamlit_schema.csv_ff;

CREATE OR REPLACE TABLE streamlit_db.streamlit_schema.documents (
	RELATIVE_PATH VARCHAR(16777216),
	RAW_TEXT VARCHAR(16777216)
)
COMMENT = '{"origin":"sf_sit-is", "name":"voc", "version":{"major":1, "minor":0}, "attributes":{"is_quickstart":1, "source":"streamlit", "vignette":"rag_chatbot"}}';

COPY INTO streamlit_db.streamlit_schema.documents
FROM @streamlit_db.streamlit_schema.s3load/documents/;

-- https://docs.snowflake.com/en/sql-reference/data-types-vector#loading-and-unloading-vector-data
CREATE OR REPLACE TABLE streamlit_db.streamlit_schema.array_table (
  SOURCE VARCHAR(6),
	SOURCE_DESC VARCHAR(16777216),
	FULL_TEXT VARCHAR(16777216),
	SIZE NUMBER(18,0),
	CHUNK VARCHAR(16777216),
	INPUT_TEXT VARCHAR(16777216),
	CHUNK_EMBEDDING ARRAY
);

COPY INTO streamlit_db.streamlit_schema.array_table
FROM @streamlit_db.streamlit_schema.s3load/vector_store/;

CREATE OR REPLACE TABLE streamlit_db.streamlit_schema.vector_store (
	SOURCE VARCHAR(6),
	SOURCE_DESC VARCHAR(16777216),
	FULL_TEXT VARCHAR(16777216),
	SIZE NUMBER(18,0),
	CHUNK VARCHAR(16777216),
	INPUT_TEXT VARCHAR(16777216),
	CHUNK_EMBEDDING VECTOR(FLOAT, 768)
) AS
SELECT 
  source,
	source_desc,
	full_text,
	size,
	chunk,
	input_text,
  chunk_embedding::VECTOR(FLOAT, 768)
FROM streamlit_db.streamlit_schema.array_table;
