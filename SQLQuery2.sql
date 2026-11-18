--Q01
begin tran 
  update Patients
  set WardId = 2
  where Id = 1
commit tran
--Q02
begin tran
  update Consultants
  set salary =  Salary + 5000
  where Id = 1
rollback tran
--disable trigger  trg_consultant_salaryupdate on consultants
--Q03
begin tran
  update Patients 
  set WardId = 3
  where Id = 1

  update Nurses 
  set ServesInWardId = 3
  where Number = 1
commit tran
--Q04
begin tran
  update Patients
  set WardId = 2
  where id = 1
save tran PATIENTUPDATE

  update Patients
  set Name = 'Temporary Patient Name'
  where id = 1
rollback tran PATIENTUPDATE
commit tran
--Q05
begin try
begin tran
  update Consultants 
  set Salary = Salary + 3000
  where Id = 1
commit tran
end try
begin catch
  if @@TRANCOUNT > 0
  rollback tran

  select 
   ERROR_NUMBER() as errorNumber,
   ERROR_MESSAGE() as errorMessage;
end catch;
--Q06
go
create view vw_ConsultantPatientStatistics 
as
select 
 c.id ,
 c.name , 
 c.salary ,
 count (pca.patientId) as AssignedPatientsCount
from Consultants c
left join PatientConsultantAssignments PCA on c.Id = pca.ConsultantId
group by c.Id , c.Name , c.Salary
--Q07
select * 
from vw_ConsultantPatientStatistics
where AssignedPatientsCount > 5 
--Q08
go
CREATE VIEW dbo.vw_IndexedConsultantPatientCount
WITH SCHEMABINDING
AS
SELECT 
    C.Id AS ConsultantID,
    COUNT_BIG(*) AS AssignedPatientsCount
FROM dbo.Consultants C
JOIN dbo.PatientConsultantAssignments PCA ON C.Id = PCA.ConsultantId
GROUP BY C.Id;
GO
CREATE UNIQUE CLUSTERED INDEX IX_IndexedConsultantPatientCount 
ON dbo.vw_IndexedConsultantPatientCount (ConsultantID);
GO
--Q09
select *
from dbo.vw_IndexedConsultantPatientCount
where AssignedPatientsCount > 5
--Q10
SELECT 
    name AS ViewName,
    create_date AS CreationDate,
    modify_date AS ModificationDate
FROM sys.views
--Q11
go
CREATE VIEW vw_PatientInformation
AS
SELECT Id, Name, DOB
FROM Patients;
GO
EXEC sp_helptext 'vw_PatientInformation'
--Q12
go
ALTER VIEW vw_PatientInformation 
AS
SELECT 
    Id, 
    Name, 
    DOB
FROM Patients
--Q13
go
IF OBJECT_ID('vw_ConsultantsSalary', 'V') IS NOT NULL
    DROP VIEW vw_ConsultantsSalary;
go
--Q14
CREATE VIEW vw_PatientHospitalReport AS
SELECT 
    P.Id AS PatientId,
    P.Name AS PatientName,
    P.DOB AS DOB,
    W.Name AS WardName,
    C.Name AS ConsultantName
FROM Patients P
LEFT JOIN Wards W ON P.WardId = W.Id
LEFT JOIN PatientConsultantAssignments PCA ON P.Id = PCA.PatientId
LEFT JOIN Consultants C ON PCA.ConsultantId = C.Id
GO
--Q15
SELECT * 
FROM vw_PatientHospitalReport
WHERE ConsultantName IS NOT NULL
--Q16
SELECT 
    PatientName, 
    WardName, 
    ConsultantName
FROM vw_PatientHospitalReport
WHERE WardName = 'SpecificWardName'
--Q17
SELECT TOP 1 * 
FROM vw_ConsultantPatientStatistics
ORDER BY AssignedPatientsCount DESC
--Q18
SELECT * 
FROM vw_PatientAgeInformation
WHERE Age > 60
--Q19
SELECT * 
FROM vw_ConsultantPatientStatistics
ORDER BY AssignedPatientsCount DESC
--Q20
SELECT 
    WardName, 
    COUNT(PatientId) AS PatientCount
FROM vw_PatientWardInformation
GROUP BY WardName
--Q21
-- de bel ai

SELECT 
    SCHEMA_NAME(v.schema_id) AS SchemaName,
    v.name AS ViewName,
    i.name AS IndexName,
    i.type_desc AS IndexType
FROM sys.views v
JOIN sys.indexes i ON v.object_id = i.object_id
WHERE i.type > 0