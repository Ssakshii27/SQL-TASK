create table students(student_id int primary key, name varchar,email varchar,registration_date timestamp);
copy students from 'D:\ARC\SQL\SQL Task-3\students.csv' delimiter ',' csv header;
select * from students;

create table courses(course_id int primary key,course_name varchar,category varchar,created_at timestamp);
copy courses from 'D:\ARC\SQL\SQL Task-3\courses.csv' delimiter ',' csv header;
select * from courses;

create table enrollments(enrollment_id int primary key,student_id int references students(student_id),course_id int references courses(course_id),enrolled_on date,status varchar);
copy enrollments from 'D:\ARC\SQL\SQL Task-3\enrollments.csv' delimiter ',' csv header;
select * from enrollments;

--1. Retrieve all students who have an active enrollment
select s.student_id,s.name,c.course_id,e.status from students s join enrollments e on s.student_id=e.student_id 
join courses c on c.course_id=e.course_id where e.status='Active';

--2. Find the most enrolled courses
select c.course_id,c.course_name,count(e.enrollment_id) as total_enrollments from courses c 
left join enrollments e on c.course_id=e.course_id group by c.course_name,c.course_id order by total_enrollments desc;

--3. Find students who enrolled in at least 2 courses
select s.student_id,s.name,count(e.course_id) as total_courses_enrolled from students s join enrollments e on s.student_id=e.student_id
group by s.student_id,s.name having count(e.course_id)>=2 ; 

--4. List courses that have no students enrolled
select c.course_id,c.course_name,count(e.enrollment_id) from courses c 
join enrollments e on c.course_id=e.course_id group by c.course_name,c.course_id having count(e.enrollment_id)=0;

--5. Find enrollments with conditional labels
select enrolled_on,
case 
	when enrolled_on<='2024-11-30' then 'Old Enrollment'
	when enrolled_on between '2024-12-01' and '2025-02-28' then 'Mid Enrollment'
	else 'New Enrollment'
end as Type_of_Enrollment
from enrollments;

--6. Count the number of enrollments per course
select c.course_name,count(e.enrollment_id) as total_enrollments from courses c 
join enrollments e on c.course_id=e.course_id group by c.course_name;

--7. Get students who have never enrolled in any course
select s.name,s.student_id,count(e.enrollment_id),c.course_name from students s
join enrollments e on s.student_id=e.student_id
join courses c on c.course_id=e.course_id 
group by s.name,s.student_id,c.course_name having count(e.enrollment_id)=0;

--8. Get students who have enrolled in both 'Python for Data Science' and 'SQL Mastery'
select s.name,s.student_id,c.course_name from students s
join enrollments e on s.student_id=e.student_id
join courses c on c.course_id=e.course_id where c.course_name='Python for Data Science'and c.course_name='SQL Mastery';

--9. Get the latest enrolled students (last 5 enrollments)
select enrolled_on from enrollments order by enrolled_on desc limit 5;

--10. Count the number of students enrolled in each category of courses
select c.course_name,count(e.enrollment_id) as total_students_enrolled from courses c 
join enrollments e on c.course_id=e.course_id group by c.course_name;

--11. Find students who have completed at least one course
select s.student_id,s.name,count(c.course_name) as total_courses,e.status from students s join enrollments e on s.student_id=e.student_id 
join courses c on c.course_id=e.course_id group by s.student_id,e.status having e.status='Completed';

--12. Retrieve students enrolled in courses under 'Programming' category
select s.name,s.student_id,c.course_name,c.category from students s
join enrollments e on s.student_id=e.student_id
join courses c on c.course_id=e.course_id where c.category='Programming';

--13. Get the total number of enrollments per month
select extract(month from enrolled_on) as Months ,count(extract(month from enrolled_on)) as total_enrollments_per_month from enrollments group by extract(month from enrolled_on);

--14. Find students who enrolled but never completed a course
select s.name,s.student_id,c.course_name,e.status from students s
join enrollments e on s.student_id=e.student_id
join courses c on c.course_id=e.course_id where e.status<>'Completed';

--15. Get the earliest and latest enrollment date
select min(enrolled_on) as earliest_enrollment_date,max(enrolled_on) as latest_enrollment_date from enrollments ;

--16. Get students who enrolled in the last 6 months
select s.name,s.student_id,e.enrolled_on from students s join enrollments e on s.student_id=e.student_id where enrolled_on<='2025-03-31' and enrolled_on>='2024-09-01';

--17. Find courses with more than 5 enrollments
select c.course_id,c.course_name,count(e.enrollment_id) as total_enrollments from courses c 
join enrollments e on c.course_id=e.course_id group by c.course_name,c.course_id having count(e.enrollment_id)>5;

--18. Get students and their most recent enrollment date
select s.name,s.student_id,max(e.enrolled_on) from students s join enrollments e on s.student_id=e.student_id group by s.name,s.student_id;

--19. Find students who enrolled but dropped a course
select s.name,s.student_id,c.course_name,e.enrolled_on,e.status from students s
join enrollments e on s.student_id=e.student_id
join courses c on c.course_id=e.course_id where e.status='Dropped';

--20. List courses with the highest number of enrollments
select c.course_name,count(e.enrollment_id) as total_enrollments from courses c 
join enrollments e on c.course_id=e.course_id group by c.course_name order by count(e.enrollment_id) desc;


