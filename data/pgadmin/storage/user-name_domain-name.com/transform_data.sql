CREATE SCHEMA IF NOT EXISTS processed_data;

create table processed_data.modelo (
	id smallserial primary key,
	modelo char(6) unique not null
);

insert into processed_data.modelo (modelo) 
	select distinct model from raw_data.machines 
	order by model;
	
--------------------------------------------------
	
create table processed_data.componente (
	id smallserial primary key,
	componente char(5) unique not null
);
	
insert into processed_data.componente (componente)
	select distinct failure from raw_data.failures
	order by failure;
	
---------------------------------------------------

create table processed_data.erro (
	id smallserial primary key,
	erro char(6) unique not null
);

insert into  processed_data.erro (erro)
	select distinct errorid from raw_data.errors
	order by errorid;
	
------------------------------------------------------

create table processed_data.maquina (
	id smallserial primary key,	
	id_modelo smallint references processed_data.modelo (id) not null,
	ano smallint not null check (ano <= EXTRACT(YEAR FROM CURRENT_DATE))
);

insert into processed_data.maquina (id_modelo, ano)
select pmod.id, date_part('year', CURRENT_DATE) - rmac.age
from raw_data.machines rmac
inner join processed_data.modelo pmod on rmac.model = pmod.modelo;

------------------------------------------------------------

create table processed_data.maquina_erro (
	id smallserial primary key,
	id_maquina smallint references processed_data.maquina (id) not null,
	id_erro smallint references processed_data.erro (id) not null,
	data_erro timestamp not null
);

insert into processed_data.maquina_erro (id_maquina, id_erro, data_erro)
select re.machineid, pe.id, re.datetime
from raw_data.errors re
inner join processed_data.erro pe on re.errorid = pe.erro;

-----------------------------------------------------------

create table processed_data.telemetria (
	id serial primary key,
	id_maquina smallint references processed_data.maquina (id),
	volt decimal(16,12) check (volt >=0)  not null,
	rotate decimal(16,12) check (rotate >=0)  not null,
	pressure decimal(16,12) check (rotate >=0)  not null,
	vibration decimal(16,13) check (rotate >=0)  not null,
	data_telemetria timestamp not null
);

insert into processed_data.telemetria (id_maquina, volt, rotate, pressure, vibration, data_telemetria)
select  machineID, volt, rotate, pressure, vibration, datetime 
from  raw_data.telemetry;
------------------------------------------------------------------------

create table processed_data.falha (
	id smallserial primary key,
	id_maquina smallint references processed_data.maquina (id) not null,
	id_componente smallint references processed_data.componente (id)  not null,
	data_falha timestamp not null
);

insert into processed_data.falha (id_maquina, id_componente, data_falha)
select  rf.machineid, pc.id, rf.datetime
from raw_data.failures rf
inner join  processed_data.componente pc on pc.componente = rf.failure;

--------------------------------------------------------------------

create table processed_data.manutencao (
	id smallserial primary key,
	id_maquina smallint references processed_data.maquina (id) not null,
	id_componente smallint references processed_data.componente (id) not null,
	data_manutencao timestamp not null
);

insert into processed_data.manutencao (id_maquina, id_componente, data_manutencao)
select rm.machineid, pc.id, rm.datetime
from raw_data.maint rm
inner join processed_data.componente pc on rm.comp = pc.componente


-- select * from teste_csv.maint;
