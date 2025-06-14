--STEP 1
create table Customers (customer_id serial primary key,first_name varchar,	last_name varchar,	date_of_birth date,	gender varchar,	contact_number varchar,	email varchar,	address varchar,	aadhaar_number bigint,	pan_number varchar);
create table Agents (agent_id serial primary key,	first_name varchar,	last_name varchar,	contact_number varchar,	email varchar,	commission_rate numeric);
create table Policies (policy_id serial primary key,	policy_type	 varchar,coverage_amount int,	premium_amount int,	start_date	date,end_date date,	customer_id	serial references Customers(customer_id),agent_id serial references Agents(agent_id),approved_by varchar);
create table Claims (claim_date date,	amount_claimed int,	status varchar,	policy_id serial references Policies(policy_id),	approved_by varchar);
create table Payments (payment_date date,	amount	int,payment_method	varchar,payment_uuid	varchar, policy_id serial references Policies(policy_id));
--STEP 2
copy Customers from 'D:\ARC\SQL\SQL Task-4\Customers.csv' delimiter ',' csv header; 
copy Agents from 'D:\ARC\SQL\SQL Task-4\Agents.csv' delimiter ',' csv header; 
copy Policies from 'D:\ARC\SQL\SQL Task-4\Policies.csv' delimiter ',' csv header; 
copy Claims from 'D:\ARC\SQL\SQL Task-4\Claims.csv' delimiter ',' csv header; 
copy Payments from 'D:\ARC\SQL\SQL Task-4\Payments.csv' delimiter ',' csv header; 

select * from Customers;
select * from Agents;
select * from Policies;
select * from Claims;
select * from Payments;

--STEP 3
--2.
create or replace function auto_update()
returns trigger as $$
begin
if new.amount_claimed > 10000 then new.status = 'Approved';
elseif new.amount_claimed > 200000 then new.status= 'Rejected';
else new.status = 'Pending';
end if;
return new;
end;
$$ language plpgsql;

create or replace trigger auto_trig
before insert or update on Claims
for each row
execute function auto_update()

insert into Claims (claim_date, amount_claimed, status, policy_id, approved_by) values (CURRENT_DATE, 10029, NULL, 1, 'Manager2');
select * from Claims where policy_id=1;

--3.1
select a.agent_id, first_name ||' '|| last_name as agent_name,count(policy_id) as policy_sold from agents a left join policies p on a.agent_id=p.agent_id
group by a.agent_id order by policy_sold desc; 

--OR
create or replace procedure policy_sold(inout agentid int default null,inout agentname varchar default null,inout policysold int default null)
language plpgsql as $$
begin
select a.agent_id, first_name ||' '|| last_name as agent_name,count(policy_id) as policy_sold into agentid,agentname,policysold 
from agents a  left join policies p on a.agent_id=p.agent_id group by a.agent_id order by policy_sold desc;
end;
$$;

call policy_sold();


--3.2
select status,count(*) from Claims group by status;

--3.3
select c.customer_id,c.first_name||' '||c.last_name as customer_name,p.policy_id,policy_type,payment_method,amount,payment_date from Customers c 
join Policies p on c.customer_id=p.customer_id
join Payments pm on pm.policy_id=p.policy_id;

--STEP 4
alter table Policies add column status text default 'Not Expired';
-- 1. Create a trigger that automatically expires policies after the end date.
create or replace function expiry ()
returns trigger as $$
begin
if new.end_date > current_date then new.status='Not Expired';
else new.status='Expired';
end if;
return new;
end;
$$ language plpgsql;

create or replace trigger exp_trig
before insert or update on Policies
for each row
execute function expiry()

update Policies set approved_by='Sakshi' where policy_id=1 returning *;
insert into Policies (policy_id,start_date,end_date)values(12347,'2025-01-01','2025-09-30') returning *;
insert into Policies (policy_id,start_date,end_date)values(12348,'2025-01-01','2025-03-30') returning *;

-- 2. Write a trigger to prevent customers from submitting duplicate claims for the same incident.
create or replace function duplicate()
returns trigger as $$
begin
if exists(
select * from Claims where 
claim_date=new.claim_date and 
policy_id=new.policy_id and
amount_claimed=new.amount_claimed)
then raise exception 'Duplicate Claim';
end if;
return new;
end;
$$ language plpgsql;

create or replace trigger dup_trig
before insert on Claims
for each row
execute function duplicate()

insert into Claims ( policy_id, claim_date,amount_claimed)
values ( 102, '2025-04-08', 10000) returning *;

-- 3. Write a trigger that automatically calculates and updates the commission earned by agents whenever a new policy is created.
-- alter table Policies add column Commision_Earned numeric;
-- select * from Policies;

-- create or replace function commision()
-- returns trigger as $$
-- begin
-- 	new.commision_earned = new.premium_amount * 0.05  ;
-- return new;
-- end;
-- $$ language plpgsql;

