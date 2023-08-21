#ddev-generated
drop table if exists daily_sensor_report;
CREATE TABLE daily_sensor_report (
    aggregation_date DATE,
    sensor_id VARCHAR(16),
    fuel_output FLOAT8,
    fuel_input FLOAT8,
    water_output FLOAT8,
    water_input FLOAT8
);



CREATE OR REPLACE procedure processDailyInputOutput(chosen_date date) as $$
	delete from daily_sensor_report dtr where dtr.aggregation_date = chosen_date;
	with tabular as (
		select "timestamp", fuel, water, (metadata->>'sensorId')::text  as sensor_id from
		data where chosen_date = "timestamp"::DATE
	),
	diffs as (
	SELECT
	    "timestamp"::DATE as aggregation_date,
		fuel  -	coalesce (LAG(fuel) OVER (partition by sensor_id ORDER by "timestamp"), fuel) AS fuel_diff,
		water - coalesce (LAG(water) OVER (partition by sensor_id ORDER by "timestamp"), water) AS water_diff,
		sensor_id
	FROM tabular
	)
	insert into daily_sensor_report(aggregation_date , sensor_id, fuel_output, fuel_input, water_output, water_input )
	select 	aggregation_date,
			sensor_id ,
			sum(case when fuel_diff < 0  then fuel_diff else 0 end) as fuel_output,
			sum(case when fuel_diff > 0  then fuel_diff else 0 end) as fuel_input,
			sum(case when water_diff < 0  then water_diff else 0 end) as water_output,
			sum(case when water_diff > 0  then water_diff else 0 end) as water_input
	from diffs group by sensor_id, aggregation_date;
$$ language sql;


CREATE OR REPLACE PROCEDURE processAllInputOutput() AS $$
WITH tabular AS (
    SELECT "timestamp", fuel, water, (metadata->>'sensorId')::text AS sensor_id FROM data
),
diffs AS (
    SELECT
        "timestamp"::DATE AS aggregation_date,
        fuel - COALESCE(LAG(fuel) OVER (PARTITION BY sensor_id ORDER BY "timestamp"), fuel) AS fuel_diff,
        water - COALESCE(LAG(water) OVER (PARTITION BY sensor_id ORDER BY "timestamp"), water) AS water_diff,
        sensor_id
    FROM tabular
)
INSERT INTO daily_sensor_report(aggregation_date, sensor_id, fuel_output, fuel_input, water_output, water_input)
SELECT
    aggregation_date,
    sensor_id,
    SUM(CASE WHEN fuel_diff < 0 THEN fuel_diff ELSE 0 END) AS fuel_output,
    SUM(CASE WHEN fuel_diff > 0 THEN fuel_diff ELSE 0 END) AS fuel_input,
    SUM(CASE WHEN water_diff < 0 THEN water_diff ELSE 0 END) AS water_output,
    SUM(CASE WHEN water_diff > 0 THEN water_diff ELSE 0 END) AS water_input
FROM diffs
GROUP BY sensor_id, aggregation_date;
$$ LANGUAGE SQL;


CREATE  or replace VIEW daily_facts
    AS

	select
		dsr.aggregation_date , dsr.sensor_id , dsr.fuel_output , dsr.fuel_input , dsr.water_output , dsr.water_input ,
		p.municipality, p.city, c.name as company_name, t.fuel_type
	from daily_sensor_report dsr join device d on d.id::TEXT  = dsr.sensor_id

	join tank t on d.id = t.device_id

	join pump p on p.id = t.pump_id

	join company c on c.id = p.company_id ;
