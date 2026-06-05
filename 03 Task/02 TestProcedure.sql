USE [test]
GO

DECLARE	@return_value int

EXEC	@return_value = dbo.StatisticsAndDataAggregation

SELECT	'Return Value' = @return_value

GO
