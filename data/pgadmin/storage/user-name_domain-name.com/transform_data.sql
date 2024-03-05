CREATE SCHEMA IF NOT EXISTS processed_data;

CREATE TABLE processed_data.modelo (
	id smallserial PRIMARY KEY,
	modelo char(6) UNIQUE NOT NULL
);

INSERT INTO processed_data.modelo (modelo) 
	SELECT DISTINCT model FROM raw_data.machines 
	ORDER BY model;
	
--------------------------------------------------
	
CREATE TABLE processed_data.componente (
	id smallserial PRIMARY KEY,
	componente char(5) UNIQUE NOT null
);
	
INSERT INTO processed_data.componente (componente)
	SELECT DISTINCT failure FROM raw_data.failures
	ORDER BY failure;
	
---------------------------------------------------

CREATE TABLE processed_data.erro (
	id smallserial PRIMARY KEY,
	erro char(6) UNIQUE NOT NULL
);

INSERT INTO  processed_data.erro (erro)
	SELECT DISTINCT errorid FROM raw_data.errors
	ORDER BY errorid;
	
------------------------------------------------------

CREATE TABLE processed_data.maquina (
	id smallserial PRIMARY KEY,	
	id_modelo smallint REFERENCES processed_data.modelo (id) NOT NULL,
	ano smallint NOT NULL CHECK (ano <= EXTRACT(YEAR FROM CURRENT_DATE))
);

INSERT INTO processed_data.maquina (id_modelo, ano)
SELECT pmod.id, date_part('year', CURRENT_DATE) - rmac.age
FROM raw_data.machines rmac
INNER JOIN processed_data.modelo pmod ON rmac.model = pmod.modelo;

------------------------------------------------------------

CREATE TABLE processed_data.maquina_erro (
	id smallserial PRIMARY KEY,
	id_maquina smallint REFERENCES processed_data.maquina (id) NOT NULL,
	id_erro smallint REFERENCES processed_data.erro (id) NOT NULL,
	data_erro timestamp NOT NULL
);

INSERT INTO processed_data.maquina_erro (id_maquina, id_erro, data_erro)
SELECT re.machineid, pe.id, re.datetime
FROM raw_data.errors re
INNER JOIN processed_data.erro pe ON re.errorid = pe.erro;

-----------------------------------------------------------

CREATE TABLE processed_data.telemetria (
	id serial PRIMARY KEY,
	id_maquina smallint REFERENCES processed_data.maquina (id),
	volt decimal(16,12) CHECK (volt >=0)  not null,
	rotate decimal(16,12) CHECK (rotate >=0)  not null,
	pressure decimal(16,12) CHECK (rotate >=0)  not null,
	vibration decimal(16,13) CHECK (rotate >=0)  not null,
	data_telemetria timestamp NOT NULL
);

INSERT INTO processed_data.telemetria (id_maquina, volt, rotate, pressure, vibration, data_telemetria)
SELECT  machineID, volt, rotate, pressure, vibration, datetime 
FROM  raw_data.telemetry;
------------------------------------------------------------------------

CREATE TABLE processed_data.falha (
	id smallserial PRIMARY KEY,
	id_maquina smallint REFERENCES processed_data.maquina (id) NOT NULL,
	id_componente smallint REFERENCES processed_data.componente (id)  NOT NULL,
	data_falha timestamp NOT NULL
);

INSERT INTO processed_data.falha (id_maquina, id_componente, data_falha)
SELECT  rf.machineid, pc.id, rf.datetime
FROM raw_data.failures rf
INNER JOIN  processed_data.componente pc ON pc.componente = rf.failure;

--------------------------------------------------------------------

CREATE TABLE processed_data.manutencao (
	id smallserial PRIMARY KEY,
	id_maquina smallint REFERENCES processed_data.maquina (id) NOT NULL,
	id_componente smallint REFERENCES processed_data.componente (id) NOT NULL,
	data_manutencao timestamp NOT NULL
);

INSERT INTO processed_data.manutencao (id_maquina, id_componente, data_manutencao)
SELECT rm.machineid, pc.id, rm.datetime
FROM raw_data.maint rm
INNER JOIN processed_data.componente pc ON rm.comp = pc.componente


-- select * from teste_csv.maint;
