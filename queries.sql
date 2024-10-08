--											+-------------------+
--											|	    Desing      |
--											+-------------------+
--+-------------------+      
--|    VesselTypes    |      
--+-------------------+      
--| code: integer     |      
--| description: text |      
--| PRIMARY KEY(code) |      
--+-------------------+      


--+--------------------------------------------------+      
--|       			Vessels     				     |       
--+--------------------------------------------------+          
--| id varchar(64),								     |		
--| type integer,							         |  
--| flag varchar(30),							     |
--| PRIMARY KEY (id),								 |
--| FOREIGN KEY (type) REFERENCES vesseltypes (code) |            
--+--------------------------------------------------+


--+----------------------------------------------+
--|                Positions				     |
--+----------------------------------------------+
--| id: bigInt NOT NULL                    	     |
--| vessel_id: varchar(64)     				     |
--| t: timestamp             				     |
--| lon: double             			         |
--| lat: double             				     |
--| heading: double         				     |
--| course: double          				     |
--| speed: double           	   			     |
--| PRIMARY KEY(id)         					 |
--| FOREIGN KEY(vessel_id) REFERENCES VesselType |
--+----------------------------------------------+


--										+-------------------------+
--										|	   Create tables      |
--										+-------------------------+
--										
--				+--------------------+
--				| TABLE1 VesselTypes |
--				+--------------------+

drop table if exists VesselTypes

create table VesselTypes(
	code integer,
	description text, 
	primary key(code)
);

COPY VesselTypes FROM 'C:\Program Files\PostgreSQL\15\data\VesselTypes.csv' WITH CSV HEADER DELIMITER ',';


--				+----------------+
--				| TABLE2 Vessels |
--				+----------------+
				
drop table if exists Vessels

create table Vessels(
	id varchar(64),
	type integer,
	flag varchar(30),
	primary key (id),
	FOREIGN KEY (type) REFERENCES vesseltypes (code)
);

COPY Vessels FROM 'C:\Program Files\PostgreSQL\15\data\Vessels.csv' WITH CSV HEADER DELIMITER ',';


--				+-------------------+
--				| TABLE3 Positions  |
--				+-------------------+

drop table if exists Positions

create table Positions(
	id bigint NOT NULL, 
	vessel_id varchar(64), 
	t timestamp, 
	lon double precision, 
	lat double precision, 
	heading double precision, 
	course double precision, 
	speed double precision, 
	primary key(id),
	FOREIGN KEY(vessel_id) REFERENCES vessels (id)
);

COPY Positions FROM 'C:\Program Files\PostgreSQL\15\data\Positions.csv' WITH CSV HEADER DELIMITER ',';

--+---------------------------------------------------Ερώτημα 1 (30 %)---------------------------------------------------------------+
--shared_buffers = '128MB'
--max_parallel_workers_per_gather = 2

vacuum full vessels;
vacuum full vesseltypes;
vacuum full positions


--drop view view_1;

	create view view_1 as
	select vesseltypes.description, vessels.id, vessels.type
	from vessels
	left outer join vesseltypes on vesseltypes.code = vessels.type;


--(i):

	select date(t) as day, count(*) as num_positions
	from positions
	group by day
	order by num_positions desc;


--(ii): 

	select foo.description, foo.type, count(*) 
	from (select vesseltypes.description, vessels.id, vessels.type, vessels.flag
			 from vessels
			 left outer join vesseltypes on vesseltypes.code = vessels.type
		 ) as foo
	where foo.flag='Greece'
	group by foo.type, foo.description;


--(iii):

	select view_1.description, view_1.type, count(*)
	from view_1
	join positions on positions.vessel_id = view_1.id
	where speed > 30
	group by view_1.type, view_1.description;


--(iv):

	select date(t) as day, count(*)
	from view_1
	join positions on positions.vessel_id = view_1.id 
	where view_1.description like '%Passenger%' and positions.t between '2019-08-14 00:00:00' and '2019-08-18 23:59:59'
	group by day
	order by day;


--(v)
--a meros:

	select view_1.id, positions.speed, date(t) as day
	from view_1
	join positions on positions.vessel_id = view_1.id 
	where view_1.description like '%Cargo%' and positions.t between '2019-08-15 00:00:00' and '2019-08-18 23:59:59' and positions.speed = 0
	group by day, view_1.id ,positions.speed;


