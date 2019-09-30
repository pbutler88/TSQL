BEGIN TRY
    BEGIN TRANSACTION;
      USE ClaimLineSQL;
            
      DECLARE @Commit           BIT,
				@ShowDetails    BIT,
                @DevTrack       Varchar(7),
                @Developer      Varchar(50),
				@RowCount		INT,
				@PRPaymentKey	INT,
				@DateRequested  DateTime = GetDate(),
				@ProcessedDate  DateTime = GetDate(),
				@ErrorCode		INT,
     			@PHPaymentKey	INT, 
     			@Error			INT, 
     			@ErrorMessage	Varchar(255)
                 
      Select @Commit            = 0,
             @ShowDetails       = 1,
             @DevTrack          = 'L4',
             @Developer         = 'Paul Butler'

         
      If @ShowDetails = 1
            BEGIN
				Select 'BEFORE' As Result
				
            END

		--PERFORM ACTIONS
		DECLARE curRequest INSENSITIVE Cursor FOR 

		Select A.CNRLink, A.MedCheck, -(A.AmountRequested), AI.CompanyCode, A.DOS, 'Refund amount over billed' As Comments
		from #Adjustments as A
			JOIN Cases as C
				on C.CNRLink = A.CNRLink
			JOIN AccidentInfo as AI
				on C.CNR = AI.CNR
		Order by CNRLink, MedCheck, AmountRequested
				
		Open curRequest

		DECLARE @CNRLink nVarchar(22), 
				@MedCheck Varchar(15), 
				@AmountRequested Money,
				@CompanyCode INT,
				@DOS datetime,
				@Comments varchar(255)

		While 1 = 1
			BEGIN
				Fetch NEXT FROM curRequest INTO @CNRLink, @MedCheck, @AmountRequested, @CompanyCode, @DOS, @Comments
				IF (@@FETCH_STATUS <> 0)
					Break
			
					--Select @CNRLink, @MedCheck, @AmountRequested, @CompanyCode, @DOS, @Comments
				     		 
			END

		CLOSE curRequest
		DEALLOCATE curRequest
		
		         
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

 