create table agent_commission(
commission_id serial primary key,
agent_id int references agents(agent_id),
policy_id int references policies(policy_id),
commission real,
date timestamp default current_timestamp);

create or replace function auto_commission()
returns trigger as $$
declare rate real;
begin
select commission_rate into rate from agents where agent_id=new.agent_id;
insert into agent_commission(agent_id,policy_id,commission) values (new.agent_id,new.policy_id,new.premium_amount * rate);
return new;
end;
$$ language plpgsql;

create or replace trigger comm_trig
before insert on policies
for each row
execute function auto_commission()

insert into policies values(1001,'Car',450000,4500,'2025-03-01','2026-03-02',30,21,'SAkshi');

-- 4. If a claim is below a certain amount (e.g., ₹10,000), write a trigger to automatically approve it
create or replace function approve()
returns trigger as $$
begin
if new.amount_claimed <=10000 then new.status='Approved';
end if;
return new;
end;
$$ language plpgsql;

create or replace trigger approve_trig
before insert on Claims
for each row
execute function approve();

insert into Claims ( policy_id, claim_date,amount_claimed) values ( 213, '2025-04-08', 11000) returning *;
insert into Claims ( policy_id, claim_date,amount_claimed) values ( 105, '2025-04-08', 9000) returning *;
insert into Claims ( policy_id,amount_claimed) values ( 106,789056) returning *;
insert into Claims (claim_date, amount_claimed, status, policy_id, approved_by)values ('2025-04-08', 9000, 'Pending', 212, 'System') returning *;
insert into Claims (claim_date, amount_claimed, status, policy_id, approved_by)values ('2025-04-08', 15000, 'Pending', 103, 'ManagerA') returning *;

-- Stored Procedures:
-- 1. Write a stored procedure to automatically renew policies that are expiring, if the customer has made full payments and has no outstanding claims.
create or replace procedure renew_policy()
language plpgsql as $$
begin
if exists
status<>'Pending' and 
update policies set start_date=current_date and end_date=current_date + interval '1 year';

end;
$$;





-- 2. Create a stored procedure to automatically process recurring payments for policies that are paid in installments.
create or replace procedure 


















-- 3. Implement a stored procedure that dynamically generates reports on the number of policies, claims, and payments processed each day.
create or replace procedure reports(inout fisdate date default null,inout lasdate date default null)
language plpgsql as $$
declare 
total_policies int;
total_claims int;
total_payments int;
begin 
select count(*)into total_policies from policies where start_date between fisdate and lasdate;
select count(*)into total_claims from claims where claim_date between fisdate and lasdate;
select count(*) into total_payments from payments where payment_date between fisdate and lasdate;
raise exception 'Total Policies: % ,Total Claims: % , Total Payments: %',total_policies,total_claims,total_payments;
end;
$$;

call reports('2024-01-01','2025-01-01');











-- Audit Tables:
-- 1. Tracking all changes in key tables:
--Implement audit tables to log any changes made to important tables such as Policies, Claims, and Payments. The audit tables will track what data was changed, when, and by whom

create table save_log(
log_id serial primary key,
username varchar default CURRENT_USER,
tablename varchar,
operation varchar,
op_date timestamp default current_timestamp,
olddata jsonb,
newdata jsonb
)

create or replace function save_log()
returns trigger as $$
begin
if TG_OP = 'INSERT' then 
insert into save_log (username,tablename,operation,olddata,newdata) values(current_user,TG_Table_name,TG_OP,null,row_to_json(new));
elseif TG_OP='UPDATE' then
insert into save_log (username,tablename,operation,olddata,newdata) values(current_user,TG_Table_name,TG_OP,row_to_json(old),row_to_json(new));
elseif TG_OP='DELETE' then
insert into save_log (username,tablename,operation,olddata,newdata) values(current_user,TG_Table_name,TG_OP,row_to_json(old),null);
end if;
return new;
end;
$$ language plpgsql;

create or replace trigger log_trigger
after insert or update or delete on Policies
for each row
execute function save_log()

create or replace trigger log_trigger1
after insert or update or delete on Claims
for each row
execute function save_log()

create or replace trigger log_trigger2
after insert or update or delete on Payments
for each row
execute function save_log()

update Policies set premium_amount=45000 where policy_id=2;
update Claims set claim_date='2025-01-01' where policy_id=45;
update Payments set amount=50000 where policy_id=1;

insert into Claims(policy_id) values(34);
insert into Policies(policy_id) values(1234);
insert into Payments(policy_id) values(12345);

delete from Claims where policy_id=34;
delete from Policies where policy_id=1234;
delete from Claims where policy_id=12345;

select * from save_log;

select * from Policies;
select * from Claims;
select * from Payments;