--b meros:

	select view_1.id, count(case when positions.speed = 0 then 1 else NULL end) as count_zero_speed
	from view_1
	join positions on positions.vessel_id = view_1.id
	where view_1.description like '%Cargo%' and positions.t between '2019-08-12 00:00:00' and '2019-08-19 23:59:59'
	group by view_1.id
	having count(case when positions.speed = 0 then 1 else NULL end) = count(view_1.id)
	order by view_1.id;
	
--+---------------------------------------------------Ερώτημα 2 (15 %)---------------------------------------------------------------+
--shared_buffers = '8GB'
--max_parallel_workers_per_gather = 2

alter system set shared_buffers to '8GB'
show shared_buffers


--(i):

explain analyze
	select date(t) as day, count(*) as num_positions
	from positions
	group by day
	order by num_positions desc;


--(ii): 

explain analyze
	select foo.description, foo.type, count(*) 
	from (select vesseltypes.description, vessels.id, vessels.type, vessels.flag
			 from vessels
			 left outer join vesseltypes on vesseltypes.code = vessels.type
		 ) as foo
	where foo.flag='Greece'
	group by foo.type, foo.description;


--(iii):

explain analyze
	select view_1.description, view_1.type, count(*)
	from view_1
	join positions on positions.vessel_id = view_1.id
	where speed > 30
	group by view_1.type, view_1.description;


--(iv):

explain analyze
	select date(t) as day, count(*)
	from view_1
	join positions on positions.vessel_id = view_1.id 
	where view_1.description like '%Passenger%' and positions.t between '2019-08-14 00:00:00' and '2019-08-18 23:59:59'
	group by day
	order by day;


--(v)
--a meros:

explain analyze
	select view_1.id, positions.speed, date(t) as day
	from view_1
	join positions on positions.vessel_id = view_1.id 
	where view_1.description like '%Cargo%' and positions.t between '2019-08-15 00:00:00' and '2019-08-18 23:59:59' and positions.speed = 0
	group by day, view_1.id ,positions.speed;


--b meros:

explain analyze
	select view_1.id, count(case when positions.speed = 0 then 1 else NULL end) as count_zero_speed
	from view_1
	join positions on positions.vessel_id = view_1.id
	where view_1.description like '%Cargo%' and positions.t between '2019-08-12 00:00:00' and '2019-08-19 23:59:59'
	group by view_1.id
	having count(case when positions.speed = 0 then 1 else NULL end) = count(view_1.id)
	order by view_1.id;

--+--------------------------------------------------Ερώτημα 3 (15 %)----------------------------------------------------------------+
--shared_buffers = '8GB'
--max_parallel_workers_per_gather = 4

set max_parallel_workers_per_gather=4;  
show max_parallel_workers_per_gather


--(i):

explain analyze
	select date(t) as day, count(*) as num_positions
	from positions
	group by day
	order by num_positions desc;


--(ii): 

explain analyze
	select foo.description, foo.type, count(*) 
	from (select vesseltypes.description, vessels.id, vessels.type, vessels.flag
			 from vessels
			 left outer join vesseltypes on vesseltypes.code = vessels.type
		 ) as foo
	where foo.flag='Greece'
	group by foo.type, foo.description;


--(iii):

explain analyze
	select view_1.description, view_1.type, count(*)
	from view_1
	join positions on positions.vessel_id = view_1.id
	where speed > 30
	group by view_1.type, view_1.description;


--(iv):

explain analyze
	select date(t) as day, count(*)
	from view_1
	join positions on positions.vessel_id = view_1.id 
	where view_1.description like '%Passenger%' and positions.t between '2019-08-14 00:00:00' and '2019-08-18 23:59:59'
	group by day
	order by day;


--(v)
--a meros:

explain analyze
	select view_1.id, positions.speed, date(t) as day
	from view_1
	join positions on positions.vessel_id = view_1.id 
	where view_1.description like '%Cargo%' and positions.t between '2019-08-15 00:00:00' and '2019-08-18 23:59:59' and positions.speed = 0
	group by day, view_1.id ,positions.speed;


--b meros:

