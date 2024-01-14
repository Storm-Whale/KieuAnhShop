USE KIEUANHSHOP
GO

CREATE PROC pro_InsertSP
	@tenSP NVARCHAR(50), @kichThuoc NVARCHAR(20),
	@mauSac NVARCHAR(20), @gia DECIMAL(10,2),
	@soLuongTonKho INT, @mota NTEXT
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @id_SP INT;
	INSERT INTO SANPHAM (TENSP, MOTA, GIA, SOLUONGTRONGKHO) VALUES 
		(@tenSP,@mota,@gia,@soLuongTonKho);
	SET @id_SP = SCOPE_IDENTITY();

	INSERT INTO CHITETSP (IDSP, KICHTHUOC, MAUSAC) VALUES 
		(@id_SP,@kichThuoc,@mauSac);
END

GO

CREATE PROC pro_UpdateSP
	@idSP INT,
	@tenSP NVARCHAR(50), @kichThuoc NVARCHAR(20),
	@mauSac NVARCHAR(20), @gia DECIMAL(10,2),
	@soLuongTonKho INT, @mota NTEXT
AS
BEGIN
    UPDATE SANPHAM SET TENSP = @tenSP, SOLUONGTRONGKHO = @soLuongTonKho, 
		GIA = @gia, MOTA = @mota
			WHERE IDSP = @idSP;
	UPDATE dbo.CHITETSP SET MAUSAC = @mauSac, KICHTHUOC = @kichThuoc
		WHERE IDSP = @idSP
END

GO

CREATE PROC pro_DeleteSP
	@idSP INT
AS
BEGIN
	DELETE FROM dbo.CHITETSP WHERE IDSP = @idSP;
    DELETE FROM dbo.SANPHAM WHERE IDSP = @idSP;
END

GO 
CREATE PROC pro_ThemMoiSPVaoGioHang
	@idhd INT,
	@idhdct INT,
	@idsp INT,
	@soluong INT
AS
BEGIN
	DECLARE @tongTien DECIMAL(12,2);
	SELECT @tongTien = TONGTIEN FROM dbo.HOADON WHERE IDHD = @idhd;
	DECLARE @giaSp DECIMAL(12,2);
	SELECT @giaSp = GIA FROM dbo.SANPHAM WHERE IDSP = @idsp; 
    INSERT INTO dbo.CHITIETSPTRONGHOADON (IDHDCT, IDSP, SOLUONG, GIA, TONGTIEN) VALUES
    (   @idhdct, -- IDHDCT - int
        @idsp, -- IDSP - int
        @soluong,    -- SOLUONG - int
        @giaSp, -- GIA - decimal(10, 2)
        @giaSp*@soluong  -- TONGTIEN - decimal(12, 2)
	)

	UPDATE dbo.SANPHAM SET SOLUONGTRONGKHO = SOLUONGTRONGKHO-@soluong WHERE IDSP = @idsp

	UPDATE dbo.HOADON SET TONGTIEN = TONGTIEN + @soluong*@giaSp WHERE IDHD = @idhd
	UPDATE dbo.CHITIETHOADON SET SLSP = SLSP + @soluong, TONGTIENSP = TONGTIENSP + @soluong*@giaSp WHERE IDHD = @idhd
END

EXEC dbo.pro_ThemMoiSPVaoGioHang @idhd = 3,   -- int
                                 @idhdct = 3, -- int
                                 @idsp = 2,   -- int
                                 @soluong = 1 -- int

GO 
CREATE PROC pro_UpdateGioHang
	@idhd INT,
	@idhdct INT,
	@idsptgh INT,
	@idsp INT,
	@soluong INT
AS
BEGIN
	DECLARE @giaSp DECIMAL(12,2);
	SELECT @giaSp = GIA FROM dbo.SANPHAM WHERE IDSP = @idsp; 
	DECLARE @sl_SP_TrongGH INT;
	SELECT @sl_SP_TrongGH = SOLUONG FROM dbo.CHITIETSPTRONGHOADON 
		WHERE IDSPCTTHD = @idsptgh
