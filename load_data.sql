COPY diagnostic_report (data)  
FROM '/tmp/data/DiagnosticReport.ndjson'  
WITH (FORMAT text);

COPY immunization (data)  
FROM '/tmp/data/Immunization.ndjson'  
WITH (FORMAT text);

COPY observation (data)  
FROM '/tmp/data/Observation.ndjson'  
WITH (FORMAT text);

copy public.patient FROM '/tmp/data/Patient.ndjson' csv quote e'\x01' delimiter e'\x02';