explain analyze
	select view_1.id, count(case when positions.speed = 0 then 1 else NULL end) as count_zero_speed
	from view_1
	join positions on positions.vessel_id = view_1.id
	where view_1.description like '%Cargo%' and positions.t between '2019-08-12 00:00:00' and '2019-08-19 23:59:59'
	group by view_1.id
	having count(case when positions.speed = 0 then 1 else NULL end) = count(view_1.id)
	order by view_1.id;

--+--------------------------------------------------Ερώτημα 4 (20 %)----------------------------------------------------------------+
--shared_buffers = '8GB'
--max_parallel_workers_per_gather = 4


--set enable_seqscan = on;
set enable_seqscan = off;

--(i):

----index----
--drop index idx_positions_date;

create index idx_positions_date 
on positions using btree (t);

select pg_size_pretty(pg_relation_size('idx_positions_date'));

explain analyze
	select date(t) as day, count(*) as num_positions
	from positions
	group by day
	order by num_positions desc;


--(ii):

----index----
--drop index idx_vessels_flag_type_id;

create index idx_vessels_flag_type_id 
on vessels using btree (type)
where flag = 'Greece';

select pg_size_pretty(pg_relation_size('idx_vessels_flag_type_id'));

explain analyze
	select foo.description, foo.type, count(*) 
	from (select vesseltypes.description, vessels.id, vessels.type, vessels.flag
			 from vessels
			 left outer join vesseltypes on vesseltypes.code = vessels.type
		 ) as foo
	where foo.flag='Greece'
	group by foo.type, foo.description;


--(iii):

----index----
--drop index idx_positions_vessel_id_speed;

create index idx_positions_vessel_id_speed
on positions using btree (vessel_id, speed)
where speed > 30;

select pg_size_pretty(pg_relation_size('idx_positions_vessel_id_speed'));

explain analyze
	select view_1.description, view_1.type, count(*)
	from view_1
	join positions on positions.vessel_id = view_1.id
	where speed > 30
	group by view_1.type, view_1.description;


--(iv): 

----index----
--drop index idx_positions_t;

create index idx_positions_t
on positions using btree (t)
where t between '2019-08-14 00:00:00' and '2019-08-18 23:59:59';

select pg_size_pretty(pg_relation_size('idx_positions_t'));


explain analyze
	select date(t) as day, count(*)
	from view_1
	join positions on positions.vessel_id = view_1.id 
	where view_1.description like '%Passenger%' and positions.t between '2019-08-14 00:00:00' and '2019-08-18 23:59:59'
	group by day
	order by day;


--(v)
--a meros: 

----index----
--drop index idx_positions_t_a;

create index idx_positions_t_a
on positions using btree (t)
where t between '2019-08-15 00:00:00' and '2019-08-18 23:59:59';

select pg_size_pretty(pg_relation_size('idx_positions_t_a'));
	
explain analyze
	select view_1.id, positions.speed, date(t) as day
	from view_1
	join positions on positions.vessel_id = view_1.id 
	where view_1.description like '%Cargo%' and positions.t between '2019-08-15 00:00:00' and '2019-08-18 23:59:59' and positions.speed = 0
	group by day, view_1.id ,positions.speed;


--b meros: 

----index----
--drop index idx_positions_t_b;

create index idx_positions_t_b
on positions using btree (t)
where t between '2019-08-12 00:00:00' and '2019-08-19 23:59:59';

select pg_size_pretty(pg_relation_size('idx_positions_t_b'));

explain analyze
	select view_1.id, count(case when positions.speed = 0 then 1 else NULL end) as count_zero_speed
	from view_1
	join positions on positions.vessel_id = view_1.id
	where view_1.description like '%Cargo%' and 
		positions.t between '2019-08-12 00:00:00' and '2019-08-19 23:59:59'
	group by view_1.id
	having count(case when positions.speed = 0 then 1 else NULL end) = count(view_1.id)
	order by view_1.id;

--+--------------------------------------------------Ερώτημα 5 (20 %)----------------------------------------------------------------+
--shared_buffers = '128MB'
--max_parallel_workers_per_gather = 2


-- partition table
drop table if exists positions;
create table positions(
	id bigint not NULL,
	vessel_id varchar(64),
	t timestamp,
	lon double precision,
	lat double precision,
	heading double precision,
	course double precision,
	speed double precision,
	primary key(id,t),
	foreign key(vessel_id) references vessels (id)
);

