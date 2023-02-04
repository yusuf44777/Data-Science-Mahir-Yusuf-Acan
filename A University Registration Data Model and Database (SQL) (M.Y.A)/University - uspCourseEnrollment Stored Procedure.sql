--1 - uspCourseEnrollment stored procedure enrolls a student in a lecture. 
--If the total credits of the courses taken by the student is greater than 90 or if the student has registered for the course before, 
--registration is not made.

CREATE PROCEDURE [dbo].[uspCourseEnrollment] (
@StudentID int,
@CourseCode int,
@EnrolledDate datetime
)

AS

BEGIN

DECLARE @EnrolledCredit INT, @TotalCredit INT, @CourseCredit INT

SELECT @EnrolledCredit = SUM(Credit) FROM Course WHERE CourseCode IN ( 
SELECT CourseCode FROM Enrollment WHERE StudentID = @StudentID
)

SELECT @CourseCredit = Credit FROM Course WHERE CourseCode = @CourseCode

SELECT @TotalCredit = @EnrolledCredit + @CourseCredit

IF @TotalCredit > 90
BEGIN

PRINT 'You have exceeded the total credit you can receive!'
RETURN 1

END

IF EXISTS(SELECT 1 FROM Enrollment WHERE StudentID = @StudentID AND CourseCode = @CourseCode)
BEGIN

PRINT 'You have already registered for this course!'
RETURN 1

END

INSERT INTO Enrollment (StudentID, CourseCode, EnrolledDate)
VALUES (@StudentID, @CourseCode, @EnrolledDate)

RETURN 0

END;

GO

***

2 - uspCourseEnrollment stored procedure can be run as follows.

DECLARE @StudentID int, @CourseCode int, @EnrolledDate datetime

SELECT @StudentID = 1,
@CourseCode = 1,
@EnrolledDate = '20201030'

EXEC uspCourseEnrollment @StudentID, @CourseCode, @EnrolledDate