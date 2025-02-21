COPY diagnostic_report (data)  
FROM '/tmp/data/DiagnosticReport.ndjson'  
WITH (FORMAT text);

COPY immunization (data)  
FROM '/tmp/data/Immunization.ndjson'  
WITH (FORMAT text);

COPY observation (data)  
FROM '/tmp/data/Observation.ndjson'  
WITH (FORMAT text);

CREATE TEMP TABLE temp_patient (data text);

-- Load the file using COPY in TEXT format
COPY temp_patient (data) 
FROM '/tmp/data/Patient.ndjson' 
WITH (FORMAT text);

-- Now insert the data into the actual patient table after converting to jsonb
DO $$ 
DECLARE
    rec text;
BEGIN
    FOR rec IN SELECT data FROM temp_patient LOOP
        BEGIN
            -- Try to insert as JSONB into the patient table
            INSERT INTO patient (data) VALUES (rec::jsonb);
        EXCEPTION
            WHEN OTHERS THEN
                -- Skip any invalid data and raise a notice
                RAISE NOTICE 'Skipping invalid line: %', rec;
        END;
    END LOOP;
END $$;