-- partitions
create table positions_2019_08_01 (
check (t >= '2019-08-01' and t < '2019-08-02')
)inherits(positions);
create table positions_2019_08_02 (
check (t >= '2019-08-02' and t < '2019-08-03')
)inherits(positions);
create table positions_2019_08_03 (
check (t >= '2019-08-03' and t < '2019-08-04')
)inherits(positions);
create table positions_2019_08_04 (
check (t >= '2019-08-04' and t < '2019-08-05')
)inherits(positions);
create table positions_2019_08_05 (
check (t >= '2019-08-05' and t < '2019-08-06')
)inherits(positions);
create table positions_2019_08_06 (
check (t >= '2019-08-06' and t < '2019-08-07')
)inherits(positions);
create table positions_2019_08_07 (
check (t >= '2019-08-07' and t < '2019-08-08')
)inherits(positions);
create table positions_2019_08_08 (
check (t >= '2019-08-08' and t < '2019-08-09')
)inherits(positions);
create table positions_2019_08_09 (
check (t >= '2019-08-09' and t < '2019-08-10')
)inherits(positions);
create table positions_2019_08_10 (
check (t >= '2019-08-10' and t < '2019-08-11')
)inherits(positions);
create table positions_2019_08_11 (
check (t >= '2019-08-11' and t < '2019-08-12')
)inherits(positions);
create table positions_2019_08_12 (
check (t >= '2019-08-12' and t < '2019-08-13')
)inherits(positions);
create table positions_2019_08_13 (
check (t >= '2019-08-13' and t < '2019-08-14')
)inherits(positions);
create table positions_2019_08_14 (
check (t >= '2019-08-14' and t < '2019-08-15')
)inherits(positions);
create table positions_2019_08_15 (
check (t >= '2019-08-15' and t < '2019-08-16')
)inherits(positions);
create table positions_2019_08_16 (
check (t >= '2019-08-16' and t < '2019-08-17')
)inherits(positions);
create table positions_2019_08_17 (
check (t >= '2019-08-17' and t < '2019-08-18')
)inherits(positions);
create table positions_2019_08_18 (
check (t >= '2019-08-18' and t < '2019-08-19')
)inherits(positions);
create table positions_2019_08_19 (
check (t >= '2019-08-19' and t < '2019-08-26')
)inherits(positions);
create table positions_2019_08_26 (
check (t >= '2019-08-26' and t < '2019-08-27')
)inherits(positions);
create table positions_2019_08_27 (
check (t >= '2019-08-27' and t < '2019-08-28')
)inherits(positions);
create table positions_2019_08_28 (
check (t >= '2019-08-28' and t < '2019-08-29')
)inherits(positions);
create table positions_2019_08_29 (
check (t >= '2019-08-29' and t < '2019-08-30')
)inherits(positions);
create table positions_2019_08_30 (
check (t >= '2019-08-30' and t < '2019-08-31')
)inherits(positions);

-- function
create or replace function positions_insert_trigger()
returns trigger as $$

