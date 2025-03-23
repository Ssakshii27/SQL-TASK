select * from students;
select * from courses;
select * from enrollments;
--1. Retrieve all students who have an active enrollment
select student_id,name from students where student_id in (select student_id from enrollments where status='Active');

--2. Find the most enrolled courses
select course_id,(select course_name from courses c where c.course_id=e.course_id),count(course_id) as no_of_enrollments_per_course from enrollments e group by course_id order by count(course_id) desc;;

--3. Find students who enrolled in at least 2 courses
select student_id,(select name from students s where s.student_id=e.student_id),count(student_id) as no_of_enrollments from enrollments e group by student_id having count(student_id)>=2;

--4. List courses that have no students enrolled
select course_id,(select course_name from courses c where c.course_id=e.course_id),count(enrollment_id) as total_enrollments from enrollments e  group by enrollment_id having count(enrollment_id)=0;

--5. Find enrollments with conditional labels
select enrolled_on,status, case
when enrolled_on<='2024-11-30' then 'Old Enrollment'
when enrolled_on between '2024-12-01' and '2025-02-28' then 'Mid Enrollment'
else 'New Enrollment'
end as Type_of_Enrollment from enrollments; 

--6. Count the number of enrollments per course
select course_id,(select course_name from courses c where c.course_id=e.course_id),count(course_id) as no_of_enrollments_per_course from enrollments e group by course_id ;;

--7. Get students who have never enrolled in any course
select student_id,(select name from students s where s.student_id=e.student_id),count(enrollment_id) as total_enrollments from enrollments e  group by enrollment_id having count(enrollment_id)=0;

--8. Get students who have enrolled in both 'Python for Data Science' and 'SQL Mastery'
select student_id,(select name from students s where s.student_id=e.student_id) from enrollments e where e.course_id in(select course_id from courses where course_name in ('Python for Data Science','SQL Mastery'));

--9. Get the latest enrolled students (last 5 enrollments)
select student_id,(select name from students s where s.student_id=e.student_id),enrolled_on from enrollments e order by enrolled_on desc limit 5;

--10. Count the number of students enrolled in each category of courses
select course_id,(select course_name from courses c where c.course_id=e.course_id),count(course_id) as no_of_student_enrolled_per_course from enrollments e group by course_id order by course_id;

--11. Find students who have completed at least one course
select e.student_id,(select name from students s where s.student_id=e.student_id),count(e.course_id) as total_courses,status from enrollments e group by e.student_id,e.status having status='Completed';

--12. Retrieve students enrolled in courses under 'Programming' category
select e.student_id,(select name from students s where s.student_id=e.student_id),(select course_name from courses c where c.course_id=e.course_id),e.course_id from enrollments e where e.course_id in (select course_id from courses where category='Programming') ;

--13. Get the total number of enrollments per month
select extract(month from enrolled_on) as Months,count(extract(month from enrolled_on)) as total_enrollments_per_month from enrollments group by extract(month from enrolled_on); 

--14. Find students who enrolled but never completed a course
select e.student_id,(select name from students s where s.student_id=e.student_id),e.course_id ,status from enrollments e where status<>'Completed';

--15. Get the earliest and latest enrollment date
select max(enrolled_on) as latest,min(enrolled_on) as earliest from enrollments;

--16. Get students who enrolled in the last 6 months
select e.student_id,(select name from students s where s.student_id=e.student_id),e.course_id,enrolled_on from enrollments e where enrolled_on<='2025-03-31' and enrolled_on>='2024-09-01';

--17. Find courses with more than 5 enrollments
select course_id,(select course_name from courses c where c.course_id=e.course_id),count(enrollment_id) from enrollments e group by course_id having count(enrollment_id)>5 ;

--18. Get students and their most recent enrollment date
select student_id,(select name from students s where s.student_id=e.student_id),max(enrolled_on) as recent_enrollment_date from enrollments e group by student_id;

--19. Find students who enrolled but dropped a course
select e.student_id,(select name from students s where s.student_id=e.student_id),e.course_id,enrollment_id,status from enrollments e where status='Dropped';

--20. List courses with the highest number of enrollments
select course_id,(select course_name from courses c where c.course_id=e.course_id),count(course_id) as no_of_enrollments_per_course from enrollments e group by course_id order by count(course_id) desc;



