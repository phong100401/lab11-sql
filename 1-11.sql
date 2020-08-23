--nếu CSDL test đã tồn tại thì xóa nó đi
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'test')
	DROP DATABASE test
GO
--tạo một CSDL có tên là test
CREATE DATABASE test
GO
USE test
GO
--tạo bảng Class
CREATE TABLE Class(
	ID INT PRIMARY KEY IDENTITY,
	Name VARCHAR(10),
	Deleted INT NOT NULL DEFAULT (0)
)
GO
--tạo bảng Student
CREATE TABLE Student(
	ID INT PRIMARY KEY IDENTITY,
	Name VARCHAR(30),
	Age INT,
	ClassID INT FOREIGN KEY REFERENCES Class(ID ),
	Deleted INT NOT NULL DEFAULT (0)
)
GO
INSERT INTO Class (Name) VALUES ('C11011') 
GO
--tạo một insert trigger nhằm đảm bảo giá trị của cột tuổi khi chèn vào là luôn luôn lớn hơn 16
CREATE TRIGGER CheckAgeOnInsert
ON Student
FOR INSERT 
AS
	BEGIN
		IF EXISTS(SELECT * FROM inserted WHERE Age<16)
		BEGIN
			PRINT 'Tuổi không thể nhỏ hơn 16';
			ROLLBACK TRANSACTION;
		END
	END
GO
--KIỂM TRA SỰ HOẠT ĐỘNG CỦA INSERT TRIGGER VỪA TẠO Ở TRÊN
--câu lệnh sau sẽ không thể chèn vào vì có tuổi nhỏ hơn 16
INSERT INTO Student VALUES('Nguyễn Văn Tèo',15,1,0)
--thỏa mãn điều kiện mới dc insert
INSERT INTO Student VALUES('Nguyễn Bình Minh',19,1,0)
GO
--tạo 1 UPDATE trigger nhằm đảm bảo rằng khi tiến hành cập nhật dữ liệu thì tuổi mới phải luôn lơn hơn tuổi cũ
CREATE TRIGGER CheckAgeOnUpdate
ON Student
FOR UPDATE
AS
	BEGIN
		IF EXISTS(SELECT * FROM inserted I INNER JOIN deleted D
			ON I.ID=D.ID WHERE D.Age>I.Age)
		BEGIN
			PRINT'Tuổi mới khôg thể nhỏ hơn tuổi trc đó';
			ROLLBACK TRANSACTION;
		END
	END
GO
--kiểm tra sự hoạt động của trigger vừa tạo
--chèn mộy sinh viên có tuổi là 20 vào bảg Student
INSERT INTO Student VALUES('Nguyễn Văn Tèo',20,1,0)
--tiến hành cập nhật tuổi cho sinh viên trên,câu lệnh nầy sẽ cập nhật dc tuổi của sinh viên
--bởi vì tuổi mới là 19,trog khi đó tuổi cũ là 20
UPDATE Student SET Age = 19 WHERE Name LIKE 'Nguyễn Văn Tèo';
GO
--tạo một DELETE trigger nhằm không cho phép xóa hẳn một student khỏi bảng Student
--thay vào đó ta sẽ chuyển giá trị của cột Deleted thành 1
CREATE TRIGGER DeleteStudent
ON Student
FOR DELETE
AS
	BEGIN
		DECLARE @ID int;
		SELECT @ID = ID FROM deleted;
		ROLLBACK TRANSACTION;
		UPDATE Student SET Deleted = 1 WHERE ID = @ID;
	END
GO
--kiểm tra sự hoạt độg của trigger vừa tạo
-- INSERT INTO Student VALUES('Tèo',20,1)
--thực hiện xóa 1sv có ID là 1,sau khi thực hiện câu lệnh bên dưới thì 
--bản ghi của sv này không bị xóa đi,mà thay vào đó thì giá trị của cột Deleted của bản ghi này sẽ có giá trị là 1
--Trigger áp dụng cho xóa nhiều bản ghi
ALTER TRIGGER DeleteStudent
ON Student
FOR DELETE
AS
	BEGIN
		UPDATE Student SET Deleted=1 WHERE ID IN (SELECT ID FROM deleted);
		ROLLBACK TRANSACTION;
	END
GO

INSERT INTO Student VALUES('Tèo',20,0)
SELECT * FROM Student
DELETE FROM Student WHERE ID = 3
GO
--tạo 1INSERT OF trigger nhằm đảm bảo rằng khi ta xóa một lớp ra khỏi bảng Class
--thì đồng thời ta cũng xóa đi tất cả các sv của lớp đó
--(thực sự thì các sv này chỉ bị chuyển sang trạng thái Delete=1 mà thôi)
CREATE TRIGGER DeleteClass
ON Class
INSERTAD OF DELETE
AS
	BEGIN
		DELETE FROM Student