begin
	if (new.t >= '2019-08-01' and new.t < '2019-08-02') then
		insert into positions_2019_08_01 values (new.*);
	elsif (new.t >= '2019-08-02' and new.t < '2019-08-03') then
		insert into positions_2019_08_02 values (new.*);
	elsif (new.t >= '2019-08-03' and new.t < '2019-08-04') then
		insert into positions_2019_08_03 values (new.*);
	elsif (new.t >= '2019-08-04' and new.t < '2019-08-05') then
		insert into positions_2019_08_04 values (new.*);
	elsif (new.t >= '2019-08-05' and new.t < '2019-08-06') then
		insert into positions_2019_08_05 values (new.*);
	elsif (new.t >= '2019-08-06' and new.t < '2019-08-07') then
		insert into positions_2019_08_06 values (new.*);
	elsif (new.t >= '2019-08-07' and new.t < '2019-08-08') then
		insert into positions_2019_08_07 values (new.*);
	elsif (new.t >= '2019-08-08' and new.t < '2019-08-09') then
		insert into positions_2019_08_08 values (new.*);
	elsif (new.t >= '2019-08-09' and new.t < '2019-08-10') then
		insert into positions_2019_08_09 values (new.*);
	elsif (new.t >= '2019-08-10' and new.t < '2019-08-11') then
		insert into positions_2019_08_10 values (new.*);
	elsif (new.t >= '2019-08-11' and new.t < '2019-08-12') then
		insert into positions_2019_08_11 values (new.*);
	elsif (new.t >= '2019-08-12' and new.t < '2019-08-13') then
		insert into positions_2019_08_12 values (new.*);
	elsif (new.t >= '2019-08-13' and new.t < '2019-08-14') then
		insert into positions_2019_08_13 values (new.*);
	elsif (new.t >= '2019-08-14' and new.t < '2019-08-15') then
		insert into positions_2019_08_14 values (new.*);
	elsif (new.t >= '2019-08-15' and new.t < '2019-08-16') then
		insert into positions_2019_08_15 values (new.*);
	elsif (new.t >= '2019-08-16' and new.t < '2019-08-17') then
		insert into positions_2019_08_16 values (new.*);
	elsif (new.t >= '2019-08-17' and new.t < '2019-08-18') then
		insert into positions_2019_08_17 values (new.*);
	elsif (new.t >= '2019-08-18' and new.t < '2019-08-19') then
		insert into positions_2019_08_18 values (new.*);
	elsif (new.t >= '2019-08-19' and new.t < '2019-08-26') then
		insert into positions_2019_08_19 values (new.*);
	elsif (new.t >= '2019-08-26' and new.t < '2019-08-27') then
		insert into positions_2019_08_26 values (new.*);
	elsif (new.t >= '2019-08-27' and new.t < '2019-08-28') then
		insert into positions_2019_08_27 values (new.*);
	elsif (new.t >= '2019-08-28' and new.t < '2019-08-29') then
		insert into positions_2019_08_28 values (new.*);
	elsif (new.t >= '2019-08-29' and new.t < '2019-08-30') then
		insert into positions_2019_08_29 values (new.*);
	elsif (new.t >= '2019-08-30' and new.t < '2019-08-31') then
		insert into positions_2019_08_30 values (new.*);
	else
	raise exception 'Date out of range!';
	end if;
	return null;
end;
$$language
plpgsql;

-- trigger
create trigger insert_positions_trigger
before insert on positions
for each row execute function positions_insert_trigger();

--data
COPY Positions FROM 'C:\Program Files\PostgreSQL\15\data\Positions.csv' WITH CSV HEADER DELIMITER ',';

--queries
--(i):

explain analyze
	select date(t) as day, count(*) as num_positions
	from positions
	group by day
	order by num_positions desc;


--(ii): 

explain analyze
	select foo.description, foo.type, count(*) 
	from (select vesseltypes.description, vessels.id, vessels.type, vessels.flag
			 from vessels
			 left outer join vesseltypes on vesseltypes.code = vessels.type
		 ) as foo
	where foo.flag='Greece'
	group by foo.type, foo.description;


--(iii):

explain analyze
	select view_1.description, view_1.type, count(*)
	from view_1
	join positions on positions.vessel_id = view_1.id
	where speed > 30
	group by view_1.type, view_1.description;


--(iv):

explain analyze
	select date(t) as day, count(*)
	from view_1
	join positions on positions.vessel_id = view_1.id 
	where view_1.description like '%Passenger%' and positions.t between '2019-08-14 00:00:00' and '2019-08-18 23:59:59'
	group by day
	order by day;


--(v)
--a meros:

explain analyze
	select view_1.id, positions.speed, date(t) as day
	from view_1
	join positions on positions.vessel_id = view_1.id 
	where view_1.description like '%Cargo%' and positions.t between '2019-08-15 00:00:00' and '2019-08-18 23:59:59' and positions.speed = 0
	group by day, view_1.id ,positions.speed;


--b meros:

explain analyze
	select view_1.id, count(case when positions.speed = 0 then 1 else NULL end) as count_zero_speed
	from view_1
	join positions on positions.vessel_id = view_1.id
	where view_1.description like '%Cargo%' and positions.t between '2019-08-12 00:00:00' and '2019-08-19 23:59:59'
	group by view_1.id
	having count(case when positions.speed = 0 then 1 else NULL end) = count(view_1.id)
	order by view_1.id;
--+----------------------------------------------------------------------------------------------------------------------------------+
