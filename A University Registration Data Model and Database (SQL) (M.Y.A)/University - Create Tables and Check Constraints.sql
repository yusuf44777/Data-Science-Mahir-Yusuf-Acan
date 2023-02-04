--
-- Create Database: University
--

-- CREATE DATABASE University;
-- USE University;


--
-- Table structure for table 'Staff'
--

CREATE TABLE Staff (
  StaffNo int NOT NULL IDENTITY(1,1),
  StaffFirstName varchar(255) NOT NULL,
  StaffLastName varchar(255) NOT NULL,
  StaffRegion varchar(255) NOT NULL,
  PRIMARY KEY (StaffNo)
);


--
-- Table structure for table 'Student'
--

CREATE TABLE Student (
  StudentID int NOT NULL IDENTITY(1,1),
  StudentFirstName varchar(255) NOT NULL,
  StudentLastName varchar(255) NOT NULL,
  RegisteredDate datetime NOT NULL,
  StudentRegion varchar(255) NOT NULL,
  StaffNo int NOT NULL,
  CONSTRAINT fk1_staff_no FOREIGN KEY (StaffNo) REFERENCES Staff (StaffNo),
  PRIMARY KEY (StudentID)
);


--
-- Table structure for table 'Course'
--

CREATE TABLE Course (
  CourseCode int NOT NULL IDENTITY(1,1),
  Title varchar(255) NOT NULL,
  Credit int NOT NULL CONSTRAINT check_credit CHECK (Credit=15 OR Credit=30),
  Quota int NOT NULL,
  StaffNo int NOT NULL,
  CONSTRAINT fk2_staff_no FOREIGN KEY (StaffNo) REFERENCES Staff (StaffNo),
  PRIMARY KEY (CourseCode)
);


--
-- Table structure for table 'Enrollment'
--

CREATE TABLE Enrollment (
  StudentID int NOT NULL,
  CourseCode int NOT NULL,
  EnrolledDate datetime NOT NULL,
  FinalGrade int,
  CONSTRAINT fk1_student_id FOREIGN KEY (StudentID) REFERENCES Student (StudentID),
  CONSTRAINT fk1_course_code FOREIGN KEY (CourseCode) REFERENCES Course (CourseCode),
  PRIMARY KEY (StudentID, CourseCode)
);


--
-- Table structure for table 'Assignment'
--

CREATE TABLE Assignment (
  StudentID int NOT NULL,
  CourseCode int NOT NULL,
  AssignmentNo int NOT NULL,
  Grade int NOT NULL CONSTRAINT check_grade CHECK (Grade BETWEEN 0 AND 100),
  CONSTRAINT fk_student_course FOREIGN KEY (StudentID, CourseCode) REFERENCES Enrollment (StudentID, CourseCode),
  PRIMARY KEY (StudentID, CourseCode, AssignmentNo)
);





--////////////////////////////////
--///////////////////////////////
--//////////////////////////////


--CONSTRAINTS

CREATE FUNCTION check_volume()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT sc.StudentID, sum(Credit) 
FROM Course c JOIN StudentCourse sc ON c.CourseID=sc.CourseID
GROUP BY sc.StudentID
HAVING SUM(Credit) > 180) 
SELECT @ret = 1 ELSE SELECT @ret = 0;
RETURN @ret;
END;


ALTER TABLE StudentCourse
ADD CONSTRAINT square_volume CHECK(dbo.check_volume() = 0);


CREATE FUNCTION check_volume2()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT avg(c.Quota) - count(c.CourseID)
FROM Course c JOIN StudentCourse sc ON c.CourseID=sc.CourseID
GROUP BY c.CourseID   
HAVING avg(c.Quota) -count(c.CourseID) < 0)
SELECT @ret = 1 ELSE SELECT @ret = 0;
RETURN @ret;
END;


ALTER TABLE StudentCourse
ADD CONSTRAINT square_volume2 CHECK(dbo.check_volume2() = 0);


CREATE FUNCTION check_volume3()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT count(a.AssignmentID)
FROM Assignment a JOIN StudentCourse sc ON a.CourseID=sc.CourseID and a.StudentID = sc.StudentID
JOIN Course c ON a.CourseID = c.CourseID 
WHERE c.Credit = 30 
GROUP BY sc.StudentID, c.CourseID 
HAVING count(a.AssignmentID) > 5)
SELECT @ret =1 ELSE SELECT @ret = 0;
RETURN @ret;
END;


ALTER TABLE Assignment
ADD CONSTRAINT square_volume3 CHECK(dbo.check_volume3() = 0);


CREATE FUNCTION check_volume4()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT count(a.AssignmentID)
FROM Assignment a JOIN StudentCourse sc ON a.CourseID=sc.CourseID and a.StudentID = sc.StudentID
JOIN Course c ON a.CourseID = c.CourseID 
WHERE c.Credit = 15 
GROUP BY sc.StudentID, c.CourseID 
HAVING count(a.AssignmentID) > 3)
SELECT @ret =1 ELSE SELECT @ret = 0;
RETURN @ret;
END;


ALTER TABLE Assignment
ADD CONSTRAINT square_volume4 CHECK(dbo.check_volume4() = 0);


CREATE FUNCTION check_volume5()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT *
FROM Region r JOIN Student s ON r.RegionID = s.RegionID JOIN StudentStaff ss ON s.StudentID = ss.StudentID JOIN Staff sf ON ss.StaffID = sf.StaffID
WHERE s.RegionID != sf.RegionID)
SELECT @ret =1 ELSE SELECT @ret = 0;
RETURN @ret;
END;


ALTER TABLE StudentStaff
ADD CONSTRAINT square_volume5 CHECK(dbo.check_volume5() = 0);


CREATE FUNCTION check_volume6()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT Count(s.StudentID)
FROM Region r JOIN Student s ON r.RegionID = s.RegionID JOIN StudentStaff ss ON s.StudentID = ss.StudentID JOIN Staff sf ON ss.StaffID = sf.StaffID
WHERE StaffType = 'Counsel'
GROUP BY s.StudentID
HAVING Count(s.StudentID) != 1)
SELECT @ret =1 ELSE SELECT @ret = 0;
RETURN @ret;
END;


ALTER TABLE StudentStaff
ADD CONSTRAINT square_volume6 CHECK(dbo.check_volume6() = 0);





