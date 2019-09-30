BEGIN TRY
    BEGIN TRANSACTION;
      USE ClaimLineSQL;
            
      DECLARE @Commit           BIT,
				@ShowDetails    BIT,
                @DevTrack       Varchar(7),
                @Developer      Varchar(50),
				@RowCount		INT
                 
      Select @Commit            = 1,
             @ShowDetails       = 0,
             @DevTrack          = 'Lxxx',
             @Developer         = 'Paul Butler'
               
      If @ShowDetails = 1
            BEGIN
				Select 'BEFORE' As Result
            END

		--Do stuff
	 
		--Trap error
		Select @RowCount = @@ROWCOUNT
	
		If @RowCount != 1
		BEGIN
			RAISERROR ('Action Failed', 16, 1)
		END
		
		         
      If @ShowDetails = 1
            BEGIN
                Select 'AFTER' As Result;
            END

      If @Commit = 1
            BEGIN
                COMMIT TRANSACTION;
                Select @DevTrack + ' Transaction Completed' As TransactionStatus;
            END
      Else
            BEGIN
                  ROLLBACK TRANSACTION;
                  Select @DevTrack + ' Transaction Rolled Back' As TransactionStatus;
          END
          
END TRY
BEGIN CATCH

	ROLLBACK TRAN
	EXEC RaiseFormattedError @Developer, @DevTrack

END CATCH;

 

