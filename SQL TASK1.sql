create table employee_details (
EmployeeID 	serial ,
FirstName  varchar(50),
LastName varchar(50),	
Email varchar(100),
PhoneNumber	varchar(15),
HireDate date,	
Salary decimal(10,2),
DepartmentID int,	
IsActive boolean,
JobTitle varchar(100)
);

insert into employee_details values(1,'Sakshi','Sawate','sakshisawate1@gmail.com',7499163023,'2020/07/27',35000,3,'Yes','Data Analyst'),
(2,'Rajesh','Sharma','rajeshsharma@gmail.com',9234567890,'2021/04/03',40000,4,'Yes','Data Scientist'),
(3,'Tina','Tiwari','tinatiwari@gmail.com',8765432194,'2022/05/09',50000,1,'No','HR'),
(4,'Parul','Gulati','parulgulati@gmail.com',9235454343,'2022/12/27',60000,7,'Yes','Project Lead'),
(5,'Sharvari','Kamble','sharvarikamble@gmail.com',9649063268,'2021/04/05',30000,8,'Yes','Sales');

truncate employee_details;

copy employee_details from 'D:\ARC\SQL\SQL Task-1\Employee_Details.csv' delimiter ',' csv header;

update employee_details set departmentid=0 where isactive='false';

update employee_details set salary=(salary+(salary*0.08)) where isactive='false' and departmentid=0 and jobtitle in('HR Manager','Financial Analyst','Business Analyst','Data Analyst') returning Firstname,salary;

select Firstname,Lastname from employee_details where salary between 30000 and 50000;

select * from employee_details where Firstname ilike'A%';

delete from employee_details where employeeid between 1 and 5;

alter table employee_details rename to employee_database;
alter table employee_database rename column Firstname to Name;
alter table employee_database rename column Lastname to Surname;


alter table employee_database add column State varchar NOT NULL DEFAULT 'Unknown';
update employee_database set State='India' where isactive=true;
update employee_database set State='USA' where isactive=false;

select * from employee_database;