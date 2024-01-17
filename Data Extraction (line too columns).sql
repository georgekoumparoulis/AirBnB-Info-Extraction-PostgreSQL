/*
					Handling Missing values
*/


/*
Standarize the column name in the format
KIND in AREA · ★num · num BEDROOM · num BED · num BED
*/

select 
	name,
	case
		when split_part(name, ' ★', 2) != ''
		then name
		when split_part(name, ' ★', 2) = ''
		then trim(trailing '·' from concat(split_part(name, '·', 1),'· ★null ·', split_part(name, '·', 2),'·',SPLIT_PART(name, '·', 3),'·',split_part(name, '·', 4),split_part(name, '·', 5)))
	end as add_score,
	case
		when split_part(name,'bedroom',2)='' and split_part(name,'Studio',2)=''
		then concat(split_part(name, '·', 1), '·',split_part(name, '·', 2),'·', 'N bedroom' ,'·',split_part(name, '·', 3),'·',split_part(name, '·', 4))
		else name
	end as add_num_bedroom,
	CASE
		when (((split_part(split_part(name,'bedroom',2),'bed',2)='')) AND split_part(split_part(name,'Studio',2),'bed',2)='')
		then concat(split_part(name, '·', 1), '·',split_part(name, '·', 2), '·',split_part(name, '·', 3), '·', ' N bed ' , '·',split_part(name, '·', 4))
		else name
	end as add_num_bed
from listings_thes
;

/*
Alter table by adding a column to save the standarize format of the name as final_name
*/

alter table 
	listings_thes
add column 
	final_name varchar(500)
;

--1
/*
Split name and add score null in the corret position if missing
and update the final_name column
*/
update 
	listings_thes
set 
	final_name = case
					when split_part(name, ' ★', 2) != ''
					then name
					when split_part(name, ' ★', 2) = ''
					then trim(trailing '·' from concat(split_part(name, '·', 1),'· ★null ·', split_part(name, '·', 2),'·', split_part(name, '·', 3),'·', split_part(name, '·', 4), split_part(name, '·', 5)))
				 end
;

--2
/*
Split name and add bedroom N bedroom in the corret position if missing
and update the final_name column
*/
update 
	listings_thes
set 
	final_name = case
					when split_part(final_name,'bedroom',2)='' and split_part(final_name,'Studio',2)=''
					then concat(split_part(final_name, '·', 1), '·', split_part(final_name, '·', 2),'·', ' N bedroom ' ,'·', split_part(final_name, '·', 3),'·', split_part(final_name, '·', 4))
					else final_name
				 end
;
	
--3
/*
Split name and add bed N bed in the corret position if missing
and update the final_name column
*/
update 
	listings_thes
set 
	final_name = case
					when (((split_part(split_part(final_name,'bedroom',2),'bed',2)='')) and split_part(split_part(final_name,'Studio',2),'bed',2)='')
					then CONCAT(split_part(final_name, '·', 1), '·', split_part(final_name, '·', 2), '·', split_part(final_name, '·', 3), '·', ' N bed ' , '·', split_part(final_name, '·', 4))
					else final_name
				 end
;

/*
Comparative query with old and final_name
*/
select
	name, 
	final_name
from
	listings_thes
;

/*
Call of the updated in the correct format column
and split in the respective columns kind, area, score, bedrooms, beds, baths, bathtype
*/
select 
	final_name,
	trim(split_part(final_name, 'in', 1)) as kind,
	trim(split_part(split_part(final_name, ' in ', 2),' · ',1)) as area,
	case
		when split_part(final_name, ' ★', 2) != ''
		then trim(split_part(split_part(final_name, ' ★', 2),'·', 1))
	end as score,
	case
		when split_part(final_name, '·', 3) != ''
		then case 
				when (split_part(split_part(split_part(final_name, '·', 3),'·', 1), 'bedroom', 1))!=''
				then trim(split_part(split_part(split_part(final_name, '·', 3),'·', 1), 'bedroom', 1))
				end
		else 'Studio'
	end as Bedrooms,
	case
		when (split_part(split_part(split_part(final_name, '·', 4),'·', 1), 'bed', 1))!=''
		then trim(split_part(split_part(split_part(final_name, '·', 4),'·', 1), 'bed', 1))
	end as beds,
	case
		when length(split_part(trim(split_part(split_part(final_name, '·', 5),'·', 1)), ' ', 1)) < 5
		then split_part(trim(split_part(split_part(final_name, '·', 5),'·', 1)), ' ', 1)
		else 'NULL'
	end as Baths,
	case
 		when length(split_part(trim(split_part(split_part(final_name, '·', 5),'·', 1)), ' ', 2)) > 5
		then split_part(trim(split_part(split_part(final_name, '·', 5),'·', 1)), ' ', 2)
		else 'Common'
	end as BathType
from listings_thes
;

/*
Check the distinct values for columns 1 - 5 for any erros
column num 6 to validated the count
*/
select 
	distinct(split_part(final_name, '·', 6)), 
	count(split_part(final_name, '·', 6))
from 
	listings_thes
group by 
	distinct(split_part(final_name, '·', 6))
;