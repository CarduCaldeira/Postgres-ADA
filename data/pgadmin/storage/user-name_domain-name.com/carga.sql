CREATE SCHEMA IF NOT EXISTS raw_data;

CREATE TABLE raw_data.machines (
	machineID smallserial primary key,
	model varchar(10),
	age smallint CHECK (age >= 0)
);

CREATE TABLE raw_data.errors (
	datetime timestamp,
	machineID smallint,
	errorID  varchar(10)
);

CREATE TABLE raw_data.maint (
	datetime timestamp,
	machineID smallint,
	comp varchar(10)
);

CREATE TABLE raw_data.failures (
	datetime timestamp,
	machineID smallint,
	failure varchar(10)
);

CREATE TABLE raw_data.telemetry (
	datetime timestamp,
	machineID smallint,
	volt float,
	rotate float,
	pressure float,
	vibration float
);

COPY raw_data.machines FROM '/home/PdM_machines.csv' DELIMITER ',' CSV HEADER;
COPY raw_data.errors FROM '/home/PdM_errors.csv' DELIMITER ',' CSV HEADER;
COPY raw_data.maint FROM '/home/PdM_maint.csv' DELIMITER ',' CSV HEADER;
COPY raw_data.failures FROM '/home/PdM_failures.csv' DELIMITER ',' CSV HEADER;
COPY raw_data.telemetry FROM '/home/PdM_telemetry.csv' DELIMITER ',' CSV HEADER;
