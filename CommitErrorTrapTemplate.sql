DECLARE
	@Message VARCHAR(255),
	@Commit BIT,
	@ShowDetail BIT,
	@workorder varchar(10)

SELECT	@Commit 		= 0,
		@ShowDetail 	= 1,
		@workorder 		= 'L9800'

IF @ShowDetail = 1
BEGIN
	SELECT 'BEFORE . . .'
END

BEGIN TRAN
	--DO Stuff

	IF @@Error <> 0  OR @@RowCount <> 1
	BEGIN
		SELECT @Message = 'Failed to NOTIFY DEVELOPER'
		GOTO	END_FAILURE
	END

IF @ShowDetail = 1
BEGIN
	SELECT 'AFTER . . .'
	
END

END_SUCCESS:
	IF @Commit = 1
		BEGIN
			COMMIT TRAN
			Select 'Completed' + @workorder
		END
	ELSE
		BEGIN
			Select 'Completed without Commit' + @workorder
			ROLLBACK TRAN
		END

GOTO END_FINALLY
		
END_FAILURE:
	ROLLBACK TRAN
	RAISERROR (@Message, 16, 10)

END_FINALLY:
	WHILE ( @@TRANCOUNT) > 0
	BEGIN
		RAISERROR ('You had an open transaction so it was rolled back, please fix the script to close the transaction in order to apply your changes ',19,1) WITH LOG
		ROLLBACK TRAN
	END


