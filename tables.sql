IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tblPasswordReset]') AND type in (N'U'))
DROP TABLE tblPasswordReset;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tblUserSocialMedia]') AND type in (N'U'))
DROP TABLE tblUserSocialMedia;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tblUserEmails]') AND type in (N'U'))
DROP TABLE tblUserEmails;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tblUsers]') AND type in (N'U'))
DROP TABLE tblUsers;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[prmSocialNetwork]') AND type in (N'U'))
DROP TABLE prmSocialNetwork;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[prmCountry]') AND type in (N'U'))
DROP TABLE prmCountry;
GO

CREATE TABLE prmCountry
(
	cnt_id INT NOT NULL,
	cnt_name NVARCHAR(35) NOT NULL,
	cnt_code NVARCHAR(2) NOT NULL,
	CONSTRAINT pk_CountryId PRIMARY KEY (cnt_id),
	CONSTRAINT uc_CountryCode UNIQUE (cnt_code)
);

CREATE TABLE prmSocialNetwork
(
	socntw_id INT NOT NULL,
	socntw_name NVARCHAR(30) NOT NULL,
	CONSTRAINT pk_SocialNetworkId PRIMARY KEY (socntw_id)
);

CREATE TABLE tblUsers
(
	us_id INT IDENTITY(1,1),
	us_name NVARCHAR(254) NOT NULL,
	us_password NVARCHAR(MAX) NOT NULL,
	us_registration_date DATETIME NOT NULL,
	us_cnt_id INT,
	us_profile_picture NVARCHAR(MAX) NOT NULL,
	CONSTRAINT pk_tblUsers_UserId PRIMARY KEY (us_id),
	CONSTRAINT fk_UserDetails_CountryId FOREIGN KEY (us_cnt_id) REFERENCES prmCountry(cnt_id)
);

CREATE TABLE tblUserEmails
(
	usem_email NVARCHAR(254) NOT NULL,
	usem_us_id INT NOT NULL,
	usem_verified BIT NOT NULL DEFAULT(0),
	usem_verified_date DATETIME NULL,
	CONSTRAINT pk_UserEmail PRIMARY KEY (usem_email),
	CONSTRAINT fk_UserEmails_UserId FOREIGN KEY (usem_us_id) REFERENCES tblUsers(us_id)
);

CREATE TABLE tblUserSocialMedia
(
	ussm_socntw_id INT NOT NULL,
	ussm_socntw_user_id NVARCHAR(100) NOT NULL,
	ussm_usem_email NVARCHAR(254) NOT NULL,
	ussm_us_id INT NOT NULL,
	CONSTRAINT pk_UserSocialMedia PRIMARY KEY (ussm_socntw_id, ussm_socntw_user_id),
	CONSTRAINT fk_UserSocialMedia_UserId FOREIGN KEY (ussm_us_id) REFERENCES tblUsers(us_id),
	CONSTRAINT fk_UserSocialMedia_SocialNetworkId FOREIGN KEY (ussm_socntw_id) REFERENCES prmSocialNetwork(socntw_id),
	CONSTRAINT fk_UserSocialMedia_Email FOREIGN KEY (ussm_usem_email) REFERENCES tblUserEmails(usem_email),
	CONSTRAINT uq_UserSocialMedia_SocialNetworkUserId UNIQUE (ussm_socntw_id, ussm_usem_email)
);

CREATE TABLE tblPasswordReset
(
	pwr_email NVARCHAR(254) NOT NULL UNIQUE,
	pwr_code VARCHAR(6) NOT NULL, 
	pwr_request_date DATETIME NOT NULL,
	pwr_attempts INT NOT NULL DEFAULT(0)
	CONSTRAINT pk_PasswordResetEmail PRIMARY KEY (pwr_email)
);