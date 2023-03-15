--cau1
CREATE PROCEDURE spTangLuong1
AS
BEGIN
    UPDATE NHANVIEN
    SET LUONG = LUONG * 1.1
END;
EXEC spTangLuong1;

--Cau2
ALTER TABLE NHANVIEN
ADD NgayNghiHuu DATE;
CREATE PROCEDURE spNgayNghiHuu
AS
BEGIN
    UPDATE NHANVIEN
    SET NgayNghiHuu = DATEADD(day, 100, GETDATE())
    WHERE (PHAI = 'Nam' AND DATEDIFF(year, NGSINH, GETDATE()) >= 60)
    OR (PHAI = 'Nu' AND DATEDIFF(year, NGSINH, GETDATE()) >= 55)
END;
EXEC spNgayNghiHuu;

--cau3
CREATE PROCEDURE spXemDEAN @DDiemDA NVARCHAR(255)
AS
BEGIN
    SELECT * FROM DEAN
    WHERE DDIEM_DA = @DDiemDA
END;
EXEC spXemDEAN @DDiemDA = N'<địa điểm>';

--cau4
CREATE PROCEDURE spCapNhatDeAn @diadiem_cu NVARCHAR(255), @diadiem_moi NVARCHAR(255)
AS
BEGIN
    UPDATE DEAN
    SET DDIEM_DA = @diadiem_moi
    WHERE DDIEM_DA = @diadiem_cu
END;
EXEC spCapNhatDeAn @diadiem_cu = N'<địa điểm cũ>', @diadiem_moi = N'<địa điểm mới>';

--cau5
CREATE PROCEDURE spThemDA
   @TENDAN NVARCHAR(15),
   @MADA int,
   @DDIEM_DA NVARCHAR(50),
   @MaPhongBan INT
 
AS
BEGIN
   SET NOCOUNT ON;
   INSERT INTO DEAN (TENDEAN, MADA,DDIEM_DA)
   VALUES (@TENDAN,@MADA,@DDIEM_DA);
END;


--cau6
CREATE PROCEDURE spThemDeAn
    @MADA INT,
    @TENDEAN NVARCHAR(50),
    @MAPHG INT
AS
BEGIN
    IF EXISTS (SELECT * FROM DEAN WHERE MADA = @MADA)
    BEGIN
        RAISERROR ('Mã đề án đã tồn tại, đề nghị chọn mã đề án khác', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM PHONGBAN WHERE MAPHG = @MAPHG)
    BEGIN
        RAISERROR ('Mã phòng không tồn tại', 16, 1);
        RETURN;
    END

    INSERT INTO DEAN (MADA, TENDEAN)
    VALUES (@MADA, @TENDEAN)
END
-- Trường hợp hợp lệ:
EXEC spThemDeAn 1, 'Đề án A', 'Mô tả cho Đề án A';

-- Trường hợp không hợp lệ: Mã đề án đã tồн tại
EXEC spThemDeAn 1, 'Đề án B', 'Mô tả cho Đề án B';

-- Trường hợp không hợp lệ: Mã phòng ban không tồн tại
EXEC spThemDeAn 2

--cau8
CREATE PROCEDURE spXoaDeAn
    @MADA INT
AS
BEGIN
    IF EXISTS (SELECT * FROM PHANCONG WHERE MADA = @MADA)
    BEGIN
        DELETE FROM PHANCONG WHERE MADA = @MADA;
    END

    DELETE FROM DEAN WHERE MADA = @MADA;
END

--cau9
CREATE PROCEDURE spTongGioLamViec
    @MaNV INT,
    @TongGioLamViec INT OUTPUT
AS
BEGIN
    SELECT @TongGioLamViec = SUM(SoGio) FROM PHANCONG WHERE MaNV = @MaNV;
END
DECLARE @KetQua INT;
EXEC spTongGioLamViec 1, @KetQua OUTPUT;
SELECT @KetQua AS TongGioLamViec;

--cau10
CREATE PROCEDURE spTongTien
    @MaNV INT
AS
BEGIN
    DECLARE @Luong INT;
    DECLARE @LuongDeAn INT;
    DECLARE @TongTien INT;

    SELECT @Luong = Luong FROM NHANVIEN WHERE MaNV = @MaNV;
    SELECT @LuongDeAn = SUM(ThoiGian) * 100000 FROM PHANCONG WHERE MaNV = @MaNV;
    SET @TongTien = @Luong + ISNULL(@LuongDeAn, 0);

    PRINT 'Tổng tiền phải trả cho nhân viên ' + CAST(@MaNV AS NVARCHAR(10)) + ' là ' + CAST(@TongTien AS NVARCHAR(20)) + ' đồng';
END
EXEC spTongTien 333;