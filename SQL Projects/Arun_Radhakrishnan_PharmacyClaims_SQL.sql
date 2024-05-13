alter table fact_drug
add id int not null auto_increment primary key;

alter table dim_brand_generic
add primary key(brand_generic);

ALTER TABLE fact_drug
ADD PRIMARY KEY (id);

alter table dim_drug_ndc
add primary key(drug_ndc);

alter table dim_member
add primary key(member_id);

alter table fact_drug
add foreign key fact_drug_member_id_fk(member_id)
references dim_member(member_id)
on delete set null
on update set null;

ALTER TABLE fact_drug
MODIFY COLUMN drug_form_code VARCHAR(255);

ALTER TABLE dim_drug_form_code
MODIFY COLUMN drug_form_code VARCHAR(255);
alter table fact_drug
add foreign key fact_drug_drug_ndc_fk(drug_ndc)
references dim_drug_ndc(drug_ndc)
on delete set null
on update set null;

alter table fact_drug
add foreign key fact_drug_brand_generic_fk(brand_generic)
references dim_brand_generic(brand_generic)
on delete set null
on update set null;



select d.drug_name, count(f.member_id) as number_of_prescriptions 
from dim_drug_ndc d inner join fact_drug f
on d.drug_ndc = f.drug_ndc
group by drug_name;

select case 
when d.member_age > 65 then "greater than 65"
when d.member_age < 65 then "less than 65"
end as age_group,
count(distinct d.member_id) as number_members, 
sum(f.copay) as sum_copay, 
sum(f.insurancepaid) as sum_insurancepaid,
count(f.member_id) as number_prescriptions
from dim_member d
inner join fact_drug f on d.member_id = f.member_id
group by age_group;

create table fill_fact as
select d.member_id, d.member_first_name, d.member_last_name, dr.drug_name,
str_to_date(f.fill_date,'%d-%m-%Y') as fill_date_fixed, f.insurancepaid
from dim_member d
inner join fact_drug f 
on d.member_id = f.member_id
inner join dim_drug_ndc dr 
on dr.drug_ndc = f.drug_ndc;
select * from fill_fact;

select * from fill_fact;
create table insurance_info as
select member_id, member_first_name, member_last_name, drug_name, fill_date_fixed, insurancepaid, 
row_number() over(partition by member_id order by member_id, fill_date_fixed desc) as fill_count
from fill_fact;
select * from insurance_info;

select member_id, member_first_name, member_last_name, drug_name, fill_date_fixed, insurancepaid 
from insurance_info
where fill_count = 1;

