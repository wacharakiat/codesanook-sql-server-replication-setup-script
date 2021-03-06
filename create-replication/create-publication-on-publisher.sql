DECLARE @publicationDB AS sysname
DECLARE @publication AS sysname
DECLARE @username AS sysname
DECLARE @password AS sysname

SET @publicationDB = '$(publicationDB)'
SET @publication = '$(publication)'

-- SQL Server authentication login
SET @username = '$(username)'
SET @password = '$(password)' 

-- Enable transactional replication on the publication database.
EXEC sp_replicationdboption 
	@dbname = @publicationDB, 
	@optname ='publish',
	@value = 'true'

-- Execute sp_addlogreader_agent to create an agent job. 
EXEC sp_addlogreader_agent
	-- Explicitly specify SQL Server Authentication when connecting to a publisher.
	@publisher_security_mode = 0,
	@publisher_login = @username,
    @publisher_password = @password


-- Create a new transactional publication with the required properties. 
EXEC sp_addpublication 
	@publication = @publication, 
	@status = 'active',
	@allow_push = 'true',
	@independent_agent = 'true',
	@allow_initialize_from_backup = 'false', -- Prevent errors that not create replication for stored proc 
	@immediate_sync = 'true' -- Avoid missing transactions while subscribers are being brought online.
