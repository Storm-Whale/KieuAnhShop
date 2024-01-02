
package whale.test.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.Date;


@Entity
@Table
public class SinhVien {
    @Id
    private long id;
    
    @Column
    private String hoTen;
    
    @Column
    private String email;
    
    @Column
    private Date namSinh;
    
    @Column
    private TrangThai trangthai;

    public TrangThai getTrangthai() {
        return trangthai;
    }

    public void setTrangthai(TrangThai trangthai) {
        this.trangthai = trangthai;
    }

    public SinhVien() {
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getHoTen() {
        return hoTen;
    }

    public void setHoTen(String hoTen) {
        this.hoTen = hoTen;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Date getNamSinh() {
        return namSinh;
    }

    public void setNamSinh(Date namSinh) {
        this.namSinh = namSinh;
    }
    
}
