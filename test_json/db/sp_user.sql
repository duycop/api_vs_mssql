-- =============================================
-- Author     : do duy cop
-- Create date: 2024 april 26
-- Description:	SP xử lý bảng User
-- xử lý 6 nhiệm vụ: check_login, list user, change pw, set pw, del user, add new user
-- check_login: input(@uid,@pwd) -> ouput: json (ok=1,fullname) or ok=0
-- list_user: ko cần input , output: mọi user, ko show pw
-- change_pw: input(@uid,@pwd, @pwd_new) => ok thành công || pwd sai
-- .....
-- =============================================
alter PROCEDURE SP_User
	@action varchar(50),
    @uid varchar(50)=null,
	@pwd nvarchar(50)=null,
	@pwd_new nvarchar(50)=null
AS
BEGIN
	declare @fullname nvarchar(50)=null, @ok int=null;

	if(@action='check_login')
	begin		
		select @fullname=[fullname],@ok=1
		from [User]
		where [uid]=@uid and 
			HASHBYTES('SHA2_256', [pwd])=HASHBYTES('SHA2_256', @pwd);
		
		if(@ok is null)
			select (
				select 0 as ok,
				       N'Có gì đó sai sai!' as msg
				for json path,WITHOUT_ARRAY_WRAPPER 
			) as result;
		else
		  begin
		    update [user] 
			set LastLogin=getDate()
			where uid=@uid;

			select (
				select 1 as ok,
					   N'login ok' as msg,
					   @uid as uid,
					   isnull(@fullname,'') as fullname
				for json path,WITHOUT_ARRAY_WRAPPER 
			) as result;
		  end;
	end
	if(@action='list_user')
	begin
		select(
			select uid,fullname,lastLogin
			from [User]
			for json path
		) as [list_user]
	end;
	else if(@action='change_pw')
	begin
		select @fullname=[fullname],@ok=1
		from [User]
		where [uid]=@uid and 
			HASHBYTES('SHA2_256', [pwd])=HASHBYTES('SHA2_256', @pwd);
		
		if(@ok is null)
			select (
				select 0 as ok,
				       N'Có gì đó sai sai với pw cũ!' as msg
				for json path,WITHOUT_ARRAY_WRAPPER 
			) as result;
		else
		  begin
		    update [user] 
			set pwd=@pwd_new
			where uid=@uid;

			select (
				select 1 as ok,
					   N'change pw ok' as msg,
					   @uid as uid,
					   isnull(@fullname,'') as fullname
				for json path,WITHOUT_ARRAY_WRAPPER 
			) as result;
		  end;
	end
END
GO
