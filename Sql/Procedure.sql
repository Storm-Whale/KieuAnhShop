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

CREATE PROC pro_NewHoaDon
	@ngayTao DATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @id_HD INT;
    INSERT INTO dbo.HOADON (IDKHACHHANG, NGAYTAO, TONGTIEN, TRANGTHAI) VALUES
		(0, @ngayTao, 0, 1);
	SET @id_HD = SCOPE_IDENTITY();

	DECLARE @id_HDCT INT;
	INSERT INTO dbo.CHITIETHOADON (IDHD, SLSP, TONGTIENSP) VALUES
		(@id_HD, 0, 0)
END

GO

EXEC dbo.pro_NewHoaDon @ngayTao = '2024-01-17' -- date

GO 

CREATE PROC pro_XoaHoaDon 
	@id_HoaDon INT,
	@id_HoaDonChiTiet INT
AS
BEGIN
    DELETE dbo.CHITIETSPTRONGHOADON WHERE IDHDCT = @id_HoaDonChiTiet
	DELETE dbo.CHITIETHOADON WHERE IDCTHD = @id_HoaDonChiTiet
	DELETE dbo.HOADON WHERE IDHD = @id_HoaDon
END

GO
EXEC dbo.pro_XoaHoaDon @id_HoaDon = 5,       -- int
                       @id_HoaDonChiTiet = 5 -- int










