
USE [<YourDataBaseNameHere>]
GO

BEGIN TRAN

EXEC sys.sp_dropextendedproperty @name=N'SourceCodeVersion' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'<YourTableNameHere>' 
GO

ROLLBACK TRAN