---------------------Thực hiện Update dữ liệu trong Database-----------------------------------
	IF @soluong > @sl_SP_TrongGH
	BEGIN
	    UPDATE dbo.CHITIETSPTRONGHOADON SET SOLUONG = @soluong, 
			TONGTIEN = TONGTIEN + @giaSp*(@soluong - @sl_SP_TrongGH)
				WHERE IDSPCTTHD = @idsptgh;
		UPDATE dbo.CHITIETHOADON SET SLSP = SLSP + (@soluong - @sl_SP_TrongGH),
			TONGTIENSP = TONGTIENSP + @giaSp*(@soluong - @sl_SP_TrongGH)
				WHERE IDHD = @idhd;
		UPDATE dbo.HOADON SET TONGTIEN = TONGTIEN + @giaSp*(@soluong - @sl_SP_TrongGH)
			WHERE IDHD = @idhd;
		UPDATE dbo.SANPHAM SET SOLUONGTRONGKHO = SOLUONGTRONGKHO - (@soluong - @sl_SP_TrongGH)
			WHERE IDSP = @idsp;
	END
	ELSE 
	BEGIN
	     UPDATE dbo.CHITIETSPTRONGHOADON SET SOLUONG = @soluong, 
			TONGTIEN = TONGTIEN - @giaSp*(@sl_SP_TrongGH - @soluong)
				WHERE IDSPCTTHD = @idsptgh;

		UPDATE dbo.CHITIETHOADON SET SLSP = SLSP - (@sl_SP_TrongGH - @soluong),
			TONGTIENSP = TONGTIENSP - @giaSp*(@sl_SP_TrongGH - @soluong)
				WHERE IDHD = @idhd;

		UPDATE dbo.HOADON SET TONGTIEN = TONGTIEN - @giaSp*(@sl_SP_TrongGH - @soluong)
			WHERE IDHD = @idhd;

		UPDATE dbo.SANPHAM SET SOLUONGTRONGKHO = SOLUONGTRONGKHO + (@sl_SP_TrongGH - @soluong)
			WHERE IDSP = @idsp;
	END
END

GO

EXEC dbo.pro_UpdateGioHang @idhd = 3,    -- int
                           @idhdct = 3,  -- int
                           @idsptgh = 5, -- int
                           @idsp = 3,    -- int
                           @soluong = 1  -- int
GO
CREATE PROC pro_DeleteSpTrongGioHang
	@idhd INT,
	@idhdct INT,
	@idsp INT,
	@@idsptgh INT
AS
BEGIN
	DECLARE @giaSp DECIMAL(12,2);
	SELECT @giaSp = GIA FROM dbo.SANPHAM WHERE IDSP = @idsp; 
	DECLARE @sl_SP_TrongGH INT;
	SELECT @sl_SP_TrongGH = SOLUONG FROM dbo.CHITIETSPTRONGHOADON 
		WHERE IDSPCTTHD = @@idsptgh
	UPDATE dbo.SANPHAM SET SOLUONGTRONGKHO = SOLUONGTRONGKHO + @sl_SP_TrongGH
		WHERE IDSP = @idsp
	UPDATE dbo.CHITIETHOADON SET 
		SLSP = SLSP - @sl_SP_TrongGH, TONGTIENSP = TONGTIENSP - @giaSp*@sl_SP_TrongGH
			WHERE IDHD = @idhd
	UPDATE dbo.HOADON SET TONGTIEN = TONGTIEN - @giaSp*@sl_SP_TrongGH
		WHERE IDHD = @idhd
	DELETE dbo.CHITIETSPTRONGHOADON WHERE IDSPCTTHD = @@idsptgh
END

GO 

EXEC dbo.pro_DeleteSpTrongGioHang @idhd = 1,    -- int
                                  @idhdct = 1,  -- int
                                  @idsp = 5,    -- int
                                  @@idsptgh = 7 -- int










