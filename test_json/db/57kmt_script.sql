USE [QLSV]
GO
/****** Object:  UserDefinedFunction [dbo].[FN_GiaiPTB2]    Script Date: 2024-04-26 12:30:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Đỗ Duy Cốp
-- Create date: 17.4.2024
-- Description:	Giải toán ptb2 bằng sql cũng ok
-- =============================================
CREATE FUNCTION [dbo].[FN_GiaiPTB2]
(
	@a float,
	@b float,
	@c float
)
RETURNS nvarchar(max)
AS
BEGIN	
	DECLARE @kq nvarchar(max)='';
	--step1: calc detal =b^2-4ac
	--step2: if(delta>0):ptb2 có 2 nghiệm x1,2=(-b-+sqrt(delta))/2a
    --       else ptb2 ko có nghiệm thực
	declare @delta float = @b*@b - 4*@a*@c;
	if @delta >=0
	begin
		declare @x1 float = (-@b-sqrt(@delta))/(2*@a);
		declare @x2 float = (-@b+sqrt(@delta))/(2*@a);
		set @kq = FormatMessage(N'ptb2 có 2 nghiệm: x1=%s x2=%s',cast(@x1 as varchar),cast(@x2 as varchar))
	end
	else
		set @kq = N'ptb2 ko có nghiệm thực';
	RETURN @kq;
END
GO
/****** Object:  Table [dbo].[PTB2]    Script Date: 2024-04-26 12:30:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PTB2](
	[a] [float] NOT NULL,
	[b] [float] NOT NULL,
	[c] [float] NOT NULL,
	[loi_giai] [nvarchar](max) NULL,
 CONSTRAINT [PK_PTB2] PRIMARY KEY CLUSTERED 
(
	[a] ASC,
	[b] ASC,
	[c] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[User]    Script Date: 2024-04-26 12:30:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[uid] [varchar](50) NOT NULL,
	[pwd] [nvarchar](50) NULL,
	[fullname] [nvarchar](50) NULL,
	[lastLogin] [datetime] NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[PTB2] ([a], [b], [c], [loi_giai]) VALUES (1, 2, -3, N'ptb2 có 2 nghiệm: x1=-3 x2=1')
INSERT [dbo].[PTB2] ([a], [b], [c], [loi_giai]) VALUES (1, 2, 3, N'ptb2 ko có nghiệm thực')
INSERT [dbo].[PTB2] ([a], [b], [c], [loi_giai]) VALUES (4, -1, -3, N'ptb2 có 2 nghiệm: x1=-0.75 x2=1')
INSERT [dbo].[PTB2] ([a], [b], [c], [loi_giai]) VALUES (77, 88, -100, N'ptb2 có 2 nghiệm: x1=-1.84627 x2=0.703417')
INSERT [dbo].[PTB2] ([a], [b], [c], [loi_giai]) VALUES (99, 88, -77, N'ptb2 có 2 nghiệm: x1=-1.43202 x2=0.543133')
GO
INSERT [dbo].[User] ([uid], [pwd], [fullname], [lastLogin]) VALUES (N'admin', N'123', N'Nguyễn Văn Chí', CAST(N'2024-04-26T09:32:10.540' AS DateTime))
INSERT [dbo].[User] ([uid], [pwd], [fullname], [lastLogin]) VALUES (N'cop', N'789', NULL, CAST(N'2024-04-26T09:14:22.557' AS DateTime))
INSERT [dbo].[User] ([uid], [pwd], [fullname], [lastLogin]) VALUES (N'hoa', N'456', N'Nguyễn Thị Tuyết Hoa', CAST(N'2024-04-26T09:32:25.053' AS DateTime))
GO
/****** Object:  StoredProcedure [dbo].[SP_User]    Script Date: 2024-04-26 12:30:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		do duy cop
-- Create date: 2024 april 26
-- Description:	SP xử lý bảng User
-- xử lý 6 nhiệm vụ: check_login, list user, change pw, set pw, del user, add new user
-- check_login: input(@uid,@pwd) -> ouput: json (ok=1,fullname) or ok=0
-- list_user: ko cần input , output: mọi user, ko show pw
-- =============================================
CREATE PROCEDURE [dbo].[SP_User]
	@action varchar(50),
    @uid varchar(50)=null,
	@pwd nvarchar(50)=null
AS
BEGIN
	if(@action='check_login')
	begin
		declare @fullname nvarchar(50)=null,
		        @ok int=null;
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
	end
END
GO
