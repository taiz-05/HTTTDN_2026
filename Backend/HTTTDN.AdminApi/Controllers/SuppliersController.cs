using HTTTDN.AdminApi.Data;
using HTTTDN.AdminApi.DTOs;
using HTTTDN.AdminApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HTTTDN.AdminApi.Controllers
{
    [Route("api/admin/suppliers")]
    [ApiController]
    public class SuppliersController : ControllerBase
    {
        private readonly AppDbContext _context;
        public SuppliersController(AppDbContext context) => _context = context;

        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] string? keyword)
        {
            var query = _context.Suppliers.AsQueryable();
            if (!string.IsNullOrWhiteSpace(keyword))
            {
                query = query.Where(s => s.SupplierName.Contains(keyword) || s.SupplierCode.Contains(keyword));
            }
            return Ok(await query.OrderByDescending(s => s.SupplierId).ToListAsync());
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] SupplierSaveDto dto)
        {
            if (await _context.Suppliers.AnyAsync(s => s.SupplierCode == dto.SupplierCode.Trim()))
                return BadRequest(new { message = "Mã nhà cung cấp đã tồn tại!" });

            var sup = new Supplier
            {
                SupplierCode = dto.SupplierCode.Trim(),
                SupplierName = dto.SupplierName.Trim(),
                ContactName = dto.ContactName,
                Phone = dto.Phone,
                Email = dto.Email,
                Address = dto.Address
            };
            _context.Suppliers.Add(sup);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Thêm nhà cung cấp mới thành công!", supplier = sup });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] SupplierSaveDto dto)
        {
            var sup = await _context.Suppliers.FindAsync(id);
            if (sup == null) return NotFound(new { message = "Không tìm thấy nhà cung cấp!" });

            if (await _context.Suppliers.AnyAsync(s => s.SupplierCode == dto.SupplierCode.Trim() && s.SupplierId != id))
                return BadRequest(new { message = "Mã nhà cung cấp đã trùng với đối tác khác!" });

            sup.SupplierCode = dto.SupplierCode.Trim();
            sup.SupplierName = dto.SupplierName.Trim();
            sup.ContactName = dto.ContactName;
            sup.Phone = dto.Phone;
            sup.Email = dto.Email;
            sup.Address = dto.Address;

            await _context.SaveChangesAsync();
            return Ok(new { message = "Cập nhật thông tin nhà cung cấp thành công!", supplier = sup });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var sup = await _context.Suppliers.FindAsync(id);
            if (sup == null) return NotFound(new { message = "Không tìm thấy nhà cung cấp!" });

            bool hasProducts = await _context.Products.AnyAsync(p => p.SupplierId == id);
            if (hasProducts)
            {
                return BadRequest(new { message = "Không thể xóa nhà cung cấp đang có sản phẩm liên kết trong kho. Vui lòng chuyển hoặc xóa sản phẩm trước!" });
            }

            _context.Suppliers.Remove(sup);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã xóa nhà cung cấp thành công." });
        }
    